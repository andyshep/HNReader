//
//  HNCommentsParser.m
//  HNReader iOS
//
//  Created by Andrew Shepard on 7/26/17.
//

#import "HNCommentsParser.h"
#import "HNComment.h"

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

static void searchForTree(void *ctx, const xmlChar *name, const xmlChar **atts) {
    HNCommentsParser *parser = (__bridge HNCommentsParser *)ctx;
    
    if (!xmlStrcmp(name, (xmlChar *)"tr")) {
        NSDictionary *attributes = dictionaryFromAttributes(atts);
        NSString *klass = [attributes objectForKey:@"class"];
        
        if ([klass isEqualToString:@"athing comtr "]) {
            // found <tr> tag with class of "comtr"
            // this represents the start of a new comment
            parser.current = [[HNComment alloc] init];
            [parser nextState];
        }
    }
}

static void searchForIndent(void *ctx, const xmlChar *name, const xmlChar **atts) {
    HNCommentsParser *parser = (__bridge HNCommentsParser *)ctx;
    
    if (!xmlStrcmp(name, (xmlChar *)"img")) {
        NSDictionary *attributes = dictionaryFromAttributes(atts);
        NSString *src = [attributes objectForKey:@"src"];
        NSString *width = [attributes objectForKey:@"width"];
        
        if ([src isEqualToString:@"s.gif"]) {
            // found a spacer.gif
            // capture the width attribute for comment spacing
            parser.current.padding = [width integerValue];
            [parser nextState];
        }
    }
}

static void searchForComment(void *ctx, const xmlChar *name, const xmlChar **atts) {
    HNCommentsParser *parser = (__bridge HNCommentsParser *)ctx;
    
    if (!xmlStrcmp(name, (xmlChar *)"div")) {
        NSDictionary *attributes = dictionaryFromAttributes(atts);
        NSString *klass = [attributes objectForKey:@"class"];
        
        if ([klass isEqualToString:@"comment"]) {
            // found a comment body, move onto capturing it
            [parser nextState];
        }
    }
}

static void searchForUser(void *ctx, const xmlChar *name, const xmlChar **atts) {
    HNCommentsParser *parser = (__bridge HNCommentsParser *)ctx;
    
    if (!xmlStrcmp(name, (xmlChar *)"a")) {
        NSDictionary *attributes = dictionaryFromAttributes(atts);
        NSString *klass = [attributes objectForKey:@"class"];
        
        if ([klass isEqualToString:@"hnuser"]) {
            [parser nextState];
        }
    }
}

static void searchForAge(void *ctx, const xmlChar *name, const xmlChar **atts) {
    HNCommentsParser *parser = (__bridge HNCommentsParser *)ctx;
    
    if (!xmlStrcmp(name, (xmlChar *)"span")) {
        NSDictionary *attributes = dictionaryFromAttributes(atts);
        NSString *klass = [attributes objectForKey:@"class"];
        
        if ([klass isEqualToString:@"age"]) {
            [parser nextState];
        }
    }
}

