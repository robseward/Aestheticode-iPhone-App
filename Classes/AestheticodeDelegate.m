//
//  AugmentedRealitySampleAppDelegate.m
//  AugmentedRealitySample
//
//  Created by Chris Greening on 01/01/2010.
//

#import "AestheticodeDelegate.h"
#import "AestheticodeViewController.h"

@implementation AestheticodeDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
