
/**
 * This behaves like a WebSocket in every way, except if it fails to connect,
 * or it gets disconnected, it will repeatedly poll until it successfully
 * connects again.
 *
 * It is API compatible, so when you have:
 *   ws = new WebSocket('ws://....');
 * you can replace with:
 *   ws = new ReconnectingWebSocket('ws://....');
 *
 * The event stream will typically look like:
 *  onconnecting
 *  onopen
 *  onmessage
 *  onmessage
 *  onclose // lost connection
 *  onconnecting
 *  onopen  // sometime later...
 *  onmessage
 *  onmessage
 *  etc...
 *
 * It is API compatible with the standard WebSocket API, apart from the
 *  following members:
 *
 * - `bufferedAmount`
 * - `extensions`
 * - `binaryType`
 *
 * Latest version: https://github.com/joewalnes/reconnecting-websocket/
 * - Joe Walnes
 *
 * Syntax
 * ======
 * var socket = new ReconnectingWebSocket(url, protocols, options);
 *
 * Parameters
 * ==========
 * url - The url you are connecting to.
 * protocols - Optional string or array of protocols.
 * options - See below
 *
 * Options
 * =======
 * Options can either be passed upon instantiation or set after instantiation:
 *
 * socket = new ReconnectingWebSocket(url, null, { debug: true,
 *   reconnectInterval: 4000 })
 *
 * or
 *
 * socket = new ReconnectingWebSocket url
 * socket.debug = true
 * socket.reconnectInterval = 4000
 *
 * debug
 * - Whether this instance should log debug messages. Accepts true or false.
 *   Default: false.
 *
 * automaticOpen
 * - Whether or not the websocket should attempt to connect immediately upon
 *   instantiation. The socket can be manually opened or closed at any time
 *   using ws.open() and ws.close().
 *
 * reconnectInterval
 * - The number of milliseconds to delay before attempting to reconnect.
 *   Accepts integer.
 *   Default: 1000.
 *
 * maxReconnectInterval
 * - The maximum number of milliseconds to delay a reconnection attempt.
 *   Accepts integer.
 *   Default: 30000.
 *
 * reconnectDecay
 * - The rate of increase of the reconnect delay. Allows reconnect attempts
 *   to back off when problems persist. Accepts integer or float.
 *   Default: 1.5.
 *
 * timeoutInterval
 * - The maximum time in milliseconds to wait for a connection to succeed before
 *   closing and retrying. Accepts integer.
 *   Default: 2000.
 *
 */
var ReconnectingWebSocket;

