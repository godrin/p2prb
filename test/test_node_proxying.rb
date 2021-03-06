require 'p2prb'

class TestNodeProxying < Test::Unit::TestCase
  class TestNode
    attr_accessor :proxy
    attr_accessor :nodes
    attr_reader :peers
    
    def initialize
      @proxy=self
      @peers=[]
      @services=[]	
    end
    def got_new_peer(p)
      @peers<<p
    end
    def add_service(s)
      @services<<s.new
    end
    def service(x)
      @services.select{|s|s.is_a?(x)}[0]
    end
  end
  
  class TestService
    include NodeService
    
    def handle(ar)
      ["ok"]+ar
    end
  end

  def test_node_proxy_known_nodes
    a=TestNode.new
    b=TestNode.new
    c=TestNode.new
    d=TestNode.new
    p=BasicProxy::Node.new(a)
    l=[b,c,d]
    a.nodes=l
    assert_equal l,p.nodes
  end
  
  def test_node_proxy_new_peer
    a=TestNode.new
    b=TestNode.new
    p=BasicProxy::Node.new(a)
    a.proxy=p
    p.got_new_peer(b)
    assert_equal [b],a.peers
  end
  
  def test_node_proxy_get_service
    serviceKlass=TestService
    a=TestNode.new
    b=TestNode.new
    a.add_service(serviceKlass)
    p=BasicProxy::Node.new(a)
    s=p.service(serviceKlass)
    l=[1,2,3]
    assert_equal((["ok"]+l),s.handle(l))
  end

  def test_peering_with_proxy
    a=Basic::Node.new
    b=Basic::Node.new
    aProxy=BasicProxy::Node.new(a)
    bProxy=BasicProxy::Node.new(b)
    a.proxy=aProxy
    b.proxy=bProxy
    
    b.add_new_node(aProxy)
    1.upto(5) { a.step ; b.step }
    
  end
end
