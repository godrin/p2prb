require 'simple_http.rb'

me=Node.new(2342,"127.0.0.1",4567)
remote=Node.new(23232323234,"127.0.0.1",4597)

http(remote) {|h|
pp h.register_node(me)
pp h.get_new_nodes
}
