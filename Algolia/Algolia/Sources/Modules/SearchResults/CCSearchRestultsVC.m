//
//  CCSearchRestultsVC.m
//  Algolia
//
//  Created by Mark Molina on 19/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCSearchRestultsVC.h"
#import "CCFilterVC.h"
#import "CCSearchBarPlugin.h"
#import "CCSearchDataStore.h"
#import "CCSearchResponse.h"
#import "CCResultsCell.h"

#import "NSArray+Facets.h"

#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <RESideMenu/RESideMenu.h>

static NSString * const kFilterIcon = @"FilterIcon";
static NSString * const kResultsCell = @"CCResultsCell";
static NSString * const kFacetKey = @"categories";

static CGFloat const kCellHeigth = 130.f;
static NSUInteger const kNumberOfOffersLeftForPreload = 5;

@interface CCSearchRestultsVC () <CCSearchBarPluginDelegate, CCFilterVCDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *query;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) CCSearchBarPlugin *searchBarPlugin;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CCSearchResponse *searchResponse;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) RESideMenu *sideMenu;

@end

@implementation CCSearchRestultsVC

+ (instancetype)viewControllerWithSearchQuery:(NSString *)query categories:(NSArray *)categories {
    
    return [[self alloc] initWithSearchQuery:query categories:categories];
}

- (instancetype)initWithSearchQuery:(NSString *)query categories:(NSArray *)categories {
    
    self = [super init];
    if (self) {
        _query = query;
        _categories = categories;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Search results";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.sideMenu = (RESideMenu *)[[UIApplication sharedApplication] keyWindow].rootViewController;
    
    [self createViews];
    [self setFilterCategories];
    [self retrieveSearchResults];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self.searchBarPlugin hideSearchBar];
}

#pragma mark - Private

- (void)createViews {
    
    [self createBarButtonItems];
    [self createSearchBar];
    [self createTableView];
}

- (void)setFilterCategories {
    
    CCFilterVC *vc = (CCFilterVC *)self.sideMenu.rightMenuViewController;
    vc.delegate = self;
    vc.categories = self.categories;
}

- (void)createBarButtonItems {
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kFilterIcon]
                                                                                 style:UIBarButtonItemStyleDone
                                                                                target:self
                                                                                action:@selector(showFilter:)],
                                                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                              target:self
                                                                                              action:@selector(showSearch:)]];
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
    
    [self.searchBarPlugin showSearchBar];
}

- (void)showFilter:(id)sender {
    
    [self.sideMenu presentRightMenuViewController];
}

- (void)createTableView {
    
    self.tableView = [UITableView new];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UINib *resultsCell = [UINib nibWithNibName:kResultsCell bundle:nil];
    [self.tableView registerNib:resultsCell forCellReuseIdentifier:kResultsCell];
}

- (void)retrieveSearchResults {
    
    self.currentPage = 0;
    [[CCSearchDataStore sharedInstance] queryWithFullTextQuery:self.query facets:[self.categories facetsArrayWithKey:kFacetKey] success:^(CCSearchResponse *searchResponse) {
        
        self.searchResponse = searchResponse;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
       
        // TODO: Handle error
    }];
}

- (void)retrieveNextSearchResults {
    
    self.currentPage++;
    [[CCSearchDataStore sharedInstance] queryWithFullTextQuery:self.query page:self.currentPage facets:[self.categories facetsArrayWithKey:kFacetKey] success:^(CCSearchResponse *searchResponse) {
        
        NSArray *array = [self.searchResponse.hits arrayByAddingObjectsFromArray:searchResponse.hits];
        self.searchResponse.hits = array;
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        // TODO: Handle error
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.searchResponse.hits.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CCResultsCell *resultsCell = [tableView dequeueReusableCellWithIdentifier:kResultsCell forIndexPath:indexPath];
    
    CCHit *hit = self.searchResponse.hits[indexPath.row];
    [resultsCell setHit:hit];
    
    if (indexPath.row + kNumberOfOffersLeftForPreload >= self.searchResponse.hits.count) {
        [self retrieveNextSearchResults];
    }
    
    return resultsCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return kCellHeigth;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - CCSearchBarPluginDelegate

- (void)searchBarTextDidChange:(NSString *)searchText {
    
    self.query = searchText;
    [[CCSearchDataStore sharedInstance] queryWithFullTextQuery:searchText facets:[self.categories facetsArrayWithKey:kFacetKey] success:^(CCSearchResponse *searchResponse) {
        
        self.searchResponse = searchResponse;
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)searchBarCancelButtonClicked {
    
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked {
    
    [self saveRecentSearchesFromSearchResponse:self.searchResponse];
    self.query = self.searchResponse.query;
    [self retrieveSearchResults];
}

#pragma mark - CCFilterVCDelegate

- (void)filterVCDidSelectCategoryName:(NSString *)categoryName {
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:self.categories];
    
    if ([mutableArray containsObject:categoryName]) {
        [mutableArray removeObject:categoryName];
    } else {
        [mutableArray addObject:categoryName];
    }
    
    self.categories = mutableArray.copy;
    [self retrieveSearchResults];
}

@end
