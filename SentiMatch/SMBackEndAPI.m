//
//  SMBackEndAPI.m
//  SentiMatch
//
//  Created by ISMAIL J MUSTAFA on 6/6/15.
//
//

#import "SMBackEndAPI.h"
#import <AFNetworking/AFNetworking.h>
#import <SSKeychain/SSKeychain.h>

static NSString * const baselink = @"http://3cafb19a.ngrok.com/api/v1/";

@implementation SMBackEndAPI

+ (void)postPersonality:(NSDictionary *)personality
                 userID:(NSString *)userID
                   name:(NSString *)name
  withCompletionHandler:(void (^)(BOOL successful, NSString *UAuthToken))completionHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@sign_up", baselink]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (NSString *key in personality) {
        NSNumber *value = personality[key];
        [dict setObject:value forKey:key];
    }
    [dict setObject:[NSString stringWithFormat:@"%@@email.com", userID] forKey:@"email"];
    [dict setObject:name forKey:@"name"];
    [dict setObject:@"passwordWORDPASS" forKey:@"password"];
    
    NSDictionary *body = [NSDictionary dictionaryWithDictionary:dict];
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:0 error:nil]];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        completionHandler(YES, responseObject[@"uauth_token"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        completionHandler(NO, nil);
    }];
    [op start];
    
}

+ (void)postVenueID:(NSString *)venueID
  withCompletionHandler:(void (^)(BOOL successful, id responseObject))completionHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@locations/checkin", baselink]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *body = @{@"location_id" : venueID,
                           @"token" : [SSKeychain passwordForService:@"uauth_token" account:@"uauth_token"]};
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:0 error:nil]];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionHandler(YES, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        completionHandler(NO, nil);
    }];
    [op start];
}

+ (void)checkVenueID:(NSString *)venueID
withCompletionHandler:(void (^)(BOOL successful, id result))completionHandler
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *body = @{@"location_id" : venueID,
                        @"token" : [SSKeychain passwordForService:@"uauth_token" account:@"uauth_token"]};
    [manager GET:[NSString stringWithFormat:@"%@locations/checkedin_users", baselink] parameters:body success:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionHandler(YES, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completionHandler(NO, error);
    }];
}


@end
