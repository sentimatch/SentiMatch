//
//  SMTwitterAPI.h
//  SentiMatch
//
//  Created by ISMAIL J MUSTAFA on 6/6/15.
//
//

#import <Foundation/Foundation.h>

@interface SMTwitterAPI : NSObject

+ (void)getUserTweetsWithUserID:(NSString *)userID
          withCompletionHandler:(void (^)(NSArray *response))completionHandler;

+ (NSString *)tweetsStringFromJSON:(NSArray *)json;

@end
