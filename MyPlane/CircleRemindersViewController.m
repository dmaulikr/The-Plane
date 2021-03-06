//
//  CircleRemindersViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/18/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "CircleRemindersViewController.h"

@interface CircleRemindersViewController ()

@end

@implementation CircleRemindersViewController {
    NSDateFormatter *dateFormatter;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.loadingViewEnabled = NO;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViewController];
	
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
}

-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    self.tableView.rowHeight = 70;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadObjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable
{
    PFRelation *relation = [self.circle relationforKey:@"reminders"];
    
    PFQuery *query = [relation query];
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    [query includeKey:@"fromFriend"];
    [query includeKey:@"comments"];
    [query includeKey:@"recipient"];
    return query;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSLog(@"%d", self.objects.count);
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *cellIdentifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    Reminders *reminder = (Reminders *)object;
    
    PFImageView *profPic = (PFImageView *)[cell viewWithTag:1337];
    UILabel *reminderLabel = (UILabel *)[cell viewWithTag:1338];
    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:1339];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:1340];
    
    reminderLabel.text = reminder.title;
    usernameLabel.text = reminder.user;
    dateLabel.text = [dateFormatter stringFromDate:[object objectForKey:@"date"]];
    profPic.file = [reminder.fromFriend objectForKey:@"profilePicture"];
    [profPic loadInBackground];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"list-item"];
    av.image = background;
    
    cell.backgroundView = av;
    
    UIColor *selectedColor = [UIColor colorFromHexCode:@"FF7140"];
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = selectedColor;
    
    
    [cell setSelectedBackgroundView:bgView];
    
    UILabel *reminderLabel = (UILabel *)[cell viewWithTag:1338];
    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:1339];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:1340];
    
    reminderLabel.font = [UIFont flatFontOfSize:16];
    usernameLabel.font = [UIFont flatFontOfSize:14];
    dateLabel.font = [UIFont flatFontOfSize:14];
    
    reminderLabel.textColor = [UIColor colorFromHexCode:@"A62A00"];
    
    

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Reminders *reminder = (Reminders *)[self.objects objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ReminderDisclosure" sender:reminder];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Reminders *deleteReminder = [self.objects objectAtIndex:indexPath.row];
    NSString *deleteName = [deleteReminder objectForKey:@"fromUser"];
    NSString *tempName = [deleteReminder objectForKey:@"user"];
    NSMutableArray *commentsToDelete = [[NSMutableArray alloc] init];
    
    for (Comments *comment in deleteReminder.comments) {
        [commentsToDelete addObject:[Comments objectWithoutDataWithObjectId:comment.objectId]];
    }
    
    SocialPosts *post;
    if ((deleteReminder.socialPost)) {
        post = (SocialPosts *)deleteReminder.socialPost;
        if (post.claimerUsernames.count == 1) {
            [post setIsClaimed:NO];
        }
        [post removeObject:[Reminders objectWithoutDataWithObjectId:deleteReminder.objectId] forKey:@"reminder"];
        [post removeObject:deleteReminder.user forKey:@"claimerUsernames"];
        [post removeObject:[UserInfo objectWithoutDataWithObjectId:deleteReminder.recipient.objectId] forKey:@"claimers"];
    }
    
    [deleteReminder deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [Comments deleteAllInBackground:commentsToDelete block:^(BOOL succeeded, NSError *error) {
                [post saveInBackground];
            }];
            NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
            [self loadObjects];
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
            [SVProgressHUD showSuccessWithStatus:@"Denied Reminder"];
            
            if (![deleteName isEqualToString:[PFUser currentUser].username]) {
                NSString *message = [NSString stringWithFormat:@"%@ has deleted your reminder", tempName];
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                      message, @"alert",
                                      @"d", @"r",
                                      @"alertSound.caf", @"sound",
                                      nil];
//                NSDictionary *data = @{
//                                       @"r": @"d",
//                                       @"sound": @"alertSound.caf"
//                                       };
                
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"user" equalTo:deleteName];
                
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:pushQuery];
                //[push setMessage:message];
                [push setData:data];
                [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSString *message = [NSString stringWithFormat:@"%@ has been notified", deleteName];
                        [SVProgressHUD showSuccessWithStatus:message];
                    } else {
                        NSLog(@"%@", error);
                    }
                }];
            }
            
        }
    }];
    
    
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddReminder"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        AddCircleReminderViewController *controller = (AddCircleReminderViewController *)nav.topViewController;
        controller.delegate = self;
        controller.circle = self.circle;
        controller.currentUser = self.currentUser;
    } else if ([segue.identifier isEqualToString:@"ReminderDisclosure"]) {
        ReminderDisclosureViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.reminderObject = sender;
    }
}

- (void)addCircleReminderViewController:(AddCircleReminderViewController *)controller didFinishAddingReminderInCircle:(Circles *)circle withUsers:(NSArray *)users withTask:(NSString *)task withDescription:(NSString *)description withDate:(NSDate *)date
{
    NSMutableArray *toSave = [[NSMutableArray alloc] init];
    
    for (UserInfo *user in users) {
        Reminders *reminder = [Reminders object];
        reminder.date = date;
        if (![description isEqualToString:@"Enter more information about the reminder..."]) {
            [reminder setObject:description forKey:@"description"];
        } else {
            [reminder setObject:@"No description available." forKey:@"description"];
        }
        reminder.fromFriend = self.currentUser;
        reminder.fromUser = self.currentUser.user;
        reminder.recipient = user;
        reminder.title = task;
        reminder.user = user.user;
        [reminder setObject:circle forKey:@"circle"];
        [toSave addObject:reminder];
    }
    
    [SVProgressHUD showWithStatus:@"Sending Reminders..."];
    [Reminders saveAllInBackground:toSave block:^(BOOL succeeded, NSError *error) {
        for (Reminders *reminder in toSave) {
            PFRelation *relation = [self.circle relationforKey:@"reminders"];
//            NSLog(@"%@", reminder);
            [relation addObject:reminder];
        }
        [self.circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self dismissViewControllerAnimated:YES completion:^{
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Reminder Sent to %d Members of %@", toSave.count, circle.displayName]];
            }];
        }];
    }];
}

@end
