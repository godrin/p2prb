module P2P
  class Logger
    def self.log(e)
      puts e.inspect
      if e.respond_to?(:backtrace)
        puts e.backtrace.inspect
      end
    end
  end
end