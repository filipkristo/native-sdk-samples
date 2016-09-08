//
//  DZRNative.h
//  OfflineModePlayer
//
//  Created by Cyril Picheney on 13/06/2016.
//  Copyright © 2016 Cyril Picheney. All rights reserved.
//

#ifndef DZRNative_h
#define DZRNative_h

#import "DebugHelper.h"
#import "deezer-connect.h"
#import "deezer-offline.h"
#import "deezer-player.h"

#import "DZRTrack.h"

@protocol DZRNativeContentDisplayDelegate

/**
 Called when a track list request (album or playlist) has been successfull.

 This method is called if a track list has been returned from a Deezer API Request.
 This method should be implemented by a NSViewController in order to display the result of a request.
 The data will be given as an array of DZRTrack instances.
 */
- (void)updateCurrentPlaylistTracks:(NSMutableArray*)trackList;

- (void)updateSyncPercentDone:(int)percent forTrack:(int)trackId;

- (void)updateSyncState:(dz_offline_sync_state_t)state forContent:(NSString *)contentDescription;

@end

@interface DZRNative : NSObject

/* Get the shared main instance of the Native SDK.
 * This is a lazzy/simple way of creating the Native SDK singleton. */
+ (DZRNative *)sharedMain;

#pragma mark -
#pragma mark ***** Connection mode related methods *****

- (void)connectWithAccessToken:(NSString *)accessToken;

#pragma mark -
#pragma mark ***** Offline mode related methods *****

- (void)getOfflineSyncStateOfContent;
- (void)canBePlayedOffline:(BOOL)isEnabled forTracks:(NSMutableArray *)tracksIds;

#pragma mark -
#pragma mark ***** Playback related methods *****

/*
 * Content description property.
 * Updating this property will trigger the load of the tracks description available for the content.
 * For this demo application available content description must follow this schemes : @"/album/<album_id>" or @"/playlist/<playlist_id>"
 * The updateCurrentPlaylistTracks: delegate function will be called after the data have been retrieved.
 **/
@property (nonatomic, strong) NSString *currentContentDescription;

/**
 * Your delegate object in order to update UI.
 */
@property (unsafe_unretained) id<DZRNativeContentDisplayDelegate> delegate;


@end

#endif /* DZRNative_h */
