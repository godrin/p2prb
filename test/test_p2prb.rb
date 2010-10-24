require "test/unit"
require "p2prb"
require File.expand_path('../test_helper.rb',__FILE__)
require 'p2prb/base/node_process.rb'

class TestP2prb < Test::Unit::TestCase
  def test_sanity
    master=P2P::NodeProcess.new(66)
    nodes=[0,2,3].map{|i|P2P::NodeProcess.new(i,master.me)}
    sleep 0.5    
    
    nodes[0].hash!(nodes[0],"12345","muuuh")
    nodes.each{|node|
      node.kill!
    }
    master.kill!
  end
end
