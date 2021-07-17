//
//  AddSensorVC.h
//  HQ-INC App
//
//  Created by Ashwin on 8/27/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddSensorVC : UIViewController
{
    UITableView * tblDeviceList;
    UIView *viewForAddSensor, *viewForSensorNameNum;
    UIButton  *btnCancel, *btnSave;
    UITextField *txtNameSnr;
    
    NSString * strName;
    NSMutableArray *arrySensors,*arrBlrID,* arrdata,*arrSnrType;
    NSInteger selectedIndex;
    NSMutableDictionary * dictData;
    NSArray *indexes;
    NSTimer * connectionTimer,*timeoutforAddSensor,*timerSave,*tmScan;
    UIButton * btnCanceldown,*btnDone;
    BOOL isAnyAdded;

}

-(void)AddSensortoList:(NSString *)strSensorId withType:(NSString *)strSensorType;
-(void)FailedtoAddSensor:(NSString *)strErrorCode withSensorID:(NSString *)strSensorID;
-(void)SuccesfullyAddedSensor:(NSMutableDictionary *)dictData withSensorID:(NSString *)strSensorID;

@end

NS_ASSUME_NONNULL_END