ReconnectingWebSocket = (function() {
  function ReconnectingWebSocket(url, protocols, options) {
    var eventTarget, forcedClose, generateEvent, key, self, settings, timedOut, ws;
    settings = {
      debug: false,
      automaticOpen: true,
      reconnectInterval: 1000,
      maxReconnectInterval: 30000,
      reconnectDecay: 1.5,
      timeoutInterval: 2000,
      maxReconnectAttempts: null
    };
    if (!options) {
      options = {};
    }
    for (key in settings) {
      if (typeof options[key] !== 'undefined') {
        this[key] = options[key];
      } else {
        this[key] = settings[key];
      }
    }
    this.url = url;
    this.reconnectAttempts = 0;
    this.readyState = WebSocket.CONNECTING;
    this.protocol = null;
    ws = void 0;
    forcedClose = false;
    timedOut = false;
    self = this;
    eventTarget = document.createElement('div');
    eventTarget.addEventListener('open', function(event) {
      self.onopen(event);
    });
    eventTarget.addEventListener('close', function(event) {
      self.onclose(event);
    });
    eventTarget.addEventListener('connecting', function(event) {
      console.debug(self);
      self.onconnecting(event);
    });
    eventTarget.addEventListener('message', function(event) {
      self.onmessage(event);
    });
    eventTarget.addEventListener('error', function(event) {
      self.onerror(event);
    });
    this.addEventListener = eventTarget.addEventListener.bind(eventTarget);
    this.removeEventListener = eventTarget.removeEventListener.bind(eventTarget);
    this.dispatchEvent = eventTarget.dispatchEvent.bind(eventTarget);

    /*
     * This function generates an event that is compatible with standard
     * compliant browsers and IE9 - IE11
     *
     * This will prevent the error:
     * Object doesn't support this action
     *
     * http://stackoverflow.com/questions/19345392/why-arent-my-parameters-getting-passed-through-to-a-dispatched-event/19345563#19345563
     * @params String The name that the event should use
     * @param args Object an optional object that the event will use
     */
    generateEvent = function(s, args) {
      var evt;
      evt = document.createEvent('CustomEvent');
      evt.initCustomEvent(s, false, false, args);
      return evt;
    };
    this.open = function(reconnectAttempt) {
      var localWs, timeout;
      ws = new WebSocket(self.url, protocols || []);
      if (reconnectAttempt) {
        if (this.maxReconnectAttempts && this.reconnectAttempts > this.maxReconnectAttempts) {
          return;
        }
      } else {
        eventTarget.dispatchEvent(generateEvent('connecting'));
        this.reconnectAttempts = 0;
      }
      if (self.debug || ReconnectingWebSocket.debugAll) {
        console.debug('ReconnectingWebSocket', 'attempt-connect', self.url);
      }
      localWs = ws;
      timeout = setTimeout((function() {
        if (self.debug || ReconnectingWebSocket.debugAll) {
          console.debug('ReconnectingWebSocket', 'connection-timeout', self.url);
        }
        timedOut = true;
        localWs.close();
        timedOut = false;
      }), self.timeoutInterval);
      ws.onopen = function(event) {
        var e;
        clearTimeout(timeout);
        if (self.debug || ReconnectingWebSocket.debugAll) {
          console.debug('ReconnectingWebSocket', 'onopen', self.url);
        }
        self.protocol = ws.protocol;
        self.readyState = WebSocket.OPEN;
        self.reconnectAttempts = 0;
        e = generateEvent('open');
        e.isReconnect = reconnectAttempt;
        reconnectAttempt = false;
        eventTarget.dispatchEvent(e);
      };
      ws.onclose = function(event) {
        var e;
        clearTimeout(timeout);
        ws = null;
        if (forcedClose) {
          self.readyState = WebSocket.CLOSED;
          return eventTarget.dispatchEvent(generateEvent('close'));
        } else {
          self.readyState = WebSocket.CONNECTING;
          e = generateEvent('connecting');
          e.code = event.code;
          e.reason = event.reason;
          e.wasClean = event.wasClean;
          eventTarget.dispatchEvent(e);
          if (!reconnectAttempt && !timedOut) {
            if (self.debug || ReconnectingWebSocket.debugAll) {
              console.debug('ReconnectingWebSocket', 'onclose', self.url);
            }
            eventTarget.dispatchEvent(generateEvent('close'));
          }
          timeout = self.reconnectInterval * self.reconnectDecay * self.reconnectAttempts;
          if (timeout > self.maxReconnectInterval) {
            timeout = self.maxReconnectInterval;
          }
          setTimeout((function() {
            self.reconnectAttempts++;
            self.open(true);
          }), timeout);
        }
      };
      ws.onmessage = function(event) {
        var e;
        if (self.debug || ReconnectingWebSocket.debugAll) {
          console.debug('ReconnectingWebSocket', 'onmessage', self.url, event.data);
        }
        e = generateEvent('message');
        e.data = event.data;
        eventTarget.dispatchEvent(e);
      };
      ws.onerror = function(event) {
        if (self.debug || ReconnectingWebSocket.debugAll) {
          console.debug('ReconnectingWebSocket', 'onerror', self.url, event);
        }
        eventTarget.dispatchEvent(generateEvent('error'));
      };
    };
    if (this.automaticOpen === true) {
      this.open(false);
    }

    /*
     * Transmits data to the server over the WebSocket connection.
     *
     * @param data a text string, ArrayBuffer or Blob to send to the server.
     */
    this.send = function(data) {
      if (ws) {
        if (self.debug || ReconnectingWebSocket.debugAll) {
          console.debug('ReconnectingWebSocket', 'send', self.url, data);
        }
        return ws.send(data);
      } else {
        throw new Error('INVALID_STATE_ERR : Pausing to reconnect websocket');
      }
    };

    /*
     * Closes the WebSocket connection or connection attempt, if any.
     * If the connection is already CLOSED, this method does nothing.
     */
    this.close = function(code, reason) {
      if (typeof code === 'undefined') {
        code = 1000;
      }
      forcedClose = true;
      if (ws) {
        ws.close(code, reason);
      }
    };

    /**
     * Additional public API method to refresh the connection if still
     * open (close, re-open). For example, if the app suspects bad
     * data / missed heart beats, it can try to refresh.
     */
    this.refresh = function() {
      if (ws) {
        ws.close();
      }
    };
  }


  /*
   * An event listener to be called when the WebSocket connection's
   * readyState changes to OPEN;
   * this indicates that the connection is ready to send and receive data.
   */

  ReconnectingWebSocket.prototype.onopen = function(event) {};

  ReconnectingWebSocket.prototype.onclose = function(event) {};

  ReconnectingWebSocket.prototype.onconnecting = function(event) {};

  ReconnectingWebSocket.prototype.onmessage = function(event) {};

  ReconnectingWebSocket.prototype.onerror = function(event) {};


  /*
   * Whether all instances of ReconnectingWebSocket should log debug messages.
   * Setting this to true is the equivalent of setting all instances of
   * ReconnectingWebSocket.debug to true.
   */

  ReconnectingWebSocket.debugAll = false;

  ReconnectingWebSocket.CONNECTING = WebSocket.CONNECTING;

  ReconnectingWebSocket.OPEN = WebSocket.OPEN;

  ReconnectingWebSocket.CLOSING = WebSocket.CLOSING;

  ReconnectingWebSocket.CLOSED = WebSocket.CLOSED;

  return ReconnectingWebSocket;

})();

