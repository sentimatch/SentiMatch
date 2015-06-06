//
//  IJMPersonality.h
//  PersonalityAnalysis
//
//  Created by ISMAIL J MUSTAFA on 6/6/15.
//  Copyright (c) 2015 Ismail Mustafa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IJMPersonalityAPI : NSObject

+ (void)getPersonalityAssessmentWithText:(NSString *)text
                   withCompletionHandler:(void (^)(NSDictionary *response))completionHandler;
+ (NSDictionary *)personalityWithJSON:(NSDictionary *)json;

@end
