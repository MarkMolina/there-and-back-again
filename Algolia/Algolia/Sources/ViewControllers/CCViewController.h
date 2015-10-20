//
//  CCViewController.h
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCSearchResponse;

@interface CCViewController : UIViewController

- (void)saveRecentSearchesFromSearchResponse:(CCSearchResponse *)searchResponse;
    
@end
