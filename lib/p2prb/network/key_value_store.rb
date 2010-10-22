require File.expand_path('../node_service.rb',__FILE__)


class KeyValueStore
  include NodeService
  attr_reader :store
  
  def initialize
    @store={}
  end
  
  def get(key)
    m=get_node(key)
    if m==my_node
      @store[key]
    else
      service(m).get(key)
    end
  end
  
  def put(key,value)
    m=get_node(key)
    if m==my_node
      @store[key]=value
    else
      service(m).put(key,value)
    end
  end
  
  def get_node(key)
    hash=NodeId.from_string(key)
    m=known_nodes.map{|a|[a,a.node_hash.diff(hash)]}.min{|a,b | a[1]<=>b[1]}[0]
  end
end

class RedundantKeyValueStore
  include NodeService
  attr_reader :store, :redundancy
  
  def initialize
    @store={}
    @redundancy=3
  end
  
  def get(key)
    ms=get_node(key)
    if ms.member?(my_node)
      @store[key]
    else
      ms.each{|m|
        begin
          return service(m).get(key)
        rescue NodeError
        end
      }
      raise "Value Not Found"
    end
  end
  
  def put_internal(key,value)
    ms=get_node(key)
    if ms.member?(my_node)
      @store[key]=value
    else
      put(key,value)
    end
  end
  
  def put(key,value)
    ms=get_node(key)
    ms.each{|m|
      service(m).put_internal(key,value)
    }
  end
  
  def get_node(key)
    hash=NodeId.from_string(key)
    m=known_nodes.map{|a|[a,a.node_hash.diff(hash)]}.sort{|a,b | a[1]<=>b[1]}[0...@redundancy].map{|a|a[0]}
  end
end
