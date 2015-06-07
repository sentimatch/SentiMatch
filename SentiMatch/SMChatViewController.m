//
//  SMChatViewController.m
//  SentiMatch
//
//  Created by ISMAIL J MUSTAFA on 6/6/15.
//
//

#import "SMChatViewController.h"

@interface SMChatViewController()

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong ,nonatomic) JSQMessagesBubbleImageFactory *incomingBubble;
@property (strong, nonatomic) JSQMessagesBubbleImageFactory *outgoingBubble;

@end

@implementation SMChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.userName = @"Ismail";
    
    // Generate fake data
    for (NSInteger i = 0; i < 10; i++) {
        NSString *sender;
        if (i % 2 == 0) {
            sender = self.userName;
        }
        else sender = @"Pranav";
        JSQMessage *message = [JSQMessage messageWithSenderId:sender displayName:sender text:@"HELLO"];
        [self.messages addObject:message];
    }
    
    [self.collectionView reloadData];
    self.senderDisplayName = self.userName;
    self.senderId = self.userName;
}

-(id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *data = self.messages[indexPath.row];
    return data;
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *data = self.messages[indexPath.row];
    if ([data.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubble;
    }
    else return self.incomingBubble;
}

-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.messages.count;
}



@end
