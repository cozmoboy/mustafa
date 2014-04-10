//
//  ViewController.m
//  Bibliomancer-001
//
//  Created by David Johnston on 3/27/14.
//  Copyright (c) 2014 David Johnston. All rights reserved.
//

#import "ViewController.h"
#import "LibraryManager.h"
#import "Constants.h"
#import "UIImage+Blur.h"
#import "UIImage+TintImage.h"
#import <Social/Social.h>
#import "ImageFilter.h"
#import "UIImage+TintImage.h"

typedef void(^FacebookCompletionBlock)(BOOL);
typedef void(^FacebookFriendsBlock)(BOOL, NSArray *);

@interface ViewController ()
{
    LibraryManager *librarian;
    NSString *userQuestion;
    NSString *bookToScry;
    NSString *quote;
    NSString *authorName;
    UIImage *shadowImage;
    UIImageView *shadowImageView;
    __weak IBOutlet UIImageView *oEyesImageView;
    UITextView *oQuestionTextView;
    __weak IBOutlet UIButton *oAskButton;
    __weak IBOutlet UIImageView *oBibliomancerImageView;
    __weak IBOutlet UILabel *oFromTheBookLabel;
    __weak IBOutlet UITextView *oQuoteTextView;
    __weak IBOutlet UILabel *oUserQuestionLabel;
    __weak IBOutlet UILabel *oMysticalBackgroundLabel;
    __weak IBOutlet UITextView *oSpookyBackgroundTextView;
    __weak IBOutlet UIImageView *oBackgroundImageView;
    __weak IBOutlet UIButton *oPostToFBButton;
    
    SLComposeViewController *slComposeViewController;
    UIImageView *scrollImageView;
    
    //for Facebook Methods
        FacebookCompletionBlock         mCompletionBlock;
        FacebookFriendsBlock            mFacebookFriendsBlock;
        NSString*                       mURL;
        NSString*                       mPhotoURL;
        FBFriendPickerViewController*   mFriendPickerControler;

    
    
}

@end

@implementation ViewController

@synthesize audioPlayer;

