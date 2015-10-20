//
//  CCSearchResponse.m
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCSearchResponse.h"
#import "CCHit.h"

@implementation CCSearchResponse

- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonDict {
    
    self = [super initWithJSONDictionary:jsonDict];
    if (self) {
        
        _hitsPerPage = jsonDict[@"hitsPerPage"];
        _numberOfHits = jsonDict[@"nbHits"];
        _numberOfPages = jsonDict[@"nbPages"];
        _page = jsonDict[@"page"];
        _queryParameters = jsonDict[@"params"];
        _processingTime = jsonDict[@"processingTimeMS"];
        _query = jsonDict[@"query"];
        _hits = [self hitsFromJSONDictionary:jsonDict[@"hits"]];
    }
    
    return self;
}

- (NSArray *)hitsFromJSONDictionary:(NSDictionary *)jsonDict {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:jsonDict.count];
    for (NSDictionary *dictionary in jsonDict) {
        [mutableArray addObject:[CCHit modelFromJSONDictionary:dictionary]];
    }
    
    return mutableArray.copy;
}

@end
