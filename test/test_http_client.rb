require 'test/unit'

require 'rack/test'
require 'p2prb'

require 'testing_node.rb'

class TestHttpClient < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    P2P::HttpServer.new({:node=>@node})
  end
  
  def setup
    @node=Testing::Node.new
    @node.nodes=[1,2,3]
    @nodeB=Testing::Node.new
    @client=P2P::HttpClient.new(self)
  end
  
  def test_get_nodes
    assert_equal [1,2,3],@client.nodes    
  end
  
  def test_post_node
    assert_equal true, (@client.nodes=(@nodeB))
    assert_equal [567],@node.nodes
  end
  
  
end