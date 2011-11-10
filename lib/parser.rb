module Parser
  @regexp = /([^:]+):([0-9]+)?(\+)?:([^:]+)?:?([\s\S]*)?/

  # returns hash as {type: '1', id: '1', end_point: '4', data: [{key: value}]}
  def self.decode(string)
    if pieces = string.match(@regexp)
      {type: pieces[1], id: pieces[2], end_point: pieces[4], data: pieces[5]}
    else
      {type: '0'}
    end
  end

end