//
//  CCFilterVC.h
//  Algolia
//
//  Created by Mark Molina on 19/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCViewController.h"

@protocol CCFilterVCDelegate <NSObject>

@optional
- (void)filterVCDidSelectCategoryName:(NSString *)categoryName;

@end

@interface CCFilterVC : CCViewController

@property (nonatomic, weak) id<CCFilterVCDelegate> delegate;
@property (nonatomic, strong) NSArray *categories;

@end