- (void)viewDidLoad
{
    [self getPathAndUrlForFileNamed:@"DrHooWattHead" ofType:@"png"];
    
    
    [super viewDidLoad];
    [oQuoteTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];

	// Do any additional setup after loading the view, typically from a nib.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ExampleText" ofType:@"txt"];
    NSString *helloMessage = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    oFromTheBookLabel.text = helloMessage;
    oQuoteTextView.text = @"";
    oQuestionTextView.delegate = self;
    oQuestionTextView.text = @"";
    oUserQuestionLabel.text = @"";
    oUserQuestionLabel.alpha = 0.0f;
    oBibliomancerImageView.alpha = 0.0f;
    oAskButton.imageView.image = [UIImage colorImageNamed:@"AskMeShadow" withColor:[UIColor brownColor]]; //[oAskButton.imageView.image colo]
    //oAskButton.font = [UIFont fontWithName:@"ChangChang" size:16];
    //oAskButton.font = [UIFont fontWithName:@"ChangandEng" size:16];
    oPostToFBButton.alpha = 0.0f;
    oPostToFBButton.userInteractionEnabled = NO;

    
    [self addShadowToBibliomancerHead];
    
    //[self giveRandomStringOfCharactersOfLength];

    
    librarian = [[LibraryManager alloc]init];
    //[self logAllFonts];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






#pragma mark -- BUTTONS

- (IBAction)askMeButtonPushed:(id)sender
{
    //MAKE THE BUTTON DISAPPEAR
    [UIView animateWithDuration:0.3 animations:^(void)
     {
         oPostToFBButton.alpha = 0.0f;
     } completion:^(BOOL finished) {
         oPostToFBButton.userInteractionEnabled = NO;
     }];
    
    //MAKE EVERYTHING DISAPPEAR
    [UIView animateWithDuration:0.3 animations:^(void)
     {
         oAskButton.alpha = 0.0f;
         oQuoteTextView.alpha = 0.0;
         oFromTheBookLabel.alpha = 0.0;
         scrollImageView.alpha = 0.0;
     }];
    
    //ADD THE QUESTION TEXT VIEW, AND ADD IT
    oQuestionTextView = [[UITextView alloc]initWithFrame:self.view.frame];
    oQuestionTextView.delegate = self;
    [oQuestionTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    oQuestionTextView.textAlignment = NSTextAlignmentCenter;
    oQuestionTextView.textColor = [UIColor whiteColor];
    [oQuestionTextView setFont:[UIFont boldSystemFontOfSize:17]];
    oQuestionTextView.center = CGPointMake(self.view.center.x, self.view.center.y + self.view.frame.size.height + self.view.frame.size.height/2 + 5);
    oQuestionTextView.backgroundColor = [UIColor colorWithHue:0.7 saturation:0.7 brightness:0.7 alpha:0.4];
    [self.view addSubview: oQuestionTextView];
    
    
    //SLIDE THE QUESTION VIEW UP FROM BELOW THE SCREEN AS THE KEYBOARD APPEARS
    [UIView animateWithDuration:0.7 animations:^(void)
     {
         oQuestionTextView.center = self.view.center;//CGPointMake(self.view.center.x, self.view.center.y + self.view.frame.size.height/2 + 5);
     }];
    
    //AND ACTIVATE IT
    [oQuestionTextView becomeFirstResponder];
}

- (IBAction)postToFBButtonPushed:(id)sender
{
    [self postToFacebookByAlternateMethodMaybe];
}


#pragma  mark -- FULL PREDICTION EFFECT

-(void)fullPredictionEffect
{
    //MAKE ALL THE STUFF DISAPPEAR
    [UIView animateWithDuration:1.0 animations:^{
        oFromTheBookLabel.alpha = 0.0f;
        oQuoteTextView.alpha = 0.0f;
        oSpookyBackgroundTextView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        //MAKE AN INVISIBLE SCROLL IMAGE AND ADD IT TO THE VIEW
        NSString *thePath = [[NSBundle mainBundle] pathForResource:@"Scroll" ofType:@"png"];
        //[self setSpookyBackgroundWithText:[self randStringWithLength:300]];
        scrollImageView = [[UIImageView alloc]initWithImage:[[UIImage alloc]initWithContentsOfFile:thePath]];
        scrollImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, oQuoteTextView.frame.size.height + 20); //CGRectMake( 0, 0, self.view.frame.size.width - 10, (2 * self.view.frame.size.height)/5);
        scrollImageView.alpha = 0.0;
        scrollImageView.center = oQuoteTextView.center; //CGPointMake(self.view.center.x, (2*oQuoteTextView.frame.origin.y)/3 + scrollImageView.frame.size.height/2);// oQuoteTextView.center; //CGPointMake(self.view.center.x,self.view.center.y+scroll.frame.size.height/2);
        [self.view insertSubview:scrollImageView belowSubview:oQuoteTextView];
        
        [UIView animateWithDuration:3.0 animations:^{
            oBibliomancerImageView.alpha = 1.0f;
            shadowImageView.alpha = 0.3f;
            oEyesImageView.alpha = 1.0f;
            oSpookyBackgroundTextView.alpha = 1.0f;
            self.view.backgroundColor = [UIColor redColor];
        } completion:^(BOOL finished) {
            if ([librarian.currentBook.author isEqualToString:@"Unknown"])
            {
                oFromTheBookLabel.text =[NSString stringWithFormat: @"As it is written in\r'%@'...", librarian.currentBook.title];
            } else {
                oFromTheBookLabel.text = [NSString stringWithFormat: @"As %@ wrote in\r'%@'...", librarian.currentBook.author, librarian.currentBook.title];
            }
            oQuoteTextView.text = quote;
            oUserQuestionLabel.text = userQuestion;
            //[self soundThunder];
            [UIView animateWithDuration:0.5 animations:^{
                oFromTheBookLabel.alpha = 1.0f;
                //oQuoteTextView.alpha = 1.0f;
                oUserQuestionLabel.alpha = 1.0f;
                scrollImageView.alpha = 1.0f;
                
                //NSString* spookyString = [self randStringWithLength:300];
                //[self setSpookyBackgroundWithText:spookyString];
            }completion:^(BOOL finished) {
                [self soundThunder];
                [UIView animateWithDuration:0.5 animations:^{
                    oQuoteTextView.alpha = 1.0f;
                }];
                [self makeHeadDisappear];
            }];
            
            //[self makeHeadDisappear];
        }];
    }];
}



-(void)makeHeadAppear
{
    [UIView animateWithDuration:0.7 animations:^(void)
     {
         oBibliomancerImageView.alpha = 1.0f;
         oEyesImageView.alpha = 1.0;
         shadowImageView.alpha = 0.3f;
         
     }];
}

-(void)addShadowToBibliomancerHead
{
    //shadowImage = [[UIImage colorImageNamed:@"DrHooWattHead.png" withColor:[UIColor blackColor]]blurredImage];
    shadowImage = [[UIImage colorImageNamed:@"DrHooWattHead.png" withColor:[UIColor blackColor]]blurredImageWithRadius:10.0f];
    
    shadowImageView = [[UIImageView alloc]initWithImage:shadowImage];
    shadowImageView.frame = CGRectMake(0, 0, oBibliomancerImageView.frame.size.width+10, oBibliomancerImageView.frame.size.height+10);
    shadowImageView.center = CGPointMake(oBibliomancerImageView.center.x, oBibliomancerImageView.center.y+10);
    shadowImageView.alpha = 0.0f;
    [self.view addSubview:shadowImageView];
    [self.view sendSubviewToBack:shadowImageView];
    [self.view sendSubviewToBack:oSpookyBackgroundTextView];
    [self.view sendSubviewToBack:oBackgroundImageView];
}

-(void)makeHeadDisappear
{
    [UIView animateWithDuration:1.0 animations:^(void){
        [oEyesImageView.image brightness:10.0];
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.7 animations:^(void)
         {
             oBibliomancerImageView.alpha = 0.0f;
             shadowImageView.alpha = 0.0f;
             oEyesImageView.alpha = 0.0;
             self.view.backgroundColor = [UIColor whiteColor];
         }];
    }];
    
    
    //    [UIView animateWithDuration:0.7 animations:^(void)
    //     {
    //         oBibliomancerImageView.alpha = 0.0f;
    //         shadowImageView.alpha = 0.0f;
    //         oEyesImageView.alpha = 0.0;
    //         self.view.backgroundColor = [UIColor whiteColor];
    //     }];
}

