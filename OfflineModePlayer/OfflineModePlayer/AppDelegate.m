//
//  AppDelegate.m
//  OfflineModePlayer
//
//  Created by Cyril Picheney on 14/06/2016.
//  Copyright © 2016 Deezer. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"

@implementation AppDelegate


// -------------------------------------------------------------------------------
//	newDocument:sender
// -------------------------------------------------------------------------------
- (IBAction)newDocument:(id)sender
{
    if (myMainWindowController == nil)
    {
        myMainWindowController = [[MainWindowController alloc] initWithWindowNibName:@"MainWindow"];
    }
    [myMainWindowController showWindow:self];
}

// -------------------------------------------------------------------------------
//	applicationDidFinishLaunching:notification
// -------------------------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
    [self newDocument:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
