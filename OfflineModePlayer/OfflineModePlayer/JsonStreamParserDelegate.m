#import "JsonStreamParserDelegate.h"

@implementation JsonStreamParserDelegate

- (void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict {
    // Dictonnary found
    [self setDict:dict];
}

- (void)parser:(SBJsonStreamParser *)parser foundArray:(NSArray *)array {
    // Array found (no need to be supported for this sample code)
}

@end
