//
//  CreateCircleViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/22/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "CreateCircleViewController.h"
#import "Reachability.h"

@interface CreateCircleViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
@property (strong, nonatomic) UITextField *textField;
@property (nonatomic, strong) CurrentUser *sharedManager;
@property (nonatomic, strong) UILabel *limitLabel;

@end

@implementation CreateCircleViewController {
    BOOL public;
    NSString *privacy;
    NSMutableArray *invitedMembers;
    NSMutableArray *invitedUsernames;
    NSString *circleName;
    Reachability *reachability;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:YES];
//    self.currentUser = self.sharedManager.currentUser;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    public = YES;
        
    privacy = @"closed";
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
    
    if (reachability.currentReachabilityStatus == NotReachable) {
        self.doneBarButton.enabled = NO;
    } else {
        [self checkTextField:nil];
    }
}

- (void)reachabilityChanged:(NSNotification*) notification
{
    if (reachability.currentReachabilityStatus == NotReachable) {
        self.doneBarButton.enabled = NO;
    } else {
        [self checkTextField:nil];
    }
}

-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 1;
            break;
            
        default:
            return invitedMembers.count;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFTableViewCell *cell;
    
    // I configure the cells based on section; where section 0 = Name and Bool cells,
    // section 1 = invite members cell, and section 2 = invited members details.
    
    if (indexPath.section == 0) { // Name and Bool Cells
        
        if (indexPath.row == 0) { // Name Cell
            static NSString *CellIdentifier = @"NameCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            UITextField *name = (UITextField *)[cell viewWithTag:6221];
            self.limitLabel = (UILabel *)[cell viewWithTag:1337];
            self.limitLabel.hidden = YES;
            name.delegate = self;
            
            self.textField = name;
            
            [self.textField addTarget:self action:@selector(checkTextField:) forControlEvents:UIControlEventEditingChanged];
            
        } else if (indexPath.row == 1){ // Bool Cell
            static NSString *CellIdentifier = @"BoolCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            FUISegmentedControl *privacySegmentedController = (FUISegmentedControl *)[cell viewWithTag:6251];
            UIButton *infoButton = (UIButton *)[cell viewWithTag:6261];
            
            privacySegmentedController.selectedSegmentIndex = 1;
            
            [privacySegmentedController addTarget:self action:@selector(publicBoolSwitch:) forControlEvents:UIControlEventValueChanged];
            [infoButton addTarget:self action:@selector(infoButton:) forControlEvents:UIControlEventTouchUpInside];
        }
        
    } else if (indexPath.section == 1){ // Invite Members (Segue) Cell
        static NSString *CellIdentifier = @"InviteCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

        cell.textLabel.text = @"Invite Members";
        
    } else { // Invited members cell(s)
        static NSString *CellIdentifier = @"MemberCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        UILabel *name = (UILabel *)[cell viewWithTag:6201];
        UILabel *username = (UILabel *)[cell viewWithTag:6202];
        PFImageView *userImage = (PFImageView *)[cell viewWithTag:6211];
        FUIButton *removeMember = (FUIButton *)[cell viewWithTag:6241];
        
        UserInfo *user = [invitedMembers objectAtIndex:indexPath.row];
        
        name.text = user.firstName;
        username.text = user.user;
        userImage.file = user.profilePicture;
        [userImage loadInBackground];
        
        [removeMember addTarget:self action:@selector(removeInvitedMember:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        return 70;
    } else {
        return 44;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ((invitedMembers.count > 0) && (section == 2)) {
        return @"Invited Members";
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *selectedColor = [UIColor colorFromHexCode:@"FF7140"];
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageWithColor:[UIColor whiteColor] cornerRadius:1.0f];
    av.image = background;
    cell.backgroundView = av;
    
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = selectedColor;
    
    
    [cell setSelectedBackgroundView:bgView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator2"]];
    imgView.frame = CGRectMake(-1, (cell.frame.size.height - 1), 302, 1);
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            UILabel *nameTitle = (UILabel *)[cell viewWithTag:622];
            UITextField *postLabel = (UITextField *)[cell viewWithTag:6221];
            
            nameTitle.font = [UIFont flatFontOfSize:17];
            postLabel.font = [UIFont flatFontOfSize:14];
            
            
            [cell.contentView addSubview:imgView];
            
        } else {
            UILabel *publicTitle = (UILabel *)[cell viewWithTag:625];
            FUISegmentedControl *postLabel = (FUISegmentedControl *)[cell viewWithTag:6251];
            
            publicTitle.font = [UIFont flatFontOfSize:17];
            
            postLabel.selectedFont = [UIFont boldFlatFontOfSize:16];
            postLabel.selectedFontColor = [UIColor cloudsColor];
            postLabel.deselectedFont = [UIFont flatFontOfSize:16];
            postLabel.deselectedFontColor = [UIColor cloudsColor];
            postLabel.selectedColor = [UIColor colorFromHexCode:@"FF7140"];
            postLabel.deselectedColor = [UIColor colorFromHexCode:@"FF9773"];
            postLabel.dividerColor = [UIColor colorFromHexCode:@"FF7140"];
            postLabel.cornerRadius = 15.0f;
            
            
        } 
    } else if (indexPath.section == 1) {
        cell.textLabel.font = [UIFont flatFontOfSize:17];
        cell.textLabel.backgroundColor = [UIColor whiteColor];
        
    } else {
        
        UILabel *name = (UILabel *)[cell viewWithTag:6201];
        UILabel *usernameLabel = (UILabel *)[cell viewWithTag:6202];
        FUIButton *removeBtn = (FUIButton *)[cell viewWithTag:6241];
        
        name.font = [UIFont flatFontOfSize:15];
        usernameLabel.font = [UIFont flatFontOfSize:14];
        
        removeBtn.buttonColor = [UIColor colorFromHexCode:@"FF7140"];
        removeBtn.shadowColor = [UIColor colorFromHexCode:@"FF9773"];
        removeBtn.shadowHeight = 2.0f;
        removeBtn.cornerRadius = 3.0f;
        removeBtn.titleLabel.font = [UIFont boldFlatFontOfSize:14];
        
        [removeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [removeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        [cell.contentView addSubview:imgView];
        
    }
    

    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        nil;
    }
}


#pragma mark - Other Methods

- (void)publicBoolSwitch:(id)sender {
    FUISegmentedControl *privacySegmentedControl = (FUISegmentedControl *)sender;
    
    switch (privacySegmentedControl.selectedSegmentIndex) {
        case 0:
            public = NO;
            privacy = @"private";
            break;
        case 1:
            public = YES;
            privacy = @"closed";
            break;
        case 2:
            public = YES;
            privacy = @"open";
            break;
            
        default:
            break;
    }
}

- (void)infoButton:(id)sender
{
    NSString *message;
    if ([privacy isEqualToString:@"private"]) {
        message = @"'Invite-Only' groups are not searchable. \n Recommended for families and other small groups.";
    } else if ([privacy isEqualToString:@"closed"]) {
        message = @"Searchable groups that require others to request to join unless invited.";
    } else if ([privacy isEqualToString:@"open"]) {
        message = @"Open Circles are searchable. You can join within the search menu, and can receive a request to join. Open Circles are not managed by any single entity.";
    }
    
    UIColor *barColor = [UIColor colorFromHexCode:@"F87056"];
    
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"Privacy Description"
                                                          message:message
                                                         delegate:nil
                                                cancelButtonTitle:@"Close"
                                                otherButtonTitles:nil];
    
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:17];
    alertView.messageLabel.textColor = [UIColor whiteColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:15];
    alertView.backgroundOverlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f];
    alertView.alertContainer.backgroundColor = barColor;
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor clearColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    
    
    [alertView show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *nav = [segue destinationViewController];
    InviteMembersToCircleViewController *controller = (InviteMembersToCircleViewController *)nav.topViewController;
    
    controller.delegate = self;
    controller.currentlyInvitedMembers = [[NSMutableArray alloc] initWithArray:invitedMembers];
    controller.invitedUsernames = [[NSMutableArray alloc] initWithArray:invitedUsernames];
}

