#!/usr/bin/python

from ctypes import *
import time

dz_on_event_cb_func = CFUNCTYPE(c_int, c_void_p, c_void_p, c_void_p)
dz_connect_crash_reporting_delegate_func = CFUNCTYPE(c_bool)
void_func = CFUNCTYPE(None, c_void_p)
libdeezer = cdll.LoadLibrary("libdeezer.so")
nb_track_played = 0  # TODO: get rid of globals
nb_track_to_play = 1


class DZConnectConfiguration(Structure):
    _pack_ = 1
    _fields_ = [
        ("app_id", c_char_p),
        ("product_id", c_char_p),
        ("product_build_id", c_char_p),
        ("user_profile_path", c_char_p),
        ("dz_connect_on_event_cb", c_void_p),
        ("anonymous_blob", c_void_p),
        ("dz_connect_crash_reporting_delegate", c_void_p)
    ]


# TODO: Find an elegant way to do that
class Connection:
    def __init__(self,
                 app_id="",
                 product_id="",
                 product_build_id="",
                 user_profile_path="/var/tmp/dzrcache_NDK_SAMPLE",
                 dz_connect_on_event_cb=None,
                 anonymous_blob=None,
                 dz_connect_crash_reporting_delegate=None
                 ):
        self.app_id = app_id
        self.product_id = product_id
        self.product_build_id = product_build_id
        self.user_profile_path = user_profile_path
        self.dz_connect_on_event_cb = dz_connect_on_event_cb
        self.anonymous_blob = anonymous_blob
        self.dz_connect_crash_reporting_delegate = dz_connect_crash_reporting_delegate
        self.connect_handle = 0
        self.active = False
        self._init_handle()

    def _init_handle(self):
        """Initialize connection info and return the connection handler"""
        # TODO: See ConnectionInfo TODO
        config = DZConnectConfiguration(
            c_char_p(self.app_id),
            c_char_p(self.product_id),
            c_char_p(self.product_build_id),
            c_char_p(self.user_profile_path),
            c_void_p(self.dz_connect_on_event_cb),
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
        self.active = True

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

    def shutdown(self):
        if self.connect_handle:
            libdeezer.dz_connect_deactivate(self.connect_handle, c_void_p(0), None)
            self.active = False


class Player:
    def __init__(self, connection):
        self.connection = connection
        self.dz_player = 0
        self._dz_player_init()
        self.current_track = "dzmedia:///track/3135556"
        self.active = False

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
    def player_on_event_callback(self, handle, event, delegate):
        global nb_track_played
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
        type = libdeezer.dz_player_event_get_type(c_void_p(event))
        if not libdeezer.dz_player_event_get_playlist_context(c_void_p(event), byref(streaming_mode), byref(idx)):
            streaming_mode = "FIXME"  # TODO: Add streaming_mode enum
            idx = -1
        if events_codes[int(type)] == 'PLAYLIST_TRACK_SELECTED':
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
            log("==== PLAYER_EVENT ==== "+events_codes[int(type)]+" for idx: "+str(idx.value)+" - is_preview: "+str(
                is_preview.value))
            log("\tcan_pause_unpause:"+str(can_pause_unpause)+"can_seek")  # TODO: fix log as printf
            if selected_dz_api_info.value:
                log("FIXME")
            if next_dz_api_info.value:
                log("FIXME")
            nb_track_played += 1
            return 0
        log("==== PLAYER_EVENT ==== "+events_codes[int(type)]+" for idx: "+str(idx.value))
        if events_codes[int(type)] == 'RENDER_TRACK_END':  # TODO: start new track by setting current track ?
            log("FIXME")
            if nb_track_played != -1 and nb_track_to_play == nb_track_played:
                self.shutdown()
            else:
                self.launch_play()
        return 0

    def shutdown(self):
        log("FIXME")
        if self.dz_player:
            libdeezer.dz_player_deactivate(self.dz_player, c_void_p(0), None)
            self.active = False
        self.connection.shutdown()

    def launch_play(self):
        self.load()
        self.play()


def main():
    # Identifiers
    user_access_token = "frUQyHM7UjLP2lzMUR7gJjF20YUPNMQ47LeSqp3zsLRue2VKEs9"  # SET your user access token
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
    player.set_event_cb(player.player_on_event_callback)
    connection.set_access_token(user_access_token)
    connection.connect_offline_mode()
    """
    time.sleep(2)  # wait for login (ugly) TODO: Add an event listener
    player.load("dzmedia:///track/3135556")
    player.play()
    """
    while connection.active and player.active:
        time.sleep(0.001)
    return 0


def log(message):
    print message


if __name__ == "__main__":
    main()
