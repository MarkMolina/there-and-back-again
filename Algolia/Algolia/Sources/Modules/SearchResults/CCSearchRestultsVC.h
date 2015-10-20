//
//  CCSearchRestultsVC.h
//  Algolia
//
//  Created by Mark Molina on 19/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCViewController.h"

@interface CCSearchRestultsVC : CCViewController

+ (instancetype)viewControllerWithSearchQuery:(NSString *)query categories:(NSArray *)categories;
- (instancetype)initWithSearchQuery:(NSString *)query categories:(NSArray *)categories;

@end
