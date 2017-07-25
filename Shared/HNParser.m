//
//  HNParser.m
//  HNReader
//
//  Created by Andrew Shepard on 1/31/14.
//  Copyright 2014 Andrew Shepard. All rights reserved.
//

#import "HNParser.h"
#import "HNEntry.h"

#import <libxml/HTMLparser.h>

static NSDictionary* dictionaryFromAttributes(const xmlChar **atts) {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    if (atts != NULL) {
        for (int i = 0; (atts[i] != NULL); i++) {
            const xmlChar *attribValue = NULL;
            const xmlChar *attribName = atts[i++];
            
            if (atts[i] != NULL) {
                attribValue = atts[i];
                
                NSString *name = [NSString stringWithUTF8String:(const char *)attribName];
                NSString *value = [NSString stringWithUTF8String:(const char *)attribValue];
                
                [dictionary setObject:value forKey:name];
            }
        }
    }
    
    return [dictionary copy];
}

static void searchForStoryLink(void *ctx, const xmlChar *name, const xmlChar **atts) {
    HNParser *parser = (__bridge HNParser *)ctx;
    
    if (!xmlStrcmp(name, (xmlChar *)"a")) {
        NSDictionary *attributes = dictionaryFromAttributes(atts);
        NSString *href = [attributes objectForKey:@"href"];
        NSString *klass = [attributes objectForKey:@"class"];
        
        if ([klass isEqualToString:@"storylink"] && href != nil) {
            parser.current.linkURL = href;
        }
    }
}

static void searchForEntry(void *ctx, const xmlChar *name, const xmlChar **atts) {
    HNParser *parser = (__bridge HNParser *)ctx;
    
    if (!xmlStrcmp(name, (xmlChar *)"tr")) {
        NSDictionary *attributes = dictionaryFromAttributes(atts);
        NSString *klass = [attributes objectForKey:@"class"];
        
        if ([klass isEqualToString:@"athing"]) {
            // found <tr> tag with class of "athing"
            // this represents the start of a new entry
            
            parser.current = [[HNEntry alloc] init];
            [parser nextState];
        }
        else if ([klass isEqualToString:@"morespace"]) {
            [parser terminate];
        }
    }
}

static void startElementSAX(void *ctx, const xmlChar *name, const xmlChar **atts) {
    HNParser *parser = (__bridge HNParser *)ctx;
    
    if (parser.state == HNParserParserStateSearchForEntry) {
        searchForEntry(ctx, name, atts);
    }
    else if (parser.state == HNParserParserStateSearchForStoryLink) {
        searchForStoryLink(ctx, name, atts);
    }
}

static void charactersFoundSAX(void *ctx, const xmlChar *ch, int len) {
    HNParser *parser = (__bridge HNParser *)ctx;
    
    if (parser.state == HNParserParserStateSearchForStoryLink) {
        if (parser.current.linkURL != nil) {
            // FIXME: should be appending characters
            
            NSString *title = [NSString stringWithUTF8String:(const char *)ch];
            parser.current.title = title;
        }
    }
}

static void endElementSAX(void *ctx, const xmlChar *name) {
    HNParser *parser = (__bridge HNParser *)ctx;
    
    if (parser.state == HNParserParserStateSearchForStoryLink) {
        if (parser.current.linkURL != nil && parser.current.title != nil) {
            // if title and url are both not nil
            // then the current entry should be done
             
            [parser nextState];
        }
    }
}

static void errorEncounteredSAX(void *ctx, const char *msg, ...) {
    // Handle errors as appropriate for your application.
    NSCAssert(NO, @"Unhandled error encountered during SAX parse.");
}

static htmlSAXHandler simpleSAXHandlerStruct = {
    NULL,                       /* internalSubset */
    NULL,                       /* isStandalone   */
    NULL,                       /* hasInternalSubset */
    NULL,                       /* hasExternalSubset */
    NULL,                       /* resolveEntity */
    NULL,                       /* getEntity */
    NULL,                       /* entityDecl */
    NULL,                       /* notationDecl */
    NULL,                       /* attributeDecl */
    NULL,                       /* elementDecl */
    NULL,                       /* unparsedEntityDecl */
    NULL,                       /* setDocumentLocator */
    NULL,                       /* startDocument */
    NULL,                       /* endDocument */
    startElementSAX,            /* startElement*/
    endElementSAX,              /* endElement */
    NULL,                       /* reference */
    charactersFoundSAX,         /* characters */
    NULL,                       /* ignorableWhitespace */
    NULL,                       /* processingInstruction */
    NULL,                       /* comment */
    NULL,                       /* warning */
    errorEncounteredSAX,        /* error */
    NULL,                       /* fatalError //: unused error() get all the errors */
    NULL,                       /* getParameterEntity */
    NULL,                       /* cdataBlock */
    NULL,                       /* externalSubset */
    XML_SAX2_MAGIC,             //
    NULL,
    NULL,                       /* startElementNs */
    NULL,                       /* endElementNs */
    NULL,                       /* serror */
};

@interface HNParser ()

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSMutableArray *results;

@property (nonatomic, assign) htmlParserCtxt *htmlContext;
@property (nonatomic, assign, readwrite) HNParserParserState state;

@end

@implementation HNParser

- (instancetype)initWithData:(NSData *)data {
    if (self = [super init]) {
        self.data = data;
        self.state = HNParserParserStateIdle;
        self.results = [NSMutableArray array];
    }
    
    return self;
}

- (void)nextState {
    if (_state == HNParserParserStateSearchForEntry) {
        _state = HNParserParserStateSearchForStoryLink;
    }
    else if (_state == HNParserParserStateSearchForStoryLink) {
        [_results addObject:_current];
        self.current = nil;
        
        _state = HNParserParserStateSearchForEntry;
    }
    else {
        _state = HNParserParserStateIdle;
    }
}

- (void)terminate {
    _state = HNParserParserStateIdle;
}

- (NSArray<HNEntry *> *)parseEntries {
    _state = HNParserParserStateSearchForEntry;
    _current = nil;
    
    self.htmlContext = htmlCreatePushParserCtxt(&simpleSAXHandlerStruct, (__bridge void *)self, NULL, 0, NULL, XML_CHAR_ENCODING_UTF8);
    
    htmlParseChunk(_htmlContext, [_data bytes], (int)[_data length], 0);
    htmlFreeParserCtxt(_htmlContext);
    
    return [NSArray arrayWithArray:_results];
}

@end
