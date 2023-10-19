require __dir__+"/darebee.rb"

Darebee.setInstance(?2)
Darebee.loadDates
d=Darebee.class_variable_get(:@@dates)
s=Darebee.class_variable_get(:@@start)

p d.bit_length
c=0
(d.bit_length-1).downto(0) do |i|
  #p [i,(1<<i)]
  if d&(1<<i)==0
    p (s+i)
    c+=1
  end
  break if c>100
end