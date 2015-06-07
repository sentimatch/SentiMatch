//
//  TwitterLogin.m
//  SentiMatch
//
//  Created by ISMAIL J MUSTAFA on 6/6/15.
//
//

#import "TwitterLogin.h"
#import <TwitterKit/TwitterKit.h>
#import "SMTwitterAPI.h"
#import <SSKeychain/SSKeychain.h>
#import "IJMPersonalityAPI.h"
#import "SMBackEndAPI.h"

@interface TwitterLogin()

@end

@implementation TwitterLogin

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TWTRLogInButton* logInButton =  [TWTRLogInButton
                                     buttonWithLogInCompletion:
                                     ^(TWTRSession* session, NSError* error) {
    if (session) {
        // Store in SSKeychain if not already there
        if (![SSKeychain passwordForService:@"twitter_login" account:@"twitter_account"]) {
            [SSKeychain setPassword:[session userID] forService:@"twitter_login" account:@"twitter_account"];
            NSLog(@"JUST signed in as %@", [session userName]);
        }
        else {
            NSLog(@"signed in as %@", [session userName]);
        }
        
        // Handles posting personality and twitter details to backend
        [self postPersonality];
        
    } else {
         NSLog(@"error: %@", [error localizedDescription]);
    }
    }];
    logInButton.center = self.view.center;
    [self.view addSubview:logInButton];
}

- (void)postPersonality
{
    [SMTwitterAPI getUserTweetsWithUserID:[SSKeychain passwordForService:@"twitter_login" account:@"twitter_account"] withCompletionHandler:^(NSArray *response) {
        NSString *tweets = [SMTwitterAPI tweetsStringFromJSON:response];
        [IJMPersonalityAPI getPersonalityAssessmentWithText:tweets withCompletionHandler:^(NSDictionary *response) {
            NSDictionary *personality = [IJMPersonalityAPI personalityWithJSON:response];
            [SMBackEndAPI postPersonality:personality withCompletionHandler:^(BOOL successful) {
                
            }];
            NSLog(@"%@", personality);
        }];
    }];
}




@end
