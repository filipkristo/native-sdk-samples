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


def init_connection(connection_info):
    """Initialize connection info and return the connection handler"""
    # TODO: See ConnectionInfo TODO
    config = dz_connect_configuration(
        c_char_p(connection_info.app_id),
        c_char_p(connection_info.product_id),
        c_char_p(connection_info.product_build_id),
        c_char_p(connection_info.user_profile_path),
        c_void_p(connection_info.dz_connect_onevent_cb),
        c_void_p(connection_info.anonymous_blob),
        c_void_p(connection_info.dz_connect_crash_reporting_delegate)
    )
    connect_handle = libdeezer.dz_connect_new(byref(config))
    if not connect_handle:
        pass  # TODO: Error
    return connect_handle


def get_device_id(connect_handle):
    return libdeezer.dz_connect_get_device_id(connect_handle)


def debug_log_disable(connect_handle):
    if libdeezer.dz_connect_debug_log_disable(connect_handle):
        pass  # TODO: Error


# TODO: handle user_data c cast
def connection_activate(connect_handle, user_data=None):
    error = libdeezer.dz_connect_activate(connect_handle, user_data)
    if error:
        pass  # TODO: Error


# TODO: handle last two args c cast
def connection_cache_path_set(connect_handle, user_cache_path, activity_operation_cb=None, operation_userdata=None):
    libdeezer.dz_connect_cache_path_set(connect_handle, activity_operation_cb, operation_userdata,
                                        c_char_p(user_cache_path))


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
    connect_handle = init_connection(config)
    print "Device ID:", get_device_id(connect_handle)
    debug_log_disable(connect_handle)
    connection_activate(connect_handle)
    connection_cache_path_set()
    player = libdeezer.dz_player_new(connect_handle)
    print type(player)
    if not player:
        print "Player null"
    connect = libdeezer.dz_player_activate(player, None)
    if connect != 0:
        print "Failed to activate player"
    connect = libdeezer.dz_player_set_event_cb(player, dz_onevent_cb(connect_cb))
    if connect != 0:
        print "Failed to set event callback"
    connect = libdeezer.dz_connect_set_access_token(connect_handle, None, None, c_char_p(user_access_token))
    if connect != 0:
        print "Failed to set access token"
    connect = libdeezer.dz_connect_offline_mode(connect_handle, None, None, c_bool(False))  # error callback
    time.sleep(2)  # wait for login (ugly)
    if connect != 0:
        print "Failed to connect offline mode"
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
