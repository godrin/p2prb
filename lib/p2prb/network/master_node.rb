
class MasterNode
  attr_reader :known_nodes
  
  def initialize
    @known_nodes=[]
  end
  
  def register(me)
    @known_nodes=(@known_nodes+[me]).uniq
  end
  def unregister(me)
    @known_nodes.delete(me)
  end
end
