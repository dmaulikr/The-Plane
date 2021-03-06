//
//  CircleRequestsViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/23/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubclassHeader.h"

@class CircleRequestsViewController;

@protocol CircleRequestsViewControllerDelegate <NSObject>

- (void)circleRequestsDidFinish:(CircleRequestsViewController *)controller;

@end

@interface CircleRequestsViewController : PFQueryTableViewController

@property (nonatomic, weak) id <CircleRequestsViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet FUISegmentedControl *segmentedControl;
- (IBAction)segmentedChange:(id)sender;
@property (nonatomic, strong) UserInfo *currentUser;
@property (nonatomic, strong) NSArray *circles;

@end
 