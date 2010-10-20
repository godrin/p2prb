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

  def self.hexDist(hash1,hash2)
    assert{hash1.length==hash2.length}
    dist=0
    (0...hash1.length).each{|i|
      current=(hash1[i]^hash2[i])
      dist*=256
      dist+=current
      #r+=c
    } 
    dist

  end
end
