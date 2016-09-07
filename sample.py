#!/usr/bin/python

from ctypes import *

dz_connect_onevent_cb = CFUNCTYPE(c_int, c_void_p, c_void_p, c_void_p)
dz_connect_crash_reporting_delegate = CFUNCTYPE(c_bool)


class dz_connect_configuration(Structure):
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
    user_access_token = "FIXME"  # SET your user access token
    your_application_id = "FIXME"  # SET your application id
    your_application_name = "FIXME"  # SET your application name
    your_application_version = "FIXME"  # SET your application version
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
<<<<<<< 017f697f71a04fce59b0fbade02998b7d8b181f1
    libdeezer.dz_connect_new(config)
=======
    toto = libdeezer.dz_connect_new(byref(config))
    if not toto:
        print "Oups"
>>>>>>> Establish connection with api


if __name__ == "__main__":
    main()
