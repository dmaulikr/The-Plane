//
//  RemindersViewController.h
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/7/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "AddReminderViewController.h"
#import "firstTimeSettingsViewController.h"
#import "ReminderDisclosureViewController.h"
#import "AddCircleReminderViewController.h"
#import "CurrentUser.h"


@interface RemindersViewController : PFQueryTableViewController <AddReminderViewControllerDelegate, firstTimeSettingsViewControllerDelegate, ReminderDisclosureViewControllerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, FUIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *sentReminders;


- (IBAction)unwindToReminders:(UIStoryboardSegue *)unwindSegue;
- (IBAction)addReminder:(id)sender;

@end
 