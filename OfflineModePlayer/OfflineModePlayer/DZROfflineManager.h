//
//  DZROfflineManager.h
//  OfflineModePlayer
//
//  Created by Cyril Picheney on 13/06/2016.
//  Copyright © 2016 Cyril Picheney. All rights reserved.
//

#ifndef DZROfflineManager_h
#define DZROfflineManager_h

#import "DebugHelper.h"
#import "DZRTrack.h"

#import "deezer-offline.h"

@protocol DZROfflineManagerContentDisplayDelegate

- (void)updateSyncPercentDone:(int)percent forTrack:(int)trackId;

- (void)updateSyncState:(dz_offline_sync_state_t)state forContent:(NSString *)contentDescription;

@end

@interface DZROfflineManager : NSObject

- (DZROfflineManager *)initWithConnect:(dz_connect_handle)dzConnect;

- (void)getSyncState;
- (void)offlineMode:(BOOL)isEnabled forTracks:(NSMutableArray *)tracksIds;

/**
 Your delegate object
 */
@property (unsafe_unretained) id<DZROfflineManagerContentDisplayDelegate> delegate;

@end

#endif /* DZROfflineManager_h */
