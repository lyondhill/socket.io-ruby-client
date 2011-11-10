require 'socketIO'

client = SocketIO.connect("localhost") do
  before_start do
    on_message {|message| puts "incoming message: #{message}"}
    on_disconnect {puts "I GOT A TDISCONNECT"}
  end

  after_start do
    emit("loadLogs", "/Users/lyon/test/rails_app/log/development.log")
  end
end

puts "thread exited and I have the power back"