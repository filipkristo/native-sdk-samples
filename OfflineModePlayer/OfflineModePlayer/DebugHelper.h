//
//  DebugHelper.h
//  OfflineModePlayer
//
//  Created by Cyril Picheney on 06/06/2016.
//  Copyright © 2016 Cyril Picheney. All rights reserved.
//

#ifndef DebugHelper_h
#define DebugHelper_h


#import <Foundation/Foundation.h>

#define DEBUG_ENTER_EXIT_FUNCTION

#ifdef DEBUG
#define DebugLog(args...) ExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#else
#define DebugLog(x...) NSLog(x);
#endif

#ifdef DEBUG_ENTER_EXIT_FUNCTION
#define DEBUG_ENTER DebugLog(@"----->");
#define DEBUG_EXIT  DebugLog(@"<-----");
#else
#define DEBUG_ENTER
#define DEBUG_EXIT
#endif

void ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...);


#endif /* DebugHelper_h */
