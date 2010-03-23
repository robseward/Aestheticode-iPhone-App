/*
 *  ImageUtils.c
 *  AugmentedRealitySample
 *
 *  Created by Chris Greening on 01/01/2010.
 *
 */

#include "ImageUtils.h"

Image *createImage(int width, int height) {
	Image *result=(Image *) malloc(sizeof(Image));
	result->width=width;
	result->height=height;
	result->rawImage=(uint32_t *) calloc(result->width*result->height, 4);
	// create a 2D aray - this makes using the data a lot easier
	result->pixels=(uint32_t **) malloc(sizeof(uint32_t *)*result->height);
	for(int y=0; y<result->height; y++) {
		result->pixels[y]=result->rawImage+y*result->width;
	}
	return result;
}

Image *fromCGImage(CGImageRef srcImage, CGRect srcRect) {
	Image *result=createImage(srcRect.size.width, srcRect.size.height);
	// get hold of the image bytes
	CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
	CGContextRef context=CGBitmapContextCreate(result->rawImage,  
											   result->width, 
											   result->height, 
											   8, 
											   CGImageGetBytesPerRow(srcImage), 
											   CGImageGetColorSpace(srcImage), 
											   kCGImageAlphaNoneSkipFirst);
	// lowest possible quality for speed
	CGContextSetInterpolationQuality(context, kCGInterpolationNone);
	CGContextSetShouldAntialias(context, NO);
	// get the rectangle of interest from the image
	CGImageRef subImage=CGImageCreateWithImageInRect(srcImage, srcRect);
	// draw it into our bitmap context
	CGContextDrawImage(context, CGRectMake(0,0, result->width, result->height), subImage);
	// cleanup
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	CGImageRelease(subImage);
	return result;
}

CGImageRef toCGImage(Image *srcImage) {
	// generate space for the result
	uint8_t *rgbData=(uint8_t *) calloc(srcImage->width*srcImage->height*sizeof(uint32_t),1);
	// process the greyscale image back to rgb
	for(int i=0; i<srcImage->height*srcImage->width; i++) {			
		// no alpha
		rgbData[i*4]=0;
		int val=srcImage->rawImage[i];
		// rgb values
		rgbData[i*4+1]=val;
		rgbData[i*4+2]=val;
		rgbData[i*4+3]=val;
	}
	// create the CGImage from this data
	CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
	CGContextRef context=CGBitmapContextCreate(rgbData, 
											   srcImage->width, 
											   srcImage->height, 
											   8, 
											   srcImage->width*sizeof(uint32_t), 
											   colorSpace, 
											   kCGBitmapByteOrder32Little|kCGImageAlphaNoneSkipLast);
	// cleanup
	CGImageRef image=CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	free(rgbData);
	return image;
}

void destroyImage(Image *image) {
	free(image->rawImage);
	free(image->pixels);
	free(image);
}