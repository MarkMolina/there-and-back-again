//
//  CCHomeVC.m
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCHomeVC.h"
#import "CCSearchDataStore.h"
#import "CCSearchResponse.h"

@interface CCHomeVC ()

@end

@implementation CCHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Home";
    self.view.backgroundColor = [UIColor greenColor];
    [self testSearch];
}

- (void)testSearch {
    
    [[CCSearchDataStore sharedInstance] queryWithFullTextQuery:@"iphone" success:^(CCSearchResponse *searchResponse) {
        
        NSLog(@"%@", searchResponse);
    } failure:^(NSError *error) {
        
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

@end
