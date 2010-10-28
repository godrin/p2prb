class P2prb
  VERSION = '1.0.0'
end

#require File.join(File.dirname(__FILE__),'p2prb/swarm.rb')
require File.join(File.dirname(__FILE__),'p2prb/base/basics.rb')

require File.join(File.dirname(__FILE__),'p2prb/network/basic_node.rb')

require File.join(File.dirname(__FILE__),'p2prb/communication/basic_proxy.rb')
require File.join(File.dirname(__FILE__),'p2prb/communication/http_server.rb')

require File.join(File.dirname(__FILE__),'p2prb/network/key_value_store.rb')
require File.join(File.dirname(__FILE__),'p2prb/network/master_node.rb')

