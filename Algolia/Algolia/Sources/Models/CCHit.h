//
//  CCHit.h
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCBaseModel.h"

@interface CCHit : CCBaseModel

@property (nonatomic, strong) NSNumber *objectId;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *popularity;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *objectDescription;
@property (nonatomic, strong) NSString *brand;
@property (nonatomic, strong) NSString *highLightedString;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *priceRange;

@property (nonatomic, strong) NSURL *imageUrl;
@property (nonatomic, strong) NSURL *directUrl;

@property (nonatomic, strong) NSArray *categories;

@property (nonatomic, assign) BOOL freeShipping;

@end
