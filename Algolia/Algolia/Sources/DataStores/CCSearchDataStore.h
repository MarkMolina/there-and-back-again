//
//  CCSearchDataStore.h
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;
@class CCSearchResponse;

typedef void (^CCSearchDataStoreSuccess)(CCSearchResponse *searchResponse);
typedef void (^CCSearchDataStoreFailure)(NSError *error);

@interface CCSearchDataStore : NSObject

@property(nonatomic, strong) RACSignal *rac_foundObjects;
@property(nonatomic, strong) RACSignal *rac_operationStarted;
@property(nonatomic, strong) RACSignal *rac_operationEnded;
@property(nonatomic, strong) RACSignal *rac_operationFailed;

+ (instancetype)sharedInstance;

- (void)queryWithFullTextQuery:(NSString *)queryString;
- (void)queryWithFullTextQuery:(NSString *)queryString success:(CCSearchDataStoreSuccess)success failure:(CCSearchDataStoreFailure)failure;
- (void)queryWithFullTextQuery:(NSString *)queryString page:(NSInteger)page success:(CCSearchDataStoreSuccess)success failure:(CCSearchDataStoreFailure)failure;
- (NSArray *)retrieveCategories;

@end
