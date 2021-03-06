//
//  AppDelegate.m
//  Twitter
//
//  Created by Sarat Tallamraju on 2/20/15.
//  Copyright (c) 2015 Sarat Tallamraju. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "TwitterClient.h"
#import "User.h"
#import "Tweet.h"
#import "TweetsViewController.h"
#import "TweetDetailViewController.h"
#import "ComposeViewController.h"
#import "MenuViewController.h"
#import "MainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    [self styleApplication];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(userDidLogout) name: UserDidLogoutNotification object:nil];
    
    User *user = [User currentUser];
    // jUIViewController *vc = nil;
    if (user != nil) {
        NSLog(@"User already logged in! Welcome, %@", user.name);
        TweetsViewController *tweetsVC = [[TweetsViewController alloc] init];
        MenuViewController *menuVC = [[MenuViewController alloc] init];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tweetsVC];
        
        UIViewController *mainVC = [[MainViewController alloc] initWithRootViewController: navigationController
                                                                    andMenuViewController:menuVC];
        
        
        [self setNavigationControllerProperties: navigationController];
        self.window.rootViewController = mainVC;
    } else {
        NSLog(@"Not already logged in...");
        UIViewController *mainVC = [[LoginViewController alloc] init];
        self.window.rootViewController = mainVC;
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void) styleApplication {
    UIColor *babyBlue = [UIColor colorWithRed:0.34 green:0.68 blue:0.94 alpha:1.0];
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
    
    [[UINavigationBar appearance] setBarTintColor: babyBlue];
    [[UINavigationBar appearance] setTintColor: [UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes: navbarTitleTextAttributes];
    [[UINavigationBar appearance] setTranslucent: NO];
    
    [[UIView appearanceWhenContainedIn: [TweetsViewController class], nil] setBackgroundColor: [UIColor whiteColor]];
    [[UIView appearanceWhenContainedIn: [ComposeViewController class], nil] setBackgroundColor: [UIColor whiteColor]];
    [[UIView appearanceWhenContainedIn: [TweetDetailViewController class], nil] setBackgroundColor: [UIColor whiteColor]];
}

- (void) setNavigationControllerProperties: (UINavigationController *) navigationController {
    navigationController.navigationBar.translucent = NO;
}

- (void) userDidLogout {
    UIViewController *vc = [[LoginViewController alloc] init];
    self.window.rootViewController = vc;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    [[TwitterClient sharedInstance] openURL: url];
    
    
    return YES;
}

@end
