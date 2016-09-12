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
        self.debug_mode = False
        self.player = None

    def initialize_connection(self, event_callback, debug_mode=False):
        self.debug_mode = debug_mode
        self.connection.set_event_callback(event_callback)
        self.connection.init_handle()
        if not debug_mode:
            self.connection.debug_log_disable()
        print "Device ID:", self.connection.get_device_id()

    def activate_connection(self, user_access_token):
        self.connection.activate()
        self.connection.cache_path_set(self.connection.user_profile_path)  # TODO: ask if user cache path here is sometimes different than in MDA
        self.connection.set_access_token(user_access_token)
        self.connection.connect_offline_mode()  # Required

    def initialize_player(self, event_callback=None):
        self.player = Player(self.connection)
        self.player.set_event_cb(event_callback)

    def activate_player(self, track=None):
        self.player.current_track = track
        self.player.activate()

    def start_player(self):
        self.player.load()
        self.player.play()

    def log(self, message):
        if self.debug_mode:
            print message
