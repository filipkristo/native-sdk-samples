#!/usr/bin/python

from connection import *

libdeezer = cdll.LoadLibrary("libdeezer.so")

void_func = CFUNCTYPE(None, c_void_p)


class PlayerInitFailedError(Exception):
    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)


class PlayerRequestFailedError(Exception):
    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)


class PlayerActivationError(Exception):
    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)


class PlayerEvent:
    def __init__(self):
        pass

    (
        UNKNOWN,
        LIMITATION_FORCED_PAUSE,
        PLAYLIST_TRACK_NOT_AVAILABLE_OFFLINE,
        PLAYLIST_TRACK_NO_RIGHT,
        PLAYLIST_TRACK_RIGHTS_AFTER_AUDIOADS,
        PLAYLIST_SKIP_NO_RIGHT,
        PLAYLIST_TRACK_SELECTED,
        PLAYLIST_NEED_NATURAL_NEXT,
        MEDIASTREAM_DATA_READY,
        MEDIASTREAM_DATA_READY_AFTER_SEEK,
        RENDER_TRACK_START_FAILURE,
        RENDER_TRACK_START,
        RENDER_TRACK_END,
        RENDER_TRACK_PAUSED,
        RENDER_TRACK_SEEKING,
        RENDER_TRACK_UNDERFLOW,
        RENDER_TRACK_RESUMED,
        RENDER_TRACK_REMOVED
    ) = range(0, 18)


class Player:
    def __init__(self, connection):
        self.connection = connection
        self.dz_player = 0
        self._dz_player_init()
        self.current_track = "dzmedia:///track/3135556"
        self.active = False
        self.nb_tracks_played = 0
        self.nb_tracks_to_play = 1
        self._dz_player_init()

    def _dz_player_init(self):
        self.dz_player = libdeezer.dz_player_new(self.connection.connect_handle)
        if not self.dz_player:
            raise PlayerInitFailedError("Player failed to init. Check that connection is established.")

    def activate(self, supervisor=None):
        if libdeezer.dz_player_activate(self.dz_player, c_void_p(supervisor)):
            raise PlayerActivationError("Player activation failed. Check player info and your network connection.")
        self.active = True

    def set_event_cb(self, cb):
        if libdeezer.dz_player_set_event_cb(self.dz_player, dz_on_event_cb_func(cb)):
            raise PlayerRequestFailedError(
                "set_event_cb: Request failed. Check the given callback arguments and return types and/or the player.")

    def load(self, tracklist_data=None, activity_operation_cb=None, operation_user_data=None):
        if tracklist_data:
            self.current_track = tracklist_data
        if libdeezer.dz_player_load(self.dz_player, activity_operation_cb, operation_user_data,
                                    self.current_track):
            raise PlayerRequestFailedError("load: Unable to load selected track. Check connection and tracklist data.")

    def play(self, command=1, mode=1, index=0, activity_operation_cb=None, operation_user_data=None):
        if libdeezer.dz_player_play(self.dz_player, activity_operation_cb, operation_user_data,
                                    command, mode, index) not in range(0, 2):
            raise PlayerRequestFailedError("play: Unable to play selected track. Check player commands and info.")

    def shutdown(self):
        if self.dz_player:
            libdeezer.dz_player_deactivate(self.dz_player, c_void_p(0), None)
            self.active = False
        self.connection.shutdown()

    def launch_play(self):
        self.load()
        self.play()
