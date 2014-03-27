//
//  SVGView.h
//  svgrenderer
//
//  Created by Johannes Schriewer on 24.03.14.
//  Copyright (c) 2014 planetmutlu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVGImageView : UIView

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithFrame:(CGRect)frame svgFile:(NSString *)svgFile;

@property (nonatomic, strong) NSString *svgFile;

@end
