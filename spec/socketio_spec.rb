describe SocketIO do
  
  before :all do
    @client = SocketIO.connect("http://localhost", :sync => true)
  end

  it "can send a heartbeat" do
    @client.send_heartbeat
    # should not bonk. haha
  end

  it "gets a message back when it sends one" do
    count = 0
    @client.on_message do |msg|
      count += 1 if msg == "hay dude"
    end
    @client.send("hay dude")
    sleep 0.5
    count.should == 1
  end

  it "gets an emit back when it hits the echo" do
    count = 0
    @client.on_event("event") do |data|
      count += 1 if data[0] == {"first"=>"element", "second"=>"guy"}
    end 
    @client.emit("event", {first: "element", second: "guy"})
    sleep 0.5
    count.should == 1
  end

  it "can have a block for every thing" do
    @client.on_disconnect { }
    @client.on_connect { }
    @client.on_heartbeat { }
    @client.on_message { |msg| }
    @client.on_json_message { |json| }
    @client.on_event('en') { |event_hash| }
    @client.on_ack { }
    @client.on_error { |data| }
    @client.on_noop { }
  end

  

end
