require File.expand_path('../node_service.rb',__FILE__)


class KeyValueStore
  include NodeService
  attr_reader :store
  
  def initialize
    @store={}
  end
  
  def get(key)
    m=get_node_id(key)
    if m==my_node_id
      @store[key]
    else
      @node.remote_service(m,self.class).get(key)
    end
  end
  
  def put(key,value)
    m=get_node_id(key)
    if m==my_node_id
      @store[key]=value
    else
      @node.remote_service(m,self.class).put(key,value)
    end
  end
  
  def get_node_id(key)
    hash=NodeId.from_string(key)
    m=known_node_ids.map{|a|[a,a.diff(hash)]}.min{|a,b | a[1]<=>b[1]}[0]
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
    ms=get_node_id(key)
    if ms.member?(my_node_id)
      @store[key]
    else
      ms.each{|m|
        begin
          return @node.remote_service(m,self.class).get(key)
        rescue NodeError
        end
      }
      raise "Value Not Found"
    end
  end
  
  def put_internal(key,value)
    ms=get_node_id(key)
    if ms.member?(my_node_id)
      @store[key]=value
    else
      put(key,value)
    end
  end
  
  def put(key,value)
    ms=get_node_id(key)
    ms.each{|m|
      @node.remote_service(m,self.class).put_internal(key,value)
    }
  end
  
  def get_node_id(key)
    hash=NodeId.from_string(key)
    m=known_node_ids.map{|a|[a,a.diff(hash)]}.sort{|a,b | a[1]<=>b[1]}[0...@redundancy].map{|a|a[0]}
  end
end
