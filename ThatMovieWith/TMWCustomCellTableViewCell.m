//
//  TMWCustomCellTableViewCell.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/16/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "TMWCustomCellTableViewCell.h"

@implementation TMWCustomCellTableViewCell

// Creates circular images in table cells
- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(IMAGE_LEFT_OFFSET,IMAGE_TOP_OFFSET,IMAGE_SIZE,IMAGE_SIZE);
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
   
    float limgW =  self.imageView.image.size.height;
    if(limgW > 0) {
        self.textLabel.frame = CGRectMake(IMAGE_SIZE+IMAGE_TEXT_OFFSET,self.textLabel.frame.origin.y,self.textLabel.frame.size.width,self.textLabel.frame.size.height);

    }
}

@end
