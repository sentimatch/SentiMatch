//
//  ChatsListViewController.m
//  SentiMatch
//
//  Created by Anas Bouzoubaa on 6/6/15.
//
//

#import "ChatsListViewController.h"

@interface ChatsListViewController ()

@end

@implementation ChatsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Check out from venue
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Leave" style:UIBarButtonItemStyleDone target:self action:@selector(checkoutFromVenue)];
    self.navigationItem.rightBarButtonItem = item;
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
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Checked in @ %@", [self.venue objectForKey:@"name"]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"threadCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"threadCell"];
    }

    cell.textLabel.text = [NSString stringWithFormat:@"Random person #%ld", (long)indexPath.row];
    
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
