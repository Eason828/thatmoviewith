//
//  ParallaxPhotoCell.h
//  ThatMovieWith
//
//  Created by johnrhickey on 4/24/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

@import UIKit;

@interface ParallaxPhotoCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UILabel *label;
@property (nonatomic, strong, readonly) UILabel *secondLabel;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) CGFloat maxParallaxOffset;

@end
