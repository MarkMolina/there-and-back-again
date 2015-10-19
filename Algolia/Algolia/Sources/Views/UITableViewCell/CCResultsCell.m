//
//  CCResultsCell.m
//  Algolia
//
//  Created by Mark Molina on 19/10/15.
//  Copyright © 2015 CleverCode. All rights reserved.
//

#import "CCResultsCell.h"
#import "CCHit.h"

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
}

- (void)setTitleText {
    
    self.titleLabel.text = self.hit.name;
}

- (void)setDescriptionText {
    
    self.descriptionLabel.text = self.hit.objectDescription;
}

- (void)setPriceText {
    
    self.priceLabel.text = [NSString stringWithFormat:@"%@", self.hit.price];
}

- (void)setIconImage {
    
    [self.image setImageWithURL:self.hit.imageUrl];
}

@end
