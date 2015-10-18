//
//  CCSearchVC.m
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCSearchVC.h"
#import "CCSearchBarPlugin.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface CCSearchVC () <CCSearchBarPluginDelegate>
@property (nonatomic, strong) CCSearchBarPlugin *searchBarPlugin;
@end

@implementation CCSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Search";
    self.view.backgroundColor = [UIColor purpleColor];
    
    [self createViews];
}

#pragma mark - Private

- (void)createViews {
    
    [self createSearchButton];
    [self createSearchBar];
    
    // Make the seachbar the first responder on load
    [self showSearch:nil];
}

- (void)createSearchButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                           target:self
                                                                                           action:@selector(showSearch:)];
}

- (void)createSearchBar {
    self.searchBarPlugin = [[CCSearchBarPlugin alloc] initWithRootController:self];
    self.searchBarPlugin.delegate = self;
    
    @weakify(self)
    [self.searchBarPlugin.rac_searchRequestFailed subscribeNext:^(id x) {
        @strongify(self)
        
        // Handle error
    }];
}

- (void)showSearch:(id)sender {
    
    [self.searchBarPlugin showSearchBar];
}

#pragma mark - CCSearchBarPlugin

- (void)searchBarTextDidChange:(NSString *)searchText {
    
    NSLog(@"search query: %@", searchText);
}

@end
