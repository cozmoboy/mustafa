//
//  UIImage+Blur.h
//  Napkins
//
//  Created by David Johnston on 3/18/14.
//  Copyright (c) 2014 Eight Bit Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Blur)

-(UIImage*)blurredImage;

-(UIImage*)blurredImageWithRadius:(float)blurFloat;


@end
