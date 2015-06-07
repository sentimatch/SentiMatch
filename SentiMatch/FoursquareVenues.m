//
//  FoursquareVenues.m
//  SentiMatch
//
//  Created by Anas Bouzoubaa on 6/6/15.
//
//

#import "FoursquareVenues.h"
#import <Foursquare-API-v2/Foursquare2.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface FoursquareVenues () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *venues;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation FoursquareVenues

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup table view
    self.venues = [[NSMutableArray alloc] init];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    // Query Foursquare
    [Foursquare2 venueSearchNearByLatitude:@(40.702973)
                                 longitude:@(-73.990258)
                                     query:nil
                                     limit:nil
                                    intent:intentBrowse
                                    radius:@(50)
                                categoryId:nil
                                  callback:^(BOOL success, id result){
                                      if (success) {
                                          self.venues = [result valueForKeyPath:@"response.venues"];
                                          [self.tableView reloadData];
                                      }
                                  }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView setFrame:self.view.bounds];
}

#pragma mark - Table View

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.venues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"venueCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"venueCell"];
    }
    
    NSDictionary *venue = [self.venues objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [venue objectForKey:@"name"];
    cell.detailTextLabel.text = [[[venue objectForKey:@"categories"] objectAtIndex:0] objectForKey:@"name"];
    NSString *imgURL = [NSString stringWithFormat:@"%@bg_32%@", [[[[venue objectForKey:@"categories"] objectAtIndex:0] objectForKey:@"icon"] objectForKey:@"prefix"],
                        [[[[venue objectForKey:@"categories"] objectAtIndex:0] objectForKey:@"icon"] objectForKey:@"suffix"]];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imgURL]];
    
    return cell;
}

@end
