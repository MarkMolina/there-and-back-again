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

static NSString * const kRecentSearchesKey = @"recent_searches";
static NSString * const kSearchSuggestionCell = @"CCSearchSuggestionCell";
static NSString * const kCategoryCell = @"CCCategoryCell";

static CGFloat const kHeiderHeigth = 77.f;

@interface CCSearchVC () <CCSearchBarPluginDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CCSearchBarPlugin *searchBarPlugin;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CCSearchResponse *searchResponse;
@property (nonatomic, strong) NSArray *recentSearches;
@property (nonatomic, assign) CCDataSourceType dataSourceType;

@end

@implementation CCSearchVC

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _shouldShowSearchBar = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Search";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createViews];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self.tableView reloadData];
    
    self.recentSearches = [[NSUserDefaults standardUserDefaults] objectForKey:kRecentSearchesKey];
    if (!self.recentSearches) {
        self.recentSearches = [NSArray new];
    }
    
    // Make the seachbar the first responder
    if (self.shouldShowSearchBar) {
        [self showSearch:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self.searchBarPlugin hideSearchBar];
    self.showSearchBar = YES;
}

#pragma mark - Setters

- (void)setShowSearchBar:(BOOL)showSearchBar {
    
    _shouldShowSearchBar = showSearchBar;
    _dataSourceType = CCDataSourceCategory;
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
    
    //@weakify(self)
    [self.searchBarPlugin.rac_searchRequestFailed subscribeNext:^(id x) {
        //@strongify(self)
        
        // TODO: Handle error
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
    
    UINib *searchSuggestionCellNib = [UINib nibWithNibName:kSearchSuggestionCell bundle:nil];
    [self.tableView registerNib:searchSuggestionCellNib forCellReuseIdentifier:kSearchSuggestionCell];
    
    UINib *categoryCellNib = [UINib nibWithNibName:kCategoryCell bundle:nil];
    [self.tableView registerNib:categoryCellNib forCellReuseIdentifier:kCategoryCell];
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
        
        // TODO: Handle error
    }];
}

- (void)searchBarCancelButtonClicked {
    
    self.dataSourceType = CCDataSourceCategory;
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked {
    
    [self saveRecentSearchesFromSearchResponse:self.searchResponse];
    self.recentSearches = [[NSUserDefaults standardUserDefaults] objectForKey:kRecentSearchesKey];
    [self.tableView reloadData];
    
    [self pushSearchResultsVCWithQuery:self.searchResponse.query categories:nil];
}

- (BOOL)shouldShowRecentSearches {
    
    if (!self.searchResponse.hits.count && self.dataSourceType == CCDataSourceSearch) {
        return YES;
    }
    
    return NO;
}

- (void)pushSearchResultsVCWithQuery:(NSString *)query categories:(NSArray *)categories {
    
    CCSearchRestultsVC *searchVC = [[CCSearchRestultsVC alloc] initWithSearchQuery:query categories:categories];
    [self.navigationController pushViewController:searchVC animated:YES];
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
        return kHeiderHeigth;
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
        CCCategoryCell *categoryCell = [tableView dequeueReusableCellWithIdentifier:kCategoryCell forIndexPath:indexPath];
        
        if (indexPath.row >= [[CCSearchDataStore sharedInstance] retrieveCategories].count) {
            return categoryCell;
        }
        
        CCCategory *category = [[CCSearchDataStore sharedInstance] retrieveCategories][indexPath.row];
        categoryCell.nameLabel.text = category.name;
        categoryCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return categoryCell;
    }
    
    if (![self shouldShowRecentSearches]) {
        CCSearchSuggestionCell *cell = [tableView dequeueReusableCellWithIdentifier:kSearchSuggestionCell forIndexPath:indexPath];
        
        CCHit *hit = self.searchResponse.hits[indexPath.row];
        cell.hit = hit;
        
        return cell;
    } else {
        CCSearchSuggestionCell *tableviewCell = [tableView dequeueReusableCellWithIdentifier:kSearchSuggestionCell];
        
        tableviewCell.nameLabel.text = self.recentSearches[indexPath.row];
        
        return tableviewCell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataSourceType == CCDataSourceCategory) {
        CCCategory *category = [[CCSearchDataStore sharedInstance] retrieveCategories][indexPath.row];
        [self pushSearchResultsVCWithQuery:@"" categories:@[category.name]];
        return;
    }
    
    if (![self shouldShowRecentSearches]) {
        
        /*
         * NOTE: Out of scope for this assignment
         *  -
         */
        
        NSLog(@"Show details of this object");
        return;
    } else {
        [self.searchBarPlugin hideSearchBar];
        [self pushSearchResultsVCWithQuery:self.recentSearches[indexPath.row] categories:nil];
        return;
    }
    
}

@end
