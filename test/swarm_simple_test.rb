require "test/unit"
require 'digest/sha1'
require File.expand_path('../stepping_job_queue.rb',__FILE__)
require File.expand_path('../event_queue.rb',__FILE__)

require 'pp'

def passert(&proc)
  raise "Assertion failed: val is not true!" unless proc.call
end

class Numeric
  def count_set_bits
    x=self
    count = 0
    count += x & 1 and x >>= 1 until x == 0
    count
  end
end

class NodeId
  def initialize(i)
    if i.is_a?(String)
      @id=i
    else
      @id="%X" % i
    end
  end
  
  def ==(other)
    value==other.value
  end
  
  def self.from_string(str)
    NodeId.new(Digest::SHA1.hexdigest(str))
  end
  
  def to_s
    "#<NodeId id:#{@id}>"
  end
  
  def <=>(other)
    value<=>other.value
  end
  
  def value
    @id.hex
  end
  def diff(x)
    raise "Not a NodeId" unless x.is_a?(NodeId)
    v=(value ^ x.value)
    v.count_set_bits
  end
end

class BasicNode
  include SteppingJobQueue
  include EventQueue
  
  STANDARD_PEER_COUNT=4
  
  attr_accessor :peers
  attr_accessor :known_nodes
  attr_accessor :masters
  
  rule(:created) { enqueue{register_at_master} }
  rule(:new_nodes) { checkForEnoughPeers }
  rule(:new_peer) {|peer| checkForNodesFromPeer(peer) }
  
  def initialize
    @peers=[]
    @known_nodes=[]
    @masters=[]
    @services={}
    event(:created)
    
  end
  
  def add_service(klass)
    s=@services[klass.to_s]=klass.new
    s.node=self
    s
  end
  
  def service(klass)
    @services[klass.to_s] 
  end
  
  def rm_service(klass)
    @services.delete(klass.to_s)
  end
  def remote_service(nodeId,klass)
    passert { nodeId.is_a?(NodeId) }
    @known_nodes.select{|node|node.node_hash==nodeId}[0].service(klass)
  end
  
  def step
    eventStep
    jobStep
#    checkForEnoughPeers
  end
  
  def node_hash
    NodeId.from_string(self.object_id.to_s)
  end
  
  def known_node_ids
    @known_nodes.map{|node|node.node_hash}
  end
  
  def register_at_master
    passert { @known_nodes.empty? }
    passert { @peers.empty? }
    
    if @masters.empty?
      enqueue { register_at_master }
    else
      @masters.each{|master|
        master.register(self)
        @known_nodes+=master.known_nodes
        @known_nodes.uniq!
        event(:new_nodes)
      }
      enqueue
    end
  end
  
  def checkForEnoughPeers
    if @peers.length<STANDARD_PEER_COUNT
      (@known_nodes-@peers-[self]).each {| node |
        addAsPeer(node)
        break if @peers.length>=STANDARD_PEER_COUNT
      }
    end
  end
  
  def checkForNodesFromPeer(peer)
    addNewNodes(peer.known_nodes)
  end
  
  def addAsPeer(node)
    @peers<<node
    node.gotNewPeer(self)
    event(:new_peer,node)
  end
  
  def gotNewPeer(other)
    @peers<<other
    addNewNode(other)
    event(:new_peer,other)
  end
  
  def addNewNodes(others)
    others.each{|other|addNewNode(other)}
  end
  
  def addNewNode(other)
    unless @known_nodes.member?(other)
      @known_nodes<<other
      event(:new_nodes,[other])
    end
  end
  
  def add_master(master)
    @masters=(@masters+[master]).uniq
  end
  
  def <=>(other)
    node_hash<=>other.node_hash
  end
end

module NodeService
  def node=(pnode)
    @node=pnode
  end
  def my_node_id
    @node.node_hash
  end
  def known_node_ids
    @node.known_node_ids
  end
  def service(node_id)
    @node.known_nodes.select{|node|node.node_hash==node_id}.service(self.klass)
  end
end

