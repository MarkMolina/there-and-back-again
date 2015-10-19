//
//  CCResultsCell.h
//  Algolia
//
//  Created by Mark Molina on 19/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCHit;

@interface CCResultsCell : UITableViewCell

@property (nonatomic, strong) CCHit *hit;

@end
