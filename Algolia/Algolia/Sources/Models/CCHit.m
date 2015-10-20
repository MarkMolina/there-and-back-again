//
//  CCHit.m
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCHit.h"
#import "CCCategory.h"

@implementation CCHit

- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonDict {
    
    self = [super initWithJSONDictionary:jsonDict];
    if (self) {
        _objectId = jsonDict[@"objectID"];
        _name = jsonDict[@"name"];
        _objectDescription = jsonDict[@"description"];
        _brand = jsonDict[@"brand"];
        _categories = [self categoriesFromJSONDictionary:jsonDict[@"categories"]];
        _type = jsonDict[@"type"];
        _price = jsonDict[@"price"];
        _priceRange = jsonDict[@"price_range"];
        _imageUrl = [NSURL URLWithString:jsonDict[@"image"]];
        _directUrl = [NSURL URLWithString:jsonDict[@"url"]];
        _freeShipping = jsonDict[@"free_shipping"];
        _popularity = jsonDict[@"popularity"];
        _highLightedString = [self highLightedFromHTMLString:jsonDict[@"_highlightResult"][@"name"][@"value"]];
    }
    
    return self;
}

- (NSArray *)categoriesFromJSONDictionary:(NSDictionary *)jsonDict {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:jsonDict.count];
    for (NSString *name in jsonDict) {
        [mutableArray addObject:[[CCCategory alloc] initWithName:name]];
    }
    
    return mutableArray.copy;
    
}

- (NSString *)highLightedFromHTMLString:(NSString *)htmlString {
    
    NSString *highLightedString;

    NSRange range = [htmlString rangeOfString:@"<em>" options:NSCaseInsensitiveSearch];
    if (range.location != NSNotFound) {
        NSRange endRange;
        
        endRange.location = range.length + range.location;
        endRange.length   = [htmlString length] - endRange.location;
        endRange = [htmlString rangeOfString:@"</em>" options:NSCaseInsensitiveSearch range:endRange];
        
        if (endRange.location != NSNotFound) {
            range.location += range.length;
            range.length = endRange.location - range.location;
            
            highLightedString = [htmlString substringWithRange:range];
        }
    }
    
    return highLightedString;
}

@end
