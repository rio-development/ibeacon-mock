//
//  CustomTableViewCell.h
//  ibeaconmock
//
//  Created by nakashima on 2014/10/05.
//  Copyright (c) 2014年 Rio. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UILabel *mm;
@property (weak, nonatomic) IBOutlet UILabel *comment;

+ (CGFloat)rowHeight;
@end

