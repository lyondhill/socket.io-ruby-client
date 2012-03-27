# Simple Socket IO client

Quick and kinda dirty socket.io client using web sockets

## Features

This client currently supports:

* Listeners for all 9 possible message
* Send messages of the type:
  * message
  * json
  * event

## How to use:

```ruby
require 'SocketIO'

client = SocketIO.connect("http://localhost") do
  before_start do
    on_message {|message| puts "incoming message: #{message}"}
    on_event('news') { |data| puts data.first} # data is an array fo things.
  end

end
```

## Sync vs Async

You can start the socket io syncronously and then continue with your work
this crates threads so be careful.

```ruby
require 'SocketIO'

client = SocketIO.connect("http://localhost", sync: true) do
  before_start do
    on_message {|message| puts message}
    on_disconnect {puts "I GOT A DISCONNECT"}
  end

  after_start do
    emit("loadLogs", "/var/www/rails_app/log/production.log")
  end
end

puts "socket still running"
loop do
  sleep 10
  puts 'zzz'
end
```

## Examples

examples can be found in the examples/ folder. 
A corrosponding server can be found in the examples/servers
