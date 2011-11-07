require 'web_socket'
require 'parser'

module SocketIO

  def connect(host)
    response = `curl http://#{host}/socket.io/1/`
    # resonse should be in the form of sessionid:heartbeattimeout:closetimeout:supported stuff
    response_array = response.split(':')
    response_array = [host] + response_array
    client.new(*response_array)
  end

  class Client
    VERSION = "0.0.1"

    # The state of the Socket.IO socket can be disconnected, disconnecting, connected and connecting.
    # The transport connection can be closed, closing, open, and opening.

    def initialize(session_id, heartbeat_timeout, connection_timeout, supported_transports)
      @session_id = session_id
      @hb_timeout = heartbeat_timeout
      @connect_timeout = connection_timeout
      @supported_transports = supported_transports
      connect_transport
      start_recieve_loop
      start_heartbeat
    end

    def connect_transport
      if supported_transports.include? "websocket"
        @transport = WebSocket.new("ws://#{host}/socket.io/1/websocket/#{session_id}")
      else
        raise "We only support WebSockets.. and this server doesnt like web sockets.. O NO!!"
      end
    end

    def start_recieve_loop
      Thread.new() do
      while data = @transport.receive()
        decoded = Parser.decode(data)
        case decoded[:type]
        when '0'
          @on_disconnect.call if @on_disconnect
        when '1'
          @on_connect.call if @on_connect
        when '2'
          @on_heartbeat.call if @on_heartbeat
        when '3'
          @on_message.call data_array[:data] if @on_message
        when '4'
          @on_json_message.call JSON.parse(data_array[:data]) if @on_json_message
        when '5'
          # 5:::{"name":"my other event","args":[{"hello":"world"}]}
          message = JSON.parse(data_array[:data])
          @on_event[message['name']].call message['args'] if @on_event[message['name']]
        when '6'
          @on_error.call data_array[:data] if @on_error
        when '7'
          @on_ack.call if @on_ack
        when '8'
          @on_noop.call if @on_noop
        end
      end
      disconnected # Need something like a reconnect attempt
    end

    def disconnect
      @transport.send("0::")
    end

    def disconnected
      if @reconnect
        connect_transport
        start_recieve_loop
        start_heartbeat
      else
        
      end
    end

    def start_heartbeat
      Thread.new do
        loop do
          sleep((@hb_timeout - (@hb_timeout * 0.25)).to_i)
          break unless send_heartbeat
        end
      end
    end

    def send_heartbeat
      @transport.send("2::") #rescue false
    end

    def send_message(string)
      @transport.send("3:::#{string}") #rescue false
    end
    alias :send :send_message

    def send_json_message(hash)
      @transport.send("4:::#{hash.to_json}") # rescue false
    end

    def send_event(name, hash)
      @transport.send("5:::#{{name: name, args: [hash]}.to_json}") # rescue false
    end
    alias :emit :send_event

    def on_disconnect(&block)
      @on_disconnect = block
    end

    def on_connect(&block)
      @on_connect = block
    end

    def on_heartbeat(&block)
      @on_heartbeat = block
    end

    def on_message(&block)
      @on_message = block
    end

    def on_json_message(&block)
      @on_json_message = block
    end

    def on_event(name, &block)
      @on_event[name] = block
    end

    def on_ack(&block)
      @on_ack = block
    end

    def on_error(&block)
      @on_error = block
    end

    def on_noop(&block)
      @on_noop = block
    end


  end
end
