//
//  LibraryManager.h
//  Bibliomancer-001
//
//  Created by David Johnston on 3/28/14.
//  Copyright (c) 2014 David Johnston. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Book.h"

@interface LibraryManager : NSObject

@property (strong, nonatomic) NSArray *libraryArray;
@property (strong, nonatomic) Book *currentBook;



-(NSString*)grabRandomQuote;
-(void)setupLibrary;
@end
