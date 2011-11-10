require 'socketIO'

client = SocketIO.connect("localhost") do
  before_start do
    on_message {|message| puts "incoming message: #{message}"}
  end

  after_start do
    emit("loadLogs", "/Users/lyon/test/rails_app/log/development.log")
  end
end