var BaseSocket,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

BaseSocket = (function() {
  function BaseSocket() {
    this.notConnected = bind(this.notConnected, this);
    this.updateState = bind(this.updateState, this);
    this.updateStatusLabel = bind(this.updateStatusLabel, this);
    this.params = void 0;
    this.ws = new ReconnectingWebSocket("ws://" + document.location.host + "/ws");
    this.ws.reconnectInterval = 3000;
    this.ws.onopen = (function(_this) {
      return function() {
        console.log('Socket opened');
        return _this.getParams(_this.updateState);
      };
    })(this);
    this.ws.onclose = (function(_this) {
      return function() {
        console.log('Socket close');
        return _this.notConnected();
      };
    })(this);
    this.ws.onerror = (function(_this) {
      return function(e) {
        console.log("Socket error: " + e);
        return _this.notConnected();
      };
    })(this);
  }

  BaseSocket.prototype.ajaxCommand = function(command) {
    return function() {
      return $.ajax({
        data: {
          command: command
        }
      });
    };
  };

  BaseSocket.prototype.updateStatusLabel = function(status) {
    var lblStatus, statusClases;
    statusClases = ['label-default', 'label-default', 'label-warning', 'label-warning', 'label-info', 'label-success'];
    lblStatus = $('#cal-status');
    lblStatus.text(this.params.state_message);
    lblStatus.removeClass('label-default label-danger label-warning label-success label-info');
    return lblStatus.addClass(statusClases[this.params.state]);
  };

  BaseSocket.prototype.getParams = function(callback) {
    if (callback == null) {
      callback = void 0;
    }
    return $.ajax({
      data: {
        command: 'get_params'
      },
      success: (function(_this) {
        return function(data) {
          _this.params = JSON.parse(data);
          if (callback) {
            return callback();
          }
        };
      })(this)
    });
  };

  BaseSocket.prototype.updateState = function() {
    console.log("applyStatus new state: " + this.params.state);
    return this.updateStatusLabel(this.params.state_message);
  };

  BaseSocket.prototype.notConnected = function() {
    console.log("notConnected");
    this.setNavbarTime('no-connect');
    this.params.state = 0;
    this.params.state_message = "Not Connected";
    return this.updateState();
  };

  BaseSocket.prototype.drawImage = function(canvas, image, callback) {
    var ch, ctx, cw;
    if (callback == null) {
      callback = void 0;
    }
    ctx = canvas.getContext("2d");
    cw = canvas.width;
    ch = canvas.height;
    ctx.drawImage(image, 0, 0, cw, ch);
    if (callback) {
      callback(ctx);
    }
    return ctx;
  };

  BaseSocket.prototype.loadDrawImage = function(src, canvas, callback) {
    var imageObj;
    if (callback == null) {
      callback = void 0;
    }
    console.log("loadDrawImage");
    imageObj = new Image();
    imageObj.onload = (function(_this) {
      return function() {
        console.log("loadDrawImage: image loaded", src);
        return _this.drawImage(canvas, imageObj, callback);
      };
    })(this);
    imageObj.src = src;
  };

  BaseSocket.prototype.setNavbarTime = function(value) {
    return $('#ls-time-tick').text(value);
  };

  return BaseSocket;

})();


