var io = require('socket.io').listen(80);

io.sockets.on('connection', function(socket) {

  socket.on('message', function(msg) {
    socket.send(msg)
  })

  socket.on('event', function(data) {
    socket.emit('event', data);
  });

  socket.on('dc', function() {
  	socket.close()
  })

});