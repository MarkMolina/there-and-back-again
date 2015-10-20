//
//  NSArray+Facets.m
//  Algolia
//
//  Created by Mark Molina on 20/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "NSArray+Facets.h"

@implementation NSArray (Facets)

- (instancetype)facetsArrayWithKey:(NSString *)key {
    
    if (!self || !key) {
        return @[];
    }
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:self.count];
    
    for (NSString *facet in self) {
        [mutableArray addObject:[NSString stringWithFormat:@"%@:%@", key, facet]];
    }
    
    return mutableArray.copy;
}

@end
