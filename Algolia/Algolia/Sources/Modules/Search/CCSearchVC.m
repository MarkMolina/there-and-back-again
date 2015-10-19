//
//  CCSearchVC.m
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCSearchVC.h"
#import "CCSearchRestultsVC.h"
#import "CCSearchBarPlugin.h"
#import "CCSearchDataStore.h"
#import "CCSearchResponse.h"
#import "CCHit.h"
#import "CCCategory.h"

#import "CCSearchSuggestionCell.h"
#import "CCCategoryCell.h"
#import "CCRecentSearchHeader.h"

#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

typedef NS_ENUM(NSInteger, CCDataSourceType) {
    CCDataSourceCategory = 0,
    CCDataSourceSearch
};

@interface CCSearchVC () <CCSearchBarPluginDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CCSearchBarPlugin *searchBarPlugin;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CCSearchResponse *searchResponse;
@property (nonatomic, strong) NSArray *recentSearches;
@property (nonatomic, assign) CCDataSourceType dataSourceType;

@end

@implementation CCSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Search";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createViews];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    self.recentSearches = [[NSUserDefaults standardUserDefaults] objectForKey:@"recent_searches"];
    if (!self.recentSearches) {
        self.recentSearches = [NSArray new];
    }
    
    // Make the seachbar the first responder
    [self showSearch:nil];
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
    
    self.dataSourceType = CCDataSourceSearch;
    [self.searchBarPlugin showSearchBar];
    [self.tableView reloadData];
}

- (void)createTableView {
    
    self.tableView = [UITableView new];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UINib *searchSuggestionCellNib = [UINib nibWithNibName:@"CCSearchSuggestionCell" bundle:nil];
    [self.tableView registerNib:searchSuggestionCellNib forCellReuseIdentifier:@"CCSearchSuggestionCell"];
    
    UINib *categoryCellNib = [UINib nibWithNibName:@"CCCategoryCell" bundle:nil];
    [self.tableView registerNib:categoryCellNib forCellReuseIdentifier:@"CCCategoryCell"];
}

#pragma mark - CCSearchBarPlugin

- (void)searchBarTextDidChange:(NSString *)searchText {
    
    if (!searchText.length) {
        self.searchResponse = nil;
        [self.tableView reloadData];
        return;
    }
    
    [[CCSearchDataStore sharedInstance] queryWithFullTextQuery:searchText success:^(CCSearchResponse *searchResponse) {
       
        self.searchResponse = searchResponse;
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
    
    
}

- (void)searchBarCancelButtonClicked {
    
    self.dataSourceType = CCDataSourceCategory;
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked {
    
    [self saveRecentSearchesFromSearchResponse:self.searchResponse];
    self.recentSearches = [[NSUserDefaults standardUserDefaults] objectForKey:@"recent_searches"];
    [self.tableView reloadData];
    
    [self pushSearchResultsVCWithQuery:self.searchResponse.query facets:nil];
}

- (BOOL)shouldShowRecentSearches {
    
    if (!self.searchResponse.hits.count && self.dataSourceType == CCDataSourceSearch) {
        return YES;
    }
    
    return NO;
}

- (void)pushSearchResultsVCWithQuery:(NSString *)query facets:(NSArray *)facets {
    
    CCSearchRestultsVC *vc = [[CCSearchRestultsVC alloc] initWithSearchQuery:query facets:facets];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (![self shouldShowRecentSearches]) {
        return nil;
    }
    
    CCRecentSearchHeader *header = [CCRecentSearchHeader new];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if ([self shouldShowRecentSearches]) {
        return 77.f;
    }
    
    return 0.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.dataSourceType == CCDataSourceCategory) {
        return [[CCSearchDataStore sharedInstance] retrieveCategories].count;
    }
    
    return [self shouldShowRecentSearches] ? self.recentSearches.count : self.searchResponse.hits.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataSourceType == CCDataSourceCategory) {
        CCCategoryCell *categoryCell = [tableView dequeueReusableCellWithIdentifier:@"CCCategoryCell" forIndexPath:indexPath];
        
        CCCategory *category = [[CCSearchDataStore sharedInstance] retrieveCategories][indexPath.row];
        categoryCell.nameLabel.text = category.name;
        categoryCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return categoryCell;
    }
    
    if (![self shouldShowRecentSearches]) {
        CCSearchSuggestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CCSearchSuggestionCell" forIndexPath:indexPath];
        
        CCHit *hit = self.searchResponse.hits[indexPath.row];
        cell.hit = hit;
        
        return cell;
    } else {
        CCSearchSuggestionCell *tableviewCell = [tableView dequeueReusableCellWithIdentifier:@"CCSearchSuggestionCell"];
        
        tableviewCell.nameLabel.text = self.recentSearches[indexPath.row];
        
        return tableviewCell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataSourceType == CCDataSourceCategory) {
        CCCategory *category = [[CCSearchDataStore sharedInstance] retrieveCategories][indexPath.row];
        [self pushSearchResultsVCWithQuery:@"" facets:@[[NSString stringWithFormat:@"%@:%@", @"categories", category.name]]];
        return;
    }
    
    if (![self shouldShowRecentSearches]) {
        NSLog(@"Show details of this object");
        return;
    } else {
        [self.searchBarPlugin hideSearchBar];
        [self pushSearchResultsVCWithQuery:self.recentSearches[indexPath.row] facets:nil];
        return;
    }
    
}

@end
