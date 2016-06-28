//
//  DZRTrack.h
//

#import <Foundation/Foundation.h>

@interface DZRTrack : NSObject {
@public
    NSInteger trackId;
    NSString* title;
    NSString* artist;
}

@property NSInteger trackId;
@property (copy) NSString *title;
@property (copy) NSString *artist;
@property BOOL readable;
@property (copy) NSString *syncDonePercent;

- (id)initWithId:(int)trackId;

@end
