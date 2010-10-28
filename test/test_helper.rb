$:<<File.expand_path('../../lib',__FILE__)

def mrequire(*x)
  puts x
  require *x
end