//
//  UIImage+Blur.m
//  Napkins
//
//  Created by David Johnston on 3/18/14.
//  Copyright (c) 2014 Eight Bit Studios. All rights reserved.
//

#import "UIImage+Blur.h"

@implementation UIImage (Blur)

-(UIImage*)blurredImage
{
        CIContext*          context;
        CIImage*            inputImage;
        CIFilter*           filter ;
        CIImage*            filteredImage;
        CGImageRef          imageRef;
        UIImage*            finalImage;
    
        context = [CIContext contextWithOptions:nil];
        inputImage = [CIImage imageWithCGImage:self.CGImage];
        
        filter = [CIFilter filterWithName:@"CIGaussianBlur"];
        [filter setValue:inputImage forKey:kCIInputImageKey];
        [filter setValue:[NSNumber numberWithFloat:5.0f] forKey:@"inputRadius"];
        
        filteredImage = [filter valueForKey:kCIOutputImageKey];
        
        imageRef = [context createCGImage:filteredImage fromRect:[inputImage extent]];
        finalImage = [UIImage imageWithCGImage:imageRef];
    
        return finalImage;
}



-(UIImage*)blurredImageWithRadius:(float)blurFloat
{
    CIContext*          context;
    CIImage*            inputImage;
    CIFilter*           filter ;
    CIImage*            filteredImage;
    CGImageRef          imageRef;
    UIImage*            finalImage;
    
    context = [CIContext contextWithOptions:nil];
    inputImage = [CIImage imageWithCGImage:self.CGImage];
    
    filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:blurFloat] forKey:@"inputRadius"];
    
    filteredImage = [filter valueForKey:kCIOutputImageKey];
    
    imageRef = [context createCGImage:filteredImage fromRect:[inputImage extent]];
    finalImage = [UIImage imageWithCGImage:imageRef];
    
    return finalImage;
}

@end
