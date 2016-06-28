//
//  JsonParserHelper.m
//  OfflineModePlayer
//
//  Created by Cyril Picheney on 07/06/2016.
//  Copyright © 2016 Cyril Picheney. All rights reserved.
//


#import "JsonParserHelper.h"

#import "JsonStreamParserDelegate.h"

static dz_stream_tokener json_parser_tokener_new(void);
static void              json_parser_tokener_free(dz_stream_tokener tok);
static dz_stream_object  json_parser_tokener_parse(dz_stream_tokener tok, const char*data, size_t len);
void  json_parser_object_release(dz_stream_object obj);

static struct dz_stream_parser_class json_parser = {
    json_parser_tokener_new,
    json_parser_tokener_free,
    json_parser_tokener_parse,
    json_parser_object_release,
};

dz_stream_tokener json_parser_tokener_new(void) {
    JsonStreamParserDelegate  *adapterDelegate = [[JsonStreamParserDelegate alloc] init];
    SBJsonStreamParserAdapter *adapter = [[SBJsonStreamParserAdapter alloc] init];
    SBJsonStreamParser        *parser  = [[SBJsonStreamParser alloc] init];
    
    [adapterDelegate setAdapter:adapter];
    [adapterDelegate setParser:parser];
    adapter.delegate = adapterDelegate;
    
    parser.delegate = adapter;
    parser.supportMultipleDocuments = YES;
    
    dz_stream_tokener tok = (__bridge_retained  dz_stream_tokener)adapterDelegate;
    return tok;
}


dz_stream_object  json_parser_tokener_parse(dz_stream_tokener tok, const char*data, size_t len)
{
    SBJsonStreamParserStatus status;
    NSData *nsdata;
    JsonStreamParserDelegate *adapterDelegate = (__bridge JsonStreamParserDelegate*)tok;
    SBJsonStreamParser*parser = [adapterDelegate parser];
    
    if (len == 0)
        len = strlen(data);
    
    nsdata = [[NSData alloc] initWithBytesNoCopy:(void*)data length:len freeWhenDone:NO];

    status = [parser parse:nsdata];
    
    if (status == SBJsonStreamParserError) {
        NSLog(@"json error %@", [[NSString alloc] initWithData:nsdata encoding:NSUTF8StringEncoding]);
        return NULL;
    } else if (status == SBJsonStreamParserComplete) {
        dz_stream_object obj = (__bridge_retained dz_stream_object)[adapterDelegate dict];
        return obj;
    } else {
        return NULL;
    }
}

void  json_parser_object_release(dz_stream_object obj) {
    // nothing to be done
}

void json_parser_tokener_free(dz_stream_tokener tok) {
    JsonStreamParserDelegate *adapterDelegateRetained = (__bridge_transfer JsonStreamParserDelegate*)tok;
    (void)adapterDelegateRetained;
}

dz_stream_parser_class json_parser_singleton() {
    return &json_parser;
}
