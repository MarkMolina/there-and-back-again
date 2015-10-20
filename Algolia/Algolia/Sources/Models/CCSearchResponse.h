//
//  CCSearchResponse.h
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCBaseModel.h"

@interface CCSearchResponse : CCBaseModel

/* number of hits per page */
@property (nonatomic, strong) NSNumber *hitsPerPage;

/* total number of matched hits in the index */
@property (nonatomic, strong) NSNumber *numberOfHits;

/* total number of accessible pages */
@property (nonatomic, strong) NSNumber *numberOfPages;

/* backend processing time in miliseconds */
@property (nonatomic, strong) NSNumber *processingTime;

/* current page number */
@property (nonatomic, strong) NSNumber *page;

/* query parameters */
@property (nonatomic, strong) NSString *queryParameters;

/* full-text query */
@property (nonatomic, strong) NSString *query;

/* array of matched hits */
@property (nonatomic, strong) NSArray *hits;

@end
