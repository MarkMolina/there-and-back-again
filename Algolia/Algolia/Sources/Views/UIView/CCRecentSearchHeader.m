//
//  CCRecentSearchHeader.m
//  Algolia
//
//  Created by Mark Molina on 19/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCRecentSearchHeader.h"
#import "CCSearchStyle.h"

static NSString * const kResentSearchHeaderNibName = @"CCRecentSearchHeader";

@interface CCRecentSearchHeader()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation CCRecentSearchHeader

-(id)init {
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:kResentSearchHeaderNibName owner:self options:nil];
    id mainView = [subviewArray objectAtIndex:0];
    return mainView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.titleLabel.textColor = [CCSearchStyle recentSearchGrey];
}

@end
