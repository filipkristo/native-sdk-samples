//
//  DZROfflineManager.m
//  OfflineModePlayer
//
//  Created by Cyril Picheney on 13/06/2016.
//  Copyright © 2016 Cyril Picheney. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DZROfflineManager.h"
#import "SBJsonParser.h"
#import "SBJsonWriter.h"
#import "deezer-connect.h"

@interface DZROfflineManager ()
{
    dz_connect_handle dzConnect;
}

@end

@implementation DZROfflineManager

@synthesize delegate;


void playerui_connect_offline_event_cb(dz_connect_handle handle,
                                       dz_offline_event_handle event,
                                       void* supervisor) {

    DZROfflineManager *self = (__bridge DZROfflineManager *)supervisor;
    DebugLog(@"--> (self:%p)",self);
#if 1

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
#ifdef IMPLEMENTED
                [uiCtrl
                 updatePlaylistViewSyncForTrack:trackid
                 withString:[NSString stringWithFormat:@"%d",
                             ]];
#endif
                DebugLog(@"DZ_OFFLINE_EVENT_DOWNLOAD_PROGRESS : %d for id : %d",(int)(100*downloaded_size/complete_size),trackid);
            }
                break;
            case DZ_OFFLINE_EVENT_NEW_SYNC_STATE: {
                dz_offline_sync_state_t new_state = dz_offline_event_resource_get_sync_state(event);
                const char* resource_type;
                NSString* currentPlaylist;

                resource_type = dz_offline_event_get_resource_type(event);
#if 1
                DebugLog(@"DZ_OFFLINE_EVENT_NEW_SYNC_STATE : app got %s on %s %s",
                      dz_offline_state_to_cchar(new_state),
                      resource_type,
                      dz_offline_event_get_resource_id(event));
#endif
                if (strcmp(resource_type, "dz_tracklist") == 0) {
                    const char* tracklist_id;
                    const char* tracklist_version;

                    //currentPlaylist = [uiCtrl getCurrentPlaylist];
                    tracklist_id = dz_offline_event_get_resource_id(event);
                    tracklist_version = dz_offline_event_get_resource_version(event);
                    if ([self delegate])
                        [[self delegate] updateSyncState:new_state forContent:[NSString stringWithUTF8String:tracklist_id]];

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
                } else if (strcmp(resource_type, "dz_track_offline") == 0) {
                    dz_track_id_t trackid;
                    const char* tracklist_version;
                    trackid = dz_offline_event_trackoffline_trackid(event);
                    tracklist_version = dz_offline_event_get_resource_version(event);
#ifdef IMPLEMENTED
                    if (new_state == DZ_OFFLINE_SYNC_STATE_SYNCED)
                        [uiCtrl updatePlaylistViewSyncForTrack:trackid withString:@"done"];
                    else
                        [uiCtrl updatePlaylistViewSyncForTrack:trackid withString:@""];
#endif
                }

            }
                break;

            case DZ_OFFLINE_EVENT_UNKNOWN:
                DebugLog(@"DZ_OFFLINE_EVENT_UNKNOWN");
                break;
        }
        DZ_OBJECT_RELEASE(event);
    });
#endif

}

void playerui_connect_sync_result_cb(void* supervisor,
                                     void* operation_userdata,
                                     dz_error_t status,
                                     dz_object_handle offlineState)
{
    DebugLog(@"-->");
    DZROfflineManager *self = (__bridge DZROfflineManager *)operation_userdata;
    DebugLog(@"self:%p %s",self,dz_offline_state_to_json(offlineState));

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

                //NSLog(@"playlist state : %@", playlistState);

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
        
        //if ([self delegate])
        //    [[self delegate] updateSyncState:syncState forContent:self.currentContentDescription];

        if (offlineState)
            DZ_OBJECT_RELEASE(offlineState);
    });
}

- (DZROfflineManager *)initWithConnect:(dz_connect_handle)dzConnectHandle
{
    DebugLog(@"-->");
    
    dzConnect = dzConnectHandle;

    dz_offline_eventcb_set(dzConnect,
                           NULL,
                           (__bridge void *)(self),
                           playerui_connect_offline_event_cb);

    DebugLog(@"self:%p",self);

    return self;
}

-(void)dealloc
{
    DebugLog(@"--->");
    return;
}

- (void)offlineMode:(BOOL)isEnabled forTracks:(NSMutableArray *)tracksIds ofContent:(NSString *)contentDescription
{
    DebugLog(@"-->");

    if (!dzConnect)
        return;

    if (isEnabled)  {
        [self updateOfflinePlaylistForTracks:tracksIds forContent:contentDescription];
    } else {
        NSLog(@"unsyncing %@", contentDescription);
        dz_offline_remove(dzConnect, NULL, NULL,
                          [contentDescription UTF8String]);
        if ([self delegate])
            [[self delegate] updateSyncState:DZ_OFFLINE_SYNC_STATE_UNSYNCED forContent:contentDescription];
    }

}

