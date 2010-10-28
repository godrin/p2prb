require 'net/http'
require 'uri'
require 'yaml'
require File.expand_path('../../network/common.rb',__FILE__)
require File.expand_path('../../base/logger.rb',__FILE__)

module P2P
  class HttpClient
    def initialize(url) #,node)
      @url=url
#      @node=node
    end
  
    def register_node(node)
      post("/register_node",{'node'=>YAML.dump(node)})
    end
  
    def get_id
      get("/get_id")
    end
    
    def me
      get_id
    end
  
    def get_new_nodes
      get("/get_new_nodes")
    end

    def nodes
      get("/nodes")
    end
    
    def masters
      get("/masters")
    end
    
    def hash!(writer,name,value)
      post("/hash",{:name=>name,:value=>value,:writer=>YAML.dump(writer)})
    end
  
    private
    def post(path,args)
      req = Net::HTTP::Post.new(path)
      req.set_form_data(args, ';')
      res = Net::HTTP.new(@url.host, @url.port).start {|http| http.request(req) }
      YAML.load(res.body)
    end
    def get(path,args={})
      req = Net::HTTP::Get.new(path)
      req.set_form_data(args, ';')
      res = Net::HTTP.new(@url.host, @url.port).start {|http| http.request(req) }
      YAML.load(res.body)
    end
  end

  def self.http(node)
    uri="http://#{node.ip}:#{node.port}"
    url = URI.parse(uri)
    begin
      result=yield HttpClient.new(url) #,node) #.instance_eval(&block)
    rescue SocketError => e
      log "HTTP Call failed to #{uri} - Could not connect"
      nil
    rescue Object=>e
      P2P::Logging.log e
      P2P::Logging.log "HTTP Call failed to #{uri}"
      nil
    end
    result
  end
end