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
  end
  
  def test_get_nodes
    @client=P2P::HttpClient.new(self)
    assert_equal [1,2,3],@client.nodes    
  end
  
  
end