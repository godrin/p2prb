require 'sinatra/base.rb'


module Sinatra
  class Base
  
    Address=Struct.new(:host,:port)
  
    attr_accessor :server
    
    def self.run!(options={})
      started=false
      result=nil
      Thread.new {
        begin
          set options
#          set :logging, false
          handler      = detect_rack_handler
          handler_name = handler.name.gsub(/.*::/, '')
          puts "== Sinatra/#{Sinatra::VERSION} has taken the stage " +
            "on #{port} for #{environment} with backup from #{handler_name}" unless handler_name =~/cgi/i
          ::Thin::Logging.silent=true
          
          app=self.new(options)
          
          result=app
          handler.run app, :Host => bind, :Port => port do |server|
            trap(:INT) do
              ## Use thins' hard #stop! if available, otherwise just #stop
              server.respond_to?(:stop!) ? server.stop! : server.stop
              puts "\n== Sinatra has ended his set (crowd applauds)" unless handler_name =~/cgi/i
            end
            set :running, true
            @server=server
            app.server=server
            started=true
          end
        rescue Errno::EADDRINUSE => e
          puts "== Someone is already performing on port #{port}!"
        end
      }
      
      sleep 0.002 while started==false
      result
    end
    
    def url
 #     pp @server.methods.sort
      #pp methods.sort
      Address.new(@server.host,@server.port)
#      "http://#{@server.host}:#{@server.port}"
      #nil
    end
    
    def stop!
      server=@server
      server.respond_to?(:stop!) ? server.stop! : server.stop    
    end
  end
end
