module P2P


  class NodeProcess
    def initialize(id,master=nil)
      pid=fork
      port=5000+id
      @startTime=Time.now
      @port=port
      unless pid
        NodeApp.go! :host => P2P::localhost, :port => port, :nodeid=>port,:master=>master
        exit
      end
      @pid=pid
    end
    def kill(wait=true)
      Process.kill("INT", @pid)
      Process.wait(@pid) if wait
#      Process.kill("TERM", @pid)
    end
    def kill!
      Process.kill("KILL", @pid)
    end
    
    def method_missing(*args)
      if Time.now-@startTime<1
        sleep 1
      end
      P2P::http(Node.new(nil,P2P::localhost,@port)) {|h|h.send(*args)}
    end
  end
end