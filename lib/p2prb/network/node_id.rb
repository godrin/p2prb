require 'digest/sha1'

require File.expand_path('../../base/basics.rb',__FILE__)

class NodeId
  def initialize(i)
    if i.is_a?(String)
      @id=i
    else
      @id="%X" % i
    end
  end
  
  def ==(other)
    if other.is_a?(NodeId)
      self.value==other.value
    else
      false
    end
  end
  
  def self.from_string(str)
    NodeId.new(Digest::SHA1.hexdigest(str))
  end
  
  def to_s
    "#<NodeId id:#{@id}>"
  end
  
  def <=>(other)
    value<=>other.value
  end
  
  def value
    @id.hex
  end
  def diff(x)
    raise "Not a NodeId" unless x.is_a?(NodeId)
    v=(value ^ x.value)
    v.count_set_bits
  end
end