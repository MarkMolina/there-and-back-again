//
//  CCResultsCell.m
//  Algolia
//
//  Created by Mark Molina on 19/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCResultsCell.h"
#import "CCHit.h"
#import "CCSearchStyle.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@interface CCResultsCell()

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation CCResultsCell

- (void)setHit:(CCHit *)hit {
    
    _hit = hit;
    
    [self setTitleText];
    [self setDescriptionText];
    [self setPriceText];
    [self setIconImage];
    [self hightLightLabel];
}

- (void)setTitleText {
    
    self.titleLabel.text = self.hit.name;
}

- (void)setDescriptionText {
    
    self.descriptionLabel.text = self.hit.objectDescription;
}

- (void)setPriceText {
    
    self.priceLabel.text = [NSString stringWithFormat:@"%.02f", self.hit.price.floatValue];
}

- (void)setIconImage {
    
    [self.image setImageWithURL:self.hit.imageUrl];
}

- (void)hightLightLabel {
    
    if (!self.hit.highLightedString) {
        return;
    }
    
    NSRange range = [self.hit.name rangeOfString:self.hit.highLightedString options:NSCaseInsensitiveSearch];
    if (range.location != NSNotFound) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.hit.name];
        
        [attributedString beginEditing];
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[CCSearchStyle highLightBlue]
                                 range:range];
        
        [attributedString endEditing];
        
        self.titleLabel.attributedText = attributedString;
    }
}

@end
