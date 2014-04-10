//
//  ViewController.h
//  Bibliomancer-001
//
//  Created by David Johnston on 3/27/14.
//  Copyright (c) 2014 David Johnston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MessageUI/MessageUI.h>
#import <FacebookSDK/FacebookSDK.h>

@interface ViewController : UIViewController <AVAudioPlayerDelegate, MFMessageComposeViewControllerDelegate, UITextViewDelegate>

@property (nonatomic, retain) AVAudioPlayer *audioPlayer;

@end
