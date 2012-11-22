require 'web_socket'
require 'rest_client'
require 'json'
require 'parser'

module SocketIO

  # params [URI, String] uri
  def self.connect(uri, options = {}, &block)
    uri = URI(uri)
    options[:path] = uri.path
    # handshake
    response = RestClient.get "#{uri.scheme}://#{uri.host}:#{uri.port}/socket.io/1/"
    response_array = response.split(':')
    response_array = [uri] + response_array << options
    cli = Client.new(*response_array)
    cli.instance_eval(&block) if block
    cli.start
  end

  class Client
    VERSION = "0.0.2"

    [:INT, :TERM].each do |sig|
      Signal.trap(sig) do
        puts
        puts "bye"
        exit
      end
    end

    # The state of the Socket.IO socket can be disconnected, disconnecting, connected and connecting.
    # The transport connection can be closed, closing, open, and opening.

    def initialize(uri, session_id, heartbeat_timeout, connection_timeout, supported_transports, options = {})
      @uri = uri
      namespace = uri.path.sub(%r~^/~, '')
      @namespace =  namespace.empty? ? "socket.io" : namespace
      @session_id = session_id
      @hb_timeout = heartbeat_timeout
      @connect_timeout = connection_timeout
      @supported_transports = supported_transports
      @options = options
      @reconnect = options[:reconnect]
      @on_event = {}
      @path = options[:path]
    end

    def start
      self.instance_eval(&@before_start) if @before_start
      connect_transport
      start_recieve_loop
      self.instance_eval(&@after_start) if @after_start
      @thread.join unless @options[:sync]
      self
    end

    def connect_transport
      if @supported_transports.include? "websocket"
        scheme = @uri.scheme == "https" ? "wss" : "ws"
        @transport = WebSocket.new("#{scheme}://#{@uri.host}:#{@uri.port}/socket.io/1/websocket/#{@session_id}", origin: @uri.to_s)
        @transport.send("1::#{@path}")
      else
        raise "We only support WebSockets.. and this server doesnt like web sockets.. O NO!!"
      end
    end

    def start_recieve_loop
      @thread = Thread.new() do
        while data = @transport.receive()
          decoded = Parser.decode(data)
          case decoded[:type]
          when '0'
            @on_disconnect.call if @on_disconnect
          when '1'
            @on_connect.call if @on_connect
          when '2'
            send_heartbeat
            @on_heartbeat.call if @on_heartbeat
          when '3'
            @on_message.call decoded[:data] if @on_message
          when '4'
            @on_json_message.call decoded[:data] if @on_json_message
          when '5'
            message = JSON.parse(decoded[:data])
            @on_event[message['name']].call message['args'] if @on_event[message['name']]
          when '6'
            @on_ack.call if @on_ack
          when '7'
            @on_error.call decoded[:data] if @on_error
          when '8'
            @on_noop.call if @on_noop
          end
        end
      end
      @thread
    end

    def disconnect
      @transport.send("0::")
    end

    def disconnected
      if @reconnect
        connect_transport
        start_recieve_loop
      end
    end

    def join
      @thread.join
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

    def before_start(&block)
      @before_start = block
    end

    def after_start(&block)
      @after_start = block
    end

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
