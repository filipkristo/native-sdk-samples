#import <Foundation/Foundation.h>
#import "SBJsonStreamParserAdapter.h"

@interface JsonStreamParserDelegate : NSObject <SBJsonStreamParserAdapterDelegate>

@property (nonatomic, strong) SBJsonStreamParserAdapter* adapter;
@property (nonatomic, strong) SBJsonStreamParser* parser;
@property (nonatomic, strong) NSDictionary* dict;

@end
