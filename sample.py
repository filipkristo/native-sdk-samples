#!/usr/bin/python

from ctypes import *
import time

dz_onevent_cb = CFUNCTYPE(c_int, c_void_p, c_void_p, c_void_p)
dz_connect_crash_reporting_delegate = CFUNCTYPE(c_bool)
void_func = CFUNCTYPE(None, c_void_p)
activation_count = 0


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


def player_event_cb(dz_connect_handle, dz_connect_event_handle, delegate):
    print "I am the player event callback"
    return 1


def main():
    global activation_count
    # Load libdeezer
    libdeezer = cdll.LoadLibrary("libdeezer.so")
    # Identifiers
    user_access_token = "fru8j4CtsuhoUkO5SXVxW3bZyMzlbZq1rbnCPPTVVkHHtNcDrtG"  # SET your user access token
    your_application_id = "190262"  # SET your application id
    your_application_name = "PythonSampleApp"  # SET your application name
    your_application_version = "00001"  # SET your application version
    # TODO: WIN32 cache path
    user_cache_path = "/var/tmp/dzrcache_NDK_SAMPLE"  # SET the user cache path, the path must exist

    def connect_cb(a, b, c):
        print "I am the connect callback"
        return 0

    def error_cb():
        print "I am the error callback"
        return 0

    config = dz_connect_configuration(
        your_application_id,
        your_application_name,
        your_application_version,
        user_cache_path,
        c_void_p(0),
        c_void_p(0),
        c_void_p(0)
    )

    connect_handle = libdeezer.dz_connect_new(byref(config))
    if not connect_handle:
        print "Deezer connect handle was not initialized properly."
        return 1
    print "Device ID:", libdeezer.dz_connect_get_device_id(connect_handle)
    """
    connect = libdeezer.dz_connect_debug_log_disable(connect_handle)
    if connect != 0:
        print "Failed to activate connection"
    """
    connect = libdeezer.dz_connect_activate(connect_handle, None)
    if connect != 0:
        print "Failed to activate connection"
    activation_count += 1
    libdeezer.dz_connect_cache_path_set(connect_handle, None, None, c_char_p(user_cache_path))
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
    if connect != 0:
        print "Failed to connect offline mode"
    connect = libdeezer.dz_player_load(player, None, None, "dzmedia:///track/3135556")
    if connect != 0:
        print "Failed to connect offline mode"
    connect = libdeezer.dz_player_play(player, None, None, 1, 1, 0)
    while 1:
        time.sleep(0.001)
    return 0


if __name__ == "__main__":
    main()
