var Class     = require('uclass');
var Options         = require('uclass/options');
var spawn        = require('child_process').spawn;
var util      = require('util');
var WebSocketServer = require('ws').Server; //it's a good idea to try uws instead of ws
var gstreamer        = require('gstreamer010-superficial');

var GstreamerServer = new Class({

  Implements :  [Options],
  Binds  : ['new_client', 'start_feed', 'broadcast'],

  options  : {
    width : 1920,
    height: 1088,
  },

  initialize : function(server, options){
    this.setOptions(options)

    this.wss = new WebSocketServer({server: server});
    this.wss.on('connection', this.new_client);
  },

  start_feed : function(){
    var self = this;
    var cmd = "videotestsrc num-buffers=200 ! " +
              "video/x-raw-rgb,width=640,height=480,framerate=10/1 ! " +
              "ffmpegcolorspace ! appsink name=sink";
    console.log(cmd);

    var pipeline = new gstreamer.Pipeline(cmd);
    this.pipeline = pipeline;

    var appsink = pipeline.findChild("sink");

    appsink.pull( function(buf) {
      console.log("BUFFER size",buf.length);
      self.broadcast(buf);
    }, function(caps) {
      console.log("CAPS",caps);
    } );
  },

  broadcast : function(data){
    this.wss.clients.forEach(function(socket) {

      if(socket.buzy)
        return;

      socket.buzy = true;
      socket.buzy = false;

      socket.send(data, { binary: true}, function ack(error) {
        socket.buzy = false;
      });
    });

  },

  new_client : function(socket) {
  
    var self = this;
    console.log('New guy');

    socket.send(JSON.stringify({
      action : "init",
      width  : this.options.width,
      height : this.options.height,
    }));

    socket.on("message", function(data){
      var cmd = "" + data, action = data.split(' ')[0];
      console.log("Incomming action '%s'", action);

      if(action == "REQUESTSTREAM") {
        self.start_feed();
        self.pipeline.play();
      }
      
      if(action == "STOPSTREAM")
        self.pipeline.pause();
    });

    socket.on('close', function() {
      self.pipeline.stop();
      console.log('stopping client interval');
    });
  },

});


module.exports = GstreamerServer;