-(void)soundThunder
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Thunder2" ofType:@"wav"];
    audioPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
    audioPlayer.delegate = self;
    [audioPlayer play];
}



-(NSString *)randStringWithLength:(int)length
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";//0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    
    for (int i=0; i<length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}



-(void)setSpookyBackgroundWithText:(NSString*)string
{
    NSArray *fontNamesArray = [NSArray arrayWithObjects:
                               [NSArray arrayWithObjects: @"Hieroglify", @40, nil],//HandDrawnWasabi
                               [NSArray arrayWithObjects: @"Ming Imperial", @30, nil],
                               [NSArray arrayWithObjects:@"SPIonic", @30, nil],
                               [NSArray arrayWithObjects:@"HandDrawnWasabi", @30, nil],
                               nil];
    
    NSArray *fontArray = [fontNamesArray objectAtIndex:arc4random() %fontNamesArray.count];
    NSString * fontNameString = (NSString*)[fontArray objectAtIndex:0];
    NSNumber *fontSizeNSnumber = (NSNumber*)[fontArray objectAtIndex:1];
    int fontSize = [fontSizeNSnumber intValue];
    UIFont *spookyFont =[UIFont fontWithName:fontNameString size:fontSize];
    
    //UIColor * parchmentColor = [UIColor colorWithRed:253/255.0f green:250/255.0f blue:218/255.0f alpha:0.5f];
    UIColor * inkColor = [UIColor colorWithRed:142/255.0f green:63/255.0f blue:39/255.0f alpha:0.1f]; //[UIColor colorWithRed:172/255.0f green:83/255.0f blue:59/255.0f alpha:0.1f];
    
    oSpookyBackgroundTextView.text = string;
    oSpookyBackgroundTextView.font = spookyFont;
    //oSpookyBackgroundTextView.backgroundColor = parchmentColor;
    oSpookyBackgroundTextView.textColor = inkColor;//[UIColor colorWithHue:0.5 saturation:0.5 brightness:0.5 alpha:0.1];
    
}

