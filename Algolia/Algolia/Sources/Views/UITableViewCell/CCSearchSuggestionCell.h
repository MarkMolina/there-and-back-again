//
//  CCSearchSuggestionCell.h
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCHit;

@interface CCSearchSuggestionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) CCHit *hit;

@end
