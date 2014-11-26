//
//  MonitoringController.m
//  ibeaconmock
//
//  Created by nakashima on 2014/10/08.
//  Copyright (c) 2014年 Rio. All rights reserved.
//

#import "MonitoringController.h"
#import <UAProgressView.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface MonitoringController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UAProgressView *progressView1;
@property (weak, nonatomic) IBOutlet UAProgressView *progressView2;
@property (weak, nonatomic) IBOutlet UAProgressView *progressView3;
@property (weak, nonatomic) IBOutlet UAProgressView *progressView4;
@property (weak, nonatomic) IBOutlet UAProgressView *progressView5;
@property (weak, nonatomic) IBOutlet UAProgressView *progressView6;
@property (weak, nonatomic) IBOutlet UAProgressView *progressView7;
@property (weak, nonatomic) IBOutlet UAProgressView *progressView8;
@property (weak, nonatomic) IBOutlet UAProgressView *progressView9;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic) NSMutableArray *progressView;

@end

@implementation MonitoringController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.topViewController.title = @"モニタリング中";

    self.progressView = [NSMutableArray array];
    [self.progressView addObject:self.progressView1];
    [self.progressView addObject:self.progressView2];
    [self.progressView addObject:self.progressView3];
    [self.progressView addObject:self.progressView4];
    [self.progressView addObject:self.progressView5];
    [self.progressView addObject:self.progressView6];
    [self.progressView addObject:self.progressView7];
    [self.progressView addObject:self.progressView8];
    [self.progressView addObject:self.progressView9];
    
    // Do any additional setup after loading the view.
    for (UAProgressView *progressView in self.progressView) {
        progressView.lineWidth = 8.0;
        progressView.borderWidth = 1.0;
    }
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        // CLLocationManager の生成とデリゲートの設定
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        
        // 生成したUUIDからNSUUIDを生成
        self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"00000000-86C3-1001-B000-001C4D7C17F3"];
        
        // CLBeaconRegionを生成
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID identifier:@"jp.ne.rio.sample.ibeacon"];
        
        // Beaconによる領域観測を開始
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            // iOS8 による位置情報認証の変更による実装
            [self.locationManager requestAlwaysAuthorization];
        } else {
            [self.locationManager startMonitoringForRegion:self.beaconRegion];
        }

        // progressView が変わった時の処理
        void (^progressChangedBlock)(UAProgressView *progressView, float progress);
        progressChangedBlock = ^(UAProgressView *progressView, float progress) {
            NSString *mm;
            if (progress > 0) {
                mm = [NSString stringWithFormat:@"約%2.2fm", progress * 30];
            } else {
                mm = @"";
            }
            [(UILabel *)progressView.centralView setText:mm];
        };

        // progressView 設定
        for (UAProgressView *progressView in self.progressView) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80.0, 20.0)];
            [label setTextAlignment:NSTextAlignmentCenter];
            label.userInteractionEnabled = NO; // Allows tap to pass through to the progress view.
            progressView.centralView = label;
            progressView.progressChangedBlock = progressChangedBlock;
        }
    } else {
        // iBeaconが利用できない端末の場合
        NSLog(@"iBeaconを利用できません。");
    }
}

-(void)viewDidLayoutSubviews {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusNotDetermined) {
        // ユーザが位置情報の使用を許可していない
        NSLog(@"位置情報を許可していない");
    } else if (status == kCLAuthorizationStatusAuthorizedAlways) {
        // ユーザが位置情報の使用を常に許可している場合
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // ユーザが位置情報の使用を使用中のみ許可している場合
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
    }
}

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
    for (UAProgressView * progressView in self.progressView) {
        [(UILabel *)progressView.centralView setText:@"エリア外"];
    }
    [self sendLocalNotificationForMessage:message];
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    float progress = (0.0);
    
    if (beacons.count > 0) {
        for(CLBeacon *beacon in beacons){
            progress = 0.0;
            switch (beacon.proximity) {
                case CLProximityImmediate:
                case CLProximityNear:
                case CLProximityFar:
                    progress = beacon.accuracy / 30;
                    break;
                case CLProximityUnknown:
                    break;
            }
            
            // 距離表示
            [self.progressView enumerateObjectsUsingBlock:^(UAProgressView *progressView, NSUInteger idx, BOOL *stop) {
                if (idx + 1 == beacon.minor.intValue) {
                    [progressView setProgress:progress];
                }
            }];

            // Logに出力
            NSString *rangeMessage = [NSString stringWithFormat:@"proximity:%ld", beacon.proximity];
            NSString *message = [NSString stringWithFormat:@": major:%@, minor:%@, accuracy:%f, rssi:%ld", beacon.major, beacon.minor, beacon.accuracy, (long)beacon.rssi];
            NSLog([rangeMessage stringByAppendingString:message]);
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


@end
