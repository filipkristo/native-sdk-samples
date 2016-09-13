#!/usr/bin/python

from player import *
from connection import *


class MyDeezerApp(object):
    """A simple deezer application using NativeSDK

    Initialize a connection and a player, then load and play a song.

    Attributes:
        connection  A Connection instance to store connection info
        player      A Player instance to store the player's data
        debug_mode  When True displays event and API logs
    """

    def __init__(self,
                 app_id="",
                 product_id="",
                 product_build_id="",
                 user_profile_path="/var/tmp/dzrcache_NDK_SAMPLE",
                 dz_connect_on_event_cb=None,
                 anonymous_blob=None,
                 dz_connect_crash_reporting_delegate=None
                 ):
        """
        :param app_id: The ID of the application
        :type app_id: str
        :param product_id: The name of your application
        :type product_id: str
        :param product_build_id: The version number
        :type product_build_id: str
        :param user_profile_path: The cache path of the user. Deprecated.
        :type user_profile_path: str
        :param dz_connect_on_event_cb: The event listener to connection operations
        :param anonymous_blob: Deprecated
        :param dz_connect_crash_reporting_delegate: The error callback
        """
        self.connection = Connection(app_id, product_id, product_build_id, user_profile_path,
                                     dz_connect_on_event_cb, anonymous_blob, dz_connect_crash_reporting_delegate)
        self.debug_mode = False
        self.player = None

    def initialize_connection(self, event_callback, debug_mode=False):
        """
        Set up connection
        :param event_callback: The event listener triggered when the connection
            state change.
        :param debug_mode: Set to true to mute API and callback logs.
        """
        self.debug_mode = debug_mode
        self.connection.set_event_cb(event_callback)
        self.connection.init_handle()
        if not debug_mode:
            self.connection.debug_log_disable()
        print "Device ID:", self.connection.get_device_id()

    def activate_connection(self, user_access_token):
        """
        Activate the connection. Must be used after initialization.
        :param user_access_token: The token given by OAuth 2 process.
            Refer to the API documentation.
        """
        self.connection.activate()
        self.connection.cache_path_set(self.connection.user_profile_path)
        self.connection.set_access_token(user_access_token)
        self.connection.connect_offline_mode()  # Required

    def initialize_player(self, event_callback=None):
        """
        Set up the player
        :param event_callback: The event listener triggered when the connection
            state change.
        """
        self.player = Player(self.connection)
        self.player.set_event_cb(event_callback)

    def activate_player(self, track=None):
        """
        Activate the player. Must be used after calling initialize_player
        Sets the track that will be played using start_player.
        :param track: The track to be played.
        """
        self.player.current_track = track
        self.player.activate()

    def start_player(self):
        """
        Load the current track and play it.
        """
        self.player.load()
        self.player.play()

    def log(self, message):
        """
        Print a log message unless debug_mode is False
        :param message: The message to display
        """
        if self.debug_mode:
            print message
