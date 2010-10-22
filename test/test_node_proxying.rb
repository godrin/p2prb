require "test/unit"

require File.expand_path('../test_helper.rb',__FILE__)

require 'p2prb/network/basic_node.rb'
require 'p2prb/communication/basic_proxy.rb'

require 'pp'

class TestNodeProxying < Test::Unit::TestCase
  class TestNode
    attr_accessor :proxy
    attr_accessor :known_nodes
    attr_accessor :service
    attr_reader :peers
    
    def initialize
      @proxy=self
      @peers=[]
    end
    def got_new_peer(p)
      @peers<<p
    end
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
  
  def test_node_proxy_new_peer
    a=TestNode.new
    b=TestNode.new
    p=BasicProxy::Node.new(a)
    a.proxy=p
    p.got_new_peer(b)
    assert_equal [b],a.peers
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
