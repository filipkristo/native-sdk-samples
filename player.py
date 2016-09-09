#!/usr/bin/python

from ctypes import *

libdeezer = cdll.LoadLibrary("libdeezer.so")


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

    # TODO: Type of arguments ?
    def player_on_event_callback(self):
        def sub(handle, event, delegate):
            print "Coucou"
            events_codes = [
                'UNKNOWN',
                'LIMITATION_FORCED_PAUSE',
                'PLAYLIST_TRACK_NOT_AVAILABLE_OFFLINE',
                'PLAYLIST_TRACK_NO_RIGHT',
                'PLAYLIST_TRACK_RIGHTS_AFTER_AUDIOADS',
                'PLAYLIST_SKIP_NO_RIGHT',
                'PLAYLIST_TRACK_SELECTED',
                'PLAYLIST_NEED_NATURAL_NEXT',
                'MEDIASTREAM_DATA_READY',
                'MEDIASTREAM_DATA_READY_AFTER_SEEK',
                'RENDER_TRACK_START_FAILURE',
                'RENDER_TRACK_START',
                'RENDER_TRACK_END',
                'RENDER_TRACK_PAUSED',
                'RENDER_TRACK_SEEKING',
                'RENDER_TRACK_UNDERFLOW',
                'RENDER_TRACK_RESUMED',
                'RENDER_TRACK_REMOVED'
            ]
            streaming_mode = c_int()
            idx = c_int()
            event_type = libdeezer.dz_player_event_get_type(c_void_p(event))
            if not libdeezer.dz_player_event_get_playlist_context(c_void_p(event), byref(streaming_mode), byref(idx)):
                streaming_mode = "FIXME"  # TODO: Add streaming_mode enum
                idx = -1
            if events_codes[int(event_type)] == 'PLAYLIST_TRACK_SELECTED':
                can_pause_unpause = c_bool()
                can_seek = c_bool()
                no_skip_allowed = c_int()
                next_dz_api_info = c_char_p()
                is_preview = libdeezer.dz_player_event_track_selected_is_preview(c_void_p(event))
                libdeezer.dz_player_event_track_selected_rights(
                    c_void_p(event),
                    byref(can_pause_unpause),
                    byref(can_seek),
                    byref(no_skip_allowed)
                )
                selected_dz_api_info = libdeezer.dz_player_event_track_selected_dzapiinfo(c_void_p(event))
                next_dz_api_info = libdeezer.dz_player_event_track_selected_next_track_dzapiinfo(c_void_p(event))
                log("==== PLAYER_EVENT ==== "+events_codes[int(event_type)]+" for idx: "+str(idx.value)+" - is_preview: "+str(
                    is_preview.value))
                log("\tcan_pause_unpause:"+str(can_pause_unpause)+"can_seek")  # TODO: fix log as printf
                if selected_dz_api_info.value:
                    log("FIXME")
                if next_dz_api_info.value:
                    log("FIXME")
                self.nb_tracks_played += 1
                return 0
            log("==== PLAYER_EVENT ==== "+events_codes[int(event_type)]+" for idx: "+str(idx.value))
            if events_codes[int(event_type)] == 'RENDER_TRACK_END':  # TODO: start new track by setting current track ?
                log("FIXME")
                if self.nb_tracks_played != -1 and self.nb_tracks_to_play == self.nb_tracks_played:
                    self.shutdown()
                else:
                    self.launch_play()
            return 0
        return sub

    def shutdown(self):
        log("FIXME")
        if self.dz_player:
            libdeezer.dz_player_deactivate(self.dz_player, c_void_p(0), None)
            self.active = False
        self.connection.shutdown()

    def launch_play(self):
        self.load()
        self.play()

    def log(self, message):
        print message

