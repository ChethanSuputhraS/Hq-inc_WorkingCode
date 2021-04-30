//
//  SubjSetupVC.h
//  HQ-INC App
//
//  Created by Ashwin on 3/25/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SubjSetupVC : UIViewController
{
    UILabel *lblSubject, *lbladdsetup, *lblHash, *lblAddAlarms,*lblType2iblSenAlarm, *lblType2ible, *lblHighTempAlarm, *lblLowTempAlarm,*lblDermalSensorAlram,* lblType1,*lblNameNo1,* lblType2,*lblNameNo2,* lblHeader;
    UIView *addSetUpView, *addSensorView, *addAlarmsView,*viewForSensorNameNum,*viewForAddSensor,*viewAllSensor,*viewForListOfSensor;
    UIButton  *btnCancel, *btnDone,*btnCamera,*btnSave,*btnCancelSnr,*btnIngsetAddSnr,* btnSkinAddSnr;
    UITextView *txtViewNote;
    UIImageView *imgViewProPic;
    UITextField *txtFullName,*txtIngesTmpHigh,*txtlngeslowTmpAl,* txtTimeInterval;
    UIImagePickerController *pickerImg;
    UITextField * txtDermalLowTmp , * txtDemalTmpHigh, * txtHash,*txtNameSnr,*txtNumberSnr;
    NSMutableDictionary * dict;
    UITableView *tblListOfSensor;
    float _numberOfDecimal;
    NSMutableArray * arrSensors;
    BOOL isImageEdited;
    
        float highIngstF, highIngstC,lowIngestF, lowIngestC, highDermalC,highDermalF,lowDermalF, lowDermalC;
    BOOL isCClicked;
    UIView *indiVisualView;
}
@property (nonatomic) BOOL isFromEdit;
@property(nonatomic, strong) NSMutableDictionary * dataDict;

-(void)ConnectedMonitorDetail:(NSMutableDictionary *)arryFromAddMonitor;
-(void)SetupDemoFromAddSensorData:(NSMutableArray *)arryData;
@end

NS_ASSUME_NONNULL_END
