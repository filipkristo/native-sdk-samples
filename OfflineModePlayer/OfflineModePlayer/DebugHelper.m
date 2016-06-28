//
//  DebugHelper.m
//  OfflineModePlayer
//
//  Created by Cyril Picheney on 07/06/2016.
//  Copyright © 2016 Cyril Picheney. All rights reserved.
//


#import "DebugHelper.h"


// Custom log function example comming from:
// http://code.tutsplus.com/tutorials/quick-tip-customize-nslog-for-easier-debugging--mobile-19066

void ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...)
{
    // Type to hold information about variable arguments.
    va_list ap;
    
    // Initialize a variable argument list.
    va_start (ap, format);
    
    // NSLog only adds a newline to the end of the NSLog format if
    // one is not already there.
    // Here we are utilizing this feature of NSLog()
    if (![format hasSuffix: @"\n"])
    {
        format = [format stringByAppendingString: @"\n"];
    }
    
    NSString *body = [[NSString alloc] initWithFormat:format arguments:ap];
    
    // End using variable argument list.
    va_end (ap);
    
    NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
    fprintf(stderr, "(%s:%d) (%s) %s",
            [fileName UTF8String],
            lineNumber,
            functionName,
            [body UTF8String]);
}
