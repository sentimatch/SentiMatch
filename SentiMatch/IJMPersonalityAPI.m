//
//  IJMPersonality.m
//  PersonalityAnalysis
//
//  Created by ISMAIL J MUSTAFA on 6/6/15.
//  Copyright (c) 2015 Ismail Mustafa. All rights reserved.
//

#import "IJMPersonalityAPI.h"
#import <AFNetworking/AFNetworking.h>

static NSString * const username = @"dc22de8f-920e-4d19-9e69-ef61222c3749";
static NSString * const password = @"YC9kZMdIx6ie";
static NSString * const baselink = @"https://gateway.watsonplatform.net/personality-insights/api/v2/profile";

@implementation IJMPersonalityAPI

// Returns YES if phone number exists on database, otherwise NO
+ (void)getPersonalityAssessmentWithText:(NSString *)text
                   withCompletionHandler:(void (^)(NSDictionary *response))completionHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", baselink]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    // Body
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    // Credentials
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.credential = [NSURLCredential credentialWithUser:username password:password persistence:NSURLCredentialPersistenceForSession];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionHandler(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }];
    [op start];
}

+ (NSDictionary *)personalityWithJSON:(NSDictionary *)json
{
    NSDictionary *tree = json[@"tree"];
    NSArray *categories = tree[@"children"];
    NSArray *personality = categories[0][@"children"][0][@"children"];
    NSDictionary *needs = categories[1][@"children"][0][@"children"];
    NSDictionary *values = categories[2][@"children"][0][@"children"];
    NSMutableDictionary *allTraits = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *dict in personality) {
        NSNumber *percentage = @([dict[@"percentage"] floatValue]);
        NSString *categoryName = [dict[@"name"] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        [allTraits setObject:percentage forKey:categoryName];
    }
    for (NSDictionary *dict in needs) {
        NSNumber *percentage = @([dict[@"percentage"] floatValue]);
        NSString *categoryName = [dict[@"name"] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        [allTraits setObject:percentage forKey:categoryName];
    }
    for (NSDictionary *dict in values) {
        NSNumber *percentage = @([dict[@"percentage"] floatValue]);
        NSString *categoryName = [dict[@"name"] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        [allTraits setObject:percentage forKey:categoryName];
    }
    return [NSDictionary dictionaryWithDictionary:allTraits];
}

@end
