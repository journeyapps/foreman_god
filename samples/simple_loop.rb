puts "Starting simple loop"
begin
  while true
    sleep 1
  end
rescue Exception => e
  puts "Terminated loop with #{e.inspect}"
end