- (void)getSyncStateOfContent:(NSString *)contentDescription
{
    DebugLog(@"-->");

    if (contentDescription) {
        dz_offline_get_state(dzConnect,
                             playerui_connect_sync_result_cb,
                             (__bridge void *)(self),
                             [contentDescription UTF8String],
                             true);
    }

}

// Called when click onSync to launch the sync action or auto sync if version of playlist has changed
- (void) updateOfflinePlaylistForTracks:(NSMutableArray *)tracksIds forContent:(NSString * )contentDescription
{
    DebugLog(@"-->");


    NSMutableDictionary *syncObj;
    NSString * syncJson;

    syncObj = [NSMutableDictionary dictionaryWithObjectsAndKeys:
               tracksIds, @"tracks",
               nil];

    syncJson = [[[SBJsonWriter alloc
                  ] init] stringWithObject:syncObj];

    NSLog(@"syncing %@ from %@", syncJson, contentDescription);
    dz_offline_synchronize(dzConnect, NULL, NULL,
                           [contentDescription UTF8String],
                           "0",  // 0 for album, or playlist checksum
                           [syncJson UTF8String]);
    if ([self delegate])
        [[self delegate] updateSyncState:DZ_OFFLINE_SYNC_STATE_SYNCING forContent:contentDescription];
}

- (void) updateOfflinePlaylistState:(dz_object_handle)offlineState;
{
#if 0
    NSInteger syncState;
    NSDictionary *playlistState = NULL;

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

                //NSLog(@"playlist state : %@", playlistState);

            if ([@"synced" isEqualToString:playlistState[@"state"]]) {
                if ([playlistState[@"version"] isEqualToString:playlistVersion]) {
                    syncState = DZ_OFFLINE_SYNC_STATE_SYNCED;
                } else {
                        // update offline playlist
                    [self updateOfflinePlaylist];
                    syncState = DZ_OFFLINE_SYNC_STATE_ENQUEUED_FOR_SYNC;
                }
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

    [self updateSyncButton:syncState];

    if (syncState == DZ_OFFLINE_SYNC_STATE_UNSYNCED)
        [self updatePlaylistViewSyncForAll:@""];
    else if (syncState == DZ_OFFLINE_SYNC_STATE_SYNCED)
        [self updatePlaylistViewSyncForAll:@"done"];
    else if (syncState == DZ_OFFLINE_SYNC_STATE_SYNCING) {
        NSArray *tracks = playlistState[@"tracks"];

        [tracks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *track_state = obj;
            NSString *newstring;

            if ([@"synced" isEqualToString:track_state[@"state"]]) {
                newstring = @"done";
            } else if ([@"syncing" isEqualToString:playlistState[@"state"]]) {
                NSDictionary *first_trackfile = track_state[@"trackfiles"][0];
                NSNumber* downloaded_size;
                NSNumber* complete_size;
                complete_size = [first_trackfile valueForKey:@"complete_size"];

                if (downloaded_size && [downloaded_size longValue]) {
                    downloaded_size = [first_trackfile valueForKey:@"downloaded_size"];
                    newstring = [NSString stringWithFormat:@"%d",
                                 (int)(100*[downloaded_size longValue]/[complete_size longValue])];
                } else {
                    newstring = @"";
                }
            } else  {
                newstring = @"";
            }
            [self updatePlaylistViewSyncForIndex:idx withString:newstring];


        }];
    }
#endif
}

- (void) updatePlaylistViewSyncForIndex:(int)idx withString:(NSString*)status
{
    NSIndexSet *indexSet;
    DebugLog(@"-->");

    indexSet = [NSIndexSet indexSetWithIndex:idx];
#if 0
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        DZRTrack *track;
        track = playlistTracks[idx];
        [track setSyncDonePercent:status];
    }];

    // update sync% column on the rows
    [playlistTableView reloadDataForRowIndexes:indexSet
                                 columnIndexes:[NSIndexSet
                                                indexSetWithIndex:4]];
    [playlistTableView reloadData];
#endif
}

- (void) updatePlaylistViewSyncForAll:(NSString*)status;
{
    NSIndexSet* indexSet;
    NSUInteger count;
#if 0
    count = [playlistTracks count];

    if (count == 0)
        return;

    indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, count)];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        DZRTrack *track;
        track = playlistTracks[idx];
        [track setSyncDonePercent:status];
    }];
        // update sync% column on the rows
    [playlistTableView reloadDataForRowIndexes:indexSet
                                 columnIndexes:[NSIndexSet indexSetWithIndex:4]];
    [playlistTableView reloadData];
#endif
}


@end

