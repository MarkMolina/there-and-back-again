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
#import "CCResultsCell.h"

#import "NSArray+Facets.h"

#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <RESideMenu/RESideMenu.h>

@interface CCSearchRestultsVC () <CCSearchBarPluginDelegate, UITableViewDataSource, UITableViewDelegate>

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
    
    [self createViews];
    [self retrieveSearchResults];
}

#pragma mark - Private

- (void)createViews {
    
    [self createBarButtonItems];
    [self createSearchBar];
    [self createTableView];
}

- (void)createBarButtonItems {
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"FilterIcon"] style:UIBarButtonItemStyleDone target:self action:@selector(showFilter:)],[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                                                                                                           target:self
                                                                                                                                                                           action:@selector(showSearch:)]];
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

- (void)showFilter:(id)sender {
    
    self.sideMenu = (RESideMenu *)[[UIApplication sharedApplication] keyWindow].rootViewController;
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
    
    UINib *resultsCell = [UINib nibWithNibName:@"CCResultsCell" bundle:nil];
    [self.tableView registerNib:resultsCell forCellReuseIdentifier:@"CCResultsCell"];
}

- (void)retrieveSearchResults {
    
    self.currentPage = 0;
    [[CCSearchDataStore sharedInstance] queryWithFullTextQuery:self.query facets:[self.categories facetsArrayWithKey:@"categories"] success:^(CCSearchResponse *searchResponse) {
        
        self.searchResponse = searchResponse;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
       
        NSLog(@"Implement failure");
    }];
}

- (void)retrieveNextSearchResults {
    
    self.currentPage++;
    [[CCSearchDataStore sharedInstance] queryWithFullTextQuery:self.query page:self.currentPage facets:[self.categories facetsArrayWithKey:@"categories"] success:^(CCSearchResponse *searchResponse) {
        
        NSArray *array = [self.searchResponse.hits arrayByAddingObjectsFromArray:searchResponse.hits];
        self.searchResponse.hits = array;
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        NSLog(@"Implement failure");
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.searchResponse.hits.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CCResultsCell *resultsCell = [tableView dequeueReusableCellWithIdentifier:@"CCResultsCell" forIndexPath:indexPath];
    
    CCHit *hit = self.searchResponse.hits[indexPath.row];
    [resultsCell setHit:hit];
    
    if (indexPath.row + 5 >= self.searchResponse.hits.count) {
        [self retrieveNextSearchResults];
    }
    
    return resultsCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 130.f;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - CCSearchBarPlugin

- (void)searchBarTextDidChange:(NSString *)searchText {
    
    [[CCSearchDataStore sharedInstance] queryWithFullTextQuery:searchText facets:[self.categories facetsArrayWithKey:@"categories"] success:^(CCSearchResponse *searchResponse) {
        
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
    [self.tableView reloadData];
    
    //[self pushSearchResultsVCWithQuery:self.searchResponse.query facets:nil];
}

@end
