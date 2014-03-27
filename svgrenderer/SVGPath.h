//
//  SVGPath.h
//  svgrenderer
//
//  Created by Johannes Schriewer on 25.03.14.
//  Copyright (c) 2014 planetmutlu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVGItem.h"

@interface SVGPath : NSObject <SVGItem>

+ (instancetype)pathWithShape:(struct svgtiny_shape *)shape;
@property (nonatomic, readonly) struct svgtiny_shape shape;

@property (nonatomic, readonly) CGPathRef cgPath;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat strokeWidth;

@property (nonatomic, assign) CGAffineTransform transform;

@end
