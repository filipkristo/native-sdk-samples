//
//  DZRMainManager.m
//  OfflineModePlayer
//
//  Created by Cyril Picheney on 13/06/2016.
//  Copyright © 2016 Cyril Picheney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DZRMainManager.h"
#import "DebugHelper.h"

#import "deezer-connect.h"
#import "deezer-player.h"
#import "deezer-api.h"

//NSString *const kUserAccessToken      = @"fr49mph7tV4KY3ukISkFHQysRpdCEbzb958dB320pM15OpFsQs"; // Sample access token corresponding to a free user account, to be replaced by yours.
NSString *const kMyApplicationID      = @"180202";            // SET YOUR APPLICATION ID
NSString *const kMyApplicationName    = @"OfflineModePlayer"; // SET YOUR APPLICATION NAME
NSString *const kMyApplicationVersion = @"00001";             // SET YOUR APPLICATION VERSION
NSString *const kUserCacehPath        = @"/var/tmp/dzrcache_NDK_SAMPLE"; // SET THE USER CACHE PATH, This pasth must already exist


@interface DZRMainManager ()
{
    dz_connect_handle dzConnect;
}
@end

@implementation DZRMainManager

@synthesize delegate;

void app_connect_onevent_cb(dz_connect_handle handle,
                            dz_connect_event_handle event,
                            void* delegate) {
    
    dz_connect_event_t type = dz_connect_event_get_type(event);
    switch (type) {
        case DZ_CONNECT_EVENT_USER_OFFLINE_AVAILABLE:
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


void connect_request_result_cb(dz_api_request_processing_handle request,
                               dz_api_result_t  ret,
                               dz_stream_object responseData,
                               void* supervisor)
{
    DebugLog(@"-->");
    DZRMainManager *self = (__bridge DZRMainManager *)supervisor;

    // Check we did not get an error

    // ret == DZ_API_RESULT_COMPLETED and response data != error
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

+ (DZRMainManager *)sharedMain
{
    static dispatch_once_t onceToken;
    static DZRMainManager *manager;
    
    DebugLog(@"-->");

    dispatch_once(&onceToken, ^{
        manager = [[DZRMainManager alloc] init];
    });

    return manager;
}

- (DZRMainManager *)init
{
    dz_error_t dzerr = DZ_ERROR_NO_ERROR;
    DebugLog(@"-->");
    
    struct dz_connect_configuration config;
    
    memset(&config, 0, sizeof(config));
    
    config.app_id           = [kMyApplicationID UTF8String];
    config.product_id       = [kMyApplicationName UTF8String];
    config.product_build_id = [kMyApplicationVersion UTF8String];
    config.user_profile_path = [kUserCacehPath UTF8String];
    config.connect_event_cb = app_connect_onevent_cb;
    
    DebugLog(@"--> Application ID:    %s", config.app_id);
    DebugLog(@"--> Product ID:        %s", config.product_id);
    DebugLog(@"--> Product BUILD ID:  %s", config.product_build_id);
    DebugLog(@"--> User Profile Path: %s", config.user_profile_path);
    
    dzConnect = dz_connect_new(&config);
    
    if (!dzConnect) {
        DebugLog(@"ERROR - dz_connect is nil");
    }
    
    /* Disable debug log from the Native SDK */
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
    
    /* Calling dz_connect_cache_path_set()
     * is mandatory in order to have the attended behavior */
    dz_connect_cache_path_set(dzConnect, NULL, NULL, [kUserCacehPath UTF8String]);

    if (self.playerManager == nil)
    {
        _playerManager = [[DZRPlayerManager alloc] initWithConnect:dzConnect];
    }
    if (self.offlineManager == nil)
    {
        _offlineManager = [[DZROfflineManager alloc] initWithConnect:dzConnect];
        [_offlineManager setDelegate:self];
    }

    return self;
}

- (void)dealloc
{
    DebugLog(@"--->");
    return;
}

- (void)setAccessToken:(NSString *)accessToken
{
    dz_error_t dzerr = DZ_ERROR_NO_ERROR;
    DebugLog(@"-->");

    dzerr = dz_connect_set_access_token(dzConnect,NULL, NULL, [accessToken UTF8String]);
    if (dzerr != DZ_ERROR_NO_ERROR) {
        DebugLog(@"dz_connect_set_access_token error: %d",dzerr);
    }
    
    /* Calling dz_connect_offline_mode(FALSE) is mandatory to force the login */
    dzerr = dz_connect_offline_mode(dzConnect, NULL, NULL, false);
    if (dzerr != DZ_ERROR_NO_ERROR) {
        DebugLog(@"dz_connect_offline_mode error: %d",dzerr);
    }

    return;
}

- (void)loadTracksDescriptionForContent:(NSString* )contentDescription
{
    NSString *contentDescriptionWithTracks;

    dz_api_request_handle dzr_request;
    dz_api_request_processing_handle dzr_request_process;

    DebugLog(@"--> load %@",contentDescription);

    /* Check the content description is valid */
    if ((!contentDescription) &&
        ([contentDescription hasPrefix:@"/album/"] ||
         [contentDescription hasPrefix:@"/playlist/"])) {

            DebugLog(@"Error argument %@",contentDescription);
            return;
        }

    // append /tracks
    contentDescriptionWithTracks = [[NSString alloc] initWithFormat:@"%@/tracks",contentDescription];

    /* Create a new request to get the tracks of the album or playlist */
    dzr_request = dz_api_request_new(DZ_API_CMD_GET, [contentDescriptionWithTracks UTF8String]);
    if (dzr_request == NULL) {
        DebugLog(@"couldn't create a request");
    }

    dzr_request_process = dz_api_request_processing_async(dzConnect,
                                                          dzr_request,
                                                          json_parser_singleton(),
                                                          connect_request_result_cb,
                                                          (__bridge void *)(self)); //(__bridge_retained void*)searchRequest->subrequests[0]);
    DZ_OBJECT_RELEASE(dzr_request);
    if (dzr_request_process == NULL) {
        DebugLog(@"couldn't queue the request");
    }
    
}

#pragma mark -
#pragma mark ***** Offline forwad deletation relative methods *****

- (void)updateSyncPercentDone:(int)percent forTrack:(int)trackId
{
    if ([self delegate])
        [[self delegate] updateSyncPercentDone:percent forTrack:trackId];
}

- (void)updateSyncState:(dz_offline_sync_state_t)state forContent:(NSString *)contentDescription
{
#ifdef IMPLEMENTED
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
    if ([self delegate])
        [[self delegate] updateSyncState:state forContent:contentDescription];
}

@end
