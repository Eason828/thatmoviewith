//
//  ParallaxPhotoCell.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/24/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "ParallaxPhotoCell.h"
#import "ParallaxLayoutAttributes.h"

@interface ParallaxPhotoCell ()

@property (nonatomic, strong) NSLayoutConstraint *imageViewHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *imageViewCenterYConstraint;
@property (nonatomic, strong) NSLayoutConstraint *movieNameHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *movieNameCenterYConstraint;

@end


@implementation ParallaxPhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil) {
        return nil;
    }

    self.clipsToBounds = YES;

    [self setupImageView];
    [self setupActivityIndicator]; // Must be added to view after imageview so
                                   // it isn't covered by black temp image
    [self setupLabel];
    [self setupSecondLabel];
    [self setupConstraints];
    [self setNeedsUpdateConstraints];
    
    return self;
}

- (void)setupImageView
{
    _imageView = [[UIImageView alloc] initWithImage:nil];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.bounds = self.contentView.bounds;
    [self.contentView addSubview:_imageView];
}

- (void)setupActivityIndicator
{
    _activityIndicator = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityIndicator.bounds = self.contentView.bounds;
    self.activityIndicator.center = self.contentView.center;
    [self.contentView addSubview:_activityIndicator];
}

- (void)setupLabel
{
    _label = [UILabel new];
    self.label.textColor = [UIColor whiteColor];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.backgroundColor = [UIColor clearColor];
    self.label.frame = self.contentView.bounds;
    self.label.center = self.contentView.center;
    [self.contentView addSubview:_label];
}

- (void)setupSecondLabel
{
    _secondLabel = [UILabel new];
    self.secondLabel.textColor = [UIColor whiteColor];
    self.secondLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    self.secondLabel.textAlignment = NSTextAlignmentRight;
    self.secondLabel.backgroundColor = [UIColor clearColor];
    self.secondLabel.frame = CGRectMake(self.contentView.frame.origin.x - 5, self.contentView.frame.origin.y + self.contentView.frame.size.height/2 - 12, self.contentView.frame.size.width, self.contentView.frame.size.height);
    [self.contentView addSubview:_secondLabel];
}

- (void)setupConstraints
{
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Horizontal constraints for image view
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    
    // Vertical constraints for image view
    self.imageViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    self.imageViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self.contentView addConstraint:self.imageViewHeightConstraint];
    [self.contentView addConstraint:self.imageViewCenterYConstraint];
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    // Make sure image view is tall enough to cover maxParallaxOffset in both directions
    self.imageViewHeightConstraint.constant = 2 * self.maxParallaxOffset;
}

- (void)setMaxParallaxOffset:(CGFloat)maxParallaxOffset
{
    _maxParallaxOffset = maxParallaxOffset;
    [self setNeedsUpdateConstraints];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    NSParameterAssert(layoutAttributes != nil);
    NSParameterAssert([layoutAttributes isKindOfClass:[ParallaxLayoutAttributes class]]);

    ParallaxLayoutAttributes *parallaxLayoutAttributes = (ParallaxLayoutAttributes *)layoutAttributes;
    self.imageViewCenterYConstraint.constant = parallaxLayoutAttributes.parallaxOffset.y;
}

@end
