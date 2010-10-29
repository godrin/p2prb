
class MasterNode
  attr_reader :nodes
  
  def initialize
    @nodes=[]
  end
  
  def register(me)
    passert{me}
    @nodes=(@nodes+[me]).uniq
  end
  def unregister(me)
    @nodes.delete(me)
  end
end
