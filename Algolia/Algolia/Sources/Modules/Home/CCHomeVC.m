//
//  CCHomeVC.m
//  Algolia
//
//  Created by Mark Molina on 19/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCHomeVC.h"
#import "CCSearchVC.h"

@interface CCHomeVC () <UITableViewDelegate>

@end

@implementation CCHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableViewController *tableViewController = self.childViewControllers.lastObject;
    tableViewController.tableView.delegate = self;
}

#pragma mark - Private

- (void)showCategories {
    
    UINavigationController *navigationController = self.tabBarController.viewControllers[1];
    [navigationController popToRootViewControllerAnimated:NO];
    
    CCSearchVC *vc = navigationController.viewControllers[0];
    
    vc.shouldShowSearchBar = NO;
    
    [self.tabBarController setSelectedIndex:1];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
            [self showCategories];
            break;
        default:
            break;
    }
}

@end