class KeyValueStore
  include NodeService
  attr_reader :store
  
  def initialize
    @store={}
  end
  
  def get(key)
    m=get_node_id(key)
    if m==my_node_id
      @store[key]
    else
      @node.remote_service(m,self.class).get(key)
    end
  end
  
  def put(key,value)
    m=get_node_id(key)
    if m==my_node_id
      @store[key]=value
    else
      @node.remote_service(m,self.class).put(key,value)
    end
  end
  
  def get_node_id(key)
    hash=NodeId.from_string(key)
    m=known_node_ids.map{|a|[a,a.diff(hash)]}.min{|a,b | a[1]<=>b[1]}[0]
  end
end

class RedundantKeyValueStore
  include NodeService
  attr_reader :store, :redundancy
  
  def initialize
    @store={}
    @redundancy=3
  end
  
  def get(key)
    ms=get_node_id(key)
    if ms.member?(my_node_id)
      @store[key]
    else
      ms.each{|m|
        begin
          return @node.remote_service(m,self.class).get(key)
        rescue NodeError
        end
      }
      raise "Value Not Found"
    end
  end
  
  def put_internal(key,value)
    ms=get_node_id(key)
    if ms.member?(my_node_id)
      @store[key]=value
    else
      put(key,value)
    end
  end
  
  def put(key,value)
    ms=get_node_id(key)
    ms.each{|m|
      @node.remote_service(m,self.class).put_internal(key,value)
    }
  end
  
  def get_node_id(key)
    hash=NodeId.from_string(key)
    m=known_node_ids.map{|a|[a,a.diff(hash)]}.sort{|a,b | a[1]<=>b[1]}[0...@redundancy].map{|a|a[0]}
  end
end

class MasterNode
  attr_reader :known_nodes
  
  def initialize
    @known_nodes=[]
  end
  
  def register(me)
    @known_nodes=(@known_nodes+[me]).uniq
  end
  def unregister(me)
    @known_nodes.delete(me)
  end
end

class TestP2prb < Test::Unit::TestCase
  def test_distance_of_node_ids
    a=NodeId.new(64+32)
    b=NodeId.new(32)
    c=NodeId.new(64)
    assert_equal 1,a.diff(b)
    assert_equal 1,a.diff(c)
    assert_equal 2,b.diff(c)

  end
  def test_simple_network
  
    nodeCount=20
    steps=3
    master=MasterNode.new

    nodes=(0...nodeCount).to_a.map{|i|BasicNode.new}
    assert_equal nodeCount,nodes.length
    nodes.each{|node|node.add_master(master)}

    # one step for each node
    nodes.each{|node|node.step}

    # every node is registered
    nodes.each{|node|
      assert master.known_nodes.member?(node)
    }
    # let them talk
    1.upto(steps) {
      nodes.each{|node|node.step}
    }

    nodes.each{|node|
      assert_equal node.known_nodes.length,nodes.length
      assert_equal node.known_nodes.sort,nodes.sort
    }
  end
  
  def test_simple_service
    check_key_value_store(KeyValueStore)
  end
  
  def test_redundant_key_value_store
    klass=RedundantKeyValueStore
    data,nodes=check_key_value_store(klass)
    # check if redundancy is correct
    firstNode=nodes[0].service(klass)
    data.each{|k,v|
      assert_equal firstNode.redundancy, 
        nodes.select{|node|node.service(klass).store[k]}.length
    }
  end
  def check_key_value_store(klass)
    nodes=setupNetwork(10)
    nodes.each{|node|node.add_service(klass)}
    
    data={"a"=>"b", 
      "key" => "someValue", 
      "someOtherKey"=>"yetAnotgherValue",
      "3"=>"10"}
    
    writerNode=nodes[0].service(klass)
    readerNode=nodes[5].service(klass)
    
    data.each{|k,v|writerNode.put(k,v)}

    # output data    
        nodes.each{|node|pp node.service(klass).store }
    
    data.each{|k,v|assert_equal v,readerNode.get(k)}
    
    [data,nodes]
  end

  def setupNetwork(nodeCount,steps=4)
    master=MasterNode.new
    nodes=(0...nodeCount).to_a.map{|i|BasicNode.new}
    nodes.each{|node|node.add_master(master)}
    1.upto(steps) {
      nodes.each{|node|node.step}
    }
    nodes
  end
end
