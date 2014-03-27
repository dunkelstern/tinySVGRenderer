//
//  SVGPath.m
//  svgrenderer
//
//  Created by Johannes Schriewer on 25.03.14.
//  Copyright (c) 2014 planetmutlu. All rights reserved.
//

#import "SVGPath.h"
#import "SVGPrivate.h"

@implementation SVGPath

#pragma mark - API

+ (instancetype)pathWithShape:(struct svgtiny_shape *)shape {
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
    // TODO: Linear and Radial gradients
    // TODO: embedded background images

    if (![self.fillColor isEqual:[UIColor clearColor]]) {
        CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
        CGContextAddPath(context, self.cgPath);
        CGContextFillPath(context);
    }

    if (![self.strokeColor isEqual:[UIColor clearColor]]) {
        CGContextSetLineWidth(context, self.strokeWidth);
        CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
        CGContextAddPath(context, self.cgPath);
        CGContextStrokePath(context);
    }
}

#pragma mark - Setter

- (void)setTransform:(CGAffineTransform)transform {
    if (!CGAffineTransformEqualToTransform(_transform, transform)) {
        _transform = transform;
        [self parseShape:&_shape];
    }
}

#pragma mark - internal

- (void)parseShape:(struct svgtiny_shape *)shape {
    CGMutablePathRef currentPath = CGPathCreateMutable();

	for (unsigned int j = 0; j != shape->path.length; ) {
		switch ((int) shape->path.path[j]) {
            case svgtiny_PATH_MOVE:
                CGPathMoveToPoint(currentPath, &_transform, shape->path.path[j + 1], shape->path.path[j + 2]);
                j += 3;
                break;
            case svgtiny_PATH_CLOSE:
                CGPathCloseSubpath(currentPath);
                j += 1;
                break;
            case svgtiny_PATH_LINE:
                CGPathAddLineToPoint(currentPath, &_transform, shape->path.path[j + 1], shape->path.path[j + 2]);
                j += 3;
                break;
            case svgtiny_PATH_BEZIER:
                CGPathAddCurveToPoint(currentPath, &_transform, shape->path.path[j + 1], shape->path.path[j + 2], shape->path.path[j + 3], shape->path.path[j + 4], shape->path.path[j + 5], shape->path.path[j + 6]);
                j += 7;
                break;
            default:
                NSLog(@"Error drawing path segment");
                j += 1;
		}
	}
	if (shape->stroke != svgtiny_TRANSPARENT) {
        _strokeColor = [UIColor colorWithRed:svgtiny_RED(shape->stroke) / 255.0 green:svgtiny_GREEN(shape->stroke) / 255.0 blue:svgtiny_BLUE(shape->stroke) / 255.0 alpha:1.0];
        _strokeWidth = shape->stroke_width;
	} else {
        _strokeColor = [UIColor clearColor];
    }

	if (shape->fill == svgtiny_TRANSPARENT) {
        _fillColor = [UIColor clearColor];
    } else {
        _fillColor = [UIColor colorWithRed:svgtiny_RED(shape->fill) / 255.0 green:svgtiny_GREEN(shape->fill) / 255.0 blue:svgtiny_BLUE(shape->fill) / 255.0 alpha:1.0];
    }

    _cgPath = CGPathCreateCopy(currentPath);
    CGPathRelease(currentPath);
}

@end
