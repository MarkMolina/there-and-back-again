//
//  CCSearchBarPlugin.h
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACSignal;

@protocol CCSearchBarPluginDelegate <NSObject>

@optional
- (void)searchBarTextDidChange:(NSString *)searchText;
- (void)searchBarCancelButtonClicked;
- (void)searchBarSearchButtonClicked;

@end

@interface CCSearchBarPlugin : NSObject

@property (nonatomic, weak) id<CCSearchBarPluginDelegate>delegate;
@property (nonatomic, readonly) RACSignal *rac_searchRequestFailed;

- (instancetype)initWithRootController:(UIViewController *)controller;

- (void)showSearchBar;
- (void)hideSearchBar;

@end
