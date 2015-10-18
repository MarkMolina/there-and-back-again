//
//  CCSearchDataStore.m
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCSearchDataStore.h"

#import <AlgoliaSearch-Client/ASAPIClient.h>

@interface CCSearchDataStore()

@property (nonatomic, strong) ASRemoteIndex *index;

@end

@implementation CCSearchDataStore

+ (instancetype)sharedInstance
{
    static CCSearchDataStore *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CCSearchDataStore alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        ASAPIClient *apiClient = [ASAPIClient apiClientWithApplicationID:@"8ALNK3U7VV" apiKey:@"4c8d49f24a317cac308e4037179a5539"];
        _index = [apiClient getIndex:@"best_buy_demo"];
    }
    
    return self;
}

- (void)queryWithFullTextQuery:(NSString *)queryString success:(CCSearchDataStoreSuccess)success failure:(CCSearchDataStoreFailure)failure {
    
    [self.index search:[ASQuery queryWithFullTextQuery:queryString]
          success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *answer) {
              // answer object contains a "hits" attribute that contains all results
              // each result contains your attributes and a _highlightResult attribute that contains highlighted version of your attributes
              
              success(answer);
              
          } failure:^(ASRemoteIndex *index, ASQuery *query, NSString *errorMessage) {
              
              NSLog(@"Error: %@", errorMessage);
              NSError *error = [NSError errorWithDomain:@"some-domain" code:600 userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
              failure(error);
          }];
}

@end
