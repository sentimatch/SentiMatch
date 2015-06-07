//
//  ChatsListViewController.m
//  SentiMatch
//
//  Created by Anas Bouzoubaa on 6/6/15.
//
//

#import "ChatsListViewController.h"
#import "SMBackEndAPI.h"
#import <SSKeychain/SSKeychain.h>
#import "SMChatViewController.h"
#import "SMBackEndAPI.h"

@interface ChatsListViewController ()

@property (strong, nonatomic) NSArray *users;
@property (strong, nonatomic) NSArray *userIDs;
@property (strong, nonatomic) NSArray *percentages;
@property (strong, nonatomic) NSString *userID;
@property (nonatomic) CGFloat sum;
@property (nonatomic) BOOL check;

@end

@implementation ChatsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.navigationItem.title = self.venue[@"name"];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:222.0/255.0 blue:161.0/255.0 alpha:1.0];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.sum = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sum"] floatValue];
    self.check = NO;
    self.users = @[];
    
    self.userID = [SSKeychain passwordForService:@"twitter_login" account:@"twitter_account"];
    
    [self checkVenueAgain];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSLog(@"hello");
    }
}

- (void)checkVenueAgain
{
    [SMBackEndAPI checkVenueID:[self.venue objectForKey:@"id"] withCompletionHandler:^(BOOL successful, id result) {
        NSMutableDictionary *relativePersonalities = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *relativePersonalitiesUserID = [[NSMutableDictionary alloc] init];
        for (NSDictionary *person in result) {
            NSString *temp = person[@"email"];
            NSRange range = [temp rangeOfString:@"@"];
            NSString *currentID = [temp substringToIndex:range.location];
            if (![currentID isEqualToString:self.userID]) {
                CGFloat currentSum = [person[@"person_sum"] floatValue];
                CGFloat relativeSum = fabs(currentSum - self.sum);
                [relativePersonalities setObject:@(relativeSum) forKey:person[@"name"]];
                [relativePersonalitiesUserID setObject:@(relativeSum) forKey:currentID];
            }
        }
        
        NSArray *sorted = [[relativePersonalities allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[relativePersonalities objectForKey:obj1] compare:[relativePersonalities objectForKey:obj2]];
        }];
        
        NSArray *sorted2 = [[relativePersonalitiesUserID allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[relativePersonalitiesUserID objectForKey:obj1] compare:[relativePersonalitiesUserID objectForKey:obj2]];
        }];
        
        NSMutableArray *percentageStuff = [[NSMutableArray alloc] init];
        for (NSString *key in sorted) {
            [relativePersonalities[key] floatValue];
            NSLog(@"key: %@, value: %@", key, relativePersonalities[key]);
            CGFloat numerator = [relativePersonalities[key] floatValue];
            CGFloat val = floorf(100 - ((numerator/self.sum) * 100));
            [percentageStuff addObject:@(val)];
        }
        self.percentages = [NSArray arrayWithArray:percentageStuff];
        
        self.users = sorted;
        self.userIDs = sorted2;
        [self.tableView reloadData];
        if (!self.check) {
            self.check = YES;
            // Poll the backend every 60 seconds
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkVenueAgain) userInfo:nil repeats:YES];
            [timer fire];
        }
        
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (![[self.navigationController viewControllers] containsObject:self]) {
        [SMBackEndAPI checkoutWithCompletionHandler:^(BOOL successful) {}];
    }
}

- (void)checkoutFromVenue
{
    // nothing yet
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Checked in @ %@", [self.venue objectForKey:@"name"]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"threadCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"threadCell"];
    }
    cell.backgroundColor = self.view.backgroundColor;

    cell.textLabel.text = self.users[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-light" size:28.0];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.text = [self.percentages[indexPath.row] stringValue];
    CGFloat num = [self.percentages[indexPath.row] floatValue];
    if (num >= 85) {
        cell.detailTextLabel.textColor = [UIColor colorWithRed:27/255.0 green:188.0/255.0 blue:155.0/255.0 alpha:1.0];
    }
    else if (num >= 33 && num < 85) {
        cell.detailTextLabel.textColor = [UIColor colorWithRed:242.0/255.0 green:121.0/255.0 blue:53.0/255.0 alpha:1.0];
    }
    else {
     
        cell.detailTextLabel.textColor = [UIColor colorWithRed:246.0/255.0 green:71.0/255.0 blue:71.0/255.0 alpha:1.0];
    }
    cell.detailTextLabel.font = [UIFont fontWithName:@"Avenir-Black" size:20.0];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedUser = self.userIDs[indexPath.row];
    SMChatViewController *chatVC = [[SMChatViewController alloc] initWithOtherName:selectedUser];
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0;
}

@end
