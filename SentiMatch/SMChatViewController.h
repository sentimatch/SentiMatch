//
//  SMChatViewController.h
//  SentiMatch
//
//  Created by ISMAIL J MUSTAFA on 6/6/15.
//
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessages.h>
#import <JSQMessagesBubbleImageFactory.h>

@interface SMChatViewController : JSQMessagesViewController <JSQMessagesCollectionViewDataSource>

- (instancetype)initWithOtherName:(NSString *)otherName;

@property (weak, nonatomic) NSString *receiveName;

@end
