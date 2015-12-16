# coding: utf-8
from __future__ import unicode_literals, print_function, division, absolute_import

import json
import threading

__author__ = 'svolkov'


class Params(object):
    # manager status change from 0 -> 5
    NOT_CONNECTED = 0  # special state for disconnected clients
    CONNECTED = 1  # start state
    PREVIEW = 2  #
    CALIBRATING = 3  #
    CALIBRATED = 4  # calibrate process success
    READY = 5  # detect shot mode
    MESSAGES = [
        'Not Connected',
        'Connected',
        'Preview',
        'Calibrating',
        'Calibrated',
        'Ready'
    ]

    def __init__(self, app):
        self.app = app
        self.frame_lock = threading.Lock()
        self._frame = None  # frame, raw jpg
        self.sheet = None  # target sheet, raw jpg
        self.transform = None  # transformed target, raw jpg
        self.shot = None  # frame with detected shot raw jpg
                          # full or sheet size
        # state
        self.state = Params.CONNECTED  # default status
        # audio
        self.audio = True
        self.audio_volume = 0.05
        # camera params
        # self.detector_resolution = (800, 600)  # working: capture and detect
        # self.detector_resolution = (1024, 768)  # working: capture and detect
        self.detector_resolution = (1280, 960)  # working: capture and detect
        self.detector_resolution = (1296, 972)  # working: capture and detect
        self.detector_frame_rate = 20
        self.preview_resolution = (640, 480)
        self.preview_frame_rate = 10

        # target canvas
        # canvas size 800x800
        self.target_center = (200, 200)
        self.target_step = 18

        # self.reset_calibration()
        self.calibrated = False
        self.sheet_left_corner = (0, 0)
        self.sheet_size = (0, 0)
        self.matrix = None
        self.transform_contour = None
        self.transform_source = None
        self.transform_size = (0, 0)
        self.transform_center = (0, 0)
        self.transform_step = 0
        # last shot
        self.last_shot_hit = False
        self.last_shot = (0, 0)
        self.last_score = 0
        self.sheet_shot_center = (0, 0)
        self.transform_shot_center = (0, 0)

    def reset_calibration(self):
        # reset calibration
        # target calibrated params
        self.calibrated = False
        self.sheet_left_corner = (0, 0)
        self.sheet_size = (0, 0)
        self.matrix = None
        self.transform_contour = None
        self.transform_source = None
        self.transform_size = (0, 0)
        self.transform_center = (0, 0)
        self.transform_step = 0
        # last shot
        self.last_shot_hit = False
        self.last_shot = (0, 0)
        self.last_score = 0
        self.sheet_shot_center = (0, 0)
        self.transform_shot_center = (0, 0)
        # frame not cleaning - show last frame
        # self.frame = None

    @property
    def frame(self):
        # with self.frame_lock:
        img = self._frame
        return img

    @frame.setter
    def frame(self, value):
        # print("set_frame")
        # with self.frame_lock:
        self._frame = value

    def get_message(self):
        return Params.MESSAGES[self.state]

    def as_dict(self):
        """
        Prepare attributes for json serialization,
        exclude app reference, images and numpy arrays
        :return: dict
        """
        excludes = ('app',
                    '_frame', 'sheet', 'transform', 'shot', 'frame_lock',
                    'matrix', 'transform_contour', 'transform_source')
        res = {}
        for a in self.__dict__:
            if a not in excludes:
                res[a] = self.__getattribute__(a)
        res['state_message'] = Params.MESSAGES[self.state]
        return res

    def as_json(self):
        # print("as_json:", self.as_dict())
        return json.dumps(self.as_dict())