- (IBAction)postToFacebookButtonWasPushed:(id)sender
{
    
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
//    NSLog(@"text veiw DID END editing ... 1");
//    userQuestion = textView.text;
//    [textView resignFirstResponder];
//    quote = [librarian grabRandomQuote];
//    [self fullPredictionEffect];
    
    NSLog(@"text veiw SHOULD END editing ... 2");
    userQuestion = textView.text;
    quote = [librarian grabRandomQuote];
    bookToScry = librarian.currentBook.title;
    authorName = librarian.currentBook.author;
    [textView resignFirstResponder];
    [self fullPredictionEffect];
    //assign the book and author to variables above...
    
    [UIView animateWithDuration:0.7 animations:^(void)
     {
         oPostToFBButton.alpha = 1.0f;
     } completion:^(BOOL finished) {
         oPostToFBButton.userInteractionEnabled = YES;
     }];
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
//    NSLog(@"text veiw SHOULD END editing ... 2");
//    userQuestion = textView.text;
//    [textView resignFirstResponder];
//    quote = [librarian grabRandomQuote];
//    bookToScry = librarian.currentBook.title;
//    authorName = librarian.currentBook.author;
//    [self fullPredictionEffect];
//    //assign the book and author to variables above...
//    
//    [UIView animateWithDuration:0.7 animations:^(void)
//     {
//         oPostToFBButton.alpha = 1.0f;
//     } completion:^(BOOL finished) {
//         oPostToFBButton.userInteractionEnabled = YES;
//     }];
    return YES;
}

- (BOOL)textView:(UITextView *)_textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)atext {
	
	if ([atext isEqualToString:@"\n"])
    {
        
        [oQuestionTextView resignFirstResponder];
        
        [UIView animateWithDuration:0.5 animations:^(void)
         {
             oQuestionTextView.center = CGPointMake(self.view.center.x, self.view.center.y + self.view.frame.size.height + self.view.frame.size.height/2 + 5);
         } completion:^(BOOL finished) {
             [UIView animateWithDuration:0.3 animations:^(void)
              {
                  oAskButton.alpha =1.0f;
              }];
         }];
		
		return NO;
	}
    
	return YES;
	
    
}



//this entire method was added to help vertically center the text in the oQuoteTextView
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //this entire method was added to help vertically center the text in the oQuoteTextView
    UITextView *tv = object;
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/3.0;///2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}
//this entire method was added to help vertically center the text in the oQuoteTextView
- (void)viewWillDisappear:(BOOL)animated
{
    //this entire method was added to help vertically center the text in the oQuoteTextView
    [oQuoteTextView removeObserver:self forKeyPath:@"contentSize"];
}




-(NSString*)giveRandomStringOfCharactersOfLength//:(int)length
{
    //int randomInt =  (arc4random() % 4) +1;
    //NSString * internationalCharacterString;
    
    //    switch (randomInt) {
    //        case 1:
    //            UniChar chars[] = {0x000C, 0x2028};
    //            NSString *string = [[NSString alloc] initWithCharacters:chars length:sizeof(chars) / sizeof(UniChar)];
    //            NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:string];
    //
    //            break;
    //
    //        case 2:
    //            UniChar chars[] = {0x000C, 0x2028};
    //            NSString *string = [[NSString alloc] initWithCharacters:chars
    //                                                             length:sizeof(chars) / sizeof(UniChar)];
    //            NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:string];
    //
    //            break;
    //
    //        case 3:
    //            UniChar chars[] = {0x000C, 0x2028};
    //            NSString *string = [[NSString alloc] initWithCharacters:chars
    //                                                             length:sizeof(chars) / sizeof(UniChar)];
    //            NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:string];
    //
    //            break;
    //        case 4:
    //            UniChar chars[] = {0x000C, 0x2028};
    //            NSString *string = [[NSString alloc] initWithCharacters:chars
    //                                                             length:sizeof(chars) / sizeof(UniChar)];
    //            NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:string];
    //
    //            break;
    //
    //        default:
    //            break;
    //    }
    
    
    
    
    //    UniChar chars[] = {0x000C, 0x2028};//0400 — 04FF
    //    NSString *string = [[NSString alloc] initWithCharacters:chars length:sizeof(chars) / sizeof(UniChar)];
    //    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:string];
    //    NSLog(@"%@", string);
    return @"hello";//string;
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

#pragma mark -- FACE BOOK METHODS...




-(void)postToFacebookByAlternateMethodMaybe
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        slComposeViewController = [[SLComposeViewController alloc] init];
        slComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [slComposeViewController setInitialText:[NSString stringWithFormat:@"I have asked The BIBLIOMANCER to tell me\n\n '%@'\n\nHe has responded with a passage from '%@' by %@.\nPlease help me interpret it.\n\n'%@'", userQuestion, bookToScry, authorName, quote]];
        
        ///IF YOU WANT TO INSERT A PHOTO OF THE NECROMANCER, WHICH YOU PROBABLY DON'T...
        /* 
        UIImage *head = [UIImage imageNamed:@"DrHooWattHeadCutoutDark"];
        UIImage *tempImage = nil;
        CGSize targetSize = CGSizeMake(head.size.width/7, head.size.height/7);
        UIGraphicsBeginImageContext(targetSize);
        
        CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
        thumbnailRect.origin = CGPointMake(0.0,0.0);
        thumbnailRect.size.width  = targetSize.width;
        thumbnailRect.size.height = targetSize.height;
        
        [head drawInRect:thumbnailRect];
        
        tempImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        head = tempImage;
        //*/
        [slComposeViewController addURL:[NSURL URLWithString:@"http://bibliomancerapp.blogspot.com"]];
        [self presentViewController:slComposeViewController animated:YES completion:NULL];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Facebook Account" message:@"There are no Facebook accounts confiured, configure or create accounts in Settings." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        //[alert release];
    }
}

