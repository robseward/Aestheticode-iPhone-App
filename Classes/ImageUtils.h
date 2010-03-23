/*
 *  ImageUtils.h
 *  AugmentedRealitySample
 *
 *  Created by Chris Greening on 01/01/2010.
 *
 */

#import <UIKit/UIKit.h>

typedef struct {
	uint32_t *rawImage;
	uint32_t **pixels;
	int width;
	int height;
} Image;

Image *createImage(int width, int height);
Image *fromCGImage(CGImageRef srcImage, CGRect srcRect);
CGImageRef toCGImage(Image *srcImage);
void destroyImage(Image *image);