//
//  FacebookLibrary.m
//  GiveForward
//
//  Created by mwinkler on 8/27/13.
//  Copyright (c) 2013 EightBitStudios. All rights reserved.
//

#import "FacebookLibrary.h"
#import "Fundraiser.h"

@implementation FacebookLibrary

@synthesize delegate = _delegate;

+ (BOOL)activeSession
{
    return [FBSession.activeSession isOpen];
}

+ (BOOL)photoPermissions
{
    if ([FBSession.activeSession isOpen]) {
        return ([FBSession.activeSession.permissions indexOfObject:@"user_photos"] != NSNotFound);
    }
    return NO;
}

- (void)shareUpdateURL:(NSString *)url photoURL:(NSString *)photoURL completion:(void (^)(BOOL))completion
{
    mCompletionBlock = completion;
    mURL = url;
    mPhotoURL = photoURL;
    
    [self getDefaultPermissionsCompletion:^(BOOL success) {
        if (success) {
            [self __postUpdate];
        } else {
            mCompletionBlock(NO);
        }
    }];
}

- (void)getFriendsCompletion:(void (^)(BOOL, NSArray *))completion
{
    mFacebookFriendsBlock = completion;
    [self getPublishPermissionsCompletion:^(BOOL success) {
        if (success) {
            [self __getFriends];
        } else {
            completion(NO, nil);
        }
    }];
}

- (void)createPostWithLink:(NSString *)link picture:(NSString *)picture message:(NSString *)message caption:(NSString *)caption tags:(NSArray *)tags completion:(void (^)(BOOL))completion
{
    mCompletionBlock = completion;
    NSDictionary* params = [[NSMutableDictionary alloc] init];
    [params setValue:link forKey:@"link"];
    [params setValue:message forKey:@"message"];
    [params setValue:caption forKey:@"name"];
    [params setValue:picture forKey:@"picture"];
    [params setValue:sFacebookPageID forKey:@"place"];
    [params setValue:[tags componentsJoinedByString:@","] forKey:@"tags"];
    
    [self getPublishPermissionsCompletion:^(BOOL success) {
        if (success) {
            [self __createPost:params];
        }
    }];
}


- (void)getDefaultPermissionsCompletion:(void (^)(BOOL))completion
{
    if ([FBSession.activeSession isOpen]) {
        completion(YES);
        
    } else {
        // Session is closed
        NSLog(@"Log In");
        [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState status,
                                                          NSError *error) {
                                          if (error) {
                                              completion(NO);
                                          }
                                          
                                          if ([FBSession.activeSession isOpen]) {
                                              completion(YES);
                                          } else {
                                              completion(NO);
                                          }
                                      }];
    }
}

- (void)getPhotoPermissionsCompletion:(void (^)(BOOL))completion
{
    if ([FBSession.activeSession isOpen]) {
        // Session is open
        
        if ([self __sessionHasPhotoPermissions:FBSession.activeSession]) {
            completion(YES);
            return;
        }
        // if we don't already have the permission, then we request it now
        [FBSession openActiveSessionWithReadPermissions:@[@"user_photos"]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState status,
                                                          NSError *error) {
                                                if (error) {
                                                    NSLog(@"photo permission error: %@", error.description);
                                                    completion(NO);
                                                }
                                                
                                                if ([self __sessionHasPhotoPermissions:session]) {
                                                    completion(YES);
                                                } else {
                                                    completion(NO);
                                                }
                                            }];
    } else {
        // Session is closed
        NSLog(@"Log In");
        [FBSession openActiveSessionWithReadPermissions:@[@"user_photos"]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState status,
                                                          NSError *error) {
                                          if ([FBSession.activeSession isOpen] && [self __sessionHasPhotoPermissions:session]) {
                                              completion(YES);
                                          } else {
                                              completion(NO);
                                          }
                                      }];
    }
}

- (void)getPublishPermissionsCompletion:(void (^)(BOOL))completion
{
    if ([FBSession.activeSession isOpen]) {
        // Session is open
        
        if ([self __sessionHasPublishPermissions:FBSession.activeSession]) {
            completion(YES);
            return;
        }

        // if we don't already have the permission, then we request it now
        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_stream"]
                                           defaultAudience:FBSessionDefaultAudienceFriends
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                                if (error) {
                                                    NSLog(@"publish permission error: %@", error.description);
                                                    completion(NO);
                                                }
                                                
                                                if ([self __sessionHasPublishPermissions:session]) {
                                                    completion(YES);
                                                } else {
                                                    completion(NO);
                                                }
                                            }];
    } else {
        // Session is closed
        NSLog(@"Log In");
        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_stream"]
                                           defaultAudience:FBSessionDefaultAudienceFriends
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          if ([FBSession.activeSession isOpen] && [self __sessionHasPublishPermissions:session]) {
                                              completion(YES);
                                          } else {
                                              completion(NO);
                                          }
                                      }];
    }
}


# pragma mark - Private

- (BOOL)__sessionHasPhotoPermissions:(FBSession *)session
{
    return ([session.permissions indexOfObject:@"user_photos"] != NSNotFound);
}

- (BOOL)__sessionHasPublishPermissions:(FBSession *)session
{
    return ([session.permissions indexOfObject:@"publish_stream"] != NSNotFound);
}

- (void)__postUpdate
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

- (NSDictionary*)parseURLParams:(NSString *)query {
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

- (void)__getFriends
{
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        if (error) {
            mFacebookFriendsBlock(NO, nil);
            return;
        }
        NSArray* friends = [result objectForKey:@"data"];
        mFacebookFriendsBlock(YES, friends);
    }];
}

- (void)__createPost:(NSDictionary *)params
{
    FBRequestConnection* connection = [[FBRequestConnection alloc] init];
    
    FBRequest* request = [FBRequest requestWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST"];
    [connection addRequest:request completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            mCompletionBlock(NO);
            return;
        } else {
            mCompletionBlock(YES);
        }
    }];
    
    [connection start];
}



@end
