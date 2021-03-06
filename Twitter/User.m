//
//  User.m
//  Twitter
//
//  Created by Sarat Tallamraju on 2/21/15.
//  Copyright (c) 2015 Sarat Tallamraju. All rights reserved.
//

#import "User.h"
#import "TwitterClient.h"

@interface User()

@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation User

static User *_currentUser = nil;

NSString * const kCurrentUserKey = @"kCurrentUserKey";

NSString * const UserDidLoginNotification = @"UserDidLoginNotification";
NSString * const UserDidLogoutNotification = @"UserDidLogoutNotification";

+ (User *) currentUser {
    if (_currentUser == nil) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey: kCurrentUserKey];
        
        if (data != nil) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData: data options:0 error:NULL];
            _currentUser = [[User alloc] initWithDictionary: dictionary];
        }
    }
    
    return _currentUser;
}

+ (void) setCurrentUser: (User *) user {
    _currentUser = user;
    
    if (_currentUser != nil) {
        NSData *data = [NSJSONSerialization dataWithJSONObject: user.dictionary options:0 error:NULL];
        [[NSUserDefaults standardUserDefaults] setObject: data forKey: kCurrentUserKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject: nil forKey: kCurrentUserKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) logout {
    [User setCurrentUser: nil];
    [[TwitterClient sharedInstance].requestSerializer removeAccessToken];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: UserDidLogoutNotification object:nil];
}

-(id) initWithDictionary: (NSDictionary *) dictionary {
    self = [super init];
    
    if (self) {
        
        self.dictionary = dictionary;
        self.name = dictionary[@"name"];
        self.screenName = dictionary[@"screen_name"];
        self.profileImageUrl = dictionary[@"profile_image_url"];
        self.profileBackgroundImageUrl = dictionary[@"profile_background_image_url"];
        self.tagline = dictionary[@"description"];
        self.tweetCount = [dictionary[@"statuses_count"] integerValue];
        self.followingCount = [dictionary[@"friends_count"] integerValue];
        self.followersCount = [dictionary[@"followers_count"] integerValue];
    }
    
    return self;
}


@end
