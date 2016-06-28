//
//  PlaylistViewController.h
//  OfflineModePlayer
//
//  Created by Cyril Picheney on 06/06/2016.
//  Copyright © 2016 Cyril Picheney. All rights reserved.
//

#ifndef PlaylistViewController_h
#define PlaylistViewController_h


#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

#import "DebugHelper.h"
#import "DZRNative.h"

@interface PlaylistViewController : NSViewController <NSTableViewDataSource,DZRNativeContentDisplayDelegate>
{
    
    IBOutlet NSTextField *dzrUrlEntry;
    
    IBOutlet NSTableView *playlistTableView;
    
    IBOutlet NSButton *syncButton;
}

- (IBAction)validateDZRUrlEntry:(id)sender;

- (IBAction)clickOnSync:(id)sender;

@end

#endif /* MainWindowController_h */
