//
//  SMTwitterAPI.m
//  SentiMatch
//
//  Created by ISMAIL J MUSTAFA on 6/6/15.
//
//

#import "SMTwitterAPI.h"
#import <TwitterKit/TwitterKit.h>

@implementation SMTwitterAPI

+ (void)getUserTweetsWithUserID:(NSString *)userID
                   withCompletionHandler:(void (^)(NSArray *response))completionHandler
{
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/statuses/user_timeline.json";
    NSDictionary *params = @{@"user_id": userID};
    NSError *clientError;
    
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient] URLRequestWithMethod:@"GET" URL:statusesShowEndpoint parameters:params error:&clientError];
    
    if (request) {
        [[[Twitter sharedInstance] APIClient]
         sendTwitterRequest:request
         completion:^(NSURLResponse *response,
                      NSData *data,
                      NSError *connectionError) {
             if (data) {
                 // handle the response data e.g.
                 NSError *jsonError;
                 NSArray *json = [NSJSONSerialization
                                       JSONObjectWithData:data
                                       options:0
                                       error:&jsonError];
                 completionHandler(json);
             }
             else {
                 NSLog(@"Error: %@", connectionError);
             }
         }];
    }
    else {
        NSLog(@"Error: %@", clientError);
    }
}

+ (NSString *)tweetsStringFromJSON:(NSArray *)json
{
    NSMutableString *tweetsString = [[NSMutableString alloc] init];
    for (NSDictionary *dict in json) {
        [tweetsString appendString:dict[@"text"]];
    }
    return [NSString stringWithString:tweetsString];
}


@end
