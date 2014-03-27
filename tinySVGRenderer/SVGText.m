//
//  SVGText.m
//  svgrenderer
//
//  Created by Johannes Schriewer on 25.03.14.
//  Copyright (c) 2014 planetmutlu. All rights reserved.
//

#import "SVGText.h"
#import "SVGPrivate.h"

@implementation SVGText

#pragma mark - API

+ (instancetype)textWithShape:(struct svgtiny_shape *)shape {
    return [[self alloc] initWithShape:shape];
}

- (instancetype)initWithShape:(struct svgtiny_shape *)shape {
    self = [super init];
    if (self) {
        memcpy(&_shape, shape, sizeof(struct svgtiny_shape));
        _transform = CGAffineTransformIdentity;
        [self parseShape:&_shape];
    }
    return self;

}

- (void)renderInContext:(CGContextRef)context {
    if (!CGAffineTransformEqualToTransform(CGAffineTransformIdentity, _transform)) {
        CGContextSaveGState(context);
        CGContextConcatCTM(context, _transform);
    }

    CGPoint origin = _origin;
    origin.y -= [_font ascender];
    [_text drawAtPoint:origin];

    if (!CGAffineTransformEqualToTransform(CGAffineTransformIdentity, _transform)) {
        CGContextRestoreGState(context);
    }
}

#pragma mark - Internal

- (void)parseShape:(struct svgtiny_shape *)shape {
    if (shape->stroke != svgtiny_TRANSPARENT) {
        _strokeColor = [UIColor colorWithRed:svgtiny_RED(shape->stroke) / 255.0 green:svgtiny_GREEN(shape->stroke) / 255.0 blue:svgtiny_BLUE(shape->stroke) / 255.0 alpha:1.0];
        _strokeWidth = shape->stroke_width;
	} else {
        _strokeColor = [UIColor clearColor];
    }

	if (shape->fill != svgtiny_TRANSPARENT) {
        _fillColor = [UIColor colorWithRed:svgtiny_RED(shape->fill) / 255.0 green:svgtiny_GREEN(shape->fill) / 255.0 blue:svgtiny_BLUE(shape->fill) / 255.0 alpha:1.0];
    } else {
        _fillColor = [UIColor clearColor];
    }

    switch (shape->text.text_alignment) {
        case svgtiny_TextAlignmentRight:
            _textAlignment = NSTextAlignmentRight;
            break;
        case svgtiny_TextAlignmentCenter:
            _textAlignment = NSTextAlignmentCenter;
            break;
        case svgtiny_TextAlignmentLeft:
        default:
            _textAlignment = NSTextAlignmentLeft;
            break;
    }

    NSString *fontModifier = @"";
    if (shape->text.font_weight < 400) {
        fontModifier = @"-light";
    } else if (shape->text.font_weight >= 700) {
        fontModifier = @"-bold";
    }
    NSString *fontName = [NSString stringWithFormat:@"%s%@", shape->text.font_family, fontModifier];
    _font = [UIFont fontWithName:fontName size:shape->text.font_size];
    if (!_font) {
        _font = [UIFont fontWithName:@(shape->text.font_family) size:shape->text.font_size];
        if (!_font) {
            _font = [UIFont systemFontOfSize:shape->text.font_size];
        }
    }

    // TODO: support <tspan>

    _text = [[NSAttributedString alloc] initWithString:[NSString stringWithUTF8String:shape->text.text]
                                           attributes:@{ NSFontAttributeName : _font,
                                                         NSForegroundColorAttributeName : _fillColor,
                                                         NSStrokeColorAttributeName : _strokeColor,
                                                         NSStrokeWidthAttributeName : @(_strokeWidth),
                                                         }];
    _origin = CGPointMake(shape->text.x, shape->text.y);

    _transform = CGAffineTransformMake(shape->text.transform_matrix[0], shape->text.transform_matrix[1], shape->text.transform_matrix[2], shape->text.transform_matrix[3], shape->text.transform_matrix[4], shape->text.transform_matrix[5]);
}

@end
