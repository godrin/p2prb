require File.expand_path('../../base/basics.rb',__FILE__)
require File.expand_path('../../base/stepping_job_queue.rb',__FILE__)
require File.expand_path('../../base/event_queue.rb',__FILE__)

require File.expand_path('../node_id.rb',__FILE__)

#
# Handles a single networking node.
# does:
#  * register at master
#  * retrieve start nodes from master
#  * select peers
#  * notify peer
#  * retrieves new nodes from peers
#  * handles services
#
#
class BasicNode
  include SteppingJobQueue
  include EventQueue
  
  STANDARD_PEER_COUNT=4
  
  attr_accessor :peers
  attr_accessor :known_nodes
  attr_accessor :masters
  attr_reader :proxy
  
  rule(:created) { enqueue{register_at_master} }
  rule(:new_nodes) { checkForEnoughPeers }
  rule(:new_peer) {|peer| checkForNodesFromPeer(peer) }
  
  def initialize
    @proxy=self
    @peers=[]
    @known_nodes=[]
    @masters=[]
    @services={}
    event(:created)
  end
  
  def proxy=(pProxy)
    if @proxy==self
      passert{pProxy.respond_to?(:known_nodes) and pProxy.respond_to?(:service)}
      @proxy=pProxy
    else
      raise "proxy already set!"
    end
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
    #passert { @known_nodes.empty? }
    #passert { @peers.empty? }
    
    if @masters.empty?
      enqueue { register_at_master }
    else
      @masters.each{|master|
        master.register(proxy)
        nuNodes=master.known_nodes
        nuNodes.each{|n|passert{n}}
        @known_nodes+=nuNodes
        @known_nodes.uniq!
        @known_nodes.each{|n|passert{n}}
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
    passert{node}
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
    passert {other}
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
