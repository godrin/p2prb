module Testing

  NodeInfo=Struct.new(:id,:last_modified)
  MyService=Struct.new(:testfunction)
  
  class MyComplexService
    def somepostfunc!
      :ok
    end
    def a=(xyz)
      @a=xyz
      "ok"
    end
    
    def a
      @a
    end
  end

  class Node
    attr_accessor :nodes,:peers,:me,:services,:host,:port
    
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
    
    def url
      pp self
      "http://#{self.host}:#{self.port}"
    end
  end

end