require 'digest/sha2'

module P2P
  Node=Struct.new(:nodeid,:ip,:port)
  
  def self.generate_id
    h=Digest::SHA2.new << (rand.to_s+Time.now.to_s)
    h.to_s
#    pp h.methods.sort
#    pp h.to_s
#    exit
  end
end
