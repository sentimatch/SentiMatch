//
//  SMFirebaseShared.m
//  SentiMatch
//
//  Created by ISMAIL J MUSTAFA on 6/7/15.
//
//

#import "SMFirebaseShared.h"

@implementation SMFirebaseShared

- (instancetype)init
{
    self = [super init];
    if (self) {
        _rootRef = [[Firebase alloc] initWithUrl:@"https://sentimatch.firebaseIO.com"];
    }
    return self;
}

+ (id)sharedFirebase {
    static SMFirebaseShared *sharedFirebase = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFirebase = [[self alloc] init];
    });
    return sharedFirebase;
}

@end
