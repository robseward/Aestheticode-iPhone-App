//
//  
//  Rob Seward 02/10
//
//

#import "AestheticodeViewController.h"
#import "ImageUtils.h"
#import "OverlayView.h"

@implementation AestheticodeViewController


-(IBAction) runDecoder {
	[self init];
	// set up our camera overlay view
	
	// tool bar - handy if you want to be able to exit from the image picker...
	UIToolbar *toolBar=[[[UIToolbar alloc] initWithFrame:CGRectMake(0, 480-44, 320, 44)] autorelease];
	NSArray *items=[NSArray arrayWithObjects:
					[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil] autorelease],
					[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone  target:self action:@selector(finishedDecoding)] autorelease],
					nil];
	[toolBar setItems:items];
	// create the overlay view
	overlayView=[[[OverlayView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-44)] autorelease];
	// important - it needs to be transparent so the camera preview shows through!
	overlayView.opaque=NO;
	overlayView.backgroundColor=[UIColor clearColor];
	// parent view for our overlay
	UIView *parentView=[[[UIView alloc] initWithFrame:CGRectMake(0,0,320, 480)] autorelease];
	[parentView addSubview:overlayView];
	[parentView addSubview:toolBar];
	
	textLable = [[[UILabel alloc] initWithFrame:CGRectMake(0,400,320,480-400-44)] autorelease];
	textLable.opaque=NO;
	//lable.textColor = [UIColor blackColor];
	textLable.text = @"";
	[parentView addSubview:textLable];
	
	// configure the image picker with our overlay view
	UIImagePickerController *picker=[[UIImagePickerController alloc] init];
	picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	UIImagePickerControllerSourceTypePhotoLibrary;
	// hide the camera controls
	picker.showsCameraControls=NO;
	picker.delegate = nil;
	picker.allowsEditing = NO;
	// and put our overlay view in
	picker.cameraOverlayView=parentView;
	[self presentModalViewController:picker animated:YES];		
	[picker release];
	// start our processing timer
	processingTimer=[NSTimer scheduledTimerWithTimeInterval:1/15.0f target:self selector:@selector(processImage) userInfo:nil repeats:YES];
}

-(void) finishedDecoding {
	[self dismissModalViewControllerAnimated:YES];
	[processingTimer invalidate];
	overlayView=nil;
}


// this is where is all happens
CGImageRef UIGetScreenImage();

-(void) processImage {
	// grab the screen
	CGImageRef screenCGImage=UIGetScreenImage();
	// turn it into something we can use
	Image *screenImage=fromCGImage(screenCGImage, overlayView.frame);
	CGImageRelease(screenCGImage);
	
	char rgbBar[screenImage->width];
	currentKey = [NSString stringWithString:@""];
	
	NSDate *date = [NSDate date];
	
	float threshold = 1.5;
	int blue, green, red;
	uint32_t* pixel;
	BOOL letterFound = NO;
	
	//Look for R, G, or B pixels
	for(int y = screenImage->height-1; y > 0; y -= 40){

		for(int x=0; x<screenImage->width-1; x++) {
			pixel = &screenImage->pixels[y][x];
			blue = ((*pixel >> 24) & 0xFF) + 1;
			green = ((*pixel >> 16) & 0xFF) + 1;
			red = ((*pixel >> 8) & 0xFF) + 1;
			
			if( (float)red / (float)green > threshold && (float)red / (float)blue > threshold ){			
				rgbBar[x] = 'R';
			}
			else if( (float)green/ (float)red > threshold && (float)green / (float)blue > threshold ){			
				rgbBar[x] = 'G';
			}
			else if( (float)blue/ (float)red > threshold && (float)blue / (float)green > threshold ){			
				rgbBar[x] = 'B';

			} else {			
				rgbBar[x] = '.';
			}
		}
		
		letterFound = [self checkForPattern:screenImage rgbBar:rgbBar key:currentKey];
		if(letterFound == YES){	
			break;
		}
	}
	//Print some timing info
	NSTimeInterval timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
	NSLog(@"%f", timePassed_ms);
	
		
	printf("%s\n", rgbBar);
	NSLog(@"CurKey: %@", currentKey);	
	
	//If we've found a letter, let's see if it's been detected for long enough to not be a glitch
	if (letterFound == YES) {
				
		NSString *incomingLetter = [letterDictionary objectForKey:currentKey];
		NSLog(@"incomingLetter:%@ %@", currentKey, incomingLetter);

		if(start){
			start = FALSE;
			currentLetter = incomingLetter;
		}
		
		if(![incomingLetter isEqualToString:currentLetter]){
			if(letterCount > 1){	//old letter was present for more than one frame, display it
				textLable.text = [NSString stringWithFormat:@"%@%@", textLable.text, incomingLetter];
				letterCount = 0;
			}
			currentLetter = incomingLetter;

		} else {
			letterCount++;
		}
		NSLog(@"letterCount: %d", letterCount);
		
	}
	
	// finished with our screen image
	destroyImage(screenImage);
}

