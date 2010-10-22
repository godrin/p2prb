require 'rubygems'
require 'sinatra/base.rb'
require 'yaml'
require 'pp'
require File.expand_path('../common.rb',__FILE__)
require File.expand_path('../events.rb',__FILE__)
require File.expand_path('../nodes.rb',__FILE__)
require File.expand_path('../dist_hash.rb',__FILE__)

module P2P

  def self.localhost
    "0.0.0.0"
  end
  
  def self.standardPort
    5259
  end

  class NodeApp < Sinatra::Base
 
    def self.go!(hash)
      NodeManager.nodeid=hash[:nodeid]
      NodeManager.ip=hash[:host]
      NodeManager.port=hash[:port]
      NodeManager.masters=hash[:masters]||[hash[:master]]
      hash[:views]=File.expand_path('../views',__FILE__)
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
      @blabla="kjshdf"
      erb :index
    end
    
    get '/get_id' do
      dynamic_header
      YAML.dump(NodeManager.me)
    end
    
    get '/masters' do
      dynamic_header
      YAML.dump(NodeManager.masters)
    end

    get '/peers' do
      dynamic_header
      YAML.dump(NodeManager.peers)
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
      node.ip=env["REMOTE_HOST"]

      MEM.enqueue{
        puts "new node #{node}"
        NodeManager.add_node(node)
      }
      "ok"
    end
    
    post '/hash' do
    pp env
      writer=if params[:node].nil? and env["REMOTE_ADDR"]=="127.0.0.1"
        NodeManager.me
      else
        YAML.load(params[:node])
      end
      writer.ip=env["REMOTE_HOST"]
      if NodeManager.valid?(writer)
        name=params[:name]
        value=params[:value]
        if DistHash.put(writer,name,value)
          "ok"
        else
          "error"
        end
      else
        "not allowed"
      end
    end
    get '/hash' do
      name=params["name"]
      DistHash.get(name)
    end
  end
end
