//
//  AddFriendViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/8/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "AddFriendViewController.h"
#import "CurrentUser.h"
#import "Reachability.h"

@interface AddFriendViewController ()

- (IBAction)adjustButtonState:(id)sender;

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
//@property (nonatomic, strong) NSMutableArray *searchResults;

@end

@interface AddFriendViewController ()

@end

@implementation AddFriendViewController {
    //NSArray *friendsArray;
    //NSMutableArray *friendsUNArray;
    NSMutableArray *friendsArray;
    NSMutableArray *sentFriendRequestsArray;
    NSMutableArray *searchResults;
    NSMutableArray *friendsObjectId;
    NSMutableArray *sentFriendRequestsObjectId;
    PFQuery *currentUserQuery;
    PFQuery *friendQuery;
    UserInfo *userObject;
    Reachability *reachability;
}


- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.pullToRefreshEnabled = NO;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
        self.parseClassName = @"UserInfo";
        
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];

    [self.searchBar becomeFirstResponder];
    self.searchBar.delegate = self;
    UIColor *barColor = [UIColor colorFromHexCode:@"FF4100"];
    [[UISearchBar appearance] setBackgroundColor:barColor];
    [self configureViewController];
    
    //self.searchResults = [NSMutableArray array];
    //friendsUNArray = [NSMutableArray array];
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    if(reachability.currentReachabilityStatus == NotReachable) {
		self.doneBtn.enabled = NO;
	} else {
		self.doneBtn.enabled = YES;
        [self currentUserQuery];
    }
    
}

- (void)reachabilityChanged:(NSNotification*)notification
{
	if(reachability.currentReachabilityStatus == NotReachable) {
		self.doneBtn.enabled = NO;
	} else {
		self.doneBtn.enabled = YES;
    }
}

-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.rowHeight = 70;
    
    self.tableView.backgroundView = av;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)currentUserQuery
{
    currentUserQuery = [UserInfo query];
    [currentUserQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    //[currentUserQuery includeKey:@"friends"];
    //[currentUserQuery includeKey:@"friends.user"];
    currentUserQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    [currentUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (UserInfo *object in objects) {
            //friendsArray = object.friends;
            userObject = object;
            friendsArray = [[NSMutableArray alloc]initWithArray:object.friends];
            sentFriendRequestsArray = [[NSMutableArray alloc]initWithArray: object.sentFriendRequests];
        }
        [self getIDs];
    }];
}

-(void)getIDs {
    
    friendsObjectId = [[NSMutableArray alloc]init];
    sentFriendRequestsObjectId = [[NSMutableArray alloc] init];
    
    for (PFObject *object in userObject.friends) {
        [friendsObjectId addObject:[object objectId]];
    }
    for (PFObject *object in userObject.sentFriendRequests) {
        [sentFriendRequestsObjectId addObject:[object objectId]];
    }
    
}

/*- (void)getUsername;
{
    
    NSMutableArray *userName = [[NSMutableArray alloc]init];
    for (UserInfo *object in friendsArray) {
        NSString *name = object.user;
        [userName addObject:name];
    }
    friendsUNArray = userName;
}*/

- (void)filterResults:(NSString *)searchTerm
{
    NSString *newTerm = [searchTerm lowercaseString];
    
    //[self.searchResults removeAllObjects];
    
    friendQuery = [UserInfo query];
    [friendQuery whereKey:@"user" hasPrefix:newTerm];
    
    if (searchResults.count == 0) {
        friendQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [searchResults removeAllObjects];
        searchResults = [[NSMutableArray alloc] initWithArray:[friendQuery findObjects]];
        /*NSArray *results = [query findObjects];
        [self.searchResults addObjectsFromArray:results];*/
        [self loadObjects];
    });
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self filterResults:searchBar.text];
    [searchBar resignFirstResponder];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //NSLog(@"Rows upon NumberofRowsInSections %d", self.searchResults.count);
    return searchResults.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *uniqueIdentifier = @"friendCell";
    
    PFTableViewCell *cell = (PFTableViewCell *) [self.tableView dequeueReusableCellWithIdentifier:uniqueIdentifier];
    
    if (searchResults.count > 0) {
        UILabel *name = (UILabel *)[cell viewWithTag:2101];
        UILabel *username = (UILabel *)[cell viewWithTag:2102];
        PFImageView *picImage = (PFImageView *)[cell viewWithTag:2111];
        UIButton *addButton = (UIButton *)[cell viewWithTag:2121];
        addButton.enabled = YES;
        
        UserInfo *searchedUser = [searchResults objectAtIndex:indexPath.row];
        name.text = [NSString stringWithFormat:@"%@ %@", searchedUser.firstName, searchedUser.lastName];
        username.text = searchedUser.user;
        picImage.file = searchedUser.profilePicture;
        
        [picImage loadInBackground];
        
        if ([friendsObjectId containsObject:searchedUser.objectId] || [sentFriendRequestsObjectId containsObject:searchedUser.objectId]) {
            addButton.enabled = NO;
        }
        
        
        [addButton addTarget:self action:@selector(adjustButtonState:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    
    return cell;
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
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2101];
    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:2101];
    
    nameLabel.font = [UIFont flatFontOfSize:16];
    usernameLabel.font = [UIFont flatFontOfSize:14];
    nameLabel.adjustsFontSizeToFitWidth = YES;
    usernameLabel.adjustsFontSizeToFitWidth = YES;
    
    nameLabel.textColor = [UIColor colorFromHexCode:@"A62A00"];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];
    nil;
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)adjustButtonState:(id)sender
{
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    UserInfo *friendAdded = [searchResults objectAtIndex:clickedButtonPath.row];
    //NSString *friendAddedName = friendAdded.user;
    NSString *friendObjectID = friendAdded.objectId;
    NSString *userID = userObject.objectId;
    
    UserInfo *friendToAdd = [UserInfo objectWithoutDataWithClassName:@"UserInfo" objectId:friendObjectID];
    UserInfo *userObjectID = [UserInfo objectWithoutDataWithClassName:@"UserInfo" objectId:userID];
    
    [sentFriendRequestsObjectId addObject:friendAdded.objectId];
    //[userObject addObject:friendAdded forKey:@"sentFriendRequests"];
    [userObject addObject:friendToAdd forKey:@"sentFriendRequests"];
    [userObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        CurrentUser *sharedManager = [CurrentUser sharedManager];
        sharedManager.currentUser = userObject;
        //[friendAdded addObject:userObject forKey:@"receivedFriendRequests"];
        [friendAdded addObject:userObjectID forKey:@"receivedFriendRequests"];
        [friendAdded saveInBackground];
        
        [SVProgressHUD showSuccessWithStatus:@"Friend Request Sent"];
        
//        NSDictionary *data = @{
//                               @"f": @"add"
//                               };
//        
//        PFQuery *pushQuery = [PFInstallation query];
//        [pushQuery whereKey:@"user" equalTo:friendAddedName];
//        
//        PFPush *push = [[PFPush alloc] init];
//        [push setQuery:pushQuery];
//        [push setData:data];
//        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        }];
        
    }];    
    
    UIButton *addFriendButton = (UIButton *)sender;
    addFriendButton.enabled = NO;
    
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    [self.delegate addFriendViewControllerDidFinishAddingFriends:self];
}
@end
