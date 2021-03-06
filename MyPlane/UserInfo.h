//
//  UserInfo.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/10/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>

@interface UserInfo : PFObject <PFSubclassing>
+ (NSString *)parseClassName;

@property (retain) NSString *firstName;
@property (retain) NSString *lastName;
@property (retain) NSString *user;
@property (retain) NSString *fReason;
@property (retain) NSArray *friends;
@property (retain) NSArray *sentFriendRequests;
@property (retain) NSArray *receivedFriendRequests;
@property (retain) NSArray *commonTasks;
@property (retain) NSArray *blockedUsers;
@property (retain) NSArray *blockedUsernames;
@property (retain) PFFile *profilePicture;
@property int gracePeriod;
@property int circleRequestsCount;
@property int adminRank;
@property BOOL flagged;

@end
