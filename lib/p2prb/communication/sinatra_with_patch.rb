require 'sinatra/base.rb'


module Sinatra
  class Base
    def self.run!(options={})
      started=false
      Thread.new {
        begin
          set options
#          set :logging, false
          handler      = detect_rack_handler
          handler_name = handler.name.gsub(/.*::/, '')
#          puts "== Sinatra/#{Sinatra::VERSION} has taken the stage " +
#            "on #{port} for #{environment} with backup from #{handler_name}" unless handler_name =~/cgi/i
          ::Thin::Logging.silent=true
          handler.run self, :Host => bind, :Port => port do |server|
            trap(:INT) do
              ## Use thins' hard #stop! if available, otherwise just #stop
              server.respond_to?(:stop!) ? server.stop! : server.stop
              puts "\n== Sinatra has ended his set (crowd applauds)" unless handler_name =~/cgi/i
            end
            set :running, true
            @server=server
            started=true
          end
        rescue Errno::EADDRINUSE => e
          puts "== Someone is already performing on port #{port}!"
        end
      }
      
      sleep 0.002 while started==false
    end
    
    def stop!
      server=@server
      server.respond_to?(:stop!) ? server.stop! : server.stop    
    end
  end
end
