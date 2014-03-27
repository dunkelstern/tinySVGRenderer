//
//  ViewController.m
//  svgrenderer
//
//  Created by Johannes Schriewer on 24.03.14.
//  Copyright (c) 2014 planetmutlu. All rights reserved.
//

#import "ViewController.h"
#import "SVGImageView.h"
#import "UIImage+SVG.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet SVGImageView *svgView;
@end

#define MAX_HEIGHT 3000
#define MAX_WIDTH 1500

#define MIN_HEIGHT 30
#define MIN_WIDTH 15

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_svgView setSvgFile:@"tiger"];
    UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [touch setNumberOfTouchesRequired:1];

    [_svgView addGestureRecognizer:touch];
#if 0
//    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tiger" ofType:@"svg"]];
    UIImage *image = [UIImage imageNamed:@"tiger"];
    [_svgView setHidden:YES];

    UIImageView *img = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:img];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tap:(UITapGestureRecognizer *)recognizer {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = [_svgView frame];
        frame.size.height /= 2.0;
        [_svgView setFrame:frame];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            [_svgView setFrame:[[UIScreen mainScreen] applicationFrame]];
        }];
    }];
}

@end
