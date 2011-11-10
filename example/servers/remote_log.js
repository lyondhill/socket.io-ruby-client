var io = require('socket.io').listen(80)
  ,spawn = require('child_process').spawn

console.log("Up and running. waiting on connections")
io.sockets.on('connection', function(socket){
  console.log("new connection.")

  socket.on("loadLogs", function(path){
    var tail = spawn("tail", ["-F", path])

    console.log("Begining tail on: " + path)
    tail.stdout.on("data", function(data){
      console.log(data.toString("utf8"))
      socket.send(data.toString("utf8"))
    })
  })

})
