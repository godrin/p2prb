def passert(&proc)
  raise "Assertion failed: val is not true!" unless proc.call
end

class Numeric
  def count_set_bits
    x=self
    count = 0
    count += x & 1 and x >>= 1 until x == 0
    count
  end
end

class Object
  def has_signature?(x)
    x.signature.each{|i|
      unless respond_to?(i)
        puts "#{self.inspect} does not have function #{i}"
        return false 
      end
    }
  end
end