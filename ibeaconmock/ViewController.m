//
//  ViewController.m
//  ibeaconmock
//
//  Created by nakashima on 2014/09/04.
//  Copyright (c) 2014年 Rio. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end


@implementation ViewController
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.topViewController.title = @"iBeacon Sample";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end