//
//  SVGObject.m
//  svgrenderer
//
//  Created by Johannes Schriewer on 25.03.14.
//  Copyright (c) 2014 planetmutlu. All rights reserved.
//

#import "SVGObject.h"
#import "SVGPrivate.h"

@interface SVGObject () {
    // Handling memory warnings
    NSObject *sentinel;

    // Cacheing infrastructure
    dom_document *dom;
    NSMutableArray *svgItems;
}
@end

@implementation SVGObject
@dynamic svgString, svgItems;

- (void)setup {
    _filename        = nil;
    dom              = NULL;
    _size            = CGSizeZero;
    sentinel         = [[NSObject alloc] init];
    svgItems         = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryWarningReceived:) name:UIApplicationDidReceiveMemoryWarningNotification object:sentinel];
}

#pragma mark - API

- (instancetype)initWithSVGNamed:(NSString *)name {
    self = [super init];
    if (self) {
        [self setup];
        if ([[name pathExtension] caseInsensitiveCompare:@"svg"] == NSOrderedSame) {
            _filename = [[NSBundle mainBundle] pathForResource:[name stringByDeletingPathExtension] ofType:[name pathExtension]];
        } else {
            _filename = [[NSBundle mainBundle] pathForResource:name ofType:@"svg"];
        }
        _svgData = [NSData dataWithContentsOfFile:_filename];
      
        // test memory leak
        // for ( int dbg = 0; dbg < 50; dbg++)
        if (![self parseSVG]) return nil;
    }
    return self;
}

- (instancetype)initWithFile:(NSString *)filename {
    self = [super init];
    if (self) {
        [self setup];
        _filename = filename;
        _svgData = [NSData dataWithContentsOfFile:filename];
        if (![self parseSVG]) return nil;
    }
    return self;
}

- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        [self setup];
        _filename = nil;
        _svgData = [string dataUsingEncoding:NSUTF8StringEncoding];
        if (![self parseSVG]) return nil;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        [self setup];
        _filename = nil;
        _svgData = data;
        if (![self parseSVG]) return nil;
    }
    return self;
}

- (void)renderInContext:(CGContextRef)context {
    // draw the cache
    for (NSObject<SVGItem> *item in svgItems) {
        [item renderInContext:context];
    }
}

#pragma mark - Memory management

- (void)memoryWarningReceived:(NSNotification *)notification {
    [svgItems removeAllObjects];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:sentinel];
    if (dom) svgtiny_free_dom(dom);
}

#pragma mark - getter/setter

- (void)setSize:(CGSize)size {
    if (!CGSizeEqualToSize(_size, size)) {
        _size = size;
        [self updatePathsForSize:size];
    }
}

- (NSString *)svgString {
    return [[NSString alloc] initWithData:_svgData encoding:NSUTF8StringEncoding];
}

- (NSArray *)svgItems {
    return [NSArray arrayWithArray:svgItems];
}

#pragma mark - Internal

- (BOOL)parseSVG {
    if ((!_svgData) || ([_svgData length] == 0)) {
        return NO;
    }

    if (dom) {
        svgtiny_free_dom(dom);
    }

    /* parse */
    int result = svgtiny_parse_dom([_svgData bytes], [_svgData length], [_filename UTF8String], &dom);
    if (result != svgtiny_OK) {
        NSLog(@"DOM parse error");
        return NO;
    }

    // fill size from viewport
    dom_exception exc;
    dom_element *svg;
    exc = dom_document_get_document_element(dom, &svg);
    if (exc == DOM_NO_ERR) {
        dom_string *name, *result;

        dom_string_create((uint8_t *)"width", 5, &name);
        dom_element_get_attribute(svg, name, &result);
        dom_string_unref(name);
        if (result) {
            _boundingBox = CGSizeMake(atoi(dom_string_data(result)), _boundingBox.height);
            dom_string_unref(result);
        }

        dom_string_create((uint8_t *)"height", 6, &name);
        dom_element_get_attribute(svg, name, &result);
        dom_string_unref(name);
        if (result) {
            _boundingBox = CGSizeMake(_boundingBox.width, atoi(dom_string_data(result)));
            dom_string_unref(result);
        }

        if ((_boundingBox.height == 0) || (_boundingBox.width == 0)) {
            dom_string_create((uint8_t *)"viewBox", 7, &name);
            dom_element_get_attribute(svg, name, &result);
            dom_string_unref(name);
            if (result) {
                NSString *resultString = [[NSString alloc] initWithBytes:dom_string_data(result) length:dom_string_length(result) encoding:NSUTF8StringEncoding];
                dom_string_unref(result);
                NSArray *components = [resultString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                _boundingBox = CGSizeMake([components[2] integerValue], [components[3] integerValue]);
            }
        }
      
        dom_node_unref(svg); // must unref or svgtiny_free_dom cannot free dom
    }

    if (CGSizeEqualToSize(_size, CGSizeZero)) {
        _size = _boundingBox;
        [self updatePathsForSize:_size];
    }
    return YES;
}

- (void)updatePathsForSize:(CGSize)size {
    if (!dom) {
        [self parseSVG];
    }
    [svgItems removeAllObjects];

    struct svgtiny_diagram *diagram;
    diagram = svgtiny_create();
    if (!diagram) {
        NSLog(@"Creating svg object failed");
        return;
    }

    int result = svgtiny_parse_svg_from_dom(diagram, dom, size.width, size.height);
    if (result != svgtiny_OK) {
        switch (result) {
            case svgtiny_OUT_OF_MEMORY:
                NSLog(@"Out of memory");
                break;
            case svgtiny_LIBDOM_ERROR:
                NSLog(@"Invalid XML");
                break;
            case svgtiny_NOT_SVG:
                NSLog(@"Not a SVG file");
                break;
            case svgtiny_SVG_ERROR:
                NSLog(@"SVG Error at line %i: %s", diagram->error_line, diagram->error_message);
                break;
            default:
                NSLog(@"Unknown error");
                break;
        }
    }

    // TODO: Embedded images
    // create paths
    for (int i = 0; i != diagram->shape_count; i++) {
        switch (diagram->shape[i].type) {
            case svgtiny_ShapeTypePath:
                [svgItems addObject:[SVGPath pathWithShape:&diagram->shape[i]]];
                break;

            case svgtiny_ShapeTypeText:
                [svgItems addObject:[SVGText textWithShape:&diagram->shape[i]]];
                break;

            case svgtiny_ShapeTypeTextArea:
            case svgtiny_ShapeTypeUnused:
            default:
                NSLog(@"unsupported shape type");
                break;
        }
	}
    svgtiny_free(diagram);
}

@end
