//
//  SMBackEndAPI.h
//  SentiMatch
//
//  Created by ISMAIL J MUSTAFA on 6/6/15.
//
//

#import <Foundation/Foundation.h>

@interface SMBackEndAPI : NSObject

+ (void)postPersonality:(NSDictionary *)personality
  withCompletionHandler:(void (^)(BOOL successful))completionHandler;

+ (void)postVenueID:(NSString *)venueID
withCompletionHandler:(void (^)(BOOL successful))completionHandler;

@end
