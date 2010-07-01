require 'pp'
require 'swarm.rb'

otherNodes=[5001,5002,5003]

masterPort=5010

masterId=777

#create Master

pid=fork
unless pid
  NodeApp.go! :host=>localhost,:port=>masterPort,:nodeid=>"Master"
  exit
end
pids=[pid]

master=Node.new(masterId,localhost,masterPort)

# create nodes

pids+=otherNodes.map{|port|
  pid=fork
  unless pid
    NodeApp.go! :host => localhost, :port => port, :nodeid=>port,:master=>master
    exit
  end
  pid
}
if pids
  pp pids
end

$quitted=false
def dokill(pids)
  $quitted=true
  pids.each{|pid|
    begin
      Process.kill("INT", pid)
      Process.wait(pid) 
    rescue
    end
  }
end

Signal.trap("HUP") { dokill pids}
Signal.trap("INT") { dokill pids}
Signal.trap("KILL") { dokill pids}
while not $quitted
  sleep 2
end
#sleep 2
dokill(pids)
