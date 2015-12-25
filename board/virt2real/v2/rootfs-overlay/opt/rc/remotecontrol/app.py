# coding: utf-8
from __future__ import unicode_literals, print_function, division, absolute_import

import json
import re
import time
import os.path
from subprocess import Popen

import tornado.gen
import tornado.web
import tornado.ioloop
import tornado.websocket
from tornado.log import app_log

import remotecontrol
from remotecontrol.handlers import (
    ErrorHandler,
    MainHandler,
    RemotesHandler,
    HelpHandler,
    SettingsHandler,
    WSHandler
)
from remotecontrol.lircd import ConfigReader
from remotecontrol.params import Params
from remotecontrol.gstreamer_manager import GstreamerManager

__author__ = 'svolkov'


# SEND_IR_SCRIPT = "send-ir.sh"
SEND_IR_SCRIPT = "v2r-irsend"

class Application(tornado.web.Application):
    def __init__(self, settings):
        # WebSocket connections pools
        self.ws_pool = []

        self.dbfile = "db/chat.sqlite"

        settings['static_url_prefix'] = '/static/'
        file_dir = os.path.dirname(__file__)
        settings['VERSION'] = remotecontrol.VERSION
        settings['VERSION_DATE'] = remotecontrol.VERSION_DATE
        settings['template_path'] = os.path.join(file_dir, "templates")
        settings['static_path'] = os.path.join(file_dir, "static")
        settings['scripts_path'] = os.path.join(file_dir, "../scripts")
        settings['lircd_path'] = os.path.join(file_dir, "../lircd")
        settings['img_path'] = os.path.join(file_dir, "static", "img")
        settings['default_handler_class'] = ErrorHandler
        settings['default_handler_args'] = dict(status_code=404)
        settings['xsrf_cookies'] = True
        # settings['cookie_secret'] = COOKIE_SECRET
        # settings['login_url'] = "/auth/signin"
        settings['autoescape'] = None
        settings['debug'] = True

        # parse lircd configs
        reader = ConfigReader(settings['lircd_path'])
        reader.parse()
        settings['remotes'] = reader.remotes

        if settings.get('pipeline_file', "") != "":
            settings['pipeline'] = self.read_pipeline(settings['pipeline_file'])

        handlers = (
            (r'/', MainHandler),
            (r'/remotes', RemotesHandler),
            (r'/help', HelpHandler),
            (r'/settings', SettingsHandler),
            (r'/ws/?', WSHandler, dict(pool=self.ws_pool)),
            (r'/static/(.*)', tornado.web.StaticFileHandler, {'path': 'static/'}),
        )
        tornado.web.Application.__init__(self, handlers, **settings)

        self.params = Params(self)

        # gstreamer manager
        self.manager = GstreamerManager(self)

        self._frame_tick = False

    @staticmethod
    def read_pipeline(file_name):
        file_path = os.path.join(os.path.curdir, file_name)
        result = ""
        with open(file_path, 'r') as f:
            for line in f.read().splitlines():
                # comments
                if line[0] == '#':
                    continue
                # first line
                if result != "":
                    result += " ! "
                result += line
        app_log.info("pipline from %s: %s", file_name, result)
        return result

    @tornado.gen.coroutine
    def send_ws_message(self, message, binary=False):
        for key, value in enumerate(self.ws_pool):
            if value.ws_connection:
                value.ws_connection.write_message(message, binary=binary)

    @tornado.gen.coroutine
    def send_ir(self, button):
        """call external script which send ir command"""
        app_log.debug("send_ir -> %s", button)
        # script_path = os.path.join(os.path.curdir, SEND_IR_SCRIPT)
        # parse button to device and button
        sep = button.index('-')
        device = button[:sep].upper()
        key = button[sep + 1:]
        key = key.replace('-', '_').upper()
        pulses = self.settings['remotes'][device].get_pulses(key)
        # params = [SEND_IR_SCRIPT] + pulses.split()
        Popen([SEND_IR_SCRIPT] + pulses.split())

    # --------------------------------
    # periodic send time tick callback
    # --------------------------------
    def second_tick(self):
        # self.manager.on_tick()
        self.send_command('time', self.get_time_tick())
        self._frame_tick = True

    @staticmethod
    def get_time_tick():
        t = time.localtime()
        return "%02d:%02d:%02d" % (t.tm_hour, t.tm_min, t.tm_sec)

    def send_command(self, command, value=""):
        # app_log.debug("send_command: {}".format(command))
        self.send_ws_message(self.make_json_command(command, value))

    @staticmethod
    def make_json_command(command, value):
        com_js = json.dumps(dict(command=command, value=value))
        # print(com_js)
        return com_js

    def get_image_no_video(self):
        return self.get_image('no_video.jpg')

    def get_image(self, filename):
        """Load image from img_path static directory"""
        file_path = os.path.join(self.settings['img_path'], filename)
        with open(file_path, 'rb') as f:
            return f.read()


def exec_script(script_name, params):
    Popen([script_name, "myarg"])

