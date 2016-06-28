//
//  DZRPlayerManager.m
//  OfflineModePlayer
//
//  Created by Cyril Picheney on 13/06/2016.
//  Copyright © 2016 Cyril Picheney. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DZRPlayerManager.h"
#import "deezer-player.h"

@interface DZRPlayerManager ()
{
    dz_player_handle dzPlayer;
}

@end

@implementation DZRPlayerManager

void app_player_onevent_cb(dz_player_handle       handle,
                           dz_player_event_handle event,
                           void *                 supervisor)
{
    dz_streaming_mode_t  streaming_mode;
    dz_index_in_playlist idx;
    
    dz_player_event_t type = dz_player_event_get_type(event);
    
    if (!dz_player_event_get_playlist_context(event, &streaming_mode, &idx)) {
        streaming_mode = DZ_STREAMING_MODE_ONDEMAND;
        idx = -1;
    }
    
    switch (type) {
        case DZ_PLAYER_EVENT_LIMITATION_FORCED_PAUSE:
            DebugLog(@"==== PLAYER_EVENT ==== LIMITATION_FORCED_PAUSE for idx: %d", idx);
            break;
            
        case DZ_PLAYER_EVENT_PLAYLIST_TRACK_NO_RIGHT:
            DebugLog(@"==== PLAYER_EVENT ==== PLAYLIST_TRACK_NO_RIGHT for idx: %d", idx);
            break;
            
        case DZ_PLAYER_EVENT_PLAYLIST_NEED_NATURAL_NEXT:
            DebugLog(@"==== PLAYER_EVENT ==== PLAYLIST_NEED_NATURAL_NEXT for idx: %d", idx);
            ///app_launch_play();
            break;
            
        case DZ_PLAYER_EVENT_PLAYLIST_TRACK_NOT_AVAILABLE_OFFLINE:
            DebugLog(@"==== PLAYER_EVENT ==== PLAYLIST_TRACK_NOT_AVAILABLE_OFFLINE for idx: %d", idx);
            break;
            
        case DZ_PLAYER_EVENT_PLAYLIST_TRACK_RIGHTS_AFTER_AUDIOADS:
            DebugLog(@"==== PLAYER_EVENT ==== PLAYLIST_TRACK_RIGHTS_AFTER_AUDIOADS for idx: %d", idx);
            ///dz_player_play_audioads(dzplayer, NULL, NULL);
            break;
            
        case DZ_PLAYER_EVENT_PLAYLIST_SKIP_NO_RIGHT:
            DebugLog(@"==== PLAYER_EVENT ==== PLAYLIST_SKIP_NO_RIGHT for idx: %d", idx);
            break;
            
        case DZ_PLAYER_EVENT_PLAYLIST_TRACK_SELECTED:
        {
            bool is_preview;
            bool can_pause_unpause;
            bool can_seek;
            int  nb_skip_allowed;
            const char *selected_dzapiinfo;
            const char *next_dzapiinfo;
            
            is_preview = dz_player_event_track_selected_is_preview(event);
            
            dz_player_event_track_selected_rights(event, &can_pause_unpause, &can_seek, &nb_skip_allowed);
            
            selected_dzapiinfo = dz_player_event_track_selected_dzapiinfo(event);
            next_dzapiinfo = dz_player_event_track_selected_next_track_dzapiinfo(event);
            
            DebugLog(@"==== PLAYER_EVENT ==== PLAYLIST_TRACK_SELECTED for idx: %d - is_preview:%d", idx, is_preview);
            DebugLog(@"\tcan_pause_unpause:%d can_seek:%d nb_skip_allowed:%d", can_pause_unpause, can_seek, nb_skip_allowed);
            if (selected_dzapiinfo)
                DebugLog(@"\tnow:%s", selected_dzapiinfo);
            if (next_dzapiinfo)
                DebugLog(@"\tnext:%s", next_dzapiinfo);
        }
            ///nb_track_played++;
            break;
            
        case DZ_PLAYER_EVENT_MEDIASTREAM_DATA_READY:
            DebugLog(@"==== PLAYER_EVENT ==== MEDIASTREAM_DATA_READY for idx: %d", idx);
            break;
            
        case DZ_PLAYER_EVENT_MEDIASTREAM_DATA_READY_AFTER_SEEK:
            DebugLog(@"==== PLAYER_EVENT ==== MEDIASTREAM_DATA_READY_AFTER_SEEK for idx: %d", idx);
            break;
            
        case DZ_PLAYER_EVENT_RENDER_TRACK_START_FAILURE:
            DebugLog(@"==== PLAYER_EVENT ==== RENDER_TRACK_START_FAILURE for idx: %d", idx);
            break;
            
        case DZ_PLAYER_EVENT_RENDER_TRACK_START:
            DebugLog(@"==== PLAYER_EVENT ==== RENDER_TRACK_START for idx: %d", idx);
            break;
            
        case DZ_PLAYER_EVENT_RENDER_TRACK_END:
            DebugLog(@"==== PLAYER_EVENT ==== RENDER_TRACK_END for idx: %d", idx);
#if 0
            DebugLog(@"\tnb_track_to_play : %d\tnb_track_played : %d",nb_track_to_play,nb_track_played);
            if (nb_track_to_play != -1 &&  // unlimited
                nb_track_to_play == nb_track_played) {
                app_shutdown();
            } else {
                app_launch_play();
            }
#endif
            break;
            
        case DZ_PLAYER_EVENT_RENDER_TRACK_PAUSED:
            DebugLog(@"==== PLAYER_EVENT ==== RENDER_TRACK_PAUSED for idx: %d", idx);
            break;
            
        case DZ_PLAYER_EVENT_RENDER_TRACK_UNDERFLOW:
            DebugLog(@"==== PLAYER_EVENT ==== RENDER_TRACK_UNDERFLOW for idx: %d", idx);
            break;
            
        case DZ_PLAYER_EVENT_RENDER_TRACK_RESUMED:
            DebugLog(@"==== PLAYER_EVENT ==== RENDER_TRACK_RESUMED for idx: %d", idx);
            break;
            
        case DZ_PLAYER_EVENT_RENDER_TRACK_SEEKING:
            DebugLog(@"==== PLAYER_EVENT ==== RENDER_TRACK_SEEKING for idx: %d", idx);
            break;
            
        case DZ_PLAYER_EVENT_RENDER_TRACK_REMOVED:
            DebugLog(@"==== PLAYER_EVENT ==== RENDER_TRACK_REMOVED for idx: %d", idx);
            break;
            
        case DZ_PLAYER_EVENT_UNKNOWN:
        default:
            DebugLog(@"==== PLAYER_EVENT ==== UNKNOWN or default (type = %d)",type);
            break;
    }
}

- (DZRPlayerManager *)initWithConnect:(dz_connect_handle)dzConnect
{
    dz_error_t dzerr = DZ_ERROR_NO_ERROR;
    DebugLog(@"-->");
    
    dzPlayer = dz_player_new(dzConnect);
    if (dzPlayer == NULL) {
        DebugLog(@"dzPlayer null");
    }
    
    dzerr = dz_player_activate(dzPlayer, NULL);
    if (dzerr != DZ_ERROR_NO_ERROR) {
        DebugLog(@"dz_player_activate error: %d",dzerr);
    }
    
    dzerr = dz_player_set_event_cb(dzPlayer, app_player_onevent_cb);
    if (dzerr != DZ_ERROR_NO_ERROR) {
        DebugLog(@"dz_player_set_event_cb error: %d",dzerr);
    }

    return self;
}

-(void)dealloc
{
    DebugLog(@"--->");
    return;
}

@end
