//
//  HomeVC.h
//  HoldItWrite
//
//  Created by Ashwin on 7/28/20.
//  Copyright © 2020 Chethan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMPullToRefreshManager.h"
#import "BLEManager.h"


NS_ASSUME_NONNULL_BEGIN

@interface HomeVC : UIViewController
{
    UITableView * tblDeviceList;
     UILabel *lblNoDevice,*lblError ,* lblScanning;
    MNMPullToRefreshManager * topPullToRefreshManager;
    UIView *viewForSensorNameNum, *viewForAddSensor;
    UIButton *btnCancelSnr,*btnSave;
    UITextField *txtNameSnr;
    NSTimer * connectionTimer, * advertiseTimer;;
    CBCentralManager * centralManager;
    CBPeripheral * classPeripheral;
    NSMutableDictionary * dictConnectedPeripheral, * dictLiveSessionData;
    UIButton *btnCanceldown,*btnDone;
    FCAlertView *alertConnection;
    NSInteger totalSensorsofLiveSession;
    NSMutableArray * arrSensorsofSessions;

}
-(void)AddTestingRecords:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
