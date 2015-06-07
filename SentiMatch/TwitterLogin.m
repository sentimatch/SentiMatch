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
#import "FoursquareVenues.h"
#import "SMChatViewController.h"

@interface TwitterLogin()

@property (strong, nonatomic) NSString *name;

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
            self.name = [session userName];
        }
        else {
            NSLog(@"signed in as %@", [session userName]);
            self.name = [session userName];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    SMChatViewController *chatVC = [[SMChatViewController alloc] init];
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:chatVC];
    [self presentViewController:navCtrl animated:YES completion:nil];
    // Uncomment this to present the foursquare venues
    // UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[FoursquareVenues alloc] init]];
    // [self presentViewController:nav animated:YES completion:nil];
}

- (void)postPersonality
{
    [SMTwitterAPI getUserTweetsWithUserID:[SSKeychain passwordForService:@"twitter_login" account:@"twitter_account"] withCompletionHandler:^(NSArray *response) {
        NSString *tweets = [SMTwitterAPI tweetsStringFromJSON:response];
        [IJMPersonalityAPI getPersonalityAssessmentWithText:tweets withCompletionHandler:^(NSDictionary *response) {
            NSDictionary *personality = [IJMPersonalityAPI personalityWithJSON:response];
            [SMBackEndAPI postPersonality:personality userID:[SSKeychain passwordForService:@"twitter_login" account:@"twitter_account"] name:self.name withCompletionHandler:^(BOOL successful, NSString *UAuthToken) {
                if (![SSKeychain passwordForService:@"uauth_token" account:@"uauth_token"]) {
                    [SSKeychain setPassword:UAuthToken forService:@"uauth_token" account:@"uauth_token"];
                    NSLog(@"Registering UAuth token: %@", UAuthToken);
                }
                else {
                    NSLog(@"Already registered UAuth token: %@", [SSKeychain passwordForService:@"uauth_token" account:@"uauth_token"]);
                }
            }];
        }];
    }];
}

@end
