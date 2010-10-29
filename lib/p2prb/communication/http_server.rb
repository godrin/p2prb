require 'rubygems'
require 'yaml'

require File.expand_path('../../communication/sinatra_with_patch.rb',__FILE__)
require File.expand_path('../../network/common.rb',__FILE__)
require File.expand_path('../../base/events.rb',__FILE__)
require File.expand_path('../../network/nodes.rb',__FILE__)
require File.expand_path('../../network/dist_hash.rb',__FILE__)


module P2P

  def self.localhost
    "0.0.0.0"
  end
  
  def self.standardPort
    5259
  end

  class HttpServer < Sinatra::Base
    attr_accessor :node
    
    def initialize(hash)
      @node=hash[:node]
      super
    end
 
    def self.go!(hash)
      node=hash[:node]
      puts "NODE:",node
      node.nodeid=hash[:nodeid]
      node.ip=hash[:host]
      node.port=hash[:port]
      node.masters=hash[:masters]||[hash[:master]]
      hash[:views]=File.expand_path('../../views',__FILE__)
      hash[:environment]=:production
      hash[:raise_errors]= true
      hash[:logging]=false
      app=run! hash
      app.node=hash[:node]
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
    
    get '/id' do
      dynamic_header
      YAML.dump(@node.me)
    end
    
    get '/masters' do
      dynamic_header
      YAML.dump(@node.masters)
    end

    get '/peers' do
      dynamic_header
      YAML.dump(@node.peers)
    end

    get '/nodes' do
      dynamic_header
      if params[:younger_than]
        d=Time.parse(params[:younger_than])
        YAML.dump(@node.nodes_younger_than(d))
      else
        YAML.dump(@node.nodes)
      end
    end

    post '/node' do
      node=YAML.load(params["node"])
      pp node
      return "fail" unless node.has_signature?(NodeImplementation)
      node.ip=env["REMOTE_HOST"]
      pp "XX"
      
      @node.add_node(node)
      YAML.dump(true)
    end
    
    get '/service/:name/:method' do
      name=params[:name]
      method=params[:method]
      callService(name,method)
    end

    put '/service/:name/:method' do
      name=params[:name]
      method=params[:method]+"="
      callService(name,method,params[:value])
    end

    post '/service/:name/:method' do
      name=params[:name]
      method=params[:method]+"!"
      callService(name,method)
    end
    
    def callService(name,method,value=nil)
      begin
        if secure?(method)
          service=@node.service(name)
          f=service.method(method)
          if f.arity==0
            YAML.dump(f.call)
          else
            if params[:value]
              ps=params[:value]
            elsif params[:arg0]
              ps=[]
              0.up_to(10) {|i|
                p=params["arg"+i]
                if p
                  ps<<p
                else
                  break
                end
              }
            else
              ps=[params]
            end
            YAML.dump(f.call(*ps))
          end
        else
          "fail"
        end
      rescue Object=>e
        puts e,e.backtrace
        "fail"
      end
    end
    
    def secure?(method)
      if ["method_missing","send","call","eval"].member?(method)
        false
      elsif method=~/.*eval.*/ or method=~/^_.*/
        false
      else
        true
      end      
    end
    
    # this deprecated - services should be generic
    if false
    post '/hash' do
      writer=if params[:node].nil? and env["REMOTE_ADDR"]=="127.0.0.1"
        @node.me
      else
        YAML.load(params[:node])
      end
      writer.ip=env["REMOTE_HOST"]
      if @node.valid?(writer)
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
end
