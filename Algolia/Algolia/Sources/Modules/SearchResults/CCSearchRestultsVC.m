//
//  CCSearchRestultsVC.m
//  Algolia
//
//  Created by Mark Molina on 19/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCSearchRestultsVC.h"
#import "CCSearchBarPlugin.h"
#import "CCSearchDataStore.h"
#import "CCSearchResponse.h"

#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface CCSearchRestultsVC () <CCSearchBarPluginDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *query;
@property (nonatomic, strong) CCSearchBarPlugin *searchBarPlugin;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CCSearchResponse *searchResponse;
@property (nonatomic, strong) NSArray *recentSearches;

@end

@implementation CCSearchRestultsVC

+ (instancetype)viewControllerWithSearchQuery:(NSString *)query {
    
    return [[self alloc] initWithSearchQuery:query];
}

- (instancetype)initWithSearchQuery:(NSString *)query {
    
    self = [super init];
    if (self) {
        _query = query;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Search results";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createViews];
}

#pragma mark - Private

- (void)createViews {
    
    [self createSearchButton];
    [self createSearchBar];
    [self createTableView];
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
    //self.tableView.dataSource = self;
    //self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    //UINib *searchSuggestionCellNib = [UINib nibWithNibName:@"CCSearchSuggestionCell" bundle:nil];
    //[self.tableView registerNib:searchSuggestionCellNib forCellReuseIdentifier:@"CCSearchSuggestionCell"];
}

@end
