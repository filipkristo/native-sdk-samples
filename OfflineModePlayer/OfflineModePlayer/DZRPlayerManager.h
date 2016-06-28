//
//  DZRPlayerManager.h
//  OfflineModePlayer
//
//  Created by Cyril Picheney on 13/06/2016.
//  Copyright © 2016 Cyril Picheney. All rights reserved.
//

#ifndef DZRPlayerManager_h
#define DZRPlayerManager_h

#import "DebugHelper.h"
#import "deezer-connect.h"

@interface DZRPlayerManager : NSObject
{
    
}

- (DZRPlayerManager *)initWithConnect:(dz_connect_handle)dzConnect;

@end

#endif /* DZRPlayerManager_h */
