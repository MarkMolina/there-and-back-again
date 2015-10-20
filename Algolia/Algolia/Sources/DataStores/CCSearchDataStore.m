//
//  CCSearchDataStore.m
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCSearchDataStore.h"
#import "CCSearchResponse.h"
#import "CCCategory.h"

#import <AlgoliaSearch-Client/ASAPIClient.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface CCSearchDataStore()

@property (nonatomic, strong) ASRemoteIndex *index;
@property (nonatomic, strong) RACSubject *requestStarted;
@property (nonatomic, strong) RACSubject *requestFailed;
@property (nonatomic, strong) RACSubject *requestCompleted;


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
    
    [self queryWithFullTextQuery:queryString page:0 success:success failure:failure];
}

- (void)queryWithFullTextQuery:(NSString *)queryString page:(NSInteger)page success:(CCSearchDataStoreSuccess)success failure:(CCSearchDataStoreFailure)failure {
    
    [self queryWithFullTextQuery:queryString page:page facets:nil success:success failure:failure];
}

- (void)queryWithFullTextQuery:(NSString *)queryString facets:(NSArray *)facets success:(CCSearchDataStoreSuccess)success failure:(CCSearchDataStoreFailure)failure {
    
    [self queryWithFullTextQuery:queryString page:0 facets:facets success:success failure:failure];
}

- (void)queryWithFullTextQuery:(NSString *)queryString page:(NSInteger)page facets:(NSArray *)facets success:(CCSearchDataStoreSuccess)success failure:(CCSearchDataStoreFailure)failure {
    
    ASQuery *query = [ASQuery queryWithFullTextQuery:queryString];
    
    if (page) {
        query.page = page;
    }
    
    if (facets.count) {
        query.facetFilters = facets;
    }
    
    [self.index search:query
               success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *answer) {
                   // answer object contains a "hits" attribute that contains all results
                   // each result contains your attributes and a _highlightResult attribute that contains highlighted version of your attributes
                   
                   success([CCSearchResponse modelFromJSONDictionary:answer]);
                   
               } failure:^(ASRemoteIndex *index, ASQuery *query, NSString *errorMessage) {
                   
                   NSLog(@"Error: %@", errorMessage);
                   NSError *error = [NSError errorWithDomain:@"some-domain" code:600 userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
                   failure(error);
               }];
    
}

- (NSArray *)retrieveCategories {
    
    /*
     * Note: Couldn't find a way to fetch all distinct categories in the dataset so doing this statically.
     *  Normally I would expect an endpoint where I could fetch all categories / subcategories and create
     *  a correct navigation tree in the client
     */
     
    
    NSMutableArray *mutableArray = [NSMutableArray new];
    [mutableArray addObject:[[CCCategory alloc] initWithName:@"Appliances"]];
    [mutableArray addObject:[[CCCategory alloc] initWithName:@"Cameras & Camcorders"]];
    [mutableArray addObject:[[CCCategory alloc] initWithName:@"Computers & Tablets"]];
    [mutableArray addObject:[[CCCategory alloc] initWithName:@"Health, Fitness & Beauty"]];
    [mutableArray addObject:[[CCCategory alloc] initWithName:@"Laptops"]];
    [mutableArray addObject:[[CCCategory alloc] initWithName:@"Car Audio"]];
    [mutableArray addObject:[[CCCategory alloc] initWithName:@"Cell Phones"]];
    [mutableArray addObject:[[CCCategory alloc] initWithName:@"Microwaves"]];
    [mutableArray addObject:[[CCCategory alloc] initWithName:@"Point & Shoot Cameras"]];
    [mutableArray addObject:[[CCCategory alloc] initWithName:@"Tablets"]];
    [mutableArray addObject:[[CCCategory alloc] initWithName:@"TV & Home Theater"]];
    
    return mutableArray.copy;

}

- (RACSubject *)requestStarted {
    if (nil == _requestStarted) {
        _requestStarted = [RACSubject subject];
        
    }
    return _requestStarted;
}

- (RACSubject *)requestFailed {
    if (nil == _requestFailed) {
        _requestFailed = [RACSubject subject];
        
    }
    return _requestFailed;
}

- (RACSubject *)requestCompleted {
    if (nil == _requestCompleted) {
        _requestCompleted = [RACSubject subject];
        
    }
    return _requestCompleted;
}

- (RACSignal *)rac_foundObjects {
    return [[self.requestCompleted deliverOn:[RACScheduler mainThreadScheduler]]
            filter:^BOOL(CCSearchResponse *searchResponse) {
                return searchResponse.hits.count > 0;
            }];
}

- (void)queryWithFullTextQuery:(NSString *)queryString {
    
    [self.requestStarted sendNext:nil];
    
    [self queryWithFullTextQuery:queryString success:^(CCSearchResponse *searchResponse) {
        [self.requestCompleted sendNext:searchResponse];
    } failure:^(NSError *error) {
        [self.requestFailed sendNext:error];
    }];
}

- (RACSignal *)rac_operationStarted {
    return self.requestStarted;
}

- (RACSignal *)rac_operationEnded {
    return [[RACSignal merge:@[
                               self.requestCompleted,
                               self.requestFailed,
                               ]] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)rac_operationFailed {
    return self.requestFailed;
}

@end
