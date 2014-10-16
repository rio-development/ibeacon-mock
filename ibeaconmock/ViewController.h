//
//  ViewController.h
//  ibeaconmock
//
//  Created by nakashima on 2014/09/04.
//  Copyright (c) 2014年 Rio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property NSMutableArray *cells;
- (IBAction)toggleMonitor:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButton;
@property (strong, nonatomic) IBOutlet UIView *mainView;

@end
