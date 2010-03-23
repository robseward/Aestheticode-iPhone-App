//
//  OverlayView.h
//  AugmentedRealitySample
//
//  Created by Chris Greening on 01/01/2010.
//

#import <UIKit/UIKit.h>
#import "ImageUtils.h"

#define MAX_LINES 10

@interface OverlayView : UIView {
	CGImageRef maskImage;
	Image *drawnImage;
	CGMutablePathRef pathToDraw;
}

@property(assign, nonatomic) Image *drawnImage;

-(void) setPath:(CGMutablePathRef) newPath;

@end

