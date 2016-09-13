#!/usr/bin/python

import time
from myDeezerApp import *


def main():
    # Identifiers
    user_access_token = "frPFVLJ4QwRKtTe2e98jfLp0QYYx9d3ycZhQ2BpDmukn6E6TpoE"  # SET your user access token
    your_application_id = "190262"  # SET your application id
    your_application_name = "PythonSampleApp"  # SET your application name
    your_application_version = "00001"  # SET your application version
    # TODO: WIN32 cache path
    user_cache_path = "/var/tmp/dzrcache_NDK_SAMPLE"  # SET the user cache path, the path must exist
    app = MyDeezerApp(
        your_application_id,
        your_application_name,
        your_application_version,
        user_cache_path,
        0, 0, 0
    )

    # TODO: Type of arguments ?
    def player_event_callback(handle, event, delegate):
        event_names = [
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
        event_type = int(libdeezer.dz_player_event_get_type(c_void_p(event)))
        if not libdeezer.dz_player_event_get_playlist_context(c_void_p(event), byref(streaming_mode), byref(idx)):
            streaming_mode = "FIXME"  # TODO: Add streaming_mode enum
            idx = -1
        if event_type == PlayerEvent.PLAYLIST_TRACK_SELECTED:
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
            app.log("==== PLAYER_EVENT ==== {0} for idx: {1} - is_preview: {2}"
                    .format(event_names[event_type], idx.value, is_preview))
            app.log("\tcan_pause_unpause: {0} - can_seek: {1}"
                    .format(can_pause_unpause.value, can_seek.value))
            if selected_dz_api_info:
                app.log("\tnow:{0}".format(selected_dz_api_info))
            if next_dz_api_info:
                app.log("\tnext:{0}".format(next_dz_api_info))
            app.player.nb_tracks_played += 1
            return 0
        app.log("==== PLAYER_EVENT ==== {0} for idx: {1}".format(event_names[event_type], idx.value))
        if event_type == PlayerEvent.RENDER_TRACK_END:  # TODO: start new track by setting current track ?
            app.log("\tnb_track_to_play: {0}\tnb_track_played: {1}"
                    .format(app.player.nb_tracks_to_play, app.player.nb_tracks_played))
            if app.player.nb_tracks_played != -1 and app.player.nb_tracks_to_play == app.player.nb_tracks_played:
                app.player.shutdown()
            else:
                app.player.launch_play()
        if event_type == PlayerEvent.PLAYLIST_NEED_NATURAL_NEXT:
            app.player.launch_play()
        return 0

    def connection_event_callback(handle, event, delegate):
        event_names = [
            'UNKNOWN',
            'USER_OFFLINE_AVAILABLE',
            'USER_ACCESS_TOKEN_OK',
            'USER_ACCESS_TOKEN_FAILED',
            'USER_LOGIN_OK',
            'USER_LOGIN_FAIL_NETWORK_ERROR',
            'USER_LOGIN_FAIL_BAD_CREDENTIALS',
            'USER_LOGIN_FAIL_USER_INFO',
            'USER_LOGIN_FAIL_OFFLINE_MODE',
            'USER_NEW_OPTIONS',
            'ADVERTISEMENT_START',
            'ADVERTISEMENT_STOP'
        ]
        event_type = int(libdeezer.dz_player_event_get_type(c_void_p(event)))
        app.log("++++ CONNECT_EVENT ++++ {0}".format(event_names[event_type]))
        if event_type == ConnectionEvent.USER_LOGIN_OK:
            app.start_player()
        return 0

    app.initialize_connection(connection_event_callback, True)
    app.activate_connection(user_access_token)
    app.initialize_player(player_event_callback)
    app.activate_player("dzmedia:///track/85509044")
    while app.connection.active and app.player.active:
        time.sleep(1)
    return 0


if __name__ == "__main__":
    main()
