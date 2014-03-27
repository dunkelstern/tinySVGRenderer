//
//  SVGText.h
//  svgrenderer
//
//  Created by Johannes Schriewer on 25.03.14.
//  Copyright (c) 2014 planetmutlu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVGText : NSObject

@property (nonatomic, readonly) NSAttributedString *text;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, readonly) UIColor *fillColor;
@property (nonatomic, readonly) UIColor *strokeColor;
@property (nonatomic, readonly) CGFloat strokeWidth;
@property (nonatomic, readonly) NSTextAlignment textAlignment;
@property (nonatomic, readonly) UIFont *font;

@property (nonatomic, assign) CGAffineTransform transform;

@end
