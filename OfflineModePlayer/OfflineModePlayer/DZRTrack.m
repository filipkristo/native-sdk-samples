//
//  DZRTrack.m

#import "DZRTrack.h"

@implementation DZRTrack

@synthesize trackId;
@synthesize title;
@synthesize readable;
@synthesize artist;

- (id)initWithId:(int) trackid;
{
    self = [super init];
    if (self) {
        self.trackId = trackid;
    }
    return self;
}

@end