-(BOOL)checkForPattern:(Image*)screenImage rgbBar:(char*)rgbBar key:(NSString*)key{
	BOOL advance = FALSE;
	BOOL counting = FALSE;
	int bin_index = 0;
	int counter = 0;
	char prev_state;
	int sequence_min = 20;
	int break_seq_min = 7;
	int bin_size = 3;
	char bin[3] = {'.', '.', '.'};	//cheating here...3 should be a #define
	BOOL patternFound = NO;
	
	for(int x=0; x<screenImage->width-1; x++) {
		if (!advance) {
			if (counter >= sequence_min) {
				bin[bin_index] = prev_state;
				bin_index++;
				counter = 0;
				advance = TRUE;
				counting = FALSE;
				continue;
			}
			
			if (counting && rgbBar[x] == prev_state) {
				counter++;
			} else {
				counting = FALSE;
				counter = 0;
			}
			
			if ((rgbBar[x] == 'R' || rgbBar[x] == 'G' || rgbBar[x] == 'B') && counting == FALSE) {
				counting = TRUE;
				prev_state = rgbBar[x];
				counter++;
			}
		}else {
			if (counter >= break_seq_min) {
				advance = FALSE;
				counting = FALSE;
				counter = FALSE;
				continue;
			}
			
			if (counting && rgbBar[x] == prev_state) {
				counter++;
			} else {
				counting = FALSE;
				counter = 0;
			}
			
			if (rgbBar[x] == '.' && counting == FALSE) {
				counting = TRUE;
				prev_state = rgbBar[x];
				counter++;
			}
		}
		
		
		if(bin_index >= bin_size){
			patternFound = YES;
			break;
		}
	}
	
	currentKey = [NSString  stringWithFormat:@"%c%c%c", bin[0], bin[1], bin[2]];
	
	return patternFound;
}



-(NSMutableString*)getBinaryString:(uint32_t)input {
	NSMutableString* output = [[NSMutableString alloc] initWithString:@""];
	
	/* display binary representation */
	for(uint32_t i = 0x80000000; i > 0; i = i / 2){
		if(i & input) 
			[output appendString:@"1"];
		else 
			[output appendString:@"0"];
	
	}
	return output;
}


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
    }
    return self;
}


- (id)init{
	[super init];
	NSArray* keys = [[NSArray alloc] initWithObjects:@"RRR", @"RRG", @"RRB", @"RGR", @"RGG", @"RGB", @"RBR", @"RBG", @"RBB", @"GRR", @"GRG", @"GRB", @"GGR", @"GGG", @"GGB", @"GBR", @"GBG", @"GBB", @"BRR", @"BRG", @"BRB", @"BGR", @"BGG", @"BGB", @"BBR", @"BBG", @"BBB", nil];
	NSArray *objects = [[NSArray alloc]  initWithObjects:@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", @" ", nil];
	letterDictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
	currentLetter = [[NSString alloc] initWithFormat:@" "]; 
	[keys release];
	[objects release];
	letterCount = 0;
	start = TRUE;
	
	return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[letterDictionary release];
	[currentLetter release];
    [super dealloc];
}

@end