/**
 * Created svolkov
 * last edit 12.03.15.
 */
var RemoteControlSocket,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

RemoteControlSocket = (function(superClass) {
  extend(RemoteControlSocket, superClass);

  function RemoteControlSocket() {
    this.updateState = bind(this.updateState, this);
    RemoteControlSocket.__super__.constructor.call(this);
    this.btnPlay = $('#btn-play');
    this.btnPlay.click(this.ajaxCommand('preview_toggle'));
    this.canvasFrame = $('#frame-canvas')[0];
    this.ws.onmessage = (function(_this) {
      return function(msg) {
        var imgBlob, message, reader;
        if (msg.data instanceof Blob) {
          console.log("Is Blob: " + msg.data.size);
          console.log("Is Blob: " + msg.type);
          _this.fps_temp += 1;
          reader = new FileReader();
          reader.onload = function(event) {
            var dataUri;
            dataUri = event.target.result;
            return _this.loadDrawImage(dataUri, _this.canvasFrame);
          };
          imgBlob = new Blob([msg.data], {
            type: 'image/jpeg'
          });
          return reader.readAsDataURL(imgBlob);
        } else if (msg.data !== Blob) {
          message = JSON.parse(msg.data);
          if (message.command === 'time') {
            return _this.setNavbarTime(message.value);
          } else if (message.command === 'update_status') {
            return _this.getParams(_this.updateState);
          } else {
            return console.log("Unknown message: " + message.command);
          }
        }
      };
    })(this);
    $('area').on('click', function() {
      var href;
      href = this.href.slice(this.href.lastIndexOf('#') + 1);
      console.log("ir_send: " + href);
      return $.ajax({
        data: {
          command: "send_ir",
          button: href
        }
      });
    });
  }

  RemoteControlSocket.prototype.updateState = function() {
    var ref;
    if ((ref = this.params.state) === 1 || ref === 2) {
      this.btnPlay.removeClass('disabled');
    } else {
      this.btnPlay.addClass('disabled');
    }
    if (this.params.state === 2) {
      return this.btnPlay.text("Stop");
    } else {
      return this.btnPlay.text("Play");
    }
  };

  return RemoteControlSocket;

})(BaseSocket);
