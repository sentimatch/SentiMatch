//
//  SMFirebaseShared.h
//  SentiMatch
//
//  Created by ISMAIL J MUSTAFA on 6/7/15.
//
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>

@interface SMFirebaseShared : NSObject

+ (id)sharedFirebase;
+(Firebase *)getRootRef;

@end
