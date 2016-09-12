#!/usr/bin/python

import time
from myDeezerApp import *


def main():
    # Identifiers
    user_access_token = "frjBTxvKeNLpG0DgYc3yOtz1hMnwgFDL46RSZLQznAHoS2asXsG"  # SET your user access token
    your_application_id = "190262"  # SET your application id
    your_application_name = "PythonSampleApp"  # SET your application name
    your_application_version = "00001"  # SET your application version
    # TODO: WIN32 cache path
    user_cache_path = "/var/tmp/dzrcache_NDK_SAMPLE"  # SET the user cache path, the path must exist
    app = MyDeezerApp (
        your_application_id,
        your_application_name,
        your_application_version,
        user_cache_path,
        0, 0, 0
    )
    app.initialize(user_access_token, True)

    # TODO: Type of arguments ?
    def callback(handle, event, delegate):
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
                is_preview))
            log("\tcan_pause_unpause: "+str(can_pause_unpause.value)+" can_seek")  # TODO: fix log as printf
            if selected_dz_api_info:
                log("FIXME")
            if next_dz_api_info:
                log("FIXME")
            app.player.nb_tracks_played += 1
            return 0
        log("==== PLAYER_EVENT ==== "+events_codes[int(event_type)]+" for idx: "+str(idx.value))
        if events_codes[int(event_type)] == 'RENDER_TRACK_END':  # TODO: start new track by setting current track ?
            log("FIXME")
            if app.player.nb_tracks_played != -1 and app.player.nb_tracks_to_play == app.player.nb_tracks_played:
                app.player.shutdown()
            else:
                app.player.launch_play()
        return 0

    app.set_player_event_callback(callback)
    app.launch()
    time.sleep(2)  # wait for login (ugly) TODO: Add an event listener
    app.player.load("dzmedia:///track/85509044")
    app.player.play()
    while app.connection.active and app.player.active:
        time.sleep(0.001)
    return 0


def log(message):
    print message


if __name__ == "__main__":
    main()
