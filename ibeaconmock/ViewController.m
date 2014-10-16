//
//  ViewController.m
//  ibeaconmock
//
//  Created by nakashima on 2014/09/04.
//  Copyright (c) 2014年 Rio. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CustomTableViewCell.h"
#import "TableViewConst.h"
#import <UAProgressView.h>

@interface ViewController () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;

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
    
    self.cells = [NSMutableArray array];
    self.mainTable.dataSource = self;
    self.mainTable.delegate = self;
    UINib *nib = [UINib nibWithNibName:TableviewCustomCellIdentifire bundle:nil];
    [self.mainTable registerNib:nib forCellReuseIdentifier:@"cid"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CustomTableViewCell rowHeight];
}

#pragma mark - UITableView Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *tvcell = [tableView dequeueReusableCellWithIdentifier: @"cid"];
    if (tvcell == nil) {
        tvcell = [CustomTableViewCell alloc];
//        tvcell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: @"cid"];
    }
    
    NSArray *data = [self.cells objectAtIndex:indexPath.row];
    tvcell.distance.text = data[0];
    tvcell.mm.text = data[1];
    tvcell.comment.text = data[2];
    return tvcell;
}

#pragma mark - CLLocationManager Methods
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self.locationManager requestStateForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
    case CLRegionStateInside: // リージョン内にいる
        if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
            [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
            break;
        }
    case CLRegionStateOutside:
    case CLRegionStateUnknown:
    default:
        break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSString *message = @"エリアに入りました.";
    [self sendLocalNotificationForMessage:message];
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSString *message = @"エリアから出ました";
    [self sendLocalNotificationForMessage:message];
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count > 0) {
        // 最も距離の近いBeaconを処理する
        CLBeacon *nearestBeacon = beacons.firstObject;
        NSString *rangeMessage;
        
        UIColor *color;
        color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
        
        // Beacon の距離でメッセージを変える
        switch (nearestBeacon.proximity) {
            case CLProximityImmediate:
                rangeMessage = @"Range Immediate";
                color = [UIColor colorWithRed:1 green:0.18 blue:0.33 alpha:1.0];
                break;
            case CLProximityNear:
                rangeMessage = @"Range Near";
                color = [UIColor colorWithRed:1 green:0.29 blue:0.51 alpha:1.0];
                [self.mainView setBackgroundColor:color];
                break;
            case CLProximityFar:
                rangeMessage = @"Range Far";
                color = [UIColor colorWithRed:1 green:0.83 blue:0.88 alpha:1.0];
                [self.mainView setBackgroundColor:color];
                break;
            case CLProximityUnknown:
                rangeMessage = @"Range Unknown";
                break;
            default:
                rangeMessage = @"Range Error";
                break;
        }

        
        NSString *message = [NSString stringWithFormat:@": major:%@, minor:%@, accuracy:%f, rssi:%ld", nearestBeacon.major, nearestBeacon.minor, nearestBeacon.accuracy, (long)nearestBeacon.rssi];
        [self sendLocalNotificationForMessage:[rangeMessage stringByAppendingString:message]];

        if (self.mainView) {
            [self.mainView setBackgroundColor:color];
            NSArray *data = @[
                              rangeMessage,
                              [NSString stringWithFormat:@"major:%@, minor:%@", nearestBeacon.major, nearestBeacon.minor],
                              [NSString stringWithFormat:@"accuracy:%f, rssi:%ld", nearestBeacon.accuracy, (long)nearestBeacon.rssi],
                              ];
            [self insertCell:data];
        }
    }
}

- (IBAction)toggleMonitor:(id)sender {
    return;
    if (self.beaconRegion) {
        [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
        [self.locationManager stopMonitoringForRegion:self.beaconRegion];
        self.cells = [NSMutableArray array];
        [self.mainTable reloadData];
        self.beaconRegion = nil;
        self.barButton.title = @"開始";
    } else {
        if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
            // CLLocationManager の生成とデリゲートの設定
            self.locationManager = [CLLocationManager new];
            self.locationManager.delegate = self;
            
            // 生成したUUIDからNSUUIDを生成
            self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"00000000-86C3-1001-B000-001C4D7C17F3"];
            
            // CLBeaconRegionを生成
            self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID identifier:@"jp.ne.rio.sample.ibeacon"];
            
            // Beaconによる領域観測を開始
            [self.locationManager startMonitoringForRegion:self.beaconRegion];
            self.barButton.title = @"停止";
        }
    }
}

#pragma mark - Private methods

- (void)sendLocalNotificationForMessage:(NSString *)message
{
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.alertBody = message;
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)insertCell:(NSArray *)data
{
    [self.cells insertObject:data atIndex:0];
    [self.mainTable reloadData];
}
@end