"use strict";

var http               = require('http');
var express            = require('express');
var RemoteTCPFeedRelay = require('./lib/static');
var app                = express();

//public website
app.use(express.static(__dirname + '/public'));

var source = {
  width     : 480,
  height    : 270,

  video_path     : "samples/admiral.264",
  video_duration : 58
};


source = {
  width     : 960,
  height    : 540,

  video_path     : "samples/orig.h264",
  video_duration : 58
};

source = {
  width     : 1920,
  height    : 1088,

  video_path     : "samples/out_div.h264",
  video_duration : 2
};


var server  = http.createServer(app);
var feed    = new RemoteTCPFeedRelay(server, source);

server.listen(8080, function(){
  console.log('Express server listening on port http://localhost:8080');
});

