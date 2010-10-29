
module NodeService
  def node=(pnode)
    @node||=nil
    if @node.nil?
      @node=pnode
      unless @node.respond_to?(:nodes) && @node.respond_to?(:service)
        raise "given *node* does not implement needed functions"
      end
    else
      raise "Node was already set !"
    end
  end
  def my_node
    @node
  end
  def node_hash
    @node.node_hash
  end
  
  def nodes
    @node.nodes
  end
  def service(node_id)
    @node.nodes.select{|node|
      node==node_id ||
      (node.respond_to?(:node_hash) && node.node_hash==node_id)
      
    }[0].service(self.class)
  end
end
