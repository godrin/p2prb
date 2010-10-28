require 'rubygems'
require "test/unit"
require 'rack/test'

require File.expand_path('../test_helper.rb',__FILE__)

require 'p2prb/communication/http_server.rb'
require 'p2prb/communication/http_client.rb'

class TestRestInterface < Test::Unit::TestCase
  include Rack::Test::Methods
  
  NodeInfo=Struct.new(:id,:last_modified)
  MyService=Struct.new(:testfunction)
  
  class MyComplexService
    def somepostfunc!
      :ok
    end
  end

  class Node
    attr_accessor :nodes,:peers,:me,:services
    
    def nodes_younger_than(time)
      if time.is_a?(Time)
        @nodes.select{|node|node.last_modified>time}
      else
        nil
      end
    end
    def service(name)
      @services[name]
    end
  end
  
  def setup
    @node=Node.new
  end
  
  def app
    P2P::HttpServer.new({:node=>@node})
  end
  
  def test_get_nodes
    l=[1234]
    @node.nodes=l
    get '/nodes'
    y=YAML.load(last_response.body)
    assert_equal l,y    
  end
  
  def test_get_nodes_younger_than_x
    a=NodeInfo.new(:a,Time.parse("2010/01/02 23:10:06"))
    b=NodeInfo.new(:b,Time.parse("2010/01/02 23:10:07"))
    c=NodeInfo.new(:c,Time.parse("2010/07/02 03:10:06"))
    
    @node.nodes=[a,b,c]
    get '/nodes'
    y=YAML.load(last_response.body)
    assert_equal [a,b,c],y
    get '/nodes?younger_than=2010/06/01'
    y=YAML.load(last_response.body)
    assert_equal [c],y
    get '/nodes?younger_than=2010/01/02%2023:10:06'
    y=YAML.load(last_response.body)
    assert_equal [b,c],y
  end
  
  def test_get_peers
    p=[4,5,6]
    @node.peers=p
    get '/peers'
    y=YAML.load(last_response.body)
    assert_equal p,y
  end
  
  def test_id
    @node.me=:abc
    get '/id'
    y=YAML.load(last_response.body)
    assert_equal :abc,y
  end
  
  def test_service_get_call
    s=MyService.new(:testreturn)
    assert_equal :testreturn,s.testfunction
    services={"myservice"=>s}
    @node.services=services
    get '/service/myservice/testfunction'
    y=YAML.load(last_response.body)
    assert_equal :testreturn,y
  end
  
  def test_service_post_call
    s=MyComplexService.new
    services={"myservice"=>s}
    @node.services=services
    post '/service/myservice/somepostfunc'
    y=YAML.load(last_response.body)
    assert_equal :ok,y
  end
end
