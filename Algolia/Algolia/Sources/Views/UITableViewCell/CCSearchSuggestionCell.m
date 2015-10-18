//
//  CCSearchSuggestionCell.m
//  Algolia
//
//  Created by Mark Molina on 18/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCSearchSuggestionCell.h"
#import "CCHit.h"
#import "CCSearchStyle.h"

@interface CCSearchSuggestionCell()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation CCSearchSuggestionCell

- (void)setHit:(CCHit *)hit {
    
    _hit = hit;
    self.nameLabel.text = hit.name;
}

- (void)setHighLightString:(NSString *)highLightString {
    
    _highLightString = highLightString;
    [self hightLightLabel];
}

- (void)hightLightLabel {
    
    NSRange range = [self.hit.name rangeOfString:self.highLightString options:NSCaseInsensitiveSearch];
    if (range.location != NSNotFound) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.hit.name];
        
        [attributedString beginEditing];
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[CCSearchStyle highLightBlue]
                                 range:range];
        
        [attributedString endEditing];
        
        self.nameLabel.attributedText = attributedString;
    }
}

@end
