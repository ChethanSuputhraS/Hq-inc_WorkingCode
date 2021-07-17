//
//  GlobalSettingVC.h
//  HQ-INC App
//
//  Created by Ashwin on 3/25/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GlobalSettingVC : UIViewController
{
    UILabel *lblGlobalsetting, *lblAddAlarms, *lblType2ible, *lblHighTempAlarm, *lblLowTempAlarm, *lblhighTmpIndicator, *lblLowTmpIndicator,*lblDermalSensorAlram, *lblAdditionalSetgs, *lblTmpUnit, *lblBatteryAlarm, *lblGlobalSnrCheck, *lblQuantity, *lblQuantityIndicator;
    UIButton *btnOk, *btnCancel, *btnDone;
    UITextField *txtHighTmpIngest,*txtLowTmpIngst,*txtHighTmpDerml,*txtLowTmpDerml,*txtbatteryAlarm,*txtQuantitySnrChk;
    NSString * strMsg;
    NSMutableArray * arrAlarm;
    UIView *allView,*viewBorderTmp;
    UIButton *  btnSwitchC ,*btnSwitchF ;
    BOOL isCClicked,isCheckBtn;
    NSInteger EnterdValue;
    NSMutableArray * arrAlrmResult, * arrSessions;
    float highIngstF, highIngstC,lowIngestF, lowIngestC, highDermalC,highDermalF,lowDermalF, lowDermalC;
    NSMutableArray * tmpDummyDataArr;
    NSMutableDictionary * dictSessionData;
    int sensorCount;
    NSMutableArray * arrSessionData, * arrSensorsofSessions;
    NSString * strCurrentSequence;
    int indexofSession;

}

@end

NS_ASSUME_NONNULL_END
@interface Temperature : NSObject

{
    double kelvin;
}

//Instance methods to convert argument to kevin
-(void) setFahrenheitValue: (double) f;
-(void) setCelsiusValue: (double) c;


//Instance methods for extracting the kelvin value using any scale
-(double) fahrenheitValue;
-(double) celsiusValue;


@end
