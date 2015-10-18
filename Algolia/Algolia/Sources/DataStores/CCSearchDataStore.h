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

@interface CCSearchDataStore : NSObject

+ (instancetype)sharedInstance;

- (void)queryWithFullTextQuery:(NSString *)queryString success:(CCSearchDataStoreSuccess)success failure:(CCSearchDataStoreFailure)failure;

@end
