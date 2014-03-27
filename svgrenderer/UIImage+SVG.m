//
//  UIImage+SVG.m
//  svgrenderer
//
//  Created by Johannes Schriewer on 25.03.14.
//  Copyright (c) 2014 planetmutlu. All rights reserved.
//

#import "UIImage+SVG.h"
#import "SVGObject.h"
#import <objc/runtime.h>

void svgSwizzle(Class class, SEL originalSelector, SEL replacementSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, replacementSelector);

    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));

    if (didAddMethod) {
        class_replaceMethod(class,
                            replacementSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@implementation UIImage (SVG)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Class class = [self class]; << Implementation Method
        // Class class = object_getClass((id)self); << Class Method

        svgSwizzle(object_getClass((id)self), @selector(imageNamed:), @selector(SVGImageNamed:));
        svgSwizzle([self class], @selector(initWithContentsOfFile:), @selector(SVGInitWithContentsOfFile:));
        svgSwizzle([self class], @selector(initWithData:), @selector(SVGInitWithData:));
        svgSwizzle([self class], @selector(initWithData:scale:), @selector(SVGInitWithData:scale:));
    });
}

+ (UIImage *)SVGImageNamed:(NSString *)name {
    UIImage *result = [self SVGImageNamed:name];
    if (!result) {
        // try svg
        SVGObject *svg = [[SVGObject alloc] initWithSVGNamed:name];
        if (svg) {
            UIGraphicsBeginImageContextWithOptions(svg.boundingBox, NO, [[UIScreen mainScreen] scale]);
            [svg renderInContext:UIGraphicsGetCurrentContext()];
            result = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
    return result;
}

- (instancetype)SVGInitWithContentsOfFile:(NSString *)path {
    id result = [self SVGInitWithContentsOfFile:path];
    if (!result) {
        SVGObject *svg = [[SVGObject alloc] initWithFile:path];
        if (svg) {
            UIGraphicsBeginImageContextWithOptions(svg.boundingBox, NO, [[UIScreen mainScreen] scale]);
            [svg renderInContext:UIGraphicsGetCurrentContext()];
            result = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
    return result;
}

- (UIImage *)SVGInitWithData:(NSData *)data {
    UIImage *result = [self SVGInitWithData:data];
    if (!result) {
        // svg
        SVGObject *svg = [[SVGObject alloc] initWithData:data];
        if (svg) {
            UIGraphicsBeginImageContextWithOptions(svg.boundingBox, NO, [[UIScreen mainScreen] scale]);
            [svg renderInContext:UIGraphicsGetCurrentContext()];
            result = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
    return result;
}

- (UIImage *)SVGInitWithData:(NSData *)data scale:(CGFloat)scale {
    UIImage *result = [self SVGInitWithData:data scale:scale];
    if (!result) {
        // svg
        SVGObject *svg = [[SVGObject alloc] initWithData:data];
        if (svg) {
            UIGraphicsBeginImageContextWithOptions(svg.boundingBox, NO, scale);
            [svg renderInContext:UIGraphicsGetCurrentContext()];
            result = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
    return result;
}

@end
