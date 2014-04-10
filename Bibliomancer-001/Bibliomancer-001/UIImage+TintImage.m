//
//  UIImage+TintImage.m
//  Napkins
//
//  Created by David Johnston on 5/30/13.
//  Copyright (c) 2013 Eight Bit Studios. All rights reserved.
//

#import "UIImage+TintImage.h"

@implementation UIImage (TintImage)

+ (UIImage *)colorImageNamed:(NSString *)name withColor:(UIColor *)color
{
    // load the image
    UIImage *img = [UIImage imageNamed:name];
    
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(img.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

//-(UIImage*)mirrorImageTo:(ImageOrientation)orientaion
//{
//    UIImage *flippedImage;
//    
//    if (orientaion == kMirrored) {
//        flippedImage = [UIImage imageWithCGImage:self.CGImage scale:self.scale orientation:UIImageOrientationUpMirrored];
//        return flippedImage;
//    }
//    else if (orientaion == kNormal)
//    {
//        flippedImage = [UIImage imageWithCGImage:self.CGImage scale:self.scale orientation:UIImageOrientationUp];
//        return flippedImage;
//    }
//    
//    return flippedImage;
//    
//}



-(UIImage*)colorArtworkWithColor:(UIColor*)inkColor
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    
    [inkColor setFill];
    
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0];
    
    UIImage *colorArtwork = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return colorArtwork;
    
}


-(UIImage*)blackAndWhieVersionOfSelf
{
    UIImage *image = [[UIImage alloc]init];
    image = [self blackAndWhiteVersionOfImage:self];
    return image;
}

- (UIImage *)blackAndWhiteVersionOfImage:(UIImage *)anImage
{
    UIImage *blackenedImage;
    blackenedImage = [anImage imageWithContrast:1 brightness:1];
	UIImage *newImage;
    //anImage = [anImage imageWithContrast:1 brightness:0];
               //newImage = [newImage imageWithContrast:1 brightness:0.00001];

               
               
	if (anImage) {
        
        
        
		CGColorSpaceRef colorSapce = CGColorSpaceCreateDeviceGray();
		CGContextRef context = CGBitmapContextCreate(nil, anImage.size.width * anImage.scale, anImage.size.height * anImage.scale, 8, anImage.size.width * anImage.scale, colorSapce, kCGImageAlphaNone);
		CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
		CGContextSetShouldAntialias(context, NO);
		CGContextDrawImage(context, CGRectMake(0, 0, anImage.size.width, anImage.size.height), [anImage CGImage]);
		
		CGImageRef bwImage = CGBitmapContextCreateImage(context);
		CGContextRelease(context);
		CGColorSpaceRelease(colorSapce);
		
		UIImage *resultImage = [UIImage imageWithCGImage:bwImage];
		CGImageRelease(bwImage);
        

		
		UIGraphicsBeginImageContextWithOptions(anImage.size, NO, anImage.scale);
		[resultImage drawInRect:CGRectMake(0.0, 0.0, anImage.size.width, anImage.size.height)];
		newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
        
        
        
        //get photo negative of newImage...
        UIGraphicsBeginImageContext(newImage.size);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy);
        [newImage drawInRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)];
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDifference);
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(),[UIColor whiteColor].CGColor);
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, newImage.size.width, newImage.size.height));
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        //and make it more contrasty...
        //newImage = [newImage imageWithContrast:1 brightness:0.00001];
        //[newImage colorArtworkWithColor:[UIColor blackColor]];
        
        //newImage = [newImage imageWithContrast:1 brightness:0];
        //newImage = [newImage imageWithContrast:1 brightness:0];
       // newImage = [newImage imageWithContrast:1 brightness:0];


        
        
	}
	
	return newImage;
}


-(UIImage*)imageWithContrast:(CGFloat)contrastFactor brightness:(CGFloat)brightnessFactor
{
    
    if ( contrastFactor == 1 && brightnessFactor == 0 ) {
        return self;
    }
    
    CGImageRef imgRef = [self CGImage];
    
    size_t width = CGImageGetWidth(imgRef);
    size_t height = CGImageGetHeight(imgRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = 4;
    size_t bytesPerRow = bytesPerPixel * width;
    size_t totalBytes = bytesPerRow * height;
    
    //Allocate Image space
    uint8_t* rawData = malloc(totalBytes);
    
    //Create Bitmap of same size
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    //Draw our image to the context
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    
    //Perform Brightness Manipulation
    for ( int i = 0; i < totalBytes; i += 4 ) {
        
        uint8_t* red = rawData + i;
        uint8_t* green = rawData + (i + 1);
        uint8_t* blue = rawData + (i + 2);
        
        *red = MIN(255,MAX(0,roundf(*red + (*red * brightnessFactor))));
        *green = MIN(255,MAX(0,roundf(*green + (*green * brightnessFactor))));
        *blue = MIN(255,MAX(0,roundf(*blue + (*blue * brightnessFactor))));
        
        *red = MIN(255,MAX(0, roundf(contrastFactor*(*red - 127.5f)) + 128));
        *green = MIN(255,MAX(0, roundf(contrastFactor*(*green - 127.5f)) + 128));
        *blue = MIN(255,MAX(0, roundf(contrastFactor*(*blue - 127.5f)) + 128));
        
    }
    
    //Create Image
    CGImageRef newImg = CGBitmapContextCreateImage(context);
    
    //Release Created Data Structs
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(rawData);
    
    //Create UIImage struct around image
    UIImage* image = [UIImage imageWithCGImage:newImg];
    
    //Release our hold on the image
    CGImageRelease(newImg);
    
    //return new image!
    return image;
    
}





@end
