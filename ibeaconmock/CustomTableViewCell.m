//
//  CustomTableViewCell.m
//  ibeaconmock
//
//  Created by nakashima on 2014/10/05.
//  Copyright (c) 2014年 Rio. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

+ (CGFloat)rowHeight
{
    return 50.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
