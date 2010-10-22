require "test/unit"

require File.expand_path('../test_helper.rb',__FILE__)

require 'p2prb/network/basic_node.rb'
require 'p2prb/communication/basic_proxy.rb'

require 'pp'

class TestNodeProxying < Test::Unit::TestCase
  class TestNode
    attr_accessor :known_nodes
    attr_accessor :service
    attr_accessor :got_new_peer
  end

  def test_node_proxy_known_nodes
    a=TestNode.new
    b=TestNode.new
    c=TestNode.new
    d=TestNode.new
    p=BasicProxy::Node.new(a)
    l=[b,c,d]
    a.known_nodes=l
    assert_equal l,p.known_nodes
    
  end

  def test_peering_with_proxy
    a=BasicNode.new
    b=BasicNode.new
    aProxy=BasicProxy::Node.new(a)
    bProxy=BasicProxy::Node.new(b)
    a.proxy=aProxy
    b.proxy=bProxy
    
    b.add_new_node(aProxy)
    1.upto(5) { a.step ; b.step }
    
  end
end
