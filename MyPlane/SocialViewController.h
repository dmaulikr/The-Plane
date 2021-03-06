//
//  SocialViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/17/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "SocialPostDetailViewController.h"
#import "AddSocialPostViewController.h"
#import "SubclassHeader.h"
#import "AddReminderViewController.h"
#import "UzysSlideMenu.h"

@interface SocialViewController : PFQueryTableViewController <UITextFieldDelegate, SocialPostDetailViewControllerDelegate, AddSocialPostViewControllerDelegate>
- (IBAction)addComment:(id)sender;
- (IBAction)unwindToSocial:(UIStoryboardSegue *)unwindSegue;


@end
 