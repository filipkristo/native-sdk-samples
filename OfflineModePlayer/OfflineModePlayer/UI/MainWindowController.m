//
//  MainWindowController.h
//  OfflineModePlayer
//
//  Created by Cyril Picheney on 06/06/2016.
//  Copyright © 2016 Cyril Picheney. All rights reserved.
//

#import "MainWindowController.h"
#import "PlaylistViewController.h"

#import "deezer-connect.h"


@implementation MainWindowController

- (void)awakeFromNib
{
    DEBUG_ENTER

    self.myPlayListViewController = [[PlaylistViewController alloc] initWithNibName:@"PlaylistView" bundle:nil];

    // Embed the current view to our host view
    [playlistView addSubview:[(NSViewController *)self.myPlayListViewController view]];

    // Make sure we automatically resize the controller's view to the current window size
    [[(NSViewController *)self.myPlayListViewController view] setFrame:[playlistView bounds]];

}

// -------------------------------------------------------------------------------
//	viewController
// -------------------------------------------------------------------------------
- (NSViewController *)viewController
{
    DEBUG_ENTER
    return (NSViewController *)self.myPlayListViewController;
}

-(void)dealloc
{
    DEBUG_ENTER
    return;
}

@end