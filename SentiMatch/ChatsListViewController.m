//
//  ChatsListViewController.m
//  SentiMatch
//
//  Created by Anas Bouzoubaa on 6/6/15.
//
//

#import "ChatsListViewController.h"
#import "SMBackEndAPI.h"

@interface ChatsListViewController ()

@property (strong, nonatomic) NSMutableArray *users;

@end

@implementation ChatsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.users = [[NSMutableArray alloc] init];
    
    // Check out from venue
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Leave" style:UIBarButtonItemStyleDone target:self action:@selector(checkoutFromVenue)];
    self.navigationItem.rightBarButtonItem = item;
    
    [SMBackEndAPI checkVenueID:[self.venue objectForKey:@"id"] withCompletionHandler:^(BOOL successful, id result) {
        self.users = result;
        [self.tableView reloadData];
        
        // Poll the backend every 60 seconds
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(checkVenueAgain) userInfo:nil repeats:YES];
        [timer fire];
    }];
}

- (void)checkVenueAgain
{
    [SMBackEndAPI checkVenueID:[self.venue objectForKey:@"id"] withCompletionHandler:^(BOOL successful, id result) {
        self.users = result;
        [self.tableView reloadData];
    }];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"threadCell"];
    }

    NSDictionary *user = [self.users objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [user objectForKey:@"name"]];
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
