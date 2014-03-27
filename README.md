tinySVGRenderer
===============

libsvgtiny (http://www.netsurf-browser.org/projects/libsvgtiny/) based SVG renderer for iOS, extends UIImage and has a scalable SVGImageView, can render into CGContext.

Building
========

You will need the following to build the SVG renderer library:
* gperf (http://www.gnu.org/software/gperf/), install with homebrew
* perl

The project is organized into a library "tinySVGRenderer" and a demo project "Demo"

Usage (ultra-short Version)
===========================

More documentation will follow soon...

## Create a UIImage from a SVG file

~~~objc
#import "UIImage+SVG.h"

...

UIImage *image = [UIImage imageNamed:@"tiger"];
~~~
(Assuming you have an image named "tiger.svg" in your project, all other `UIImage` creation methods are internally swizzled to support SVG files, so just replace your PNGs with an appropriate SVG and do not touch any code)

## Create a auto-scaling image view

~~~objc
#import "SVGImageView.h"

...

SVGImageView *svgView = [[SVGImageView alloc] initWithFrame:self.view.frame svgFile:@"tiger"];
~~~
(Assuming you have an image named "tiger.svg" in your project.)

## Rendering a SVG object into a CGContext

~~~objc
#import "SVGObject.h"

...

SVGObject *svg = [[SVGObject alloc] initWithSVGNamed:@"tiger"];

// optionally set size to render (if different from values encoded in SVG-File)
// [svg setSize:CGSizeMake(100, 100)];

[svg renderInContext:context];
~~~
(Assuming you have an image named "tiger.svg" in your project and `context` is a valid `CGContext`)
