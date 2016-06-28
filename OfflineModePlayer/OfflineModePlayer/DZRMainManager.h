//
//  DZRMainManager.h
//  OfflineModePlayer
//
//  Created by Cyril Picheney on 13/06/2016.
//  Copyright © 2016 Cyril Picheney. All rights reserved.
//

#ifndef DZRMainManager_h
#define DZRMainManager_h

#import "DZRPlayerManager.h"
#import "DZROfflineManager.h"
#import "JsonParserHelper.h"

@protocol DZRMainManagerContentDisplayDelegate

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

@interface DZRMainManager : NSObject <DZROfflineManagerContentDisplayDelegate>
{

}

+ (DZRMainManager *)sharedMain;
- (void)setAccessToken:(NSString *)accessToken;
- (void)loadTracksDescriptionForContent:(NSString *)contentDescription;

@property (nonatomic, strong) DZRPlayerManager  *playerManager;
@property (nonatomic, strong) DZROfflineManager *offlineManager;
@property (nonatomic, strong) NSString *currentContentDescription;

/**
 Your delegate object
 */
@property (unsafe_unretained) id<DZRMainManagerContentDisplayDelegate> delegate;

@end

#endif /* DZRMainManager_h */
