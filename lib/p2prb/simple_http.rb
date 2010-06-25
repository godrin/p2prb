require 'net/http'
require 'uri'
require 'yaml'
require 'pp'
    

require 'common.rb'

class NodeHttp
  def initialize(url,node)
    @url=url
    @node=node
  end
  
  def register_node(node)
    post("/register_node",{'node'=>YAML.dump(node)})
  end
  
  def get_new_nodes
    get("/get_new_nodes")
  end

  def get_nodes
    get("/get_nodes")
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

def http(node)
  url = URI.parse("http://#{node.ip}:#{node.port}")
  begin
    result=yield NodeHttp.new(url,node) #.instance_eval(&block)
  rescue
    nil
  end
  result
end