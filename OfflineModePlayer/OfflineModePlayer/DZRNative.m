//
//  DZRNative.m
//  OfflineModePlayer
//
//  Created by Cyril Picheney on 13/06/2016.
//  Copyright © 2016 Cyril Picheney. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DZRNative.h"
#import "deezer-connect.h"
#import "deezer-api.h"

#import "SBJsonParser.h"
#import "SBJsonWriter.h"

NSString *const kMyApplicationID      = @"180202";            // SET YOUR APPLICATION ID
NSString *const kMyApplicationName    = @"OfflineModePlayer"; // SET YOUR APPLICATION NAME
NSString *const kMyApplicationVersion = @"00001";             // SET YOUR APPLICATION VERSION
NSString *const kUserCacehPath        = @"/var/tmp/dzrcache_NDK_SAMPLE"; // SET THE USER CACHE PATH, This pasth must already exist

@interface DZRNative ()
{
    dz_connect_handle dzConnect;
    dz_player_handle  dzPlayer;

    NSString *dzContentDescription;
    NSString *dzLocalContentDescription;
}

@end


@implementation DZRNative

@synthesize delegate;

#pragma mark -
#pragma mark ***** API REST Callbacks related methods *****

void libdeezer_API_request_result_cb(dz_api_request_processing_handle request,
                               dz_api_result_t  ret,
                               dz_stream_object responseData,
                               void* supervisor)
{
    DEBUG_ENTER
    DZRNative *self = (__bridge DZRNative *)supervisor;

    NSMutableArray* tracksList = [NSMutableArray new];
    DZRTrack *track;
    NSString *track_id;
    NSString *track_title;
    NSNumber *track_readable;
    NSString *artist_name;

    [tracksList removeAllObjects];

    NSDictionary* albumTracksData = (__bridge NSDictionary*)responseData;

    NSArray *tracks = albumTracksData[@"data"];
    NSUInteger length = [tracks count];
    unsigned int i;
    for (i=0; i<length; ++i) {
        NSDictionary *track_json = tracks[i];
        track_id = track_json[@"id"];
        track_title = track_json[@"title"];
        track_readable = track_json[@"readable"];
        artist_name = track_json[@"artist"][@"name"];

        track = [[DZRTrack alloc] initWithId:(int)[track_id intValue]];
        [track setTitle:track_title];
        [track setArtist:artist_name];
        [track setReadable:([track_readable intValue] == 1)];

        [tracksList addObject:track];
    }

    [self.delegate updateCurrentPlaylistTracks:tracksList];
    
    DZ_OBJECT_RELEASE(request);
}


#pragma mark -
#pragma mark ***** Connection Callbacks related methods *****

void libdeezer_connect_event_cb(dz_connect_handle handle,
                            dz_connect_event_handle event,
                            void* delegate) {

    dz_connect_event_t type = dz_connect_event_get_type(event);
    switch (type) {
        case DZ_CONNECT_EVENT_USER_OFFLINE_AVAILABLE:
            // User has authorized access the app to the offline mode.
            // /!\ This does not mean the user has offline mode available for its account.
            DebugLog(@"++++ CONNECT_EVENT ++++ USER_OFFLINE_AVAILABLE");
            break;

        case DZ_CONNECT_EVENT_USER_ACCESS_TOKEN_OK:
        {
            const char* szAccessToken;
            szAccessToken = dz_connect_event_get_access_token(event);
            DebugLog(@"++++ CONNECT_EVENT ++++ USER_ACCESS_TOKEN_OK Access_token : %s", szAccessToken);
        }
            break;

        case DZ_CONNECT_EVENT_USER_ACCESS_TOKEN_FAILED:
            DebugLog(@"++++ CONNECT_EVENT ++++ USER_ACCESS_TOKEN_FAILED");
            break;

        case DZ_CONNECT_EVENT_USER_LOGIN_OK:
            DebugLog(@"++++ CONNECT_EVENT ++++ USER_LOGIN_OK");
            break;

        case DZ_CONNECT_EVENT_USER_NEW_OPTIONS:
            DebugLog(@"++++ CONNECT_EVENT ++++ USER_NEW_OPTIONS");
            break;

        case DZ_CONNECT_EVENT_USER_LOGIN_FAIL_NETWORK_ERROR:
            DebugLog(@"++++ CONNECT_EVENT ++++ USER_LOGIN_FAIL_NETWORK_ERROR");
            break;

        case DZ_CONNECT_EVENT_USER_LOGIN_FAIL_BAD_CREDENTIALS:
            DebugLog(@"++++ CONNECT_EVENT ++++ USER_LOGIN_FAIL_BAD_CREDENTIALS");
            break;

        case DZ_CONNECT_EVENT_USER_LOGIN_FAIL_USER_INFO:
            DebugLog(@"++++ CONNECT_EVENT ++++ USER_LOGIN_FAIL_USER_INFO");
            break;

        case DZ_CONNECT_EVENT_USER_LOGIN_FAIL_OFFLINE_MODE:
            DebugLog(@"++++ CONNECT_EVENT ++++ USER_LOGIN_FAIL_OFFLINE_MODE");
            break;

        case DZ_CONNECT_EVENT_ADVERTISEMENT_START:
            DebugLog(@"++++ CONNECT_EVENT ++++ ADVERTISEMENT_START");
            break;

        case DZ_CONNECT_EVENT_ADVERTISEMENT_STOP:
            DebugLog(@"++++ CONNECT_EVENT ++++ ADVERTISEMENT_STOP");
            break;

        case DZ_CONNECT_EVENT_UNKNOWN:
        default:
            DebugLog(@"++++ CONNECT_EVENT ++++ UNKNOWN or default (type = %d)",type);
            break;
    }
}

