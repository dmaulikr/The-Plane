//
//  FriendsQueryViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/17/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "FriendsQueryViewController.h"

@interface FriendsQueryViewController ()

@end

@implementation FriendsQueryViewController {
    PFObject *meObject;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (NSString *)dataFilePath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:
            @"UserProfile.plist"];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"fCenterTabbarItemTapped"
                                               object:nil];
    
    //CUSTOMIZE
    self.tableView.rowHeight = 70;
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    
    [self getUserInfo];

	// Do any additional setup after loading the view.
}

-(void)getUserInfo {
    PFQuery *query = [PFQuery queryWithClassName:@"UserInfo"];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    [query includeKey:@"friends"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        meObject = object;
    }];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"reloadFriends"
                                               object:nil];
}

- (void)receiveAddNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"fCenterTabbarItemTapped"]) {
        NSLog (@"Successfully received the add notification for friends!");
        [self performSegueWithIdentifier:@"AddFriend" sender:nil];
    }
    
    else if ([[notification name] isEqualToString:@"reloadFriends"]) {
        [self loadObjects];
    }
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable {
    

    PFQuery *query = [PFQuery queryWithClassName:@"UserInfo"];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    [query includeKey:@"friends"];
    
    
    PFQuery *friendQuery = [UserInfo query];
    [friendQuery whereKey:@"friends" matchesQuery:query];
        
    
    [friendQuery orderByAscending:@"firstName"];
    
    
    if (self.objects.count == 0) {
        friendQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    
    
    
    
    
    return friendQuery;
    
    
}

-(void)checkFriendRequests {
    PFQuery *query = [PFQuery queryWithClassName:@"UserInfo"];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        NSArray *array = [object objectForKey:@"receivedFriendRequests"];
        int count = array.count;
        NSLog(@"count: %d", count);
        self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"%d", count];
    }];
}

- (void)addFriendViewControllerDidFinishAddingFriends:(AddFriendViewController *)controller
{
    [self loadObjects];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
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
    
    
    /*cell.textLabel.backgroundColor = [UIColor clearColor];
     if ([cell respondsToSelector:@selector(detailTextLabel)])
     cell.detailTextLabel.backgroundColor = [UIColor clearColor];
     
     //Guess some good text colors
     cell.textLabel.textColor = selectedColor;
     cell.textLabel.highlightedTextColor = color;
     if ([cell respondsToSelector:@selector(detailTextLabel)]) {
     cell.detailTextLabel.textColor = selectedColor;
     cell.detailTextLabel.highlightedTextColor = color;
     }*/
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *identifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        
    }
    
    
    
    
    PFImageView *picImage = (PFImageView *)[cell viewWithTag:2000];
    UILabel *contactText = (UILabel *)[cell viewWithTag:2001];
    UILabel *detailText = (UILabel *)[cell viewWithTag:2002];
    
    PFFile *pictureFile = [object objectForKey:@"profilePicture"];
    NSString *username = [object objectForKey:@"user"];
    NSString *firstName = [object objectForKey:@"firstName"];
    NSString *lastName = [object objectForKey:@"lastName"];
    
    picImage.file = pictureFile;
    contactText.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    detailText.text = username;
    
    [picImage loadInBackground];
    
    /*dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        PFFile *theImage = (PFFile *)[object objectForKey:@"profilePicture"];
        UIImage *fromUserImage = [[UIImage alloc] initWithData:theImage.getData];
        dispatch_async(dispatch_get_main_queue(), ^{
            picImage.file = pictureFile;
            contactText.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            detailText.text = username;
        });
        
        
    });*/
    

    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    PFObject *friendRemoved = [self.objects objectAtIndex:indexPath.row];
    PFObject *friendRemovedData = [PFObject objectWithoutDataWithClassName:@"UserInfo" objectId:[friendRemoved objectId]];
    PFUser *user = [PFUser currentUser];
    NSString *username = user.username;
    NSString *friendRemoveName = [friendRemoved objectForKey:@"user"];
    
    if (![friendRemoveName isEqualToString:username]) {
    
        
        [friendRemoved removeObject:meObject forKey:@"friends"];
        [friendRemoved saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            [meObject removeObject:friendRemovedData forKey:@"friends"];
            [meObject saveInBackground];
            [self loadObjects];
        }];
        
        
    } else {
        NSLog(@"CANT DELETE SELF!");
    }
    
    
    
    
    
    
    
    
    /*NSString *friendRemovedName = friendRemoved.user;
    NSString *userName = [personObject objectForKey:@"user"];
    
    if (![friendRemovedName isEqualToString:userName]) {
        
        [personObject removeObject:friendRemoved forKey:@"friends"];
        [friendRemoved removeObject:personObject forKey:@"friends"];
        
        [personObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [friendRemoved saveInBackground];
            [self reQueryForTableWithIndexPath:indexPath];
            
        }];
        
    } else {
        NSLog(@"CANT DELETE SELF");
    }*/
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddFriend"]) {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        AddFriendViewController *controller = (AddFriendViewController *)navController.topViewController;
        controller.delegate = self;
    }
}

- (void)receivedFriendRequests:(ReceivedFriendRequestsViewController *)controller
{
    [self loadObjects];
}



@end