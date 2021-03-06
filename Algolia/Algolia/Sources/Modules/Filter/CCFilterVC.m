//
//  CCFilterVC.m
//  Algolia
//
//  Created by Mark Molina on 19/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCFilterVC.h"
#import "CCSearchDataStore.h"
#import "CCCategoryCell.h"
#import "CCCategory.h"

#import <Masonry/Masonry.h>

static NSString * const kCCCategoryCell = @"CCCategoryCell";
static NSString * const kCellReuseIdentifier = @"Cell";

static NSInteger const kLeftMargin = 110;
static NSInteger const kTopMargin = 15;

@interface CCFilterVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *categoriesDataSource;

@end

@implementation CCFilterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.categoriesDataSource =  [[CCSearchDataStore sharedInstance] retrieveCategories];
    
    [self createViews];
}

#pragma mark - Setters

- (void)setCategories:(NSArray *)categories {
    
    _categories = categories;
    [self setSelectedCategories];
}

#pragma mark - Private

- (void)createViews {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectNull style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(kLeftMargin);
        make.top.equalTo(self.view).with.offset(kTopMargin);
        make.bottom.right.equalTo(self.view);
    }];
    
    UINib *categoryCellNib = [UINib nibWithNibName:kCCCategoryCell bundle:nil];
    [self.tableView registerNib:categoryCellNib forCellReuseIdentifier:kCCCategoryCell];
}

- (void)setSelectedCategories {
    
    for (CCCategory *category in self.categoriesDataSource) {
        
        CCCategoryCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[self.categoriesDataSource indexOfObject:category] inSection:1]];
        if ([self.categories containsObject:category.name]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

- (UITableViewCell *)cellForPriceRangeFromTableView:(UITableView *)tableView {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellReuseIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    cell.textLabel.text = @"Set price range";
    
    return cell;
}

- (CCCategoryCell *)cellForCategoryFromTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    
    CCCategoryCell *categoryCell = [tableView dequeueReusableCellWithIdentifier:kCCCategoryCell forIndexPath:indexPath];
    categoryCell.backgroundColor = [UIColor clearColor];
    
    CCCategory *category = [[CCSearchDataStore sharedInstance] retrieveCategories][indexPath.row];
    categoryCell.nameLabel.text = category.name;;
    
    return categoryCell;
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return section == 0 ? @"Price" : @"Categories";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return section == 0 ? 1 : [[CCSearchDataStore sharedInstance] retrieveCategories].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            return [self cellForPriceRangeFromTableView:tableView];
        case 1:
            return [self cellForCategoryFromTableView:tableView indexPath:indexPath];
        default:
            return nil;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    CCCategory *category = self.categoriesDataSource[indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(filterVCDidSelectCategoryName:)]) {
        [self.delegate filterVCDidSelectCategoryName:category.name];
    }
}

@end
