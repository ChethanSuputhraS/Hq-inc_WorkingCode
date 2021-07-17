//
//  SubjSetupVC.h
//  HQ-INC App
//
//  Created by Ashwin on 3/25/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SubjectSetupDelegate <NSObject>
@required
-(void)UpdatePlayerDatafromSetup:(NSMutableDictionary *)updatedDataDict;
@end

@interface SubjSetupVC : UIViewController
{
//    UILabel *lblSubject, *lbladdsetup, *lblHash, *lblAddAlarms,*lblType2iblSenAlarm, *lblType2ible, *lblHighTempAlarm, *lblLowTempAlarm,*lblDermalSensorAlram,* lblType1,*lblNameNo1,* lblType2,*lblNameNo2,* lblHeader;
    UIView *addSetUpView, *addSensorView, *addAlarmsView,*viewForSensorNameNum,*viewForAddSensor,*viewAllSensor,*viewForListOfSensor;
    UIButton  *btnCamera,*btnSave,*btnCancelSnr,*btnIngsetAddSnr,* btnSkinAddSnr;
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
    
    UILabel * lblNote , * lblAddmonitorConnect,*lblNosensor, * lblTimeInterval;
    NSString * strMsg;
    bool isBtnSkinSelected;
    bool isRemoveSnrSelect;
    NSMutableArray *tmpArryMonitor,*arrPlayers,*tmpArrySensor, *arrayPiker;
    NSInteger selectedIndex;

    UIView *showPickerView,*viewForPiker;
    UIPickerView *pikerViewIntervalSelect;
    NSString *selectedFromPicker;

}
@property (nonatomic) BOOL isFromEdit;
@property(nonatomic, strong) NSMutableDictionary * dataDict;
@property (nonatomic, weak) id<SubjectSetupDelegate>SubjectDelegate;

-(void)ConnectedMonitorDetail:(NSMutableDictionary *)arryFromAddMonitor;
-(void)SetupDemoFromAddSensorData:(NSMutableArray *)arryData;
-(void)SetNameforConnectedMonitor:(NSString *)strDeviceName;
@end

NS_ASSUME_NONNULL_END
