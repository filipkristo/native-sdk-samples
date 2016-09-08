#!/usr/bin/python

from ctypes import *
import time

dz_onevent_cb = CFUNCTYPE(c_int, c_void_p, c_void_p, c_void_p)
dz_connect_crash_reporting_delegate = CFUNCTYPE(c_bool)
void_func = CFUNCTYPE(None, c_void_p)
activation_count = 0
libdeezer = cdll.LoadLibrary("libdeezer.so")


class dz_connect_configuration(Structure):
    _pack_ = 1
    _fields_ = [
        ("app_id", c_char_p),
        ("product_id", c_char_p),
        ("product_build_id", c_char_p),
        ("user_profile_path", c_char_p),
        ("dz_connect_onevent_cb", c_void_p),
        ("anonymous_blob", c_void_p),
        ("dz_connect_crash_reporting_delegate", c_void_p)
    ]


# TODO: Find an elegant way to do that
class ConnectionInfo:
    def __init__(self,
                 app_id = "",
                 product_id = "",
                 product_build_id = "",
                 user_profile_path = "/var/tmp/dzrcache_NDK_SAMPLE",
                 dz_connect_onevent_cb = None,
                 anonymous_blob = None,
                 dz_connect_crash_reporting_delegate = None
                 ):
        self.app_id = app_id
        self.product_id = product_id
        self.product_build_id = product_build_id
        self.user_profile_path = user_profile_path
        self.dz_connect_onevent_cb = dz_connect_onevent_cb
        self.anonymous_blob = anonymous_blob
        self.dz_connect_crash_reporting_delegate = dz_connect_crash_reporting_delegate
        self.connect_handle = 0
        self._init_handle()

    def _init_handle(self):
        """Initialize connection info and return the connection handler"""
        # TODO: See ConnectionInfo TODO
        config = dz_connect_configuration(
            c_char_p(self.app_id),
            c_char_p(self.product_id),
            c_char_p(self.product_build_id),
            c_char_p(self.user_profile_path),
            c_void_p(self.dz_connect_onevent_cb),
            c_void_p(self.anonymous_blob),
            c_void_p(self.dz_connect_crash_reporting_delegate)
        )
        self.connect_handle = libdeezer.dz_connect_new(byref(config))
        if not self.connect_handle:
            pass  # TODO: Error

    def get_device_id(self):
        return libdeezer.dz_connect_get_device_id(self.connect_handle)

    def debug_log_disable(self):
        if libdeezer.dz_connect_debug_log_disable(self.connect_handle):
            pass  # TODO: Error

    # TODO: handle user_data c cast
    def activate(self, user_data=None):
        error = libdeezer.dz_connect_activate(self.connect_handle, user_data)
        if error:
            pass  # TODO: Error

    # TODO: handle last two args c cast
    def cache_path_set(self, user_cache_path, activity_operation_cb=None, operation_userdata=None):
        libdeezer.dz_connect_cache_path_set(self.connect_handle, activity_operation_cb, operation_userdata,
                                            c_char_p(user_cache_path))

    # TODO: handle last two args c cast
    def set_access_token(self, user_access_token, activity_operation_cb=None, operation_user_data=None):
        if libdeezer.dz_connect_set_access_token(self.connect_handle, activity_operation_cb,
                                                 operation_user_data, c_char_p(user_access_token)):
            pass  # TODO: Error

    def connect_offline_mode(self, activity_operation_cb=None, operation_userdata=None, offline_mode_forced=False):
        if libdeezer.dz_connect_offline_mode(self.connect_handle, activity_operation_cb,
                                             operation_userdata, c_bool(offline_mode_forced)):
            pass  # TODO: Error


class Player:
    def __init__(self, connect_handle):
        self.connect_handle = connect_handle
        self.dz_player = 0
        self._dz_player_init()

    def _dz_player_init(self):
        self.dz_player = libdeezer.dz_player_new(self.connect_handle)
        if not self.dz_player:
            pass  # TODO: Error

    # TODO: handle supervisor argument type
    def activate(self, supervisor=None):
        if libdeezer.dz_player_activate(self.dz_player, c_void_p(supervisor)):
            pass  # TODO: Error

    def set_event_cb(self, cb):
        if libdeezer.dz_player_set_event_cb(self.dz_player, dz_onevent_cb(cb)):
            pass  # TODO: Error


def player_event_cb(dz_connect_handle, dz_connect_event_handle, delegate):
    print "I am the player event callback"
    return 1


def main():
    global activation_count
    # Load libdeezer
    # Identifiers
    user_access_token = "frqsykQXDPpOXbcq1u9B3PQ2q8DwM1JbjqfSFExSgsfgaY7ZuQj"  # SET your user access token
    your_application_id = "190262"  # SET your application id
    your_application_name = "PythonSampleApp"  # SET your application name
    your_application_version = "00001"  # SET your application version
    # TODO: WIN32 cache path
    user_cache_path = "/var/tmp/dzrcache_NDK_SAMPLE"  # SET the user cache path, the path must exist
    config = ConnectionInfo(
        your_application_id,
        your_application_name,
        your_application_version,
        user_cache_path,
        0,
        0,
        0
    )
    print "Device ID:", config.get_device_id()
    config.debug_log_disable()
    config.activate()
    config.cache_path_set(user_cache_path)
    player = Player(config.connect_handle)  # TODO: Getter ?
    player.activate()
    player.set_event_cb(player_event_cb)
    config.set_access_token(user_access_token)
    config.connect_offline_mode()
    time.sleep(2)  # wait for login (ugly)
    connect = libdeezer.dz_player_load(player, None, None, "dzmedia:///track/3135556")
    if connect != 0:
        print "Failed to connect offline mode"
    connect = libdeezer.dz_player_play(player, None, None, 1, 1, 0)
    if connect != 0:
        print "Failed to play song"
    while 1:
        time.sleep(0.001)
    return 0


if __name__ == "__main__":
    main()
