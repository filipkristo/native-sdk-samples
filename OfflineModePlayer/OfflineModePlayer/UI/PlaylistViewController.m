//
//  PlaylistViewController.h
//  OfflineModePlayer
//
//  Created by Cyril Picheney on 06/06/2016.
//  Copyright © 2016 Cyril Picheney. All rights reserved.
//

#import "PlaylistViewController.h"

// Sample access token corresponding to a free user account.
// --> No offline mode playback available for this free user account.
// --> SET YOUR own Premium+ ACCESS TOKEN.
NSString *const kUserAccessToken      = @"fr49mph7tV4KY3ukISkFHQysRpdCEbzb958dB320pM15OpFsQs";

@interface PlaylistViewController ()
{
    NSMutableArray *playlistTracks;
}

@end

@implementation PlaylistViewController

- (void)awakeFromNib
{
    DEBUG_ENTER
    
    if (!playlistTracks) {
        playlistTracks = [[NSMutableArray alloc] init];
    }

    /* Reset UI */
    // As an example try with http://www.deezer.com/album/8621186
    //[dzrUrlEntry setStringValue:@"/album/13223812"];
    [dzrUrlEntry setStringValue:@"/playlist/1759051802"];
    
    [playlistTracks removeAllObjects];

    [self updateSyncButton:DZ_OFFLINE_SYNC_STATE_UNKNOWN];
    
    /* Init Deezer Native SDK*/

    [[DZRNative sharedMain] setDelegate:self];
    [[DZRNative sharedMain] connectWithAccessToken:kUserAccessToken];
}

-(void)dealloc
{
    DEBUG_ENTER
    return;
}

#pragma mark -
#pragma mark ***** Search entry related methods *****

- (IBAction)validateDZRUrlEntry:(id)sender
{
    
    DEBUG_ENTER
    NSTextField* textEntry = (NSTextField*)sender;
    DebugLog(@"%@",[textEntry stringValue]);
    
    /* Clear UI */
    [playlistTracks removeAllObjects];
    [playlistTableView reloadData];
    [self updateSyncButton:DZ_OFFLINE_SYNC_STATE_UNKNOWN];
    
    [[DZRNative sharedMain] setCurrentContentDescription:[textEntry stringValue]];
    [[DZRNative sharedMain] getOfflineSyncStateOfContent];
}

#pragma mark -
#pragma mark ***** Playlist table view related methods *****

- (void)updateCurrentPlaylistTracks:(NSMutableArray*)trackList {
    DEBUG_ENTER
    playlistTracks = trackList;
    [playlistTableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    //DEBUG_ENTER
    return [playlistTracks count];
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    DZRTrack *track = [playlistTracks objectAtIndex:row];
    
    NSString *identifier = [tableColumn identifier];
    
    return [track valueForKey:identifier];
}

#pragma mark -
#pragma mark ***** Offline mode button relative methods *****


- (IBAction)clickOnSync:(id)sender {

    NSInteger newState = [syncButton state];

    DEBUG_ENTER

    DebugLog(@"Try to sync/unsync : %@",[dzrUrlEntry stringValue]);

    // Extract track IDs from the current playlist we want to synchronize/unsynchronize
    NSMutableArray *tracksIDsToBeUpdated = [playlistTracks valueForKey:@"trackId"];
    [[DZRNative sharedMain] canBePlayedOffline:(newState == 1)
                                     forTracks:tracksIDsToBeUpdated];

}

- (void)updateSyncPercentDone:(int)percent forTrack:(int)trackId {

    //DEBUG_ENTER
    [playlistTracks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
        DZRTrack *track = (DZRTrack *)obj;
        if (track.trackId == trackId) {
            if (percent > 0)
                [track setSyncDonePercent:[NSString stringWithFormat:@"%d %%",percent]];
            else
                [track setSyncDonePercent:nil];

            *stop = YES;
            DebugLog(@"DOWNLOAD (trackId %d\t - %@)",trackId,[track syncDonePercent]);
        }
    }];

    [playlistTableView reloadData];
}

- (void)updateSyncState:(dz_offline_sync_state_t)state forContent:(NSString *)contentDescription {
    DEBUG_ENTER
    [self updateSyncButton:state];
}

- (void) updateSyncButton:(dz_offline_sync_state_t)syncState {
    BOOL syncButtonState;
    NSInteger syncButtonEnable;
    NSString *syncButtonText;
    
    DEBUG_ENTER

    switch (syncState) {
        case DZ_OFFLINE_SYNC_STATE_SYNCED:
            syncButtonEnable = TRUE;
            syncButtonState = 1;
            syncButtonText = @"Synced";
            break;
            
        case DZ_OFFLINE_SYNC_STATE_ENQUEUED_FOR_SYNC:
        case DZ_OFFLINE_SYNC_STATE_SYNCING:
            syncButtonEnable = TRUE;
            syncButtonState = 1;
            syncButtonText = @"Syncing";
            break;
            
        case DZ_OFFLINE_SYNC_STATE_ENQUEUED_FOR_UNSYNC:
        case DZ_OFFLINE_SYNC_STATE_UNSYNCING:
            syncButtonEnable = TRUE;
            syncButtonState = 1;
            syncButtonText = @"Unsyncing";
            break;
            
        case DZ_OFFLINE_SYNC_STATE_UNSYNCED:
            syncButtonEnable = TRUE;
            syncButtonState = 0;
            syncButtonText = @"Sync";
            break;
            
        case DZ_OFFLINE_SYNC_STATE_SYNC_ERROR:
            syncButtonEnable = FALSE;
            syncButtonState = 0;
            syncButtonText = @"SyncErr";
            break;
            
        case DZ_OFFLINE_SYNC_STATE_UNKNOWN:
            syncButtonEnable = FALSE;
            syncButtonState = 0;
            syncButtonText = @"Sync";
            break;
    }

    [syncButton setEnabled:syncButtonEnable];
    [syncButton setState:syncButtonState];
    [syncButton setTitle:syncButtonText];
}

@end