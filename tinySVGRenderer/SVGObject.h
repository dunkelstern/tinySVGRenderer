//
//  SVGObject.h
//  svgrenderer
//
//  Created by Johannes Schriewer on 25.03.14.
//  Copyright (c) 2014 planetmutlu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVGObject : NSObject

- (instancetype)initWithSVGNamed:(NSString *)name;
- (instancetype)initWithFile:(NSString *)filename;
- (instancetype)initWithString:(NSString *)string;
- (instancetype)initWithData:(NSData *)data;

- (void)renderInContext:(CGContextRef)context;

@property (nonatomic, assign) CGSize size;
@property (nonatomic, readonly) CGSize boundingBox;
@property (nonatomic, readonly) NSArray *svgItems; // all objects will support SVGItem Protocol

@property (nonatomic, readonly) NSString *filename; // may be nil if loaded from string
@property (nonatomic, readonly) NSString *svgString;
@property (nonatomic, readonly) NSData *svgData;

@end