static void appendCommentStartTags(void *ctx, const xmlChar *name, const xmlChar **atts) {
    HNCommentsParser *parser = (__bridge HNCommentsParser *)ctx;
    NSString *existing = parser.current.commentString;
    
    if (!xmlStrcmp(name, (xmlChar *)"div")) {
        NSDictionary *attributes = dictionaryFromAttributes(atts);
        NSString *klass = [attributes objectForKey:@"class"];
        
        if ([klass isEqualToString:@"reply"]) {
            // found reply div, comment is over
            // write closing tag and move to next state
            
            NSString *comment = [existing stringByAppendingString:@"</span>"];
            
            comment = [comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            comment = [comment stringByReplacingOccurrencesOfString:@"<span></span>" withString:@""];
            
            parser.current.commentString = comment;
            
            [parser nextState];
        }
    }
    else {
        if (!xmlStrcmp(name, (xmlChar *)"a")) {
            // grab attributes too
            NSDictionary *attributes = dictionaryFromAttributes(atts);
            NSString *href = [attributes objectForKey:@"href"];
            
            NSString *tag = [NSString stringWithFormat:@"<a href=\"%@\">", href];
            
            parser.current.commentString = [existing stringByAppendingString:tag];
        }
        else {
            // just write tag
            NSString *value = [NSString stringWithUTF8String:(const char *)name];
            NSString *tag = [NSString stringWithFormat:@"<%@>", value];
            
            parser.current.commentString = [existing stringByAppendingString:tag];
        }
    }
}

static void startElementSAX(void *ctx, const xmlChar *name, const xmlChar **atts) {
    HNCommentsParser *parser = (__bridge HNCommentsParser *)ctx;
    
    if (parser.state == HNCommentsParserStateSearchForTree) {
        searchForTree(ctx, name, atts);
    }
    else if (parser.state == HNCommentsParserStateSearchForIndent) {
        searchForIndent(ctx, name, atts);
    }
    else if (parser.state == HNCommentsParserStateSearchForUser) {
        searchForUser(ctx, name, atts);
    }
    else if (parser.state == HNCommentsParserStateSearchForAge) {
        searchForAge(ctx, name, atts);
    }
    else if (parser.state == HNCommentsParserStateSearchForComment) {
        searchForComment(ctx, name, atts);
    }
    else if (parser.state == HNCommentsParserStateLoadComment) {
        appendCommentStartTags(ctx, name, atts);
    }
}

static void charactersFoundSAX(void *ctx, const xmlChar *ch, int len) {
    HNCommentsParser *parser = (__bridge HNCommentsParser *)ctx;
    
    if (parser.state == HNCommentsParserStateLoadUser) {
        NSString *string = [NSString stringWithUTF8String:(const char *)ch];
        parser.current.username = string;
    }
    else if (parser.state == HNCommentsParserStateLoadAge) {
        NSString *string = [NSString stringWithUTF8String:(const char *)ch];
        parser.current.timeSinceCreation = string;
    }
    else if (parser.state == HNCommentsParserStateLoadComment) {
        NSString *current = [NSString stringWithUTF8String:(const char *)ch];
        NSString *existing = parser.current.commentString;
        
        parser.current.commentString = [existing stringByAppendingString:current];
    }
}

static void endElementSAX(void *ctx, const xmlChar *name) {
    HNCommentsParser *parser = (__bridge HNCommentsParser *)ctx;
    
    if (parser.state == HNCommentsParserStateLoadUser) {
        if (!xmlStrcmp(name, (xmlChar *)"a")) {
            // found closing </a> tag, username is loaded
            
            [parser nextState];
        }
    }
    else if (parser.state == HNCommentsParserStateLoadAge) {
        if (!xmlStrcmp(name, (xmlChar *)"a")) {
            // found closing </a> tag, comment age is loaded
            
            [parser nextState];
        }
    }
    else if (parser.state == HNCommentsParserStateLoadComment) {
        NSString *existing = parser.current.commentString;
        NSString *value = [NSString stringWithUTF8String:(const char *)name];
        NSString *tag = [NSString stringWithFormat:@"</%@>", value];
        
        parser.current.commentString = [existing stringByAppendingString:tag];
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

@interface HNCommentsParser ()

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSMutableArray *results;

@property (nonatomic, assign) htmlParserCtxt *htmlContext;
@property (nonatomic, assign, readwrite) HNCommentsParserState state;

@end

@implementation HNCommentsParser

- (instancetype)initWithData:(NSData *)data {
    if (self = [super init]) {
        self.data = data;
        self.state = HNCommentsParserStateIdle;
        self.results = [NSMutableArray array];
    }
    
    return self;
}

- (void)nextState {
    if (_state == HNCommentsParserStateSearchForTree) {
        _state = HNCommentsParserStateSearchForIndent;
    }
    else if (_state == HNCommentsParserStateSearchForIndent) {
        _state = HNCommentsParserStateSearchForUser;
    }
    else if (_state == HNCommentsParserStateSearchForUser) {
        _state = HNCommentsParserStateLoadUser;
    }
    else if (_state == HNCommentsParserStateLoadUser) {
        _state = HNCommentsParserStateSearchForAge;
    }
    else if (_state == HNCommentsParserStateSearchForAge) {
        _state = HNCommentsParserStateLoadAge;
    }
    else if (_state == HNCommentsParserStateLoadAge) {
        _state = HNCommentsParserStateSearchForComment;
    }
    else if (_state == HNCommentsParserStateSearchForComment) {
        _state = HNCommentsParserStateLoadComment;
    }
    else if (_state == HNCommentsParserStateLoadComment) {
        [_results addObject:_current];
        self.current = nil;
        
        _state = HNCommentsParserStateSearchForTree;
    }
}

- (NSArray<HNComment *> *)parseComments {
    _state = HNCommentsParserStateSearchForTree;
    _current = nil;
    
    self.htmlContext = htmlCreatePushParserCtxt(&simpleSAXHandlerStruct, (__bridge void *)self, NULL, 0, NULL, XML_CHAR_ENCODING_UTF8);
    
    htmlParseChunk(_htmlContext, [_data bytes], (int)[_data length], 0);
    htmlFreeParserCtxt(_htmlContext);
    
    return [NSArray arrayWithArray:_results];
}

@end
