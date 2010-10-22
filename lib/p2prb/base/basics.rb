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