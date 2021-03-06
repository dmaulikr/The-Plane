//
//  UserInfo.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/10/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//
#import "UserInfo.h"
#import <Parse/PFObject+Subclass.h>

@implementation UserInfo
+ (NSString *)parseClassName {
    return @"UserInfo";
}

@dynamic firstName;
@dynamic lastName;
@dynamic user;
@dynamic friends;
@dynamic sentFriendRequests;
@dynamic receivedFriendRequests;
@dynamic commonTasks;
@dynamic blockedUsers;
@dynamic blockedUsernames;
@dynamic profilePicture;
@dynamic circleRequestsCount;
@dynamic gracePeriod;
@dynamic adminRank;
@dynamic fReason;
@dynamic flagged;

@end
