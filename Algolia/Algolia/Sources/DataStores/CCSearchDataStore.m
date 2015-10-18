//
//  CCSearchDataStore.m
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCSearchDataStore.h"

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
            filter:^BOOL(NSDictionary *searchResponse) {
                return searchResponse.count > 0;
            }];
}

- (void)queryWithFullTextQuery:(NSString *)queryString {
    
    [self.requestStarted sendNext:nil];
    
    [self queryWithFullTextQuery:queryString success:^(NSDictionary *searchResponse) {
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
