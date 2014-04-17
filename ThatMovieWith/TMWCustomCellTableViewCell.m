//
//  TMWCustomCellTableViewCell.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/16/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "TMWCustomCellTableViewCell.h"

#define IMAGE_SIZE 50
#define IMAGE_LEFT_OFFSET 10
#define IMAGE_TOP_OFFSET 8
#define IMAGE_TEXT_OFFSET 30

@implementation TMWCustomCellTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(IMAGE_LEFT_OFFSET,IMAGE_TOP_OFFSET,IMAGE_SIZE,IMAGE_SIZE);
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
   
    float limgW =  self.imageView.image.size.height;
    if(limgW > 0) {
        self.textLabel.frame = CGRectMake(IMAGE_SIZE+IMAGE_TEXT_OFFSET,self.textLabel.frame.origin.y,self.textLabel.frame.size.width,self.textLabel.frame.size.height);
        self.detailTextLabel.frame = CGRectMake(IMAGE_SIZE+IMAGE_TEXT_OFFSET,self.detailTextLabel.frame.origin.y,self.detailTextLabel.frame.size.width,self.detailTextLabel.frame.size.height);
    }
}

@end
