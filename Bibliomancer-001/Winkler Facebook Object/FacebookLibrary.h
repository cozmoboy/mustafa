//
//  FacebookLibrary.h
//  GiveForward
//
//  Created by mwinkler on 8/27/13.
//  Copyright (c) 2013 EightBitStudios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@class Fundraiser, FacebookLibraryFriendPickerDelegate;

typedef void(^FacebookCompletionBlock)(BOOL);
typedef void(^FacebookPermissionBlock)(BOOL);
typedef void(^FacebookFriendsBlock)(BOOL, NSArray *);

@protocol FacebookLibraryFriendPickerDelegate <NSObject>

-(void)faceBookLibraryFriendPickerController:(FBFriendPickerViewController *)controller didFinishWithSelectedFriends:(NSArray *)selectedFriends;
-(void)faceBookLibraryFriendPickerController:(FBFriendPickerViewController *)controller didFinishError:(NSError *)error;

@end

@interface FacebookLibrary : NSObject
<
    FBFriendPickerDelegate
>
{
    FacebookCompletionBlock         mCompletionBlock;
    FacebookFriendsBlock            mFacebookFriendsBlock;
    NSString*                       mURL;
    NSString*                       mPhotoURL;
    FBFriendPickerViewController*   mFriendPickerControler;
}

@property (nonatomic, weak) id<FacebookLibraryFriendPickerDelegate> delegate;

+(BOOL)activeSession;
+(BOOL)photoPermissions;

-(void)shareUpdateURL:(NSString *)url photoURL:(NSString *)photoURL completion:(void (^)(BOOL success))completion;
-(void)getDefaultPermissionsCompletion:(void (^)(BOOL success))completion;
-(void)getPhotoPermissionsCompletion:(void (^)(BOOL success))completion;
-(void)getPublishPermissionsCompletion:(void (^)(BOOL success))completion;
-(void)getFriendsCompletion:(void (^)(BOOL success, NSArray*friends))completion;
-(void)createPostWithLink:(NSString *)link picture:(NSString *)picture message:(NSString *)message caption:(NSString *)caption tags:(NSArray *)tags completion:(void (^)(BOOL success))completion;

@end

@interface FacebookLibrary (Private)

-(void)__postUpdate;
-(void)__getFriends;

@end
