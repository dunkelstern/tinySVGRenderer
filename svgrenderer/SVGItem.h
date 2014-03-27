//
//  SVGItem.h
//  svgrenderer
//
//  Created by Johannes Schriewer on 25.03.14.
//  Copyright (c) 2014 planetmutlu. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "svgtiny.h"

@protocol SVGItem <NSObject>
- (instancetype)initWithShape:(struct svgtiny_shape *)shape;
- (void)renderInContext:(CGContextRef)context;
@end

#include "SVGPath.h"
#include "SVGText.h"
