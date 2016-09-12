#!/usr/bin/python

from player import *
from connection import *


class MyDeezerApp(object):
    def __init__(self,
                 app_id="",
                 product_id="",
                 product_build_id="",
                 user_profile_path="/var/tmp/dzrcache_NDK_SAMPLE",
                 dz_connect_on_event_cb=None,
                 anonymous_blob=None,
                 dz_connect_crash_reporting_delegate=None
    ):
        self.connection = Connection(app_id, product_id, product_build_id, user_profile_path,
                                     dz_connect_on_event_cb, anonymous_blob, dz_connect_crash_reporting_delegate)
        self.player = Player(self.connection)
        self.debug_mode = False

    def initialize_connection(self, user_access_token, debug_mode=False):
        self.debug_mode = debug_mode
        if not debug_mode:
            self.connection.debug_log_disable()
        self.connection.activate()
        self.connection.cache_path_set(self.connection.user_profile_path)  # TODO: ask if user cache path here is sometimes different than in MDA
        self.connection.set_access_token(user_access_token)
        self.connection.connect_offline_mode()  # Required
        print "Device ID:", self.connection.get_device_id()

    def launch_player(self, event_callback=None, track=None):
        self.player.set_event_cb(event_callback)
        self.player.current_track = track
        self.player.activate()

    def log(self, message):
        if self.debug_mode:
            print message
