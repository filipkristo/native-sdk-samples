#!/usr/bin/python

from connection import *

libdeezer = cdll.LoadLibrary("libdeezer.so")

dz_on_event_cb_func = CFUNCTYPE(c_int, c_void_p, c_void_p, c_void_p)
dz_connect_crash_reporting_delegate_func = CFUNCTYPE(c_bool)
void_func = CFUNCTYPE(None, c_void_p)


class Player:
    def __init__(self, connection):
        self.connection = connection
        self.dz_player = 0
        self._dz_player_init()
        self.current_track = "dzmedia:///track/3135556"
        self.active = False
        self.nb_tracks_played = 0
        self.nb_tracks_to_play = 1

    def _dz_player_init(self):
        self.dz_player = libdeezer.dz_player_new(self.connection.connect_handle)
        if not self.dz_player:
            pass  # TODO: Error

    # TODO: handle supervisor argument type
    def activate(self, supervisor=None):
        if libdeezer.dz_player_activate(self.dz_player, c_void_p(supervisor)):
            pass  # TODO: Error
        self.active = True

    def set_event_cb(self, cb):
        if libdeezer.dz_player_set_event_cb(self.dz_player, dz_on_event_cb_func(cb)):
            pass  # TODO: Error

    def load(self, tracklist_data=None, activity_operation_cb=None, operation_user_data=None):
        if tracklist_data:
            self.current_track = tracklist_data
        if libdeezer.dz_player_load(self.dz_player, activity_operation_cb, operation_user_data,
                                    self.current_track):
            pass  # TODO: Error

    def play(self, command=1, mode=1, index=0, activity_operation_cb=None, operation_user_data=None):
        if libdeezer.dz_player_play(self.dz_player, activity_operation_cb, operation_user_data,
                                    command, mode, index):
            pass  # TODO: Error

    def shutdown(self):
        # log("FIXME")
        if self.dz_player:
            libdeezer.dz_player_deactivate(self.dz_player, c_void_p(0), None)
            self.active = False
        self.connection.shutdown()

    def launch_play(self):
        self.load()
        self.play()

