require 'SocketIO'

describe Parser do
  
  it 'should be able to decode all valid messages' do
    Parser.decode("0").should == {type: "0"}
    Parser.decode("1::").should == {type: "1", id: nil, end_point: nil, data: ""}
    Parser.decode("2::").should == {type: "2", id: nil, end_point: nil, data: ""}
    Parser.decode("3:::hay you").should == {type: "3", id: nil, end_point: nil, data: "hay you"}
    Parser.decode("4:::{\"can\":\"youcall\"}").should == {type: "4", id: nil, end_point: nil, data: "{\"can\":\"youcall\"}"}
    Parser.decode("5:::hay you").should == {type: "5", id: nil, end_point: nil, data: "hay you"}
    Parser.decode("6:::").should == {type: "6", id: nil, end_point: nil, data: ""}
    Parser.decode("7:::there is an error").should == {type: "7", id: nil, end_point: nil, data: "there is an error"}
    Parser.decode("8:::").should == {type: "8", id: nil, end_point: nil, data: ""}
  end

  it "should give a disconnect if bad input" do
    Parser.decode("hay dude").should == {type: "0"}
    Parser.decode("9").should == {type: "0"}
  end

end
