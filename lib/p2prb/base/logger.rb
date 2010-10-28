module P2P
  class Logger
    def self.log(e)
      puts e.inspect
      if e.respond_to?(:backtrace)
        puts e.backtrace.inspect
      end
    end
  end
  module Logging
    def self.log(*args)
      P2P::Logger.log(*args)
    end
  end
end