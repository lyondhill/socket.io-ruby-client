#!/usr/bin/env ruby

echo_server = fork do
  puts `pwd`
  # exec ""
end
puts "pid ??? #{echo_server}"
Process.detach(echo_server)
