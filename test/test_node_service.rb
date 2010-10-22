require "test/unit"

require File.expand_path('../test_helper.rb',__FILE__)

require 'p2prb/network/basic_node.rb'
require 'p2prb/network/node_service.rb'

require 'pp'

class TestNodeService < Test::Unit::TestCase

  class SimpleService
    include NodeService
    def check(b,bService)
      passert {bService==service(b)}
    end
  end
  
  def setup
    @a=BasicNode.new
    @b=BasicNode.new
    @a.addNewNode(@b)
    
    1.upto(5){||@a.step ; @b.step }
    
    assert @a.peers.member?(@b)
    assert @b.peers.member?(@a)
    
    @a.add_service(SimpleService)
    @b.add_service(SimpleService)
    
    @aService=@a.service(SimpleService)
    @bService=@b.service(SimpleService)
  end

  def test_node_service_communication
    @aService.check(@b,@bService)
    @bService.check(@a,@aService)
  end
  
  def test_node_known_nodes
    assert @aService.known_nodes.member?(@a)
    assert @aService.known_nodes.member?(@b)
    assert @bService.known_nodes.member?(@a)
    assert @bService.known_nodes.member?(@b)
    
    assert_equal @a,@aService.my_node
    assert_equal @b,@bService.my_node
  end
  
  def test_node_can_be_set_only_once
    begin
      @aService.node=@a
      assert_fail
    rescue RuntimeError=>e
      assert_equal "Node was already set !",e.message
    end
    
    begin
      x=SimpleService.new
      x.node=123
      assert_fail
    rescue RuntimeError=>e
      assert_equal "given *node* does not implement needed functions",e.message
    end
  end
end
