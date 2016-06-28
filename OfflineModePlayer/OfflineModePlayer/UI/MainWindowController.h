//
//  MainWindowController.h
//  OfflineModePlayer
//
//  Created by Cyril Picheney on 06/06/2016.
//  Copyright © 2016 Cyril Picheney. All rights reserved.
//

#ifndef MainWindowController_h
#define MainWindowController_h


#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

#import "DebugHelper.h"

@class PlaylistViewController;

@interface MainWindowController : NSWindowController
{
    IBOutlet NSView *playlistView;
}

@property (nonatomic, strong) PlaylistViewController *myPlayListViewController;

@end

#endif /* MainWindowController_h */
