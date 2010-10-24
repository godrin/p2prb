require "test/unit"

require File.expand_path('../test_helper.rb',__FILE__)

require 'p2prb/communication/http_server.rb'
require 'p2prb/communication/http_client.rb'

class TestRestInterface < Test::Unit::TestCase

  class Node
  end

  def setup 
    @node=Node.new
#    @client=P2P::Client.new
    @server=P2P::HttpServer.go! :nodeid=>"mynodid", :node=>@node
  end
  def teardown
    @server.stop! if @server
  end
  def test_get_nodes
    
    #sleep 2
  end
end
