# coding: utf-8
from __future__ import unicode_literals, print_function, division, absolute_import

import os
import json
import httplib
import tornado.gen
import tornado.web
import tornado.websocket
from tornado.log import app_log
from tornado.ioloop import IOLoop

__author__ = 'svolkov'


class BaseHandler(tornado.web.RequestHandler):
    def data_received(self, chunk):
        pass

    def is_ajax(self):
        return "X-Requested-With" in self.request.headers and \
               self.request.headers['X-Requested-With'] == "XMLHttpRequest"

    def get_template_namespace(self):
        """Add time_tick variable"""
        namespace = super(BaseHandler, self).get_template_namespace()
        namespace['time_tick'] = self.application.get_time_tick()
        return namespace

    def write_error(self, status_code, **kwargs):
        app_log.error(self.request.uri)
        self.require_setting("static_path")
        if status_code in [404, 500, 503, 403]:
            filename = os.path.join(self.settings['static_path'], '%d.html' % status_code)
            if os.path.exists(filename):
                f = open(filename, 'r')
                data = f.read()
                f.close()
                self.write(data)
        else:
            self.write(
                    "<html><title>%(code)d: %(message)s</title>"
                    "<body class='bodyErrorPage'>%(code)d: %(message)s</body></html>" % {
                        "code": status_code,
                        "message": httplib.responses[status_code],
                    }
            )


class DBHandler(BaseHandler):
    """Handler with DB access"""

    def get(self):
        # db = self.application.db
        # messages = db.chat.find()
        self.render('index.html', manager=self.application.manager)


class ErrorHandler(tornado.web.ErrorHandler, BaseHandler):
    """Default handler gonna to be used in case of 404 error"""
    pass


class MainHandler(BaseHandler):
    @tornado.gen.coroutine
    def get(self):
        if self.is_ajax():
            # ajax request
            if 'command' in self.request.arguments:
                command = self.request.arguments['command'][0]
                if command == "update_status":
                    self.write(self.application.manager.status_as_json())
                elif command == "get_params":
                    self.write(self.application.params.as_json())
                elif command == "preview_toggle":
                    IOLoop.current().spawn_callback(
                            self.application.manager.preview_toggle)
                elif command == "send_ir":
                    if 'button' in self.request.arguments:
                        button = self.request.arguments['button'][0]
                        IOLoop.current().spawn_callback(
                                lambda: self.application.send_ir(button))
                else:
                    app_log.debug("MainHandler ajax unknown handler: " + command)
                    self.write("error")
        else:
            self.render('index.html', manager=self.application.manager)


class RemotesHandler(BaseHandler):
    @tornado.gen.coroutine
    def get(self):
        if self.is_ajax():
            # ajax request
            if 'command' in self.request.arguments:
                command = self.request.arguments['command'][0]
                if command == "update_status":
                    self.write(self.application.manager.status_as_json())
                elif command == "get_params":
                    self.write(self.application.params.as_json())
                elif command == "preview_toggle":
                    IOLoop.current().spawn_callback(
                            self.application.manager.preview_toggle)
                elif command == "send_ir":
                    if 'button' in self.request.arguments:
                        button = self.request.arguments['button'][0]
                        IOLoop.current().spawn_callback(
                                lambda: self.application.send_ir(button))
                else:
                    app_log.debug("MainHandler ajax unknown handler: " + command)
                    self.write("error")
        else:
            self.render('remotes.html', manager=self.application.manager)


class HelpHandler(BaseHandler):
    def get(self):
        self.render('help.html')


class SettingsHandler(BaseHandler):
    def get(self):
        # db = self.application.db
        # messages = db.chat.find()
        messages = ""
        self.render("settings.html", messages=messages)


class WSHandler(tornado.websocket.WebSocketHandler):
    def data_received(self, chunk):
        pass

    def initialize(self, pool):
        self.pool = pool

    def open(self):
        self.pool.append(self)
        app_log.debug("ws open pool len: {}".format(len(self.pool)))
        IOLoop.current().add_callback(
                lambda: self.application.send_ws_message(
                        self.application.get_image_no_video(), True))

    # for revers communication from client use ajax requests!!
    def on_message(self, message):
        # input message from client
        data = json.loads(message)
        command = data["command"]
        app_log.debug("on_message command: " + command)

    def on_close(self, message=None):
        app_log.debug("on_close")
        for key, value in enumerate(self.pool):
            del self.pool[key]
