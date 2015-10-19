//
//  AppDelegate.m
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "AppDelegate.h"
#import "CCHomeVC.h"
#import "CCSearchVC.h"
#import "CCMenuVC.h"

#import "CCSearchDataStore.h"

#import <RESideMenu/RESideMenu.h>

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupApplication];
    
    // Override point for customization after application launch.
    self.window = [UIWindow new];
    self.window.frame = UIScreen.mainScreen.bounds;
    self.window.backgroundColor = UIColor.whiteColor;
    
    // Home View Controller
    UIStoryboard *homeStoryBoard = [UIStoryboard storyboardWithName:@"HomeStoryBoard" bundle:nil];
    CCHomeVC *homeVC = [homeStoryBoard instantiateViewControllerWithIdentifier:@"HomeStoryBoard"];
    
    // Search View Controller
    CCSearchVC *searchVC = [CCSearchVC new];
    UINavigationController *searchNavigationController = [[UINavigationController alloc] initWithRootViewController:searchVC];
    searchNavigationController.navigationBar.translucent = NO;
    
    // Menu View Controller
    CCMenuVC *menuVC = [CCMenuVC new];
    
    UITabBarController *tabbarController = [UITabBarController new];
    tabbarController.tabBar.translucent = NO;
    tabbarController.viewControllers = @[homeVC, searchNavigationController, menuVC];
    
    UITabBarItem *homeTabbarItem = [tabbarController.tabBar.items objectAtIndex:0];
    homeTabbarItem.title = @"Home";
    [homeTabbarItem setImage:[UIImage imageNamed:@"HomeTab"]];

    UITabBarItem *searchTabbarItem = [tabbarController.tabBar.items objectAtIndex:1];
    searchTabbarItem.title = @"Search";
    [searchTabbarItem setImage:[UIImage imageNamed:@"SearchTab"]];
    
    UITabBarItem *accountTabbarItem = [tabbarController.tabBar.items objectAtIndex:2];
    accountTabbarItem.title = @"My Account";
    [accountTabbarItem setImage:[UIImage imageNamed:@"AccountTab"]];
    
    RESideMenu *sideMenu = [[RESideMenu alloc] initWithContentViewController:tabbarController leftMenuViewController:nil rightMenuViewController:nil];
    sideMenu.backgroundImage = [UIImage imageNamed:@"SolidBG"];
    sideMenu.panGestureEnabled = NO;
    
    self.window.rootViewController = sideMenu;
    [self.window makeKeyAndVisible];
    
    return YES;
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

#pragma mark - Private

- (void)setupApplication {
    
}

@end
