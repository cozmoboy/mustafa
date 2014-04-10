//
//  Book.h
//  Bibliomancer-001
//
//  Created by David Johnston on 3/28/14.
//  Copyright (c) 2014 David Johnston. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject


@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSArray *chapters;
@property (strong, nonatomic) NSString *startOfPhraseMarker;
@property (strong, nonatomic) NSString *endOfPhraseMarker;
@property (strong, nonatomic) NSNumber *charsToClipFromFront;
@property (strong, nonatomic) NSNumber *charsToClipFromEnd;


@end
