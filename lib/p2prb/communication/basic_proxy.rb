module BasicProxy

  class Node
    attr_reader :node

    def initialize(node)
      passert {node.has_signature?(::NodeImplementation)}
      @node=node
    end
    def got_new_peer(other)
      @node.got_new_peer(_(other))
    end
  
    def nodes
      @node.nodes.each{|n|passert{n.has_signature?(::Node)}}
      @node.nodes
    end
  
    def service(serviceKlass)
      BasicProxy::Service.new(@node.service(serviceKlass))
    end
    
    def proxy
      self
    end
  
    def _(node)
      n=node.proxy
      passert {n.has_signature?(::Node)}
      n
    end
  
    def <=>(x)
      @node<=>x.node
    end
  end
  
  class Service
    def initialize(service)
      @service=service
    end
    
    def handle(*args)
      @service.handle(*args)
    end
  end


  class Master
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
      passert {node.is_a?(BasicProxy::Node)}
      @master.register(n)
    end
  
    def known_nodes
      @master.known_nodes.each{|n|
        passert{n.is_a?(BasicProxy::Node)}
        passert{n}
      }
      puts @master.known_nodes
      @master.known_nodes
    end
  end

end