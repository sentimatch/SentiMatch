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
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation TwitterLogin

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SSKeychain deletePasswordForService:@"twitter_login" account:@"twitter_account"];
    [SSKeychain deletePasswordForService:@"uauth_token" account:@"uauth_token"];
    
    TWTRLogInButton* logInButton =  [TWTRLogInButton
                                     buttonWithLogInCompletion:
                                     ^(TWTRSession* session, NSError* error) {
                                         
     _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_activityIndicator startAnimating];
    _activityIndicator.center = self.view.center;
    _activityIndicator.alpha = 1;
    [self.view addSubview:_activityIndicator];
                                        
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
        [self postPersonalityWithCompletionHandler:^{
            _activityIndicator.alpha = 0;
            [_activityIndicator stopAnimating];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[FoursquareVenues alloc] init]];
            [self presentViewController:nav animated:YES completion:nil];
        }];
        
    } else {
         NSLog(@"error: %@", [error localizedDescription]);
    }
    }];
    logInButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height * 0.9);
    [self.view addSubview:logInButton];
    
    self.view.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:222.0/255.0 blue:161.0/255.0 alpha:1.0];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height*0.2, self.view.frame.size.width, self.view.frame.size.height*0.2)];
    self.imageView.image = [UIImage imageNamed:@"devil"];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(rotateView) userInfo:nil repeats:YES];
    [timer fire];
}

- (void)rotateView
{
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    animation.fromValue = @(0);
    animation.toValue = @(M_PI);
    animation.repeatCount = 0;
    animation.duration = 1.0;
     
    [self.imageView.layer addAnimation:animation forKey:@"rotation"];
     
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / 500.0;
    self.imageView.layer.transform = transform;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)postPersonalityWithCompletionHandler:(void (^)())completionHandler
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
                completionHandler();
            }];
        }];
    }];
}

@end
