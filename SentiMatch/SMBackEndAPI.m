//
//  SMBackEndAPI.m
//  SentiMatch
//
//  Created by ISMAIL J MUSTAFA on 6/6/15.
//
//

#import "SMBackEndAPI.h"
#import <AFNetworking/AFNetworking.h>

static NSString * const baselink = @"http://3cafb19a.ngrok.com/api/v1/";

@implementation SMBackEndAPI

+ (void)postPersonality:(NSDictionary *)personality
  withCompletionHandler:(void (^)(BOOL successful))completionHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@sign_up", baselink]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *body = personality;
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:0 error:nil]];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionHandler(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        completionHandler(NO);
    }];
    [op start];
    
}

+ (void)postVenueID:(NSString *)venueID
  withCompletionHandler:(void (^)(BOOL successful))completionHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@checkin", baselink]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *body = @{@"venue_id" : venueID};
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:0 error:nil]];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionHandler(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        completionHandler(NO);
    }];
    [op start];
}

@end
