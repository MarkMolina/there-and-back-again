//
//  CCViewController.m
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCViewController.h"
#import "CCSearchResponse.h"

static NSString * const kRecentSearchesKey = @"recent_searches";

@implementation CCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)saveRecentSearchesFromSearchResponse:(CCSearchResponse *)searchResponse {
    
    if (searchResponse.hits.count) {
        NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:kRecentSearchesKey];
        NSMutableArray *mutableArray = [NSMutableArray new];
        
        if (![array containsObject:searchResponse.query]) {
            [mutableArray addObject:searchResponse.query];
        }
        
        for (NSString *string in [array reverseObjectEnumerator]) {
            [mutableArray addObject:string];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:mutableArray.copy forKey:kRecentSearchesKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
