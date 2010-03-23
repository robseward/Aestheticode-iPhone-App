//
//  AugmentedRealitySampleViewController.h
//  AugmentedRealitySample
//
//  Created by Chris Greening on 01/01/2010.
//

#import <UIKit/UIKit.h>
#import "ImageUtils.h"


@class OverlayView;

@interface AestheticodeViewController : UIViewController {
	NSTimer *processingTimer;
	OverlayView *overlayView;
	UILabel *textLable;
	NSDictionary *letterDictionary;
	NSString *currentLetter;
	NSString *currentKey;
	int letterCount;
	bool start;
}

-(IBAction) runDecoder;
-(NSMutableString*)getBinaryString:(uint32_t)input;
-(BOOL)checkForPattern:(Image*)screenImage rgbBar:(char*)rgbBar key:(NSString*)key;

@end

