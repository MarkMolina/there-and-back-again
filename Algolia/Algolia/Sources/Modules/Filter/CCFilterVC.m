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

@interface CCFilterVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation CCFilterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createViews];
}

- (void)createViews {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectNull style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(110);
        make.top.equalTo(self.view).with.offset(15);
        make.bottom.right.equalTo(self.view);
    }];
    
    UINib *categoryCellNib = [UINib nibWithNibName:@"CCCategoryCell" bundle:nil];
    [self.tableView registerNib:categoryCellNib forCellReuseIdentifier:@"CCCategoryCell"];
}

- (UITableViewCell *)cellForPriceRangeFromTableView:(UITableView *)tableView {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    cell.textLabel.text = @"Set price range";
    
    return cell;
}

- (CCCategoryCell *)cellForCategoryFromTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    
    CCCategoryCell *categoryCell = [tableView dequeueReusableCellWithIdentifier:@"CCCategoryCell" forIndexPath:indexPath];
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
}

@end
