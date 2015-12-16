# coding: utf-8
from __future__ import unicode_literals, print_function, division, absolute_import, with_statement

import logging

from concurrent.futures import ThreadPoolExecutor
from tornado.log import app_log
from tornado.ioloop import IOLoop

# load libgstpipeapp
import ctypes as ct
try:
    _lib = ct.CDLL('libgstpipeapp.so')
except OSError:
    _lib = ct.CDLL('lib/libgstpipeapp.dylib')

__author__ = 'svolkov'

CAPTURE_DIR = "captures"


def callback(size, buffer, app):
    # app_log.debug("Size: %i", size)
    # copy buffer and send to the clients
    pbuffer = ct.cast(buffer, ct.POINTER(ct.c_ubyte))
    # bytes - make array
    # frame = bytes(pbuffer[:size])
    frame1 = ct.create_string_buffer(size)
    ct.memmove(frame1, pbuffer, size)
    # lambda: add_callback <- need function without params
    IOLoop.current().add_callback(lambda: app.send_ws_message(frame1.raw, True))
    return 0


class GstreamerManager(object):
    def __init__(self, app):
        self.app = app
        self.params = app.params
        self._played = False

        # init pipeline
        pipeline = None
        if app.settings['pipeline_file'] != "":
            pipeline = app.settings['pipeline']
        _lib.pipeapp_init(ct.create_string_buffer(pipeline))

        # frame callback
        CALLBACKFUNC = ct.CFUNCTYPE(ct.c_int, ct.c_int, ct.c_void_p, ct.py_object)
        self.my_callback = CALLBACKFUNC(callback)
        _lib.pipeapp_set_callback(self.my_callback, ct.py_object(app))

        # thread_pool
        self._thread_pool = ThreadPoolExecutor(4)
        app_log.debug("GstreamerManager initialized")

    def start(self):
        app_log.debug("GstreamerManager: start flow")
        _lib.pipeapp_start()
        self._played = True

    def stop(self):
        app_log.debug("GstreamerManager: stop")
        _lib.pipeapp_stop()
        self._played = False

    def preview_toggle(self):
        if self._played:
            self.stop()
        else:
            self.start()

