//
//  TMWCustomMovieCellTableViewCell.m
//  ThatMovieWith
//
//  Created by johnrhickey on 5/1/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "TMWCustomMovieCellTableViewCell.h"

@implementation TMWCustomMovieCellTableViewCell

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

@end
