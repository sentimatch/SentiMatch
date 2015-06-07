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
#import <CoreLocation/CoreLocation.h>
#import "SMBackEndAPI.h"
#import "ChatsListViewController.h"

@interface FoursquareVenues () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (strong, nonatomic) NSMutableArray *venues;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) NSIndexPath *selectedVenue;

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
    
    // Get user's location
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined ) {
            // We never ask for authorization. Let's request it.
            [self.locationManager requestWhenInUseAuthorization];
        } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
                   [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            // We have authorization. Let's update location.
            [self.locationManager startUpdatingLocation];
        } else {
            // If we are here we have no pormissions.
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView setFrame:self.view.bounds];
}

#pragma mark - Location Manager

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
    [self getVenuesForLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"Location manager did fail with error %@", error);
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [manager startUpdatingLocation];
    }
}

- (void) getVenuesForLocation:(CLLocation *)location
{
    // Query Foursquare
    [Foursquare2 venueSearchNearByLatitude:@(location.coordinate.latitude)
                                 longitude:@(location.coordinate.longitude)
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedVenue = indexPath;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Check in" message:@"Do you want to check in to this venue?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    NSDictionary *venue = [self.venues objectAtIndex:self.selectedVenue.row];
    
    if (buttonIndex != alertView.cancelButtonIndex) {
        [SMBackEndAPI postVenueID:[venue objectForKey:@"id"] withCompletionHandler:^(BOOL successful) {
            ChatsListViewController *chats = [[ChatsListViewController alloc] init];
            chats.venue = venue;
            [self.navigationController pushViewController:chats animated:YES];
        }];
    }
}

@end
