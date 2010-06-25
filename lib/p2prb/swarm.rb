require 'rubygems'
require 'sinatra/base.rb'
require 'yaml'
require 'common.rb'
require 'events.rb'
require 'nodes.rb'

def localhost
  "0.0.0.0"
end

class NodeApp < Sinatra::Base

  def self.go!(hash)
    NodeManager.id=hash[:id]
    NodeManager.ip=hash[:host]
    NodeManager.port=hash[:port]
    NodeManager.master=hash[:master]
    run! hash
  end

  def html?
    env["HTTP_ACCEPT"]=~/text\/html/
  end
  def json?
    env["HTTP_ACCEPT"]=~/text\/json/
  end
  
  def dynamic_header
    if html?
#      content_type 'text/html', :charset => 'utf-8'
      content_type 'text/plain', :charset => 'utf-8'
    elsif json?
      raise "JSON FIXME"
    else
      content_type 'application/x-yaml', :charset => 'utf-8'
    end
  end
  
  get '/' do
    erb :index
  end

  get '/get_nodes' do
    dynamic_header
    YAML.dump(NodeManager.nodes)
  end

  get '/get_new_nodes' do
    dynamic_header
    YAML.dump(NodeManager.new_nodes)
  end

  post '/register_node' do
    node=YAML.load(params[:node])

    MEM.enqueue{
      puts "new node #{node}"
      NodeManager.add_node(node)
    }
    "ok"
  end
end

if $0=='swarm.rb'
   NodeApp.run! :host => localhost, :port => 4597, :id=>"lksjdf"
end
