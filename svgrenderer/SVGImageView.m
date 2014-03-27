//
//  SVGView.m
//  svgrenderer
//
//  Created by Johannes Schriewer on 24.03.14.
//  Copyright (c) 2014 planetmutlu. All rights reserved.
//

#import "SVGImageView.h"
#import "SVGObject.h"

@interface SVGImageView () {
    SVGObject *svgObject;
}

@end

@implementation SVGImageView

- (void)setup {
    _svgFile         = nil;
    [self setContentMode:UIViewContentModeRedraw];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame svgFile:(NSString *)svgFile {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        [self setSvgFile:svgFile];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);

    [svgObject setSize:rect.size];
    [svgObject renderInContext:context];
}

#pragma mark - Setter

- (void)setSvgFile:(NSString *)svgFile {
    if (_svgFile != svgFile) {
        _svgFile = svgFile;
        svgObject = [[SVGObject alloc] initWithSVGNamed:svgFile];
        [self setNeedsDisplay];
    }
}

@end
