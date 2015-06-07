//
//  SMChatViewController.m
//  SentiMatch
//
//  Created by ISMAIL J MUSTAFA on 6/6/15.
//
//

#import "SMChatViewController.h"
#import <Firebase/Firebase.h>

@interface SMChatViewController()

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *otherName;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong ,nonatomic) JSQMessagesBubbleImage *incomingBubble;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubble;
@property (strong, nonatomic) Firebase *rootRef;


@end

@implementation SMChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rootRef = [[Firebase alloc] initWithUrl:@"https://sentimatch.firebaseIO.com"];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubble = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubble = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
    self.userName = @"Ismail";
    self.otherName = @"Pranav";
    
    self.messages = [[NSMutableArray alloc] init];
    
    [self.collectionView reloadData];
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.senderDisplayName = self.userName;
    self.senderId = self.userName;
    
    // Receiving messages
    [self.rootRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSDictionary *dict = snapshot.value;
            for (NSString *key in dict) {
            if ([key isEqualToString:self.userName]) {
                NSString *message = dict[key];
                JSQMessage *data = [JSQMessage messageWithSenderId:self.otherName displayName:self.otherName text:message];
                [self.messages addObject:data];
                [self finishReceivingMessage];
            }
        }
    }];
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

-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    JSQMessage *newMessage = [JSQMessage messageWithSenderId:senderId displayName:senderDisplayName text:text];
    [self.messages addObject:newMessage];
    NSDictionary *dict = @{self.otherName : text};
    [self.rootRef setValue:dict];
    [self finishSendingMessage];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}

-(void)didPressAccessoryButton:(UIButton *)sender
{
    
}

@end
