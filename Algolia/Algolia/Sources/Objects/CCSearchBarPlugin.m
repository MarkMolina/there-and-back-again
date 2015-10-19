//
//  CCSearchBarPlugin.m
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCSearchBarPlugin.h"
#import "CCSearchDataStore.h"

#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

static RACSignal *RACBoolStream(id <NSFastEnumeration> yesSignals, id <NSFastEnumeration> noSignals) {
    RACSignal *yesStream = [[RACSignal merge:yesSignals] map:^id(id value) {
        return @YES;
    }];
    
    
    RACSignal *noStream = [[RACSignal merge:noSignals] map:^id(id value) {
        return @NO;
    }];
    
    return [RACSignal merge:@[
                              yesStream,
                              noStream,
                              ]];
};


@interface CCSearchBarPlugin () <UISearchBarDelegate>
@property(nonatomic, strong) UIViewController *rootController;
@property(nonatomic, strong) UISearchBar *searchBar;
@property(nonatomic, strong) UIView *shadowView;
@property(nonatomic, strong) UIActivityIndicatorView *spinner;
@property(nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property(nonatomic, readonly) RACSignal *rac_searchButtonSignal;
@property(nonatomic, readonly) RACSignal *rac_cancelButtonSignal;
@property(nonatomic, readonly) RACSignal *rac_searchFieldBecomeActive;

@property(nonatomic, assign) BOOL isSearchFieldActive;
@property(nonatomic, assign) BOOL isSpinnerVisible;
@property(nonatomic, assign) BOOL isSearchBarVisible;
@property(nonatomic, assign) BOOL isShadowViewVisible;


@end


@implementation CCSearchBarPlugin

- (instancetype)initWithRootController:(UIViewController *)controller {
    
    self = [super init];
    
    self.rootController = controller;
    self.searchBar.delegate = self;
    
    [self setupView];
    
    return self;
}

- (void)setupView {
    [self.rootController.navigationController.navigationBar addSubview:self.searchBar];
    
    [self createShadowView];
    
    [self createBindings];
}

- (RACSignal *)rac_searchButtonSignal {
    return [self rac_signalForSelector:@selector(searchBarSearchButtonClicked:)];
}

- (RACSignal *)rac_cancelButtonSignal {
    return [self rac_signalForSelector:@selector(searchBarCancelButtonClicked:)];
}

- (RACSignal *)textChangedSignal {
    return [self rac_signalForSelector:@selector(searchBar:textDidChange:)];
}

- (RACSignal *)rac_searchFieldBecomeActive {
    return [self rac_signalForSelector:@selector(searchBarTextDidBeginEditing:)];
}

- (RACSignal *)cancelSearchSignal {
    return [RACSignal merge:@[
                              self.rac_cancelButtonSignal,
                              self.tapGestureRecognizer.rac_gestureSignal,
                              ]];
}

- (RACSignal *)rac_searchRequestFailed {
    return [CCSearchDataStore sharedInstance].rac_operationFailed;
}

- (void)createBindings {
    
    RAC(self, isSearchFieldActive) = RACBoolStream(
                                                   @[self.rac_searchButtonSignal],
                                                   @[
                                                     self.rac_searchButtonSignal,
                                                     self.cancelSearchSignal,
                                                     ]
                                                   );
    
    RAC(self, isSearchBarVisible) = RACBoolStream(
                                                  @[self.rac_searchFieldBecomeActive],
                                                  @[
                                                    self.cancelSearchSignal,
                                                    [CCSearchDataStore sharedInstance].rac_foundObjects,
                                                    ]
                                                  );
    
    RAC(self, isShadowViewVisible) = RACBoolStream(
                                                   @[self.rac_searchFieldBecomeActive],
                                                   @[
                                                     self.cancelSearchSignal,
                                                     [CCSearchDataStore sharedInstance].rac_foundObjects,
                                                     ]
                                                   );
    
    RAC(self, isSpinnerVisible) = RACBoolStream(
                                                @[[CCSearchDataStore sharedInstance].rac_operationStarted],
                                                @[[CCSearchDataStore sharedInstance].rac_operationEnded]
                                                );
    
    
    @weakify(self)
    [self.rac_searchButtonSignal subscribeNext:^(id x) {
        @strongify(self)
        [[CCSearchDataStore sharedInstance] queryWithFullTextQuery:self.searchBar.text];
    }];
    
    
    [[CCSearchDataStore sharedInstance].rac_foundObjects subscribeNext:^(NSDictionary *response) {
        @strongify(self)
        
        [self.rootController.view endEditing:YES];
    }];
    
}


- (void)showSearchBar {
    [self.searchBar.superview bringSubviewToFront:self.searchBar];
    [self.searchBar becomeFirstResponder];
}


- (UISearchBar *)searchBar {
    if (nil == _searchBar) {
        CGRect bounds = self.rootController.navigationController.navigationBar.bounds;
        int leftMargin = 5;
        bounds.origin.x += leftMargin;
        bounds.size.width -= leftMargin;
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:bounds];
        searchBar.placeholder = @"Search by name, description or brand";
        searchBar.backgroundColor = [UIColor whiteColor];
        searchBar.showsCancelButton = YES;
        searchBar.alpha = 0;
        searchBar.delegate = self;
        searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchBar = searchBar;
    }
    return _searchBar;
}

- (void)createShadowView {
    [self.rootController.view addSubview:self.shadowView];
    [self.shadowView addGestureRecognizer:self.tapGestureRecognizer];
    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.rootController.view);
    }];
    
    self.shadowView.alpha = 0;
    
    
}

- (UIView *)shadowView {
    if (nil == _shadowView) {
        UIView *view = [UIView new];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [view addSubview:self.spinner];
        [self.spinner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(view);
        }];
        
        _shadowView = view;
    }
    
    return _shadowView;
}

- (UIActivityIndicatorView *)spinner {
    if (nil == _spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _spinner.hidden = YES;
    }
    return _spinner;
}

- (void)setIsSearchFieldActive:(BOOL)isSearchFieldActive {
    if (isSearchFieldActive) {
        [self.searchBar becomeFirstResponder];
    }
    else {
        [self.searchBar resignFirstResponder];
    }
}

- (void)setIsSearchBarVisible:(BOOL)isSearchBarVisible {
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.searchBar.alpha = isSearchBarVisible ? 1 : 0;
                     }];
}

- (void)setIsShadowViewVisible:(BOOL)isShadowViewVisible {
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.shadowView.alpha = isShadowViewVisible ? 1 : 0;
                     }];
}

- (void)setIsSpinnerVisible:(BOOL)isSpinnerVisible {
    self.spinner.hidden = !isSpinnerVisible;
    if (isSpinnerVisible) {
        [self.spinner startAnimating];
    }
    else {
        [self.spinner stopAnimating];
    }
}


- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (nil == _tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    }
    return _tapGestureRecognizer;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if ([self.delegate respondsToSelector:@selector(searchBarTextDidChange:)]) {
        [self.delegate searchBarTextDidChange:searchText];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    if ([self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked)]) {
        [self.delegate searchBarCancelButtonClicked];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    if ([self.delegate respondsToSelector:@selector(searchBarSearchButtonClicked)]) {
        [self.delegate searchBarSearchButtonClicked];
    }
}

@end