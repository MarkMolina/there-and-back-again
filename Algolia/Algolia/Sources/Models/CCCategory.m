//
//  CCCategory.m
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCCategory.h"

@implementation CCCategory

- (instancetype) initWithName:(NSString *)name {
    
    self = [super init];
    if (self) {
        
        _name = name;
    }
    
    return self;
}

@end
