//
//  LibraryManager.m
//  Bibliomancer-001
//
//  Created by David Johnston on 3/28/14.
//  Copyright (c) 2014 David Johnston. All rights reserved.
//

#import "LibraryManager.h"

@implementation LibraryManager
{
    //Book *currentBook;
    NSString *currentChapterName;
}

@synthesize libraryArray, currentBook;


-(id)init{
    self = [super init];
    if (self) {
        [self setupLibrary];
    }
    return self;
}

-(void)setupLibrary
{
    // TO ADD NEW BOOK TO THE LIBRARY............................. add a new item into the booksData array with the following fomat...
    //NSArray *aBookArray = [NSArray arrayWithObjects:@"put the name here", @"put the author here", /* all chapter file names go in to the next array */[NSArray arrayWithObjects:@"put name of chapter 1 text file here", @"put name of chapter 2 text file here", nil], @"startSearchChars", @"endSearchChars", /* number of chars to clip from front */ @5, /* number of chars to clip from end */ @5, nil];
    
    NSArray *booksData = [NSArray arrayWithObjects:
                          /////////
                          [NSArray arrayWithObjects:@"The Bible", @"Unknown", [NSArray arrayWithObjects:@"BM-Proverbs3",  nil], @"** ", @" **", @11, @0, nil],
                          /////////
                          [NSArray arrayWithObjects:@"Tao Te Ching", @"Lao Tzu", [NSArray arrayWithObjects:@"BM-TaoTeChing2",  nil], @"**:", @":**", @0, @0, nil],
                          /////////
                          [NSArray arrayWithObjects:@"Beyond Good And Evil", @"Friedrich Nietzsche", [NSArray arrayWithObjects:@"BM-NietzscheBGE-1-PrejudicesOfPhilosophers", @"BM-NietzscheBGEFromTheHeights", @"BM-NietzscheBGEpreface",  nil], @"**:", @":**", @0, @0, nil],
                          /////////
                          [NSArray arrayWithObjects:@"Maximes", @"Duc de La Rochefoucauld", [NSArray arrayWithObjects:@"BM-Maximes-LRF2", nil], @"**:", @":**", @0, @0, nil],
                          /////////
                          [NSArray arrayWithObjects:@"Rules of Civility & Decent Behavior in Company and Conversation", @"George Washington", [NSArray arrayWithObjects:@"BM-RulesOfCivility-Washington", nil], @"**:", @":**", @0, @0, nil],
                          /////////
                          nil];
    
    NSMutableArray *allBooks = [[NSMutableArray alloc]init];
    for (NSArray *array in booksData) {
        Book *book = [[Book alloc]init];
        book.title = (NSString*)[array objectAtIndex:0];
        book.author = (NSString*)[array objectAtIndex:1];
        book.chapters = (NSArray*)[array objectAtIndex:2];
        book.startOfPhraseMarker = (NSString*)[array objectAtIndex:3];
        book.endOfPhraseMarker = (NSString*)[array objectAtIndex:4];
        book.charsToClipFromFront = (NSNumber*)[array objectAtIndex:5];
        book.charsToClipFromEnd = (NSNumber*)[array objectAtIndex:6];
        [allBooks addObject:book];
    }
    
    libraryArray = [NSArray arrayWithArray:allBooks];
    
}





-(NSString*)grabRandomQuote
{
    currentBook = [self chooseRandomBook];
    NSString *quote = [self getRandomVerseFromBook:currentBook];
    return quote;
}


-(Book*)chooseRandomBook
{
    Book *book = (Book*)[libraryArray objectAtIndex:arc4random() %[libraryArray count]];
    return book;//(Book*)[libraryArray objectAtIndex:arc4random() %[libraryArray count]];
}

-(NSString*)chooseRandomChapterOfBook:(Book*)book
{
    NSString *chapterName = (NSString*)[book.chapters objectAtIndex:arc4random() %[book.chapters count]];
    NSLog(@"CHAPTER NAME: %@", chapterName);
    return chapterName;
}







-(NSString*)getRandomVerseFromBook:(Book*)book
{
    NSString* quote;
    while(!quote || [quote length]>300)
    {
    NSString *chapterName = [self chooseRandomChapterOfBook:book];
    NSString *path = [[NSBundle mainBundle] pathForResource:chapterName ofType:@"txt"];
    NSString *chapterText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    quote = [self formatAndClipNumberOfCharactersFromBeginning:book.charsToClipFromFront.integerValue andEnd:book.charsToClipFromEnd.integerValue ofString:[self grabRandomVerseFromChapter:chapterText fromBook:book]];
    }
    return quote;
}



-(NSString*)grabRandomVerseFromChapter:(NSString*)string fromBook:(Book*)book //withStartMarker:(NSString*)phraseStarter endMarker:(NSString*)phraseEnder
{
    int numberOfVerses = [self countNumberOfVersesInContentOfChapter:string ofBook:currentBook];
    int verseNumberToGrab = (arc4random() %numberOfVerses);
    
    
    int count = 1;
    NSScanner *scanner = [NSScanner scannerWithString:string];
    
    NSString *finalVerse;
    
    
    [scanner scanUpToString:book.startOfPhraseMarker intoString:nil]; // Scan all characters before #
    while(![scanner isAtEnd] && count < verseNumberToGrab)
    {
        NSString *substring = nil;
        [scanner scanString:book.startOfPhraseMarker intoString:nil]; // Scan the # character
        if([scanner scanUpToString:book.endOfPhraseMarker intoString:&substring])
        {
            finalVerse = substring;
        }
        
        [scanner scanUpToString:book.startOfPhraseMarker intoString:nil]; // Scan all characters before next #
        count = count +1;
    }
 
    return  finalVerse;
    
}


-(int)countNumberOfVersesInContentOfChapter:(NSString*)string ofBook:(Book*)book
{
    int count = 0;
    NSUInteger length = [string length];
    NSRange range = NSMakeRange(0, length);
    while(range.location != NSNotFound)
    {
        range = [string rangeOfString:book.endOfPhraseMarker options:0 range:range];
        if(range.location != NSNotFound)
        {
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
            count++;
        }
    }
    
    int verseCount = count -1;
    
    return verseCount;
}

-(NSString*)formatAndClipNumberOfCharactersFromBeginning:(int)intBeginning andEnd:(int)intEnd ofString:(NSString*)string
{
    
    // REMOVE LINE BREAKS FROM QUOTE
    NSString *stringWithoutLineBreaks = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
    
    // REMOVE # OF UNWANTED CHARACTERS FROM FRONT OF QUOTE
    NSString *stringWithoutBeginning = [stringWithoutLineBreaks substringWithRange:NSMakeRange(intBeginning, [stringWithoutLineBreaks length]-intBeginning)]; // djj - or if the above is giving us problems, try... NSString *stringWithoutBeginning = [string substringFromIndex:intBeginning];
    
    // REMOVE # OF UNWANTED CHARACTERS FROM END OF QUOTE
    NSString *stringWithoutEnd = [stringWithoutBeginning substringToIndex:[stringWithoutBeginning length]-intEnd];
    
    // REMOVE DOUBLE SPACES FROM QUOTE
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *trimmedString = [regex stringByReplacingMatchesInString:stringWithoutEnd options:0 range:NSMakeRange(0, [stringWithoutEnd length]) withTemplate:@" "];

    
    return trimmedString;
    
    NSLog(@"%@", stringWithoutEnd);
}


@end
