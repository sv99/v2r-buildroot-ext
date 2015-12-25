# coding: utf-8
from __future__ import unicode_literals, print_function, division, absolute_import

import os
import re

__author__ = 'svolkov'

PREFIXES = dict(
    KEY_POWER="-c 2"
)


class Remote:
    def __init__(self):
        self.name = ""
        self.keys = {}

    def get_pulses(self, key):
        result = ""
        if key in PREFIXES:
            result += PREFIXES[key] + " "
        return result + self.keys[key]

    def __getitem__(self, item):
        return self.keys[item]

    def __setitem__(self, key, value):
        self.keys[key] = value

    def __len__(self):
        return len(self.keys)


START_STATE = 0
REMOTE_STATE = 1
RAW_CODES_STATE = 2
KEY_STATE = 3


class ConfigReader:
    def __init__(self, dir_name):
        self.dir_name = dir_name
        self.confs = [f for f in os.listdir(dir_name)
                      if os.path.splitext(f)[1] == ".conf"]
        self.remotes = {}

    def parse(self):
        for c in self.confs:
            self._read_conf(c)

    def _read_conf(self, conf):
        conf_path = os.path.join(self.dir_name, conf)
        state = START_STATE
        # name = ""
        # keys = {}
        remoute = Remote()
        with open(conf_path, 'r') as f:
            name_re = re.compile('name\s+(\w+)')
            key = ""

            for line in f.read().splitlines():
                line = line.strip()
                # comments
                if line != "" and line[0] == '#':
                    continue

                if state == START_STATE:
                    if line.count("begin remote") > 0:
                        state = REMOTE_STATE
                elif state == REMOTE_STATE:
                    if line.count("begin raw_codes") > 0:
                        state = RAW_CODES_STATE
                    elif line.count("name") > 0:
                        n = name_re.search(line)
                        if n is not None:
                            remoute.name = n.group(1)
                    elif line.count("end remote") > 0:
                        state = START_STATE

                elif state == RAW_CODES_STATE:
                    if line.count("name") > 0:
                        state = KEY_STATE
                        n = name_re.search(line)
                        if n is not None:
                            key = n.group(1)
                            remoute[key] = ""
                    elif line.count("end raw_codes") > 0:
                        state = REMOTE_STATE

                elif state == KEY_STATE:
                    if line == "":
                        state = RAW_CODES_STATE
                        key = ""
                    else:
                        if remoute[key] != "":
                            remoute[key] += " "
                        remoute[key] += self._split_pulses(line)
        self.remotes[remoute.name] = remoute
        print("%s keys: %i" % (remoute.name, len(remoute.keys)))

    @staticmethod
    def _split_pulses(line):
        pulses = line.strip().split()
        result = ""
        for p in pulses:
            if result != "":
                result += " "
            result += p.strip()
        return result
