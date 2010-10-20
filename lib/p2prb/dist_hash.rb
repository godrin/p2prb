module P2P
  class DistHash
    MAX_LENGTH=1024
    REDUNDANCY=2
  
    def initialize
      @hash={}
    end
    
    def entries
      @hash.dup
    end
    
    def put(writer,name,value)
      if validate_write(writer,name,value)
        remotes(name)
        true
      else
        false
      end
    end
    
    def local_put(writer,name,value)
      if validate_write(writer,name,value)
        @hash[name]=value
        true
      else
        false
      end
    end
    
    def local_get(name)
      @hash[name]
    end
    
    def self.method_missing(*args)
      @@distHash.send(*args)
    end
    
    def validate_write(writer,name,value)
      writer.is_a?(P2P::Node) and name.is_a?(String) and value.is_a?(String) and value.length<MAX_LENGTH
    end
    
    def remotes(name)
      NodeManager.known_nodes.map{|node|[node,evaluate(name,node)]}.sort{|a,b|a[1]<=>b[1]}[0...REDUNDANCY]
    end
    
    def evaluate(name,node)
      nameHash=Digest::SHA2.new << (name.to_s)
      dist=P2P::hexDist(node.nodeid,nameHash)
      pp "DIST:",dist
      dist
    end

    @@distHash=DistHash.new
  end
end