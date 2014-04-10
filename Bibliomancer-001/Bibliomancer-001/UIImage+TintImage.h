//
//  UIImage+TintImage.h
//  Napkins
//
//  Created by David Johnston on 5/30/13.
//  Copyright (c) 2013 Eight Bit Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface UIImage (TintImage)

+(UIImage*)colorImageNamed:(NSString *)name withColor:(UIColor *)color;
-(UIImage*)colorArtworkWithColor:(UIColor*)inkColor;
-(UIImage*)blackAndWhiteVersionOfImage:(UIImage *)anImage;
-(UIImage*)blackAndWhieVersionOfSelf;
-(UIImage*)imageWithContrast:(CGFloat)contrastFactor brightness:(CGFloat)brightnessFactor;
//-(UIImage*)mirrorImageTo:(ImageOrientation)orientaion;

@end
