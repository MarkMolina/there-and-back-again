//
//  CCSearchVC.m
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCSearchVC.h"
#import "CCSearchBarPlugin.h"

#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface CCSearchVC () <CCSearchBarPluginDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CCSearchBarPlugin *searchBarPlugin;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation CCSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Search";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createViews];
}

#pragma mark - Private

- (void)createViews {
    
    [self createSearchButton];
    [self createSearchBar];
    [self createTableView];
    
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

- (void)createTableView {
    
    self.tableView = [UITableView new];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - CCSearchBarPlugin

- (void)searchBarTextDidChange:(NSString *)searchText {
    
    NSLog(@"search query: %@", searchText);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 5;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    cell.textLabel.text = @"Title here";
    
    return cell;
    
}

@end
