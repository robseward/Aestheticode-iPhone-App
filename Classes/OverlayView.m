//
//  OverlayView.m
//  AugmentedRealitySample
//
//  Created by Chris Greening on 01/01/2010.
//

#import "OverlayView.h"
#import "ImageUtils.h"

@implementation OverlayView

@synthesize drawnImage;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		// create the mask image
		Image *checkerBoardImage=createImage(self.bounds.size.width, self.bounds.size.height);
		for(int y=0;y<checkerBoardImage->height; y+=2) {
			for(int x=0; x<checkerBoardImage->width; x+=2) {
				checkerBoardImage->pixels[y][x]=255;
			}
		}
		for(int y=1;y<checkerBoardImage->height; y+=2) {
			for(int x=1; x<checkerBoardImage->width; x+=2) {
				checkerBoardImage->pixels[y][x]=255;
			}
		}
		// convert to a CGImage
		maskImage=toCGImage(checkerBoardImage);
		// cleanup
		destroyImage(checkerBoardImage);
    }
    return self;
}

- (void)dealloc {
	CGImageRelease(maskImage);
	maskImage=nil;
	if(drawnImage) destroyImage(drawnImage);
    [super dealloc];
}


- (void)drawRect:(CGRect)rect {
	// we're going to draw into an image using our checkerboard mask
	UIGraphicsBeginImageContext(self.bounds.size);
	CGContextRef context=UIGraphicsGetCurrentContext();
	CGContextClipToMask(context, self.bounds, maskImage);
	// do your drawing here
	CGContextSetLineWidth(context, 2);
	CGContextSetStrokeColorWithColor(context, [[UIColor greenColor] CGColor]);
	CGContextAddPath(context, pathToDraw);
	CGContextStrokePath(context);
	////////						
	UIImage *imageToDraw=UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	// now do the actual drawing of the image
	CGContextRef drawContext=UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(drawContext, 0.0, self.bounds.size.height);
	CGContextScaleCTM(drawContext, 1.0, -1.0);
	// very important to switch these off - we don't wnat our grid pattern to be disturbed in any way
	CGContextSetInterpolationQuality(drawContext, kCGInterpolationNone);
	CGContextSetShouldAntialias(drawContext, NO);
	CGContextDrawImage(drawContext, self.bounds, [imageToDraw CGImage]);

	// stash the results of our drawing so we can remove them later
	if(drawnImage) destroyImage(drawnImage);
	drawnImage=fromCGImage([imageToDraw CGImage], self.bounds);	
}

-(void) setPath:(CGMutablePathRef) newPath {
	if(pathToDraw!=NULL) CGPathRelease(pathToDraw);
	pathToDraw=newPath;
	[self setNeedsDisplay];
}


@end
