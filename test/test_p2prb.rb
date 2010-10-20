require "test/unit"
require "p2prb"
require File.expand_path('../../lib/p2prb/node_process.rb',__FILE__)

class TestP2prb < Test::Unit::TestCase
  def test_sanity
    master=P2P::NodeProcess.new(66)
    pp "MEEE: #{master.me}"
    nodes=[0,2,3].map{|i|P2P::NodeProcess.new(i,master.me)}
    sleep 5
    

    pp nodes[0].get_nodes
    pp nodes[0].get_new_nodes
    pp nodes[0].masters
    
    nodes[0].hash!(nodes[0],"12345","muuuh")
    pp nodes
    nodes.each{|node|
    pp node.me
    node.kill!}
    master.kill!
    flunk "write tests or I will kneecap you"
    
  end
end
