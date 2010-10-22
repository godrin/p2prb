

class NodeProxy
  attr_reader :node

  def initialize(node)
    @node=node
  end
  def gotNewPeer(other)
    @node.gotNewPeer(_(other))
  end
  
  def known_nodes
    @node.known_nodes.each{|n|passert{n.is_a?(NodeProxy)}}
    @node.known_nodes
  end
  
  def _(node)
    n=case node
      when NodeProxy
        node
      else
        node.proxy
    end
    passert {n.is_a?(NodeProxy)}
    n
  end
  
  def <=>(x)
    @node<=>x.node
  end
end


class MasterProxy
  def initialize(master)
    @master=master
  end
  
  def register(node)
    n=case node
      when NodeProxy
        node
      else
        node.proxy
    end
    passert {node.is_a?(NodeProxy)}
    @master.register(n)
  end
  
  def known_nodes
    @master.known_nodes.each{|n|passert{n.is_a?(NodeProxy)}; passert{n}}
    puts @master.known_nodes
    @master.known_nodes
  end
end

