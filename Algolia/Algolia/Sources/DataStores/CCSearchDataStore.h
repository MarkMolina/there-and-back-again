//
//  CCSearchDataStore.h
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CCSearchDataStoreSuccess)(NSDictionary *searchResponse);
typedef void (^CCSearchDataStoreFailure)(NSError *error);

@class RACSignal;

@interface CCSearchDataStore : NSObject

@property(nonatomic, strong) RACSignal *rac_foundObjects;
@property(nonatomic, strong) RACSignal *rac_operationStarted;
@property(nonatomic, strong) RACSignal *rac_operationEnded;
@property(nonatomic, strong) RACSignal *rac_operationFailed;

+ (instancetype)sharedInstance;

- (void)queryWithFullTextQuery:(NSString *)queryString;
- (void)queryWithFullTextQuery:(NSString *)queryString success:(CCSearchDataStoreSuccess)success failure:(CCSearchDataStoreFailure)failure;

@end
