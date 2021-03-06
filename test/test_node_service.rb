require 'p2prb'

class TestNodeService < Test::Unit::TestCase

  class SimpleService
    include NodeService
    def check(b,bService)
      passert {bService==service(b)}
    end
  end
  
  def setup
    @a=Basic::Node.new
    @b=Basic::Node.new
    @a.add_new_node(@b)
    
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
  
  def test_node_nodes
    assert @aService.nodes.member?(@a)
    assert @aService.nodes.member?(@b)
    assert @bService.nodes.member?(@a)
    assert @bService.nodes.member?(@b)
    
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
