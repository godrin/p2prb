require "test/unit"
require File.expand_path('../test_helper.rb',__FILE__)

require 'p2prb/network/node_id.rb'
require 'p2prb/network/key_value_store.rb'
require 'p2prb/network/master_node.rb'
require 'p2prb/network/basic_node.rb'
require 'p2prb/communication/basic_proxy.rb'

require 'pp'


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
    proxyKlass=NodeProxy
    masterProxyKlass=MasterProxy
    nodeCount=20
    steps=3
    master=MasterNode.new
    proxiedMaster=masterProxyKlass.new(master)

    nodes=(0...nodeCount).to_a.map{|i|BasicNode.new}
    assert_equal nodeCount,nodes.length
    nodes.each{|node|
      node.proxy=proxyKlass.new(node)
      node.add_master(proxiedMaster)
    }

    # one step for each node
    nodes.each{|node|node.step}

    # every node is registered
    
    nodes.each{|node|
#      puts master.known_nodes,node.proxy.ref
      assert master.known_nodes.member?(node.proxy)
    }
    # let them talk
    1.upto(steps) {
      nodes.each{|node|node.step}
    }

    nodes.each{|node|
      assert_equal nodes.length,node.known_nodes.length
#      assert_equal nodes.sort,node.known_nodes.sort
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
