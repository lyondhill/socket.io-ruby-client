require 'socketIO'

client = SocketIO.connect("localhost") do
  before_start do
    on_message {|message| puts "incoming message: #{message}"}
    on_event('news') { |data| puts data.first} # data is an array fo things.
  end

end

