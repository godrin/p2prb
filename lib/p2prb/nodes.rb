require File.expand_path('../simple_http.rb',__FILE__)
require File.expand_path('../masters.rb',__FILE__)

module P2P
  class NodeManager

    def self.method_missing(*args)
      @@nm||=NodeManager.new
      @@nm.send(*args)
    end
  
    attr_accessor :masters, :port, :ip, :nodeid
    def initialize
      @nodes=[]
      @new_nodes=[]
      @peers=[]
      @masters=nil
      @port=nil
      @ip=nil
      @nodeid=(rand*5000).to_i
    
      @nodeMutex=Mutex.new
    
      initial_register
    
      query_other_nodes_for_new_nodes
      check_new_nodes
    end
  
    def me
      Node.new(@nodeid,@ip,@port)
    end
  
    def nodes
      @nodes
    end
  
    def new_nodes
      @new_nodes
    end
  
    def add_node(node)
      @nodeMutex.synchronize {
        unless @nodes.member?(node)
          unless @new_nodes.member?(node)
            @new_nodes<<node
          end
        end
      }
    end
  
    def send_to_node(node,data)
      if @nodes.member?(node) or @new_nodes.member?(node)
      
      else
        raise "Unknown Node #{node}"
      end
    end
  
    def checked_node(node)
      @nodeMutex.synchronize {
        if @new_nodes.member?(node) and not @nodes.member?(node)
          @new_nodes.delete(node)
          @nodes<<node
        end
      }
    end
  
    private
    def initial_register(trials=0)
      MEM.enqueue(0.5){
      begin
        ok=false
        pp" initial_reg #{self.masters}"
        if self.masters
          self.masters.each{|master|
          pp master
          P2P::http(master){|h|
            pp "trying #{master}"
            pp h.register_node(NodeManager.me); ok=true; 
            pp "ok ???" 
            add_node(master)}
          }
          if not ok
            initial_register(trials+1) if trials<10
          end
        end
        rescue Object=>e
         pp e,e.backtrace
         end
      }
    end
  
    def query_other_nodes_for_new_nodes
      MEM.enqueue(5) {
        @peers+=self.masters if self.masters
        @peers.uniq!
        @peers.each{|peer|
          MEM.enqueue {
            nodes=P2P::http(peer){|h|h.get_nodes}
            nodes.each{|n|add_node(n)} if nodes
          }
        }
        query_other_nodes_for_new_nodes
      }
    end
  
    def check_new_nodes
      MEM.enqueue(5) {
        @new_nodes.each{|node|
          MEM.enqueue{
            ok=false
            othersMe=P2P::http(node){|h|oid=h.get_id ; ok=true; oid}
#            pp othersMe, node, "equal ???"
            checked_node(node) if othersMe==node.nodeid
          }
        }
        check_new_nodes
      }
    end
  end
end