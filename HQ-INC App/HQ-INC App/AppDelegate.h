//
//  AppDelegate.h
//  HQ-INC App
//
//  Created by stuart watts on 24/03/2020.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "SubjSetupVC.h"
#import "AddSensorVC.h"
#import "SessionAddVC.h"
#import "SubjDetailsVC.h"
#import "GlobalSettingVC.h"

SubjSetupVC * globalSbuSetupVC;
SubjDetailsVC * globalSubjectDetailVC;
GlobalSettingVC * globalSettingClassVC;

int textSize;
int globalStatusHeight;

NSMutableArray * globalArr;
BOOL isUserIntialized, isUserfromLogin;
BOOL isUserLoggedAndDontEndHudProcess;
BOOL isConnectedtoAdd;
BOOL isCheckforDashScann;
CBPeripheral * globalPeripheral;
 NSMutableDictionary * selectedDeviecDict;
 NSMutableArray * arrGlobalDevices;

NSMutableArray * arrGlobalSensorsAdded;

AddSensorVC * globalAddSensor;
SessionAddVC * globalSessionAddVC;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    MBProgressHUD *HUD;
    UIView * viewNetworkConnectionPopUp;
    NSTimer * timerNetworkConnectionPopUp;
    BOOL isFirstTime;

}
@property (strong, nonatomic) UIWindow *window;

#pragma mark- Helper Methods
//-(BOOL)isNetworkreachable;
-(NSString *)checkforValidString:(NSString *)strRequest;
-(NSString *)getStringConvertedinUnsigned:(NSString *)strNormal;

-(NSString *)SyncUserTextinfowithDevice:(NSString *)strName;
-(NSData *)GetEncryptedKeyforData:(NSString *)strData withKey:(NSString *)strKey withLength:(long)dataLength;
-(NSString *)GetDecrypedDataKeyforData:(NSString *)strData withKey:(NSString *)strKey withLength:(long)dataLength;
-(void)endHudProcess;
-(void)getPlaceholderText:(UITextField *)txtField  andColor:(UIColor*)color;
-(void)startHudProcess:(NSString *)text;


@end

