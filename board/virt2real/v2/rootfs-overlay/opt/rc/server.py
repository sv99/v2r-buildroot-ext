#!/usr/bin/env python
# coding: utf-8
from __future__ import unicode_literals, print_function, division, absolute_import

import tornado.ioloop
import tornado.autoreload
from tornado.log import app_log, enable_pretty_logging
from tornado.httpserver import HTTPServer
from tornado.options import define, options, parse_command_line

import remotecontrol.app

__author__ = 'svolkov'

define("host", default="", help="v2r remote control", type=str)
define("port", default=8888, help="run on the given port", type=int)
define("pipeline", default="", help="pipeline text file", type=str)

app = None

def main():
    parse_command_line()
    settings = dict(
        pipeline_file=options.pipeline
    )
    app = remotecontrol.app.Application(settings)
    options.logging = str('DEBUG')
    enable_pretty_logging()
    server = HTTPServer(app)
    server.listen(options.port, options.host)
    app_log.info("Listen on http://%s:%d/" % (
        options.host if options.host != "" else "localhost",
        options.port)
    )
    # app.processor.start()
    second_tick = None
    try:
        tornado.autoreload.add_reload_hook(app.manager.stop)
        second_tick = tornado.ioloop.PeriodicCallback(lambda: app.second_tick(), 1000)
        second_tick.start()
        tornado.ioloop.IOLoop.instance().start()
    except KeyboardInterrupt:
        second_tick.stop()
        app_log.info("stop second tick")
        app.manager.stop()
        tornado.ioloop.IOLoop.instance().stop()
    app_log.debug("Server shutdown.")

if __name__ == '__main__':
    main()