#pragma mark --WINKLER--

-(void)postToFaceBookALAWinkler
{
    NSString *biblioSiteUrlString = @"http://bibliomancerapp.blogspot.com";
    NSString *pictureURLString = @"/var/mobile/Applications/F0505D7B-8132-48EB-A5E8-3B37A6469E62/Bibliomancer-001.app/DrHooWattHead.png";
    NSString *messageString = [NSString stringWithFormat:@"I have asked The BIBLIOMANCER to tell me '%@'\nHe has responded with a passage from '%@' by %@.", userQuestion, bookToScry, authorName];//@"I have asked The BIBLIOMANCER to tell me '%@'\nHe has responded with a passage from '%@' by %@./nPlease help me interpret it\n\n'%@'", userQuestion, bookToScry, authorName, quote];
    NSString *captionString = @"Bibliomancer knows all...";
    
    NSDictionary* params = [[NSMutableDictionary alloc] init];
    [params setValue:biblioSiteUrlString forKey:@"link"];
    [params setValue:messageString forKey:@"message"];
    //[params setValue:captionString forKey:@"name"];
    //[params setValue:pictureURLString forKey:@"picture"];

    
    FBRequestConnection* connection = [[FBRequestConnection alloc] init];
    
    FBRequest* request = [FBRequest requestWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST"];
    [connection addRequest:request completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            //mCompletionBlock(NO);
            NSLog(@"error");
            return;
        } else {
            //mCompletionBlock(YES);
            NSLog(@"NO error!");

        }
    }];
    
    [connection start];
}
                                                                                                                                                                                             




-(void)getPathAndUrlForFileNamed:(NSString*)fileName ofType:(NSString*)typeSuffixWithoutPeriod
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *pathString = [mainBundle pathForResource:fileName ofType:typeSuffixWithoutPeriod];
    NSLog(@"Main bundle path: %@", mainBundle);
    NSLog(@"myFile path: %@", pathString);
    
    NSURL *urlToFile = [NSURL fileURLWithPath:pathString];
    
    NSLog(@"URL: %@", urlToFile);
    

}


-(void)__postUpdate
{
    
    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
    params.link = [NSURL URLWithString:mURL];
    if (mPhotoURL) {
        params.picture = [NSURL URLWithString:mPhotoURL];
    }
    // use share dialog if available
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        [FBDialogs presentShareDialogWithParams:params
                                    clientState:nil
                                        handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                            if (error) {
                                                mCompletionBlock(NO);
                                            } else {
                                                if ([results objectForKey:@"completionGesture"]) {
                                                    if ([[results objectForKey:@"completionGesture"] isEqualToString:@"post"]) {
                                                        mCompletionBlock(YES);
                                                        return;
                                                    }
                                                }
                                                mCompletionBlock(NO);
                                            }
                                        }];
    } else {
        // Invoke the dialog
        // Put together the dialog parameters
        NSMutableDictionary* webParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          mURL, @"link",
                                          nil];
        
        if (mPhotoURL) {
            [webParams setObject:mPhotoURL forKey:@"picture"];
        }
        
        
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:webParams
                                                  handler:
         ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
             if (error || result == FBWebDialogResultDialogNotCompleted) {
                 mCompletionBlock(NO);
             } else {
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"post_id"]) {
                     // User clicked the Cancel button
                     NSLog(@"User canceled story publishing.");
                     mCompletionBlock(NO);
                 } else {
                     // User clicked the Share button
                     mCompletionBlock(YES);
                 }
             }
         }];
    }
}

