//
//  FoursquareVenues.m
//  SentiMatch
//
//  Created by Anas Bouzoubaa on 6/6/15.
//
//

#import "FoursquareVenues.h"
#import <Foursquare-API-v2/Foursquare2.h>

@interface FoursquareVenues () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation FoursquareVenues

- (void)viewDidLoad {
    [super viewDidLoad];

    [Foursquare2 venueSearchNearByLatitude:@(40.702973)
                                 longitude:@(-73.990258)
                                     query:nil
                                     limit:nil
                                    intent:intentBrowse
                                    radius:@(50)
                                categoryId:nil
                                  callback:^(BOOL success, id result){
                                      if (success) {
                                          NSDictionary *dic = result;
                                          NSArray *venues = [dic valueForKeyPath:@"response.venues"];
//                                          FSConverter *converter = [[FSConverter alloc]init];
//                                          self.nearbyVenues = [converter convertToObjects:venues];
//                                          [self.tableView reloadData];
//                                          [self proccessAnnotations];
                                          NSLog(@"%@", venues.description);
                                          UITextView *textView = [[UITextView alloc] initWithFrame:self.view.frame];
                                          textView.text = venues.description;
                                          [self.view addSubview:textView];
                                      }
                                  }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

@end
