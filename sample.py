#!/usr/bin/python

from ctypes import *

dz_connect_onevent_cb = CFUNCTYPE(c_int, c_void_p, c_void_p, c_void_p)
dz_connect_crash_reporting_delegate = CFUNCTYPE(c_bool)


class dz_connect_configuration(Structure):
    _pack_ = 1
    _fields_ = [
        ("app_id", c_char_p),
        ("product_id", c_char_p),
        ("product_build_id", c_char_p),
        ("user_profile_path", c_char_p),
        ("dz_connect_onevent_cb", dz_connect_onevent_cb),
        ("anonymous_blob", c_void_p),
        ("dz_connect_crash_reporting_delegate", dz_connect_crash_reporting_delegate)
    ]


def main():
    # Load libdeezer
    libdeezer = cdll.LoadLibrary("libdeezer.so")
    # Identifiers
    user_access_token = "fr7lsinjmGav61VobUVyzKhyFpMGzyoGRycxWl43CtldDWuOSf5"  # SET your user access token
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
        return False

    config = dz_connect_configuration(
        your_application_id,
        your_application_name,
        your_application_version,
        user_cache_path,
        dz_connect_onevent_cb(connect_cb),
        c_void_p(0),
        dz_connect_crash_reporting_delegate(error_cb)
    )

    connect_handle = libdeezer.dz_connect_new(byref(config))
    if not connect_handle:
        print "Deezer connect handle was not initialized properly."
        return 1
    print "Device ID:", libdeezer.dz_connect_get_device_id(connect_handle)
    connect = libdeezer.dz_connect_activate(connect_handle, None)
    if connect != 0:
        print "Failed to activate connection"
    libdeezer.dz_connect_cache_path_set(connect_handle, None, None, c_char_p(user_cache_path))
    player = libdeezer.dz_player_new(connect_handle)
    connect = libdeezer.dz_player_activate(player, None)  # not init
    if connect != 0:
        print "Failed to activate player"
    connect = libdeezer.dz_player_set_event_cb(player, dz_connect_onevent_cb(connect_cb))
    if connect != 0:
        print "Failed to set event callback"
    connect = libdeezer.dz_connect_set_access_token(connect_handle, None, None, c_char_p(user_access_token))
    if connect != 0:
        print "Failed to set access token"
    connect = libdeezer.dz_connect_offline_mode(connect_handle, None, None, c_bool(False))
    if connect != 0:
        print "Failed to connect offline mode"
    connect = libdeezer.dz_player_load(player, None, None, "dzmedia:///track/3135556")
    if connect != 0:
        print "Failed to connect offline mode"
    connect = libdeezer.dz_player_play(player, None, None, 1, 1, 0)
    while 1:
        pass
    return 0


if __name__ == "__main__":
    main()
