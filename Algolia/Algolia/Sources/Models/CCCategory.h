//
//  CCCategory.h
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCBaseModel.h"

@interface CCCategory : CCBaseModel

@property (nonatomic, strong) NSString *name;

/* category only contains name but should contain an id */
- (instancetype)initWithName:(NSString *)name;

@end
