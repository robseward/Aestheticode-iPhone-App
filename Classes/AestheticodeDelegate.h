//
// Rob Seward 
// 03/2010
//

#import <UIKit/UIKit.h>

@class AestheticodeViewController;

@interface AestheticodeDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    AestheticodeViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AestheticodeViewController *viewController;

@end

