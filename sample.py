#!/usr/bin/python

from player import *
from connection import *
import time

dz_on_event_cb_func = CFUNCTYPE(c_int, c_void_p, c_void_p, c_void_p)
dz_connect_crash_reporting_delegate_func = CFUNCTYPE(c_bool)
void_func = CFUNCTYPE(None, c_void_p)


def dummy_callback(a, b, c):
    print "Hi, I am the dummy callback :B"
    return 1


def main():
    # Identifiers
    user_access_token = "frw3mjDsQ6lgPBYDfKeGCv0j2XA3yycGurZil5r2zuuPtsXrh7s"  # SET your user access token
    your_application_id = "190262"  # SET your application id
    your_application_name = "PythonSampleApp"  # SET your application name
    your_application_version = "00001"  # SET your application version
    # TODO: WIN32 cache path
    user_cache_path = "/var/tmp/dzrcache_NDK_SAMPLE"  # SET the user cache path, the path must exist
    connection = Connection(
        your_application_id,
        your_application_name,
        your_application_version,
        user_cache_path,
        0,
        0,
        0
    )
    print "Device ID:", connection.get_device_id()
    # connection.debug_log_disable()
    connection.activate()
    connection.cache_path_set(user_cache_path)
    player = Player(connection)
    player.activate()
    player.set_event_cb(player.player_on_event_callback())
    connection.set_access_token(user_access_token)
    connection.connect_offline_mode()
    time.sleep(2)  # wait for login (ugly) TODO: Add an event listener
    player.load("dzmedia:///track/3135556")
    player.play()
    while connection.active and player.active:
        time.sleep(0.001)
    return 0


if __name__ == "__main__":
    main()
