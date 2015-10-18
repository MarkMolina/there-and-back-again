//
//  CCBaseModel.m
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCBaseModel.h"

@implementation CCBaseModel

+ (instancetype)modelFromJSONDictionary:(NSDictionary *)jsonDict {
    
    return [[self alloc] initWithJSONDictionary:jsonDict];
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonDict {
    
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end