#pragma mark -
#pragma mark ***** Player Callbacks related methods *****

void libdeezer_player_event_cb(dz_player_handle       handle,
                               dz_player_event_handle event,
                               void *                 supervisor)
{
    dz_streaming_mode_t  streaming_mode;
    dz_index_in_queuelist idx;
    
    dz_player_event_t type = dz_player_event_get_type(event);
    
    if (!dz_player_event_get_queuelist_context(event, &streaming_mode, &idx)) {
        streaming_mode = DZ_STREAMING_MODE_ONDEMAND;
        idx = -1;
    }
    
    switch (type) {
        case DZ_PLAYER_EVENT_LIMITATION_FORCED_PAUSE:
            DebugLog(@"==== PLAYER_EVENT ==== LIMITATION_FORCED_PAUSE for idx: %d", idx);
            break;
            
        case DZ_PLAYER_EVENT_QUEUELIST_NO_RIGHT:
            DebugLog(@"==== PLAYER_EVENT ==== QUEUELIST_NO_RIGHT for idx: %d", idx);
            break;
            
        case DZ_PLAYER_EVENT_QUEUELIST_NEED_NATURAL_NEXT:
            DebugLog(@"==== PLAYER_EVENT ==== QUEUELIST_NEED_NATURAL_NEXT for idx: %d", idx);
            break;
            
        case DZ_PLAYER_EVENT_QUEUELIST_TRACK_NOT_AVAILABLE_OFFLINE:
            DebugLog(@"==== PLAYER_EVENT ==== QUEUELIST_TRACK_NOT_AVAILABLE_OFFLINE for idx: %d", idx);
            break;
            
        case DZ_PLAYER_EVENT_QUEUELIST_TRACK_RIGHTS_AFTER_AUDIOADS:
            DebugLog(@"==== PLAYER_EVENT ==== QUEUELIST_TRACK_RIGHTS_AFTER_AUDIOADS for idx: %d", idx);
            // TODO Check we have a dzPlayer instance and play the audioads to unlock the next track playback.
            //dz_player_play_audioads(dzPlayer, NULL, NULL);
            break;
            
        case DZ_PLAYER_EVENT_QUEUELIST_SKIP_NO_RIGHT:
            DebugLog(@"==== PLAYER_EVENT ==== QUEUELIST_SKIP_NO_RIGHT for idx: %d", idx);
            break;
            
        case DZ_PLAYER_EVENT_QUEUELIST_TRACK_SELECTED:
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
            
            DebugLog(@"==== PLAYER_EVENT ==== QUEUELIST_TRACK_SELECTED for idx: %d - is_preview:%d", idx, is_preview);
            DebugLog(@"\tcan_pause_unpause:%d can_seek:%d nb_skip_allowed:%d", can_pause_unpause, can_seek, nb_skip_allowed);
            if (selected_dzapiinfo)
                DebugLog(@"\tnow:%s", selected_dzapiinfo);
            if (next_dzapiinfo)
                DebugLog(@"\tnext:%s", next_dzapiinfo);
        }
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

#pragma mark -
#pragma mark ***** Offline Callbacks related methods *****

void libdeezer_offline_event_cb(dz_connect_handle handle,
                                       dz_offline_event_handle event,
                                       void* supervisor) {
    //DEBUG_ENTER

    DZRNative *self = (__bridge DZRNative *)supervisor;

    DZ_OBJECT_RETAIN(event);
    dispatch_async(dispatch_get_main_queue(), ^ {
        switch (dz_offline_event_get_type(event)) {
            case DZ_OFFLINE_EVENT_DOWNLOAD_PROGRESS: {
                dz_track_id_t trackid;
                dz_bigsize_t downloaded_size;
                dz_bigsize_t complete_size;

                trackid = dz_offline_event_trackfile_trackid(event);
                if (trackid == DZ_TRACK_ID_INVALID) // it's a progress event for something else than a track, we don't care
                    return;

                downloaded_size = dz_offline_event_download_progress_downloaded_size(event);
                complete_size = dz_offline_event_download_progress_complete_size(event);

                //DebugLog(@"DZ_OFFLINE_EVENT_DOWNLOAD_PROGRESS : %d for id : %d",(int)(100*downloaded_size/complete_size),trackid);
                // Update UI
                [[self delegate] updateSyncPercentDone:(int)(100*downloaded_size/complete_size) forTrack:(int)trackid];
            }
                break;
            case DZ_OFFLINE_EVENT_NEW_SYNC_STATE: {
                dz_offline_sync_state_t new_state = dz_offline_event_resource_get_sync_state(event);
                const char* resource_type;
                //NSString* currentPlaylist;

                resource_type = dz_offline_event_get_resource_type(event);

                /* Global track list info */
                if (strcmp(resource_type, "dz_tracklist") == 0) {
                    const char* tracklist_id;
                    const char* tracklist_version;

                    //currentPlaylist = [uiCtrl getCurrentPlaylist];
                    tracklist_id = dz_offline_event_get_resource_id(event);
                    tracklist_version = dz_offline_event_get_resource_version(event);

                    // Update UI
                    [[self delegate] updateSyncState:new_state forContent:[NSString stringWithUTF8String:tracklist_id]];

                    // TODO Check the playlist version to be sure we have the last version synchronized.
#ifdef TO_BE_IMPLEMENTED
                    if ([currentPlaylist isEqualToString:[NSString stringWithUTF8String:tracklist_id]]) {
                        [uiCtrl UpdateSyncButton:new_state];

                        if (new_state == DZ_OFFLINE_SYNC_STATE_UNSYNCED) {
                            [uiCtrl updatePlaylistViewSyncForAll:@""];
                        } else {
                            // we have a new tracklist, update in ui
                            [uiCtrl loadOfflinePlaylists];
                        }
                    }
#endif
                /* Single track info */
                } else if (strcmp(resource_type, "dz_track_offline") == 0) {
                    dz_track_id_t trackid;
                    const char* tracklist_version;
                    trackid = dz_offline_event_trackoffline_trackid(event);
                    tracklist_version = dz_offline_event_get_resource_version(event);

                    if (new_state == DZ_OFFLINE_SYNC_STATE_SYNCED) {
                        // Update UI
                        [[self delegate] updateSyncPercentDone:100 forTrack:(int)trackid];
                    } else {
                        // Update UI
                        [[self delegate] updateSyncPercentDone:0 forTrack:(int)trackid];
                    }
                }

            }
                break;

            case DZ_OFFLINE_EVENT_UNKNOWN:
                DebugLog(@"DZ_OFFLINE_EVENT_UNKNOWN");
                break;
        }
        DZ_OBJECT_RELEASE(event);
    });
}

void libdeezer_offline_sync_state_cb(void* supervisor,
                                     void* operation_userdata,
                                     dz_error_t status,
                                     dz_object_handle offlineState)
{
    DEBUG_ENTER
    DZRNative *self = (__bridge DZRNative *)operation_userdata;
    //DebugLog(@"self:%p %s",self,dz_offline_state_to_json(offlineState));

    if (offlineState)
        DZ_OBJECT_RETAIN(offlineState);

    dispatch_async(dispatch_get_main_queue(), ^ {

        dz_offline_sync_state_t syncState;
        NSDictionary *playlistState = nil;

        if (offlineState) {
            const char *sz_state = dz_offline_state_to_json(offlineState);

            if (sz_state == NULL) {
                syncState = DZ_OFFLINE_SYNC_STATE_UNSYNCED;
            } else {
                NSData *nsdata = [[NSData alloc]
                                  initWithBytesNoCopy:(void*)sz_state
                                  length:strlen(sz_state)
                                  freeWhenDone:NO];
                SBJsonParser *parser = [[SBJsonParser alloc] init];

                playlistState = [parser objectWithData:nsdata];

                DebugLog(@"playlist state : %@", playlistState);

                if ([@"synced" isEqualToString:playlistState[@"state"]]) {
                    //  TODO Check the playlist version know if the current playlist synced is really the last one.
                    syncState = DZ_OFFLINE_SYNC_STATE_SYNCED;
                } else if ([@"unsynced" isEqualToString:playlistState[@"state"]]) {
                    syncState = DZ_OFFLINE_SYNC_STATE_UNSYNCED;
                } else if ([@"syncing" isEqualToString:playlistState[@"state"]]) {
                    syncState = DZ_OFFLINE_SYNC_STATE_SYNCING;
                } else  {
                    syncState = DZ_OFFLINE_SYNC_STATE_UNSYNCED;
                }
            }
        } else {
            syncState = DZ_OFFLINE_SYNC_STATE_UNSYNCED;
        }
        
        if ([self delegate])
            [[self delegate] updateSyncState:syncState forContent:self.currentContentDescription];
        
        if (offlineState)
            DZ_OBJECT_RELEASE(offlineState);
    });
}

#pragma mark -
#pragma mark ***** DZRNative instance related methods *****

+ (DZRNative *)sharedMain
{
    DEBUG_ENTER
    static dispatch_once_t onceToken;
    static DZRNative *manager;
    dispatch_once(&onceToken, ^{
        manager = [[DZRNative alloc] init];
    });

    return manager;
}

- (DZRNative *)init
{
    DEBUG_ENTER

    dz_error_t dzerr = DZ_ERROR_NO_ERROR;
    struct dz_connect_configuration config;

    memset(&config, 0, sizeof(config));

    config.app_id           = [kMyApplicationID UTF8String];
    config.product_id       = [kMyApplicationName UTF8String];
    config.product_build_id = [kMyApplicationVersion UTF8String];
    config.user_profile_path = [kUserCacehPath UTF8String];
    config.connect_event_cb = libdeezer_connect_event_cb;

    DebugLog(@"--> Application ID:    %s", config.app_id);
    DebugLog(@"--> Product ID:        %s", config.product_id);
    DebugLog(@"--> Product BUILD ID:  %s", config.product_build_id);
    DebugLog(@"--> User Profile Path: %s", config.user_profile_path);

    //////////////////
    // CONNECT init //
    //////////////////
    dzConnect = dz_connect_new(&config);

    if (!dzConnect) {
        DebugLog(@"ERROR - dz_connect is nil");
    }

    // Disable debug log from the Native SDK
    dzerr = dz_connect_debug_log_disable(dzConnect);
    if (dzerr != DZ_ERROR_NO_ERROR) {
        DebugLog(@"dz_connect_debug_log_disable error");
    }

    DebugLog(@"Device ID: %s", dz_connect_get_device_id(dzConnect));
    DebugLog(@"SDK Build ID: %s", dz_connect_get_build_id());

    dz_connect_activate(dzConnect, (__bridge void*)self);
    if (dzerr != DZ_ERROR_NO_ERROR) {
        DebugLog(@"dz_connect_activate error");
    }

    // Calling dz_connect_cache_path_set()
    //is mandatory in order to have the attended behavior
    dz_connect_cache_path_set(dzConnect, NULL, NULL, [kUserCacehPath UTF8String]);

    /////////////////
    // PLAYER init //
    /////////////////
    dzPlayer = dz_player_new(dzConnect);
    if (dzPlayer == NULL) {
        DebugLog(@"dzPlayer null");
    }

    dzerr = dz_player_activate(dzPlayer, NULL);
    if (dzerr != DZ_ERROR_NO_ERROR) {
        DebugLog(@"dz_player_activate error: %d",dzerr);
    }

    dzerr = dz_player_set_event_cb(dzPlayer, libdeezer_player_event_cb);
    if (dzerr != DZ_ERROR_NO_ERROR) {
        DebugLog(@"dz_player_set_event_cb error: %d",dzerr);
    }

    //////////////////
    // OFFLINE init //
    //////////////////
    dz_offline_eventcb_set(dzConnect,
                           NULL,
                           (__bridge void *)(self),
                           libdeezer_offline_event_cb);

    //DebugLog(@"self:%p",self);

    return self;
}

- (void)dealloc
{
    DEBUG_ENTER
    return;
}

#pragma mark -
#pragma mark ***** Connection mode related methods *****

- (void)connectWithAccessToken:(NSString *)accessToken
{
    DEBUG_ENTER
    dz_error_t dzerr = DZ_ERROR_NO_ERROR;

    if (!dzConnect)
        return;

    dzerr = dz_connect_set_access_token(dzConnect,NULL, NULL, [accessToken UTF8String]);
    if (dzerr != DZ_ERROR_NO_ERROR) {
        DebugLog(@"dz_connect_set_access_token error: %d",dzerr);
    }

    // Calling dz_connect_offline_mode(FALSE) is mandatory to force the login
    dzerr = dz_connect_offline_mode(dzConnect, NULL, NULL, false);
    if (dzerr != DZ_ERROR_NO_ERROR) {
        DebugLog(@"dz_connect_offline_mode error: %d",dzerr);
    }

    return;
}

- (void)setCurrentContentDescription:(NSString *)contentDescription
{
    DEBUG_ENTER
    NSString *contentDescriptionWithTracks;
    dz_api_request_handle dzr_request;
    dz_api_request_processing_handle dzr_request_process;

    DebugLog(@"Try to LOAD: %@",contentDescription);

    // Check the content description is valid
    if ((!contentDescription) &&
        ([contentDescription hasPrefix:@"/album/"] ||
         [contentDescription hasPrefix:@"/playlist/"])) {

            DebugLog(@"Error argument %@",contentDescription);
            return;
        }

    if (!dzConnect)
        return;

    dzContentDescription = contentDescription;
    dzLocalContentDescription = [NSString stringWithFormat:@"/dzlocal/tracklist%@", dzContentDescription];

    // Append "/tracks" in order to get the tracks list JSON from the content
    contentDescriptionWithTracks = [[NSString alloc] initWithFormat:@"%@/tracks",contentDescription];

    // Create a new request to get the tracks of the album or playlist
    dzr_request = dz_api_request_new(DZ_API_CMD_GET, [contentDescriptionWithTracks UTF8String]);
    if (dzr_request == NULL) {
        DebugLog(@"couldn't create a request");
    }

    dzr_request_process = dz_api_request_processing_async(dzConnect,
                                                          dzr_request,
                                                          json_parser_singleton(),
                                                          libdeezer_API_request_result_cb,
                                                          (__bridge void *)(self));
    // Now we can release the request
    DZ_OBJECT_RELEASE(dzr_request);

    // Check we have well created the request process
    if (dzr_request_process == NULL) {
        DebugLog(@"Couldn't queue the request");
    }
    
}

#pragma mark -
#pragma mark ***** Offline mode related methods *****

- (void)canBePlayedOffline:(BOOL)isEnabled forTracks:(NSMutableArray *)tracksIds
{
    DEBUG_ENTER

    if (!dzConnect)
        return;

    if (isEnabled) {

        // Create a JSON of track IDs we want to be synchronized.
        // This JSON will be provided to dz_offline_synchronize.
        NSMutableDictionary *syncObj;
        NSString * syncJson;

        syncObj = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                   tracksIds, @"tracks",
                   nil];

        syncJson = [[[SBJsonWriter alloc
                      ] init] stringWithObject:syncObj];

        DebugLog(@"SYNCING %@ from %@", syncJson, dzLocalContentDescription);

        dz_offline_synchronize(dzConnect, NULL, NULL,
                               [dzLocalContentDescription UTF8String],
                               "0",  // 0 for album, or TODO: checksum for a playlist
                               [syncJson UTF8String]);
        // Update UI
        [[self delegate] updateSyncState:DZ_OFFLINE_SYNC_STATE_SYNCING forContent:dzContentDescription];
        
    } else {
        DebugLog(@"UN-SYNCING %@", dzLocalContentDescription);

        dz_offline_remove(dzConnect, NULL, NULL,
                          [dzLocalContentDescription UTF8String]);
        // Update UI
        [[self delegate] updateSyncState:DZ_OFFLINE_SYNC_STATE_UNSYNCED forContent:dzContentDescription];
    }

}

- (void)getOfflineSyncStateOfContent
{
    DEBUG_ENTER

    if (!dzConnect)
        return;

    if (dzLocalContentDescription) {
        dz_offline_get_state(dzConnect,
                             libdeezer_offline_sync_state_cb,
                             (__bridge void *)(self),
                             [dzLocalContentDescription UTF8String],
                             true);
    }

}

@end
