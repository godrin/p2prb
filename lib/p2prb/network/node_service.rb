
module NodeService
  def node=(pnode)
    if @node.nil?
      @node=pnode
      unless @node.respond_to?(:known_nodes) && @node.respond_to?(:service)
        raise "given *node* does not implement needed functions"
      end
    else
      raise "Node was already set !"
    end
  end
  def my_node
    @node
  end
  def known_nodes
    @node.known_nodes
  end
  def service(node_id)
    @node.known_nodes.select{|node|
      node==node_id ||
      (node.respond_to?(:node_hash) && node.node_hash==node_id)
      
    }[0].service(self.class)
  end
end