#pragma mark -- stuff to REMOVE in the end...

-(void)logAllFonts//for diagnostics....
{
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
}

//ALL THE CODE THAT WORKED BEFORE.....
//- (IBAction)postToFBButtonPushed:(id)sender
//{
    //[self postToFacebookByAlternateMethodMaybe];
    
    
    /*
     [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook];
     
     //    NSBundle *mainBundle = [NSBundle mainBundle];
     //    NSString *myFile = [mainBundle pathForResource: @"DrHooWattHead" ofType: @"png"];
     //    NSLog(@"Main bundle path: %@", mainBundle);
     //    NSLog(@"myFile path: %@", myFile);
     //
     //    NSURL *urlToBilbioHead = [NSURL fileURLWithPath:myFile];
     //    // Check if the Facebook app is installed and we can present the share dialog
     //    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
     //    params.link = [NSURL URLWithString:@"http://bibliomancerapp.blogspot.com"];
     //    params.name = @"Try this";
     //    params.caption = @"I hope this is the stuff of the body";
     //    params.picture = urlToBilbioHead;//nil;//[NSURL URLWithString:@"http://i.imgur.com/g3Qc1HN.png"];
     //    params.description = @"Allow your users to share stories on Facebook from your app using the iOS SDK.";
     //    params
     //    // If the Facebook app is installed and we can present the share dialog
     //    if ([FBDialogs canPresentShareDialogWithParams:params])
     //    {
     //        // Present the share dialog
     //        // Present share dialog
     //        [FBDialogs presentShareDialogWithLink:params.link
     //                                         name:params.name
     //                                      caption:params.caption
     //                                  description:params.description
     //                                      picture:params.picture
     //                                  clientState:nil
     //                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
     //                                          if(error) {
     //                                              // An error occurred, we need to handle the error
     //                                              // See: https://developers.facebook.com/docs/ios/errors
     //                                              NSLog(@"error");//[NSString stringWithFormat:@"Error publishing story: %@", error.description]);
     //                                          } else {
     //                                              // Success
     //                                              NSLog(@"result %@", results);
     //                                          }
     //                                      }];
     //
     //    } else {
     //        // Present the feed dialog
     //    }
     //
     //    // Check if the Facebook app is installed and we can present the share dialog
     //
     //
     //
     //    ///////
     
     FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
     params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
     
     // If the Facebook app is installed and we can present the share dialog
     if ([FBDialogs canPresentShareDialogWithParams:params]) {
     
     // Present share dialog
     [FBDialogs presentShareDialogWithLink:nil
     handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
     if(error) {
     // An error occurred, we need to handle the error
     // See: https://developers.facebook.com/docs/ios/errors
     NSLog(@"Error publishing story: %@", error.description);
     } else {
     // Success
     NSLog(@"result %@", results);
     }
     }];
     
     // If the Facebook app is NOT installed and we can't present the share dialog
     } else {
     // FALLBACK: publish just a link using the Feed dialog
     // Show the feed dialog
     [FBWebDialogs presentFeedDialogModallyWithSession:nil
     parameters:nil
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
     if (error) {
     // An error occurred, we need to handle the error
     // See: https://developers.facebook.com/docs/ios/errors
     NSLog(@"Error publishing story: %@", error.description);
     } else {
     if (result == FBWebDialogResultDialogNotCompleted) {
     // User cancelled.
     NSLog(@"User cancelled.");
     } else {
     // Handle the publish feed callback
     NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
     
     if (![urlParams valueForKey:@"post_id"]) {
     // User cancelled.
     NSLog(@"User cancelled.");
     
     } else {
     // User clicked the Share button
     NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
     NSLog(@"result %@", result);
     }
     }
     }
     }];
     }
     */
//}


//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    UITextView *tv = object;
//    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
//    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
//    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
//}


@end
