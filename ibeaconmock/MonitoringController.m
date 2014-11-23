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
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UAProgressView *progressView;
@property (weak, nonatomic) IBOutlet UAProgressView *progressView2;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;

@end

@implementation MonitoringController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.topViewController.title = @"モニタリング中";

    // Do any additional setup after loading the view.
    
    //UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60.0, 32.0)];
    //textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:32];
    //textLabel.textAlignment = NSTextAlignmentCenter;
    //textLabel.textColor = self.progressView.tintColor;
    //textLabel.backgroundColor = [UIColor clearColor];
    //self.progressView.centralView = textLabel;
    self.progressView.lineWidth = 20.0;
    self.progressView.borderWidth = 20.0;
    self.progressView2.lineWidth = 20.0;
    self.progressView2.borderWidth = 20.0;
    
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
        //self.barButton.title = @"停止";
        
        // progressView 1
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80.0, 20.0)];
        [label setTextAlignment:NSTextAlignmentCenter];
        label.userInteractionEnabled = NO; // Allows tap to pass through to the progress view.
        self.progressView.centralView = label;
        
        self.progressView.progressChangedBlock = ^(UAProgressView *progressView, float progress) {
            NSString *mm;
            if (progress > 0) {
                mm = [NSString stringWithFormat:@"約%2.2fm", progress * 10 * -1 + 10];
            } else {
                mm = @"不明";
            }
            [(UILabel *)progressView.centralView setText:mm];
        };
        // progressView 2
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80.0, 20.0)];
        [label2 setTextAlignment:NSTextAlignmentCenter];
        label2.userInteractionEnabled = NO; // Allows tap to pass through to the progress view.
        self.progressView2.centralView = label2;
        
        self.progressView2.progressChangedBlock = ^(UAProgressView *progressView, float progress) {
            NSString *mm;
            if (progress > 0) {
                mm = [NSString stringWithFormat:@"約%2.2fm", progress * 10 * -1 + 10];
            } else {
                mm = @"不明";
            }
            [(UILabel *)progressView.centralView setText:mm];
        };
    } else {
        // iBeaconが利用できない端末の場合
        NSLog(@"iBeaconを利用できません。");
    }
}

-(void)viewDidLayoutSubviews {
    [self.scrollView setContentSize: CGSizeMake(300, 332*2)];
    [self.scrollView flashScrollIndicators];
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
    [(UILabel *)self.progressView.centralView setText:@"エリア外"];
    [(UILabel *)self.progressView2.centralView setText:@"エリア外"];
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
            if (beacon.minor.intValue == 1) {
                switch (beacon.proximity) {
                    case CLProximityImmediate:
                    case CLProximityNear:
                    case CLProximityFar:
                        progress = (-1 * (beacon.accuracy - 10)) / 10;
                        break;
                    case CLProximityUnknown:
                        break;
                }
                [self.progressView setProgress:progress];
            }
            if (beacon.minor.intValue == 2) {
                switch (beacon.proximity) {
                    case CLProximityImmediate:
                    case CLProximityNear:
                    case CLProximityFar:
                        progress = (-1 * (beacon.accuracy - 10)) / 10;
                        break;
                    case CLProximityUnknown:
                        break;
                }
                [self.progressView2 setProgress:progress];
            }
            NSString *rangeMessage = [NSString stringWithFormat:@"proximity:%ld", beacon.proximity];
            NSString *message = [NSString stringWithFormat:@": major:%@, minor:%@, accuracy:%f, rssi:%ld", beacon.major, beacon.minor, beacon.accuracy, (long)beacon.rssi];
            NSLog([rangeMessage stringByAppendingString:message]);
        }
    }

}

//- (IBAction)toggleMonitor:(id)sender {
//    return;
//    if (self.beaconRegion) {
//        [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
//        [self.locationManager stopMonitoringForRegion:self.beaconRegion];
//        self.beaconRegion = nil;
//    } else {
//        if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
//            // CLLocationManager の生成とデリゲートの設定
//            self.locationManager = [CLLocationManager new];
//            self.locationManager.delegate = self;
//            
//            // 生成したUUIDからNSUUIDを生成
//            self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"00000000-86C3-1001-B000-001C4D7C17F3"];
//            
//            // CLBeaconRegionを生成
//            self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID identifier:@"jp.ne.rio.sample.ibeacon"];
//            
//            // Beaconによる領域観測を開始
//            [self.locationManager startMonitoringForRegion:self.beaconRegion];
//        }
//    }
//}

#pragma mark - Private methods

- (void)sendLocalNotificationForMessage:(NSString *)message
{
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.alertBody = message;
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
