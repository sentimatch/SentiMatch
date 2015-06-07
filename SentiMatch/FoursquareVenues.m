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
#import <MapKit/MapKit.h>

@interface FoursquareVenues () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) NSMutableArray *venues;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) NSIndexPath *selectedVenue;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong ,nonatomic) UIButton *listResultsButton;
@property (nonatomic, assign) BOOL resultsShowing;

@end

@implementation FoursquareVenues

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    // Map view setup
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height*0.95)];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.userInteractionEnabled = YES;
    [self.view addSubview:self.mapView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedMap)];
    tapGesture.numberOfTapsRequired = 1;
    [self.mapView addGestureRecognizer:tapGesture];
    
    self.listResultsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.listResultsButton addTarget:self
               action:@selector(animateView:)
     forControlEvents:UIControlEventTouchUpInside];
    [self.listResultsButton setTitle:@"Find a Place" forState:UIControlStateNormal];
    [self.listResultsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.listResultsButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
    self.listResultsButton.frame = CGRectMake(0, self.view.frame.size.height*0.93, self.view.frame.size.width, self.view.frame.size.height*0.07);
    self.listResultsButton.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:76.0/255.0 blue:16.0/255.0 alpha:1.0];
    [self.view addSubview:self.listResultsButton];
    self.resultsShowing = NO;
    
    // Setup table view
    self.venues = [[NSMutableArray alloc] init];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height * 0.95, self.view.frame.size.width, self.view.frame.size.height*0.05) style:UITableViewStylePlain];
    [self.tableView setHidden:YES];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:222.0/255.0 blue:161.0/255.0 alpha:1.0];
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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)animateView:(id)sender
{
    // Show results table
    if (!self.resultsShowing) {
        [self.tableView setHidden:NO];
        [UIView animateWithDuration:0.75 delay:0.0 usingSpringWithDamping:0.65 initialSpringVelocity:0.0 options:0 animations:^{
            self.tableView.frame = CGRectMake(0, self.view.frame.size.height*0.3, self.view.frame.size.width, self.view.frame.size.height*0.7);
            self.mapView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height*0.3);
            [self.listResultsButton setAlpha:0.f];
        } completion:^(BOOL finished) {
            self.resultsShowing = YES;
            [self setupMap];
        }];
        
    // Hide results table
    } else {
        [UIView animateWithDuration:0.75 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.0 options:0 animations:^{
            self.tableView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
            self.mapView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            [self.listResultsButton setAlpha:1.f];
        } completion:^(BOOL finished) {
            [self.tableView setHidden:YES];
            self.resultsShowing = NO;
            [self setupMap];
        }];
    }
}

#pragma mark - Location Manager

- (void)setupMap
{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0;
    span.longitudeDelta = 0;
    CLLocationCoordinate2D location;
    location.latitude = self.locationManager.location.coordinate.latitude;
    location.longitude = self.locationManager.location.coordinate.longitude;
    region.span = span;
    region.center = location;
    [self.mapView setRegion:region animated:YES];
}

- (void)tappedMap
{
    if (self.resultsShowing) {
        [self animateView:self];
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
    [self getVenuesForLocation:newLocation];
    [self setupMap];
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
                                          [self addVenuePins];
                                          [self.tableView reloadData];
                                      }
                                  }];
}

#pragma mark - Pins

- (void)addVenuePins
{
    for (NSDictionary *venue in self.venues) {
        // Place a single pin
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = (CLLocationDegrees)[[[venue objectForKey:@"location"] objectForKey:@"lat"] doubleValue];
        coordinate.longitude = (CLLocationDegrees)[[[venue objectForKey:@"location"] objectForKey:@"lng"] doubleValue];
        [annotation setCoordinate:coordinate];
        [annotation setTitle:[venue objectForKey:@"name"]];
        [annotation setSubtitle:[[[venue objectForKey:@"categories"] objectAtIndex:0] objectForKey:@"name"]];
        [self.mapView addAnnotation:annotation];
    }
}

#pragma mark - Table View

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Venues";
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
    cell.contentView.backgroundColor = self.tableView.backgroundColor;
    
    NSDictionary *venue = [self.venues objectAtIndex:indexPath.row];
    cell.textLabel.text = [venue objectForKey:@"name"];
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-light" size:24.0];
    cell.detailTextLabel.text = [[[venue objectForKey:@"categories"] objectAtIndex:0] objectForKey:@"name"];
    
    NSString *imgURL = [NSString stringWithFormat:@"%@bg_32%@", [[[[venue objectForKey:@"categories"] objectAtIndex:0] objectForKey:@"icon"] objectForKey:@"prefix"], [[[[venue objectForKey:@"categories"] objectAtIndex:0] objectForKey:@"icon"] objectForKey:@"suffix"]];
    if (!cell.imageView.image) {
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:imgURL]];
        cell.imageView.image = [UIImage imageWithData: imageData];
    }
    
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
        [SMBackEndAPI postVenueID:[venue objectForKey:@"id"] withCompletionHandler:^(BOOL successful, id responseObject) {
            NSString *mySumString = responseObject[0][@"person_sum"];
            CGFloat sum = [mySumString floatValue];
            [[NSUserDefaults standardUserDefaults] setObject:@(sum) forKey:@"sum"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            ChatsListViewController *chats = [[ChatsListViewController alloc] init];
            chats.venue = venue;
            [self.navigationController pushViewController:chats animated:YES];
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

@end