- (void)inviteMembersToCircleViewController:(InviteMembersToCircleViewController *)controller didFinishWithMembers:(NSMutableArray *)members andUsernames:(NSMutableArray *)usernames
{
    invitedMembers = members;
    invitedUsernames = usernames;
    [self.tableView reloadData];
}


- (void)checkTextField:(id)sender
{
    self.limitLabel.hidden = NO;
    
    circleName = self.textField.text;
    NSString *removedSpaces = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    int limit = 35 - self.textField.text.length;
    self.limitLabel.text = [NSString stringWithFormat:@"%d", limit];
    if ((removedSpaces.length > 0) && (limit >= 0)) {
        self.doneBarButton.enabled = YES;
    } else {
        self.doneBarButton.enabled = NO;
    }
}

- (void)removeInvitedMember:(id)sender
{
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    UserInfo *user = [invitedMembers objectAtIndex:indexPath.row];
    
    [invitedMembers removeObject:user];
    [invitedUsernames removeObject:user.user];
    [self.tableView reloadData];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    [SVProgressHUD setStatus:@"Creating circle..."];
    [self dismissViewControllerAnimated:YES completion:^{
        
    Circles *circle = [Circles object];
    circle.name = [circleName lowercaseString];
    circle.displayName = circleName;
    circle.user = [PFUser currentUser].username;
    circle.owner = self.currentUser;
    circle.public = public;
    circle.privacy = privacy;
    
    
    if (![privacy isEqualToString:@"open"]) {
        [circle addObject:[PFUser currentUser].username forKey:@"admins"];
        [circle addObject:[UserInfo objectWithoutDataWithObjectId:self.currentUser.objectId] forKey:@"adminPointers"];
    }
    
    [circle addObject:self.currentUser forKey:@"members"];
    [circle addObject:self.currentUser.user forKey:@"memberUsernames"];
    
    if (invitedMembers.count > 0) {
        
        PFRelation *relation = [circle relationforKey:@"requests"];
        NSMutableArray *requestsToSave = [[NSMutableArray alloc] init];
        //        NSMutableArray *requestsToSaveWOData = [[NSMutableArray alloc] init];
        NSMutableArray *usersToSave = [[NSMutableArray alloc] init];
        
        for (UserInfo *user in invitedMembers) {
            [user incrementKey:@"circleRequestsCount" byAmount:[NSNumber numberWithInt:1]];
            [usersToSave addObject:user];
            
            Requests *request = [Requests object];
            
            [request setCircle:circle];
            [request setSender:self.currentUser];
            [request setSenderUsername:[PFUser currentUser].username];
            [request setReceiver:user];
            [request setReceiverUsername:user.user];
            
            [circle addObject:user.user forKey:@"pendingMembers"];
            
            [requestsToSave addObject:request];
            //            [requestsToSaveWOData addObject:[Requests objectWithoutDataWithObjectId:request.objectId]];
        };
        
        [UserInfo saveAllInBackground:usersToSave block:^(BOOL succeeded, NSError *error) {
            [Requests saveAllInBackground:requestsToSave block:^(BOOL succeeded, NSError *error) {
                for (Requests *request in requestsToSave) {
                    [relation addObject:request];
                    [circle addObject:[Requests objectWithoutDataWithObjectId:request.objectId] forKey:@"requestsArray"];
                }
                [circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@ created", circle.displayName]];
                    //[self dismissViewControllerAnimated:YES completion:nil];
                }];
            }];
        }];
    } else {
        [circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@ created", circle.displayName]];
            //[self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
        
    }];
    
    /*[SVProgressHUD setStatus:@"Creating circles..."];
    
    Circles *circle = [Circles object];
    circle.name = [circleName lowercaseString];
    circle.displayName = circleName;
    circle.user = [PFUser currentUser].username;
    circle.owner = self.currentUser;
    circle.public = public;
    circle.privacy = privacy;
    
    
    if (![privacy isEqualToString:@"open"]) {
        [circle addObject:[PFUser currentUser].username forKey:@"admins"];
        [circle addObject:[UserInfo objectWithoutDataWithObjectId:self.currentUser.objectId] forKey:@"adminPointers"];
    }
    
    [circle addObject:self.currentUser forKey:@"members"];
    [circle addObject:self.currentUser.user forKey:@"memberUsernames"];
    
    if (invitedMembers.count > 0) {
        
        PFRelation *relation = [circle relationforKey:@"requests"];
        NSMutableArray *requestsToSave = [[NSMutableArray alloc] init];
//        NSMutableArray *requestsToSaveWOData = [[NSMutableArray alloc] init];
        NSMutableArray *usersToSave = [[NSMutableArray alloc] init];
        
        for (UserInfo *user in invitedMembers) {
            [user incrementKey:@"circleRequestsCount" byAmount:[NSNumber numberWithInt:1]];
            [usersToSave addObject:user];
            
            Requests *request = [Requests object];
            
            [request setCircle:circle];
            [request setSender:self.currentUser];
            [request setSenderUsername:[PFUser currentUser].username];
            [request setReceiver:user];
            [request setReceiverUsername:user.user];
            
            [circle addObject:user.user forKey:@"pendingMembers"];
            
            [requestsToSave addObject:request];
//            [requestsToSaveWOData addObject:[Requests objectWithoutDataWithObjectId:request.objectId]];
        };
        
        [UserInfo saveAllInBackground:usersToSave block:^(BOOL succeeded, NSError *error) {
            [Requests saveAllInBackground:requestsToSave block:^(BOOL succeeded, NSError *error) {
                for (Requests *request in requestsToSave) {
                    [relation addObject:request];
                    [circle addObject:[Requests objectWithoutDataWithObjectId:request.objectId] forKey:@"requestsArray"];
                }
                [circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@ created", circle.displayName]];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
            }];
        }];
    } else {
        [circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@ created", circle.displayName]];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }*/
}

- (void)hideKeyboard
{
    [self.textField resignFirstResponder];
}

@end
