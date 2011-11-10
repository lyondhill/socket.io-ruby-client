var io = require('socket.io').listen(80);

io.sockets.on('connection', function (socket) {

  setInterval(function(){
    socket.send('got something for ya');
    socket.emit('news', { hello: 'world'});
  }, 10000)

});
