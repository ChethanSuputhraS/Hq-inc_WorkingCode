//
//  GlobalSettingVC.m
//  HQ-INC App
//
//  Created by Ashwin on 3/25/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "GlobalSettingVC.h"
#import "SubjSetupVC.h"
#import "BLEManager.h"
#import "BLEService.h"
#import "SessionPlayersVC.h"
#import "FirmWareUpdateVC.h"

@interface GlobalSettingVC ()<UITextFieldDelegate, BLEServiceDelegate>
{
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

@implementation GlobalSettingVC
- (void)viewDidLoad
{
    int textPhoSize = 12;

    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = UIColor.blackColor;
    
    arrSessions = [[NSMutableArray alloc] init];
    dictSessionData = [[NSMutableDictionary alloc] init];
    arrSessionData = [[NSMutableArray alloc] init];
    arrSensorsofSessions = [[NSMutableArray alloc] init];
    
    UIColor *lblTxtClr = [UIColor colorWithRed:180.0/255 green:245.0/255 blue:254.0/255 alpha:1];
    lblGlobalsetting = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, DEVICE_WIDTH, 50)];
    [self setLabelProperties:lblGlobalsetting withText:@"GLOBAL SETTINGS" backColor:UIColor.clearColor textColor:lblTxtClr textSize:textSize-6];
    lblGlobalsetting.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lblGlobalsetting];
    
    allView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, DEVICE_WIDTH-0, DEVICE_HEIGHT-64)];
    allView.backgroundColor = UIColor.blackColor;
    [self.view addSubview:allView];
    
    lblAddAlarms = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, allView.frame.size.width-20, 45)];
    [self setLabelProperties:lblAddAlarms withText:@"Add Alarms" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textPhoSize+2];
    [allView addSubview:lblAddAlarms];
    
    UIColor *btnBgC = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(10, DEVICE_HEIGHT-60, 60, 44)];
    [self setButtonProperties:btnCancel withTitle:@"Cancel"  backColor:btnBgC textColor:UIColor.whiteColor txtSize:textPhoSize+2];
    [btnCancel addTarget:self action:@selector(btnCancelClick) forControlEvents:UIControlEventTouchUpInside];
    btnCancel.layer.cornerRadius = 5;
    [self.view addSubview:btnCancel];
    
    btnDone = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-80, DEVICE_HEIGHT-60, 60, 44)];
    [self setButtonProperties:btnDone withTitle:@"Done" backColor:btnBgC textColor:UIColor.whiteColor txtSize:textPhoSize+2];
    [btnDone addTarget:self action:@selector(btnDoneClick) forControlEvents:UIControlEventTouchUpInside];
    btnDone.layer.cornerRadius = 5;
    btnDone.tag = 1;
    btnDone.titleLabel.font = [UIFont fontWithName:CGRegular size:textPhoSize+2];
    [self.view addSubview:btnDone];
    
    [self setupAdditionalSettings];
    [self setupGlobalSeneorCheck];
    arrAlrmResult = [[NSMutableArray alloc] init];
    NSString * sqlquery = [NSString stringWithFormat:@"select * from Alarm_Table"];
    [[DataBaseManager dataBaseManager] execute:sqlquery resultsArray:arrAlrmResult];
    

    if (arrAlrmResult.count > 0)
    {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
        tmpDict = [arrAlrmResult objectAtIndex:0];
//        NSLog(@"%@",tmpDict);
    
        highIngstF = [[tmpDict valueForKey:@"high_ingest_F"] floatValue];
        lowIngestF = [[tmpDict valueForKey:@"low_ingest_F"] floatValue];
        highDermalF = [[tmpDict valueForKey:@"high_dermal_F"] floatValue];
        lowDermalF = [[tmpDict valueForKey:@"low_dermal_F"] floatValue];
        
        highIngstC = [[tmpDict valueForKey:@"high_ingest_C"] floatValue];
        lowIngestC = [[tmpDict valueForKey:@"low_ingest_C"] floatValue];
        highDermalC = [[tmpDict valueForKey:@"high_dermal_C"] floatValue];
        lowDermalC = [[tmpDict valueForKey:@"low_dermal_C"] floatValue];
       
        txtbatteryAlarm.text = [tmpDict valueForKey:@"battery_alarm"];
        txtQuantitySnrChk.text = [tmpDict valueForKey:@"quantity"];
        
        if ([[tmpDict valueForKey:@"celciusSelect"] isEqual:@"1"])
        {
            isCClicked = YES;
        }
    }
    [self setupIngestSensorAlarm];
    [self setupDermalSensorAlarm];

    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
#pragma mark- Ingest Sensor Setting
-(void)setupIngestSensorAlarm
{
    lblType2ible = [[UILabel alloc]initWithFrame:CGRectMake(10, lblAddAlarms.frame.size.height, allView.frame.size.width-20, 44)];
    [self setLabelProperties:lblType2ible withText:@"Ingestible Sensor Alarms" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize-4];
    [allView addSubview:lblType2ible];
        
    int yy = lblType2ible.frame.size.height+40;
    viewBorderTmp = [[UIView alloc]init];
    viewBorderTmp.frame = CGRectMake(0, yy, allView.frame.size.width, 50);
    viewBorderTmp.layer.borderWidth = 1;
    viewBorderTmp.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];
    viewBorderTmp.layer.cornerRadius = 5;
    [allView addSubview:viewBorderTmp];
        
    lblHighTempAlarm = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 80, 50)];
    [self setLabelProperties:lblHighTempAlarm withText:@"High Temp" backColor:UIColor.clearColor textColor:UIColor.blackColor textSize:textSize-6];
    lblHighTempAlarm.userInteractionEnabled = true;
    [viewBorderTmp addSubview:lblHighTempAlarm];
        
    txtHighTmpIngest = [[UITextField alloc]initWithFrame:CGRectMake(lblHighTempAlarm.frame.size.width+30, 5, 60, 45)];
    [self setTextfieldProperties:txtHighTmpIngest withPlaceHolderText:@"" withTextSize:textSize-6];
    txtHighTmpIngest.layer.cornerRadius = 5;
    [viewBorderTmp addSubview:txtHighTmpIngest];
    
    lblLowTempAlarm = [[UILabel alloc]initWithFrame:CGRectMake(viewBorderTmp.frame.size.width/2+30, 0, 80, 50)];
    [self setLabelProperties:lblLowTempAlarm withText:@"Low Temp" backColor:UIColor.clearColor textColor:UIColor.blackColor textSize:textSize-6];
    [viewBorderTmp addSubview:lblLowTempAlarm];
        
    txtLowTmpIngst = [[UITextField alloc]initWithFrame:CGRectMake(viewBorderTmp.frame.size.width-70, 5, 60, 45)];
    [self setTextfieldProperties:txtLowTmpIngst withPlaceHolderText:@"" withTextSize:textSize-4];
    txtLowTmpIngst.layer.cornerRadius = 5;
    txtLowTmpIngst.returnKeyType = UIReturnKeyNext;
    txtLowTmpIngst.keyboardType = UIKeyboardTypeNumberPad;
    txtLowTmpIngst.textAlignment = NSTextAlignmentCenter;
    [viewBorderTmp addSubview:txtLowTmpIngst];
    
    if (isCClicked == YES)
    {
        txtHighTmpIngest.text = [NSString stringWithFormat:@"%.02fºC",highIngstC];
        txtLowTmpIngst.text = [NSString stringWithFormat:@"%.02fºC",lowIngestC];
    }
    else
    {
        txtHighTmpIngest.text = [NSString stringWithFormat:@"%.02fºF",highIngstF];
        txtLowTmpIngst.text = [NSString stringWithFormat:@"%.02fºF",lowIngestF];
    }
}
#pragma mark- Dermal Sensor Setting
-(void)setupDermalSensorAlarm
{
    //1 Dermal
    int yy = viewBorderTmp.frame.size.height+80;

    lblDermalSensorAlram = [[UILabel alloc]initWithFrame:CGRectMake(10, yy,allView.frame.size.width-20, 44)];
    [self setLabelProperties:lblDermalSensorAlram withText:@"Dermal Sensor Alarms" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize-6];
    [allView addSubview:lblDermalSensorAlram];
       
    UIView *viewBorderTmp1 = [[UIView alloc]init];
    viewBorderTmp1.frame = CGRectMake(0, yy+40, allView.frame.size.width, 50);
    viewBorderTmp1.layer.borderWidth = 1;
    viewBorderTmp1.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];
    viewBorderTmp1.layer.cornerRadius = 5;
    [allView addSubview:viewBorderTmp1];
       
    UILabel * lblHighTempAlarm1;
    lblHighTempAlarm1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 80, 45)];
    [self setLabelProperties:lblHighTempAlarm1 withText:@"High Temp" backColor:UIColor.clearColor textColor:UIColor.blackColor textSize:textSize-6];
    [viewBorderTmp1 addSubview:lblHighTempAlarm1];
      
    txtHighTmpDerml = [[UITextField alloc]initWithFrame:CGRectMake(lblHighTempAlarm1.frame.size.width+30, 5, 60, 40)];
    [self setTextfieldProperties:txtHighTmpDerml withPlaceHolderText:@"" withTextSize:textSize-6];
    txtHighTmpDerml.layer.cornerRadius = 5;
    txtHighTmpDerml.returnKeyType = UIReturnKeyNext;
    txtHighTmpDerml.keyboardType = UIKeyboardTypeNumberPad;
    txtHighTmpDerml.textAlignment = NSTextAlignmentCenter;
    [viewBorderTmp1 addSubview:txtHighTmpDerml];

    UILabel * lblLowTempAlarm1 = [[UILabel alloc]initWithFrame:CGRectMake(viewBorderTmp1.frame.size.width/2+30, 0, 80, 50)];
    [self setLabelProperties:lblLowTempAlarm1 withText:@"Low Temp" backColor:UIColor.clearColor textColor:UIColor.blackColor textSize:textSize-6];
    [viewBorderTmp1 addSubview:lblLowTempAlarm1];
       
    txtLowTmpDerml = [[UITextField alloc]initWithFrame:CGRectMake(viewBorderTmp1.frame.size.width-80, 5, 60, 44)];
    [self setTextfieldProperties:txtLowTmpDerml withPlaceHolderText:@"" withTextSize:textSize-6];
    txtLowTmpDerml.layer.cornerRadius = 5;
    txtLowTmpDerml.returnKeyType = UIReturnKeyNext;
    txtLowTmpDerml.keyboardType = UIKeyboardTypeNumberPad;
    txtLowTmpDerml.textAlignment = NSTextAlignmentCenter;
    [viewBorderTmp1 addSubview:txtLowTmpDerml];
    
    if (isCClicked == YES)
       {
           txtHighTmpDerml.text = [NSString stringWithFormat:@"%.02fºC",highDermalC];
           txtLowTmpDerml.text = [NSString stringWithFormat:@"%.02fºC",lowDermalC];
       }
       else
       {
           txtHighTmpDerml.text = [NSString stringWithFormat:@"%.02fºF",highDermalF];
           txtLowTmpDerml.text = [NSString stringWithFormat:@"%.02fºF",lowDermalF];
       }
}
#pragma mark- Additional Settings
-(void)setupAdditionalSettings
{
    int yy = 210;

    lblAdditionalSetgs = [[UILabel alloc]initWithFrame:CGRectMake(10, yy, allView.frame.size.width-20, 44)];
    [self setLabelProperties:lblAdditionalSetgs withText:@"Additional Settings" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize-6];
    [allView addSubview:lblAdditionalSetgs];
    
    UIView *viewBgAddsetng = [[UIView alloc]init];
    viewBgAddsetng.frame = CGRectMake(0, yy+40, (DEVICE_WIDTH)/1.5, 140);
    viewBgAddsetng.layer.cornerRadius = 5;
    viewBgAddsetng.layer.borderWidth = 1;
    viewBgAddsetng.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];
    [allView addSubview:viewBgAddsetng];
       
    lblTmpUnit = [[UILabel alloc]init];
    lblTmpUnit.frame = CGRectMake(5, 35, 140, 50);
    lblTmpUnit.text = @"Temperature Units";
    lblTmpUnit.font = [UIFont fontWithName:CGRegular size:textSize-6];
    [viewBgAddsetng addSubview:lblTmpUnit];
    
    UILabel* lblC = [[UILabel alloc]init];
    lblC.frame = CGRectMake(140, 0, 40, 40);//CGRectMake(275, 0, 50, 60)
    lblC.textColor = UIColor.blackColor;
    lblC.text = @"ºC";
    lblC.textAlignment = NSTextAlignmentCenter;
    [viewBgAddsetng addSubview:lblC];
    
    UILabel* lblF = [[UILabel alloc]init];
    lblF.frame = CGRectMake(190, 0, 40, 40); //CGRectMake(225, 0, 50, 60);
    lblF.textColor = UIColor.blackColor;
    lblF.text = @"ºF";
    lblF.textAlignment = NSTextAlignmentCenter;
    [viewBgAddsetng addSubview:lblF];
    
    UIView * viewBtnBg = [[UIView alloc] initWithFrame:CGRectMake(140, 40, 100, 40)];//222
    viewBtnBg.backgroundColor = UIColor.whiteColor;//whiteColor
    viewBtnBg.layer.cornerRadius = 5;
    [viewBgAddsetng addSubview:viewBtnBg];
    
    UIColor * btnSwBg = [UIColor colorWithRed:83.0/255 green:187.0/255 blue:193.0/255 alpha:1];
    btnSwitchF = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSwitchF.frame = CGRectMake(0, 0, 50, 44);
    [self setButtonProperties:btnSwitchF withTitle:@"" backColor:btnSwBg textColor:UIColor.clearColor txtSize:28];
    [btnSwitchF addTarget:self action:@selector(btnFaradClick) forControlEvents:UIControlEventTouchUpInside];
    btnSwitchF.layer.cornerRadius = 5;
    btnSwitchF.clipsToBounds = true;
    [viewBtnBg addSubview:btnSwitchF];
    
    btnSwitchC = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSwitchC.frame = CGRectMake(50, 0, 50, 44);
    btnSwitchC.layer.cornerRadius = 5;
    btnSwitchC.clipsToBounds = true;
    [btnSwitchC addTarget:self action:@selector(btnCelsClick) forControlEvents:UIControlEventTouchUpInside];
    [viewBtnBg addSubview:btnSwitchC];
    
    lblBatteryAlarm = [[UILabel alloc]init];
    lblBatteryAlarm.frame = CGRectMake(5, 90, 150, 44);
    lblBatteryAlarm.text = @"Battery Alarm";
    lblBatteryAlarm.font = [UIFont fontWithName:CGRegular size:textSize-6];
    [viewBgAddsetng addSubview:lblBatteryAlarm];
       
    txtbatteryAlarm = [[UITextField alloc]initWithFrame:CGRectMake(150, 90, 55, 44)];
    [self setTextfieldProperties:txtbatteryAlarm withPlaceHolderText:@"20" withTextSize:textSize-6];
    txtbatteryAlarm.backgroundColor = UIColor.whiteColor;
    txtbatteryAlarm.layer.cornerRadius = 5;
    txtbatteryAlarm.returnKeyType = UIReturnKeyNext;
    txtbatteryAlarm.keyboardType = UIKeyboardTypeNumberPad;
    txtbatteryAlarm.textAlignment = NSTextAlignmentCenter;
    txtbatteryAlarm.tag = 300;
    [viewBgAddsetng addSubview:txtbatteryAlarm];
        
    UILabel *lblPersentage = [[UILabel alloc]initWithFrame:CGRectMake(220, 90, 44, 50)];
    [self setLabelProperties:lblPersentage withText:@"%" backColor:UIColor.clearColor textColor:UIColor.blackColor textSize:textSize-2];
    [viewBgAddsetng addSubview:lblPersentage];
    
//    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"isCelsicusSelect"] isEqualToString:@"Yes"])
//    {
//        isCClicked = YES;
//        btnSwitchC.backgroundColor = [UIColor colorWithRed:83.0/255 green:187.0/255 blue:193.0/255 alpha:1];
//        btnSwitchF.backgroundColor = UIColor.clearColor;
//    }
//     else
//     {
//         isCClicked = NO;
//         btnSwitchF.backgroundColor = [UIColor colorWithRed:83.0/255 green:187.0/255 blue:193.0/255 alpha:1];
//         btnSwitchC.backgroundColor = UIColor.clearColor;
//    }
    
    
   NSMutableArray * arrAlarm = [[NSMutableArray alloc] init];
    NSString * sqlquery = [NSString stringWithFormat:@"select * from Alarm_Table"];
    [[DataBaseManager dataBaseManager] execute:sqlquery resultsArray:arrAlarm];
    
    if (arrAlarm.count > 0)
    {
        if ([[[arrAlarm objectAtIndex:0] valueForKey:@"celciusSelect"] isEqual:@"1"])
        {
            btnSwitchC.backgroundColor = [UIColor colorWithRed:83.0/255 green:187.0/255 blue:193.0/255 alpha:1];
            btnSwitchF.backgroundColor = UIColor.clearColor;
        }
        else
        {
            btnSwitchF.backgroundColor = [UIColor colorWithRed:83.0/255 green:187.0/255 blue:193.0/255 alpha:1];
            btnSwitchC.backgroundColor = UIColor.clearColor;
        }
    }
}

#pragma mark-Global sensor chek
-(void)setupGlobalSeneorCheck
{
    int yy = allView.frame.size.height-220;

    lblGlobalSnrCheck = [[UILabel alloc]initWithFrame:CGRectMake(10, yy+10, DEVICE_WIDTH, 40)];
    [self setLabelProperties:lblGlobalSnrCheck withText:@"Global Sensor Check" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:20];
    [allView addSubview:lblGlobalSnrCheck];
    
    yy = yy +45;
    UIView * globalSnrCheckView  = [[UIView alloc]init];
    globalSnrCheckView.frame = CGRectMake(0, yy, allView.frame.size.width/1.5, 50);
    globalSnrCheckView.layer.cornerRadius = 5;
    globalSnrCheckView.layer.borderWidth = 1;
    globalSnrCheckView.backgroundColor= [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];
    [allView addSubview:globalSnrCheckView];
    
    lblQuantity = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 70, 50)];
    [self setLabelProperties:lblQuantity withText:@"Quantity" backColor:UIColor.clearColor textColor:UIColor.blackColor textSize:textSize-6];
    [globalSnrCheckView addSubview:lblQuantity];
    
    txtQuantitySnrChk = [[UITextField alloc]initWithFrame:CGRectMake(100, 5, 55, 40)];
    [self setTextfieldProperties:txtQuantitySnrChk withPlaceHolderText:@"10" withTextSize:textSize-6];
    txtQuantitySnrChk.layer.cornerRadius = 5;
    txtQuantitySnrChk.returnKeyType = UIReturnKeyDone;
    txtQuantitySnrChk.keyboardType = UIKeyboardTypeNumberPad;
    txtQuantitySnrChk.textAlignment = NSTextAlignmentCenter;
    txtQuantitySnrChk.tag = 200;
    [globalSnrCheckView addSubview:txtQuantitySnrChk];
    
    UIColor* btnBGC = [UIColor colorWithRed:27.0/255 green:157.0/255 blue:25.0/255 alpha:1];
    btnOk = [[UIButton alloc]initWithFrame:CGRectMake(180, 2, 46, 46)];
    [self setButtonProperties:btnOk withTitle:@"OK" backColor:btnBGC textColor:UIColor.whiteColor txtSize:textSize-6];
    [btnOk setTitle:@"OK" forState:UIControlStateNormal];
    btnOk.layer.cornerRadius = 23;
    [btnOk addTarget:self action:@selector(btnOKClick) forControlEvents:UIControlEventTouchUpInside];
    [globalSnrCheckView addSubview:btnOk];
    
    
    yy = yy +60;
    UIButton * btnReadStoredSession = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReadStoredSession.frame = CGRectMake(5, yy, 150, 44);
    [btnReadStoredSession addTarget:self action:@selector(btnReadStoreSessionClick) forControlEvents:UIControlEventTouchUpInside];
    [btnReadStoredSession setTitle:@"Get Stored Session" forState:UIControlStateNormal];
    btnReadStoredSession.layer.cornerRadius = 5;
    [self setButtonProperties:btnReadStoredSession withTitle:@"Get Stored Session" backColor:UIColor.whiteColor textColor:UIColor.blackColor txtSize:textSize-6];
    [allView addSubview:btnReadStoredSession];

    UIButton * btnFirmWareupdate = [UIButton buttonWithType:UIButtonTypeCustom];
    btnFirmWareupdate.frame = CGRectMake(allView.frame.size.width/2, yy, 150, 44);
    [btnFirmWareupdate addTarget:self action:@selector(btnFirmWarwUpdateClick) forControlEvents:UIControlEventTouchUpInside];
//    [btnFirmWareupdate setTitle:@"Get Stored Session" forState:UIControlStateNormal];
    [self setButtonProperties:btnFirmWareupdate withTitle:@"Update firmware" backColor:UIColor.whiteColor  textColor:UIColor.blackColor txtSize:textSize-6];
    btnFirmWareupdate.layer.cornerRadius = 5;
    [allView addSubview:btnFirmWareupdate];
}
#pragma mark - Buttons
-(void)btnFaradClick
{
    isCClicked = NO;

    btnSwitchF.backgroundColor = [UIColor colorWithRed:83.0/255 green:187.0/255 blue:193.0/255 alpha:1];
    btnSwitchC.backgroundColor = UIColor.clearColor;
    txtHighTmpIngest.text = [NSString stringWithFormat:@"%@ºF" ,[NSString stringWithFormat:@"%.02f", highIngstF]];
    txtLowTmpIngst.text = [NSString stringWithFormat:@"%@ºF" ,[NSString stringWithFormat:@"%.02f", lowIngestF]];
    txtHighTmpDerml.text = [NSString stringWithFormat:@"%@ºF" ,[NSString stringWithFormat:@"%.02f", highDermalF]];
    txtLowTmpDerml.text = [NSString stringWithFormat:@"%@ºF" ,[NSString stringWithFormat:@"%.02f", lowDermalF]];
}
-(void)btnCelsClick
{
    isCClicked = YES;

    btnSwitchC.backgroundColor = [UIColor colorWithRed:83.0/255 green:187.0/255 blue:193.0/255 alpha:1];
    btnSwitchF.backgroundColor = UIColor.clearColor;
    txtHighTmpIngest.text = [NSString stringWithFormat:@"%@ºC" ,[NSString stringWithFormat:@"%.02f", highIngstC]];
    txtLowTmpIngst.text = [NSString stringWithFormat:@"%@ºC" ,[NSString stringWithFormat:@"%.02f", lowIngestC]];
    txtHighTmpDerml.text = [NSString stringWithFormat:@"%@ºC" ,[NSString stringWithFormat:@"%.02f", highDermalC]];
    txtLowTmpDerml.text = [NSString stringWithFormat:@"%@ºC" ,[NSString stringWithFormat:@"%.02f", lowDermalC]];
    
}
-(void)btnOKClick
{
    [[BLEService sharedInstance] setDelegate:self];
//    [self generateDummyData];
    [self WriteCommandtoGetStoredSessions];
}
-(void)btnCancelClick
{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)btnDoneClick
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeSuccess];
    [alert showAlertInView:self
                 withTitle:@"HQ-Inc"
              withSubtitle:@"Alarm updated succesfully"
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
    [alert doneActionBlock:^{
        [self.navigationController popViewControllerAnimated:true];
        
        [self UpdatedToAlarmTable:self->isCClicked];
    }];
}
-(void)btnReadStoreSessionClick
{
    SessionPlayersVC * sessionlist = [[SessionPlayersVC alloc] init];
    [self.navigationController pushViewController:sessionlist animated:YES];
    
//    if (globalPeripheral.state == CBPeripheralStateConnected)
//    {
//
//    }
//    else
//    {
//        [self AlertViewFCTypeCaution:@"Please make sure Monitor is connected with App and then try again to Add Sensors."];
//    }
    
}
-(void)btnFirmWarwUpdateClick
{
    FirmWareUpdateVC * firmWUpdate = [[FirmWareUpdateVC alloc] init];
    [self.navigationController pushViewController:firmWUpdate animated:true];
}
#pragma mark- To Update Alarm table
-(void)UpdatedToAlarmTable:(BOOL)isCliSelect
{
    NSString * strHighIngstF = [APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%.02f",highIngstF]] ;
    NSString * strLowIngstF = [APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%.02f",lowIngestF]];
    NSString * strHigDermlF = [APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%.02f",highDermalF]];
    NSString * strLowDrmlF = [APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%.02f",lowDermalF]];
    
    NSString * strHighIngstC = [APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%.02f",highIngstC]];
    NSString * strLowIngstC = [APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%.02f",lowIngestC]];
    NSString * strHigDermlC = [APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%.02f",highDermalC]];
    NSString * strLowDrmlC = [APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%.02f",lowDermalC]];
    NSString * strBateyAlrm = [APP_DELEGATE checkforValidString:txtbatteryAlarm.text];
    NSString * strQuantity = [APP_DELEGATE checkforValidString:txtQuantitySnrChk.text];
    NSString * strCSelected = [NSString stringWithFormat:@"%d",isCliSelect];
    
     NSString * requestStr =  [NSString stringWithFormat:@"update Alarm_Table set high_ingest_F = \"%@\", low_ingest_F = \"%@\", high_dermal_F = \"%@\", low_dermal_F = \"%@\", high_ingest_C = \"%@\", low_ingest_C = \"%@\", high_dermal_C = \"%@\", low_dermal_C = \"%@\", battery_alarm = \"%@\", quantity = \"%@\", celciusSelect = \"%@\" ",strHighIngstF,strLowIngstF,strHigDermlF,strLowDrmlF,strHighIngstC,strLowIngstC,strHigDermlC,strLowDrmlC,strBateyAlrm,strQuantity,strCSelected];
    
    [[DataBaseManager dataBaseManager] executeSw:requestStr];
}
#pragma mark-TextField method
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtHighTmpIngest)
    {
        [txtHighTmpIngest resignFirstResponder];
    }
    else if (textField == txtLowTmpIngst)
    {
        [txtLowTmpIngst resignFirstResponder];
     }
    else if (textField == txtHighTmpDerml)
    {
        [txtHighTmpDerml resignFirstResponder];
     }
    else if (textField == txtLowTmpDerml)
    {
        [txtLowTmpDerml resignFirstResponder];
    }
    else if (textField == txtbatteryAlarm)
    {
        [txtbatteryAlarm resignFirstResponder];
    }
    else if (textField == txtQuantitySnrChk)
    {
        [txtQuantitySnrChk resignFirstResponder];
    }
    
    return true;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == txtbatteryAlarm)
    {
        self.view.frame = CGRectMake(0, -200, DEVICE_WIDTH, DEVICE_HEIGHT);
    }
   else if (textField == txtQuantitySnrChk)
   {
       self.view.frame = CGRectMake(0, -200, DEVICE_WIDTH, DEVICE_HEIGHT);
   }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!string.length)
        return YES;

 if (textField == txtHighTmpIngest || textField == txtLowTmpIngst || textField == txtHighTmpDerml || textField == txtLowTmpDerml || textField == txtQuantitySnrChk)
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
        options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString options:0
        range:NSMakeRange(0, [newString length] )];
        NSString *strEnterd = newString;
        EnterdValue = [strEnterd integerValue];

        if (numberOfMatches == 0)
            return NO;
    }

    //   in tis formate  100.00˚F
    NSUInteger decimalPlacesLimit = 2; // 2
    NSRange rangeDot = [textField.text rangeOfString:@"." options:NSCaseInsensitiveSearch];
    NSRange rangeComma = [textField.text rangeOfString:@"," options:NSCaseInsensitiveSearch];
    if (rangeDot.length > 0 || rangeComma.length > 0)
    {
        if([string isEqualToString:@"."])
        {
            NSLog(@"textField already contains a separator");
            return NO;
        }
        else
        {
            NSArray *explodedString = [textField.text componentsSeparatedByString:@"."];
            NSString *decimalPart = explodedString[1];
            if (decimalPart.length >= decimalPlacesLimit && ![string isEqualToString:@""])
            {
                NSLog(@"textField already contains %lu decimal places", (unsigned long)decimalPlacesLimit);
                return NO;
            }
        }
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);

    if ([[APP_DELEGATE checkforValidString:textField.text] isEqualToString:@"NA"])
    {
            [self showAlertForEmptyTextField:textField];
    }
    else
    {
        NSArray * arrVal = [self getFarnhitefromCelcius:textField.text];
        if (arrVal.count == 2)
        {
            float tmpff = [[arrVal objectAtIndex:0] floatValue];
            float tmpcc = [[arrVal objectAtIndex:1] floatValue];
            
            if([self ChecktemperatureValues:tmpcc withfernhite:tmpff withTextfield:textField] == YES)
            {
                if (textField == txtHighTmpIngest)
                {
                    highIngstF = [[arrVal objectAtIndex:0] floatValue];
                    highIngstC = [[arrVal objectAtIndex:1] floatValue];
                }
                else  if (textField == txtLowTmpIngst)
                {
                    lowIngestF = [[arrVal objectAtIndex:0] floatValue];
                    lowIngestC = [[arrVal objectAtIndex:1] floatValue];
                }
                else  if (textField == txtHighTmpDerml)
                {
                    highDermalF = [[arrVal objectAtIndex:0] floatValue];
                    highDermalC = [[arrVal objectAtIndex:1] floatValue];
                }
                else  if (textField == txtLowTmpDerml)
                {
                    lowDermalF = [[arrVal objectAtIndex:0] floatValue];
                    lowDermalC = [[arrVal objectAtIndex:1] floatValue];
                }
            }
        }
    }
}
#pragma mark-Value Check for Celsius and fernhite
-(BOOL)ChecktemperatureValues:(float)valC withfernhite:(float)valF  withTextfield:(UITextField *)txtfld
{
    BOOL isValidValue = YES;
    if(isCClicked == YES)
    {
        if(valC > 38.1)
        {
            isValidValue = NO;
           [self AlertViewFCTypeCaution:@"Maximum value Exceed for Temperature in ºC"] ;
        }
        else if (valC < 36.1)
        {
            isValidValue = NO;
           [self AlertViewFCTypeCaution:@"Temperature can't be less than 36.1 ºC"];
        }
    }
    else
    {
//        if (txtfld.tag == 200)
//        {
//
//        }
//        else if (txtfld.tag == 300)
//        {
//
//        }
//        else
//        {
            if(valF > 100.5)
            {
                isValidValue = NO;
//                [self AlertViewFCTypeCaution:@"Maximum value Exceed for temprature in ºF"] ;
            }
            else if (valF < 97)
            {
                isValidValue = NO;
    //           [self AlertViewFCTypeCaution:@"Temperature can't be less than 97 ºF"] ;
            }
//        }
 
        isValidValue = YES;
        [self checkBattryAndQuantity:txtfld];
    }
    if (isValidValue == NO)
    {
        [self AlertViewFCTypeCaution:@"Please check the values !"];
    }
    return isValidValue;
}
-(BOOL)checkBattryAndQuantity:(UITextField *) txtlield
{
    if (txtlield == txtbatteryAlarm)
    {
        if (EnterdValue > 100.1)
        {
           [self AlertViewFCTypeCaution:@"battery alarm within 100 only"] ;
            txtbatteryAlarm.text = @"20";
        }
    }
    return txtlield;
}
-(void)showAlertForEmptyTextField:(UITextField *)txtfild
{
        if(txtfild == txtHighTmpIngest)
        {
            [self AlertViewFCTypeCaution:@"Please enater High Ingest value."];
        }
        else if (txtfild == txtLowTmpIngst)
        {
           [self AlertViewFCTypeCaution:@"Please enter Low Ingest Vlaue."] ;
        }
        else if (txtfild == txtHighTmpDerml)
        {
            [self AlertViewFCTypeCaution:@"Please enter High Dermal value."] ;
        }
        else if (txtfild == txtLowTmpDerml)
        {
            [self AlertViewFCTypeCaution: @"Please enter Low Dermal value."];
        }
        else if (txtfild == txtbatteryAlarm)
        {
            [self AlertViewFCTypeCaution:@"Please enter battery alarm."] ;
        }
        else if (txtfild == txtQuantitySnrChk)
        {
            [self AlertViewFCTypeCaution:@"Pleasse enter Quantity."] ;
        }
    else
    {
        NSArray * arrVal = [self getFarnhitefromCelcius:txtfild.text];
        if (arrVal.count == 2)
        {
            float tmpff = [[arrVal objectAtIndex:0] floatValue];
            float tmpcc = [[arrVal objectAtIndex:1] floatValue];
            
            if([self ChecktemperatureValues:tmpcc withfernhite:tmpff withTextfield:txtfild] == YES)
            {
                if (txtfild == txtHighTmpIngest)
                {
                    highIngstF = [[arrVal objectAtIndex:0] floatValue];
                    highIngstC = [[arrVal objectAtIndex:1] floatValue];
                    txtHighTmpIngest.text = [NSString stringWithFormat:@"%.f ºF",highIngstF];
                }
                else  if (txtfild == txtLowTmpIngst)
                {
                    lowIngestF = [[arrVal objectAtIndex:0] floatValue];
                    lowIngestC = [[arrVal objectAtIndex:1] floatValue];
                    txtLowTmpIngst.text = [NSString stringWithFormat:@"%.f ºF",lowIngestF];
                }
                else  if (txtfild == txtHighTmpDerml)
                {
                    highDermalF = [[arrVal objectAtIndex:0] floatValue];
                    highDermalC = [[arrVal objectAtIndex:1] floatValue];
                    txtHighTmpDerml.text = [NSString stringWithFormat:@"%.f ºF",highDermalF];
                }
                else  if (txtfild == txtLowTmpDerml)
                {
                    lowDermalF = [[arrVal objectAtIndex:0] floatValue];
                    lowDermalC = [[arrVal objectAtIndex:1] floatValue];
                    txtLowTmpDerml.text = [NSString stringWithFormat:@"%.f ºF",lowDermalF];
                }
                else if (txtfild == txtQuantitySnrChk)
                {
                    
                }
            }
         }
    }
    
}
#pragma mark-Get F From C
-(NSArray *)getFarnhitefromCelcius:(NSString *)strVal
{
    if ([[APP_DELEGATE checkforValidString:strVal] isEqualToString:@"NA"])
    {
        return [NSArray new];
    }
    float fff = 0.0;
    float ccc = 0.0;
    if (isCClicked == NO)
    {
        fff = strVal.floatValue;
        ccc = (fff-32)/1.8;
    }
    else
    {
        ccc = strVal.floatValue;
        fff = (ccc * 1.8) + 32;
    }
    NSArray * arr = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%.02f",fff],[NSString stringWithFormat:@"%.02f",ccc], nil];
    return arr;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.view.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    [self.view endEditing:YES];
}
#pragma mark-textField and Lables And Button Properties
-(void)setTextfieldProperties:(UITextField *)txtfld withPlaceHolderText:(NSString *)strText withTextSize:(int)textSize
{
    txtfld.delegate = self;
    txtfld.attributedPlaceholder = [[NSAttributedString alloc] initWithString:strText attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor],NSFontAttributeName: [UIFont fontWithName:CGRegular size:textSize]}];
    txtfld.textAlignment = NSTextAlignmentCenter;
    txtfld.textColor = [UIColor blackColor];
    txtfld.backgroundColor= UIColor.whiteColor;
    txtfld.keyboardType = UIKeyboardTypeNumberPad;
    txtfld.font = [UIFont fontWithName:CGRegular size:textSize];
    txtfld.clipsToBounds = true;
}
-(void)setLabelProperties:(UILabel *)lbl withText:(NSString *)strText backColor:(UIColor *)backColor textColor:(UIColor *)txtColor textSize:(int)txtSize
{
    lbl.text = strText;
    lbl.textColor = txtColor;
    lbl.backgroundColor = backColor;
    lbl.clipsToBounds = true;
    lbl.textAlignment = NSTextAlignmentLeft;
    lbl.layer.cornerRadius = 5;
    lbl.font = [UIFont fontWithName:CGRegular size:txtSize];
}
-(void)setButtonProperties:(UIButton *)btn withTitle:(NSString *)strText backColor:(UIColor *)backColor textColor:(UIColor *)txtColor txtSize:(int)txtSize
{
    [btn setTitle:strText forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn setTitleColor:txtColor forState:UIControlStateNormal];
    btn.backgroundColor = backColor;
    btn.clipsToBounds = true;
}
-(void)AlertViewFCTypeCaution:(NSString *)strPopup
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeCaution];
    [alert showAlertInView:self
                 withTitle:@"HQ-Inc"
              withSubtitle:strPopup
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}
-(void)AlertViewFCTypeSuccess:(NSString *)strPopup
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeSuccess];
    [alert showAlertInView:self
                 withTitle:@"HQ-Inc"
              withSubtitle:strPopup
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}


#pragma mark - BLE Methods
#pragma mark - Write Commands from App to Device
-(void)WriteCommandtoGetStoredSessions
{
    NSInteger intMsg = [@"0" integerValue];
    NSData * dataMsg = [[NSData alloc] initWithBytes:&intMsg length:1];

    NSLog(@"Wrote Command to get Stored Session---==%@",dataMsg);
    [[BLEService sharedInstance] WriteValuestoDevice:dataMsg withOcpde:@"15" withLength:@"0" with:globalPeripheral];
}
-(void)GetSessionDataOnebyone:(NSString *)strSessionID
{
    NSInteger intMsg = [@"250" integerValue];
    NSData * dataMsg = [[NSData alloc] initWithBytes:&intMsg length:1];
    
    NSInteger intSequnce = [strSessionID integerValue];
    NSData * dataSequnce = [[NSData alloc] initWithBytes:&intSequnce length:1];

    NSMutableData * completeData = [[NSMutableData alloc] initWithData:dataMsg];
    [completeData appendData:dataSequnce];
    
    [[BLEService sharedInstance] WriteValuestoDevice:completeData withOcpde:@"16" withLength:@"2" with:globalPeripheral];
}

#pragma mark - Receive data from Device to App
-(NSString *)checkforValidString:(NSString *)strRequest
{
    NSString * strValid;
    if (![strRequest isEqual:[NSNull null]])
    {
        if (strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""] && ![strRequest isEqualToString:@"(null)"])
        {
            strValid = strRequest;
        }
        else
        {
            strValid = @"NA";
        }
    }
    else
    {
        strValid = @"NA";
    }
    strValid = [strValid stringByReplacingOccurrencesOfString:@"\"" withString:@""];

    return strValid;
}

#pragma mark - BLEService Delegate Methods
-(void)ReceiveListofSessionsID:(NSDictionary *)dictData
{
    if (![arrSessions containsObject:dictData])
    {
        [arrSessions addObject:dictData];
    }
    NSString * strPacketNo = [self checkforValidString:[dictData valueForKey:@"packetno"]];
    if ([strPacketNo isEqualToString:@"0"])//Means its last packet and now go for individual session data
    {
        
        NSLog(@"Found Sessions====> %@",arrSessions);
        if ([arrSessions count] > 0)
        {
            indexofSession = 0;
            [self performSelector:@selector(FetchSessionDataOnebyOne) withObject:nil afterDelay:2];

        }
    }
}
-(void)RecieveSessionInformation:(NSMutableDictionary *)dictDetail;
{
    dictSessionData = [dictDetail mutableCopy];
}
-(void)RecievePlayerNameofSession:(NSString *)strPlayerName;
{
    [dictSessionData setValue:strPlayerName forKey:@"player_name"];
}
-(void)RecieveSensorInformationofSession:(NSMutableArray *)arrSensors;
{
    arrSensorsofSessions = [[NSMutableArray alloc] init];
    arrSensorsofSessions = [arrSensors mutableCopy];
    [dictSessionData setObject:arrSensors forKey:@"sensors"];
    NSLog(@"Session Information====> %@",dictSessionData);
}
-(void)RecieveSessionDataString:(NSString *)strData withPacketLength:(int)packetLength;
{
    NSString * strSequence = [self stringFroHex:[strData substringWithRange:NSMakeRange(2, 4)]] ;

    int totalSensors = [[dictSessionData valueForKey:@"no_of_sensor"] intValue];
    NSString * strSessionID = [dictSessionData valueForKey:@"session_id"];
    
    for (int i=0; i < packetLength/2; i++)
    {
        if (sensorCount == totalSensors)
        {
            sensorCount = 0;
        }
        NSString * strSensorTemp = [self stringFroHex:[strData substringWithRange:NSMakeRange(6 + (i*4), 4)]];
        int divValue =  [strSensorTemp doubleValue];
        double fPointData = divValue / 100.0;
        NSString * strActualTemp = [NSString stringWithFormat:@"%.2f", fPointData];

        NSString * strSensorId = @"NA";
        NSString * strSensorType = @"NA";
        if ([arrSensorsofSessions count] > sensorCount)
        {
            strSensorId = [[arrSensorsofSessions objectAtIndex:sensorCount] valueForKey:@"sensor_id"];
            strSensorType = [[arrSensorsofSessions objectAtIndex:sensorCount] valueForKey:@"sensor_type"];
        }
        sensorCount = sensorCount + 1;
        NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:strActualTemp,@"temp",strSensorId,@"sensor_id",strSensorType,@"sensor_type", strSessionID,@"session_id",strData,@"packetdata",nil];
        if (![[arrSessionData valueForKey:@"packetdata"] containsObject:strData])
        {
            [arrSessionData addObject:dict];
        }
    }

    strCurrentSequence = strSequence;
    NSInteger intMsg = [@"252" integerValue];
    NSData * dataMsg = [[NSData alloc] initWithBytes:&intMsg length:1];
    
    NSInteger intSequnce = [strCurrentSequence integerValue];
    NSData * dataSequnce = [[NSData alloc] initWithBytes:&intSequnce length:2];

    NSMutableData * completeData = [[NSMutableData alloc] initWithData:dataMsg];
    [completeData appendData:dataSequnce];
    
    [[BLEService sharedInstance] WriteValuestoDevice:completeData withOcpde:@"16" withLength:@"3" with:globalPeripheral];


}
-(void)FetchSessionDataOnebyOne
{
    if ([arrSessions count] > indexofSession)
    {
        NSString * strSessionId = [[arrSessions objectAtIndex:indexofSession] valueForKey:@"session_id"];
        [self GetSessionDataOnebyone:strSessionId];
    }
    else
    {
        NSLog(@"All Session Data Imported....");
    }
}
-(void)RecieveSessionEndPacket
{
    NSString * strSessionId = [self checkforValidString:[dictSessionData valueForKey:@"session_id"]];
    NSString * strTimeStamp = [self checkforValidString:[dictSessionData valueForKey:@"timeStamp"]];
    NSString * strPlayerId = [self checkforValidString:[dictSessionData valueForKey:@"player_id"]];
    NSString * strPlayerName = [self checkforValidString:[dictSessionData valueForKey:@"player_name"]];
    NSString * strNoofSensors = [self checkforValidString:[dictSessionData valueForKey:@"no_of_sensor"]];
    NSString * strReadInterval = [self checkforValidString:[dictSessionData valueForKey:@"read_interval"]];

    NSString * strCheckSessionAvailable = [NSString stringWithFormat:@"select * from Session_Table where session_id ='%@' and timeStamp ='%@'",strSessionId, strTimeStamp];
    NSMutableArray * arrData = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager] execute:strCheckSessionAvailable resultsArray:arrData];
    if ([arrData count] == 0)
    {
        NSString * strInsertSession = [NSString stringWithFormat:@"insert into 'Session_Table' ('session_id', 'player_id', 'player_name', 'read_interval', 'timeStamp', 'no_of_sensor', 'is_active') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",strSessionId,strPlayerId,strPlayerName,strReadInterval,strTimeStamp,strNoofSensors,@"1"];
        [[DataBaseManager dataBaseManager] execute:strInsertSession];
    }
    int indexofData = 0;
    int totalSensors = [strNoofSensors intValue];
    int intReadInterval = [strReadInterval intValue];

    int timeValue = [strTimeStamp intValue];
    
    for (int i = 0; i < [arrSessionData count]; i++)
    {
        NSString * strTemp = [self checkforValidString:[[arrSessionData objectAtIndex:i] valueForKey:@"temp"]];
        NSString * strSensorId = [self checkforValidString:[[arrSessionData objectAtIndex:i] valueForKey:@"sensor_id"]];
        NSString * strSensorType = [self checkforValidString:[[arrSessionData objectAtIndex:i] valueForKey:@"sensor_type"]];
        NSString * strPacket = [self checkforValidString:[[arrSessionData objectAtIndex:i] valueForKey:@"packetdata"]];

        if (![strTemp isEqualToString:@"NA"])
        {
            if (indexofData == totalSensors)
            {
                timeValue = timeValue + intReadInterval;
                indexofData = 0;
            }
            else
            {
                timeValue = timeValue;
            }
            indexofData = indexofData + 1;

            NSString * strDataTime = [NSString stringWithFormat:@"%d",timeValue];
            NSString * strDataQuery = [NSString stringWithFormat:@"insert into 'Session_data' ('session_id', 'temp', 'timestamp', 'sensor_type', 'sensor_id', 'packet', 'player_id') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\", \"%@\")",strSessionId,strTemp,strDataTime,strSensorType,strSensorId,strPacket, strPlayerId];
            [[DataBaseManager dataBaseManager] execute:strDataQuery];
        }
    }
    NSLog(@"Final Session Data====>%@",arrSessionData);
    [self performSelector:@selector(SendRecievedDataAcknowledgement) withObject:nil afterDelay:1];
    [arrSessionData removeAllObjects];
    [arrSensorsofSessions removeAllObjects];
}
-(void)SendRecievedDataAcknowledgement
{
    NSInteger intMsg = [@"251" integerValue];
    NSData * dataMsg = [[NSData alloc] initWithBytes:&intMsg length:1];
    [[BLEService sharedInstance] WriteValuestoDevice:dataMsg withOcpde:@"16" withLength:@"1" with:globalPeripheral];
    
    indexofSession = indexofSession + 1;
    [self FetchSessionDataOnebyOne];
}
-(void)generateDummyData
{
    tmpDummyDataArr = [[NSMutableArray alloc] init];
    [tmpDummyDataArr addObject:@"100DFF01000000016c453245000205000000"];
    [tmpDummyDataArr addObject:@"1005FE546573740000000000000000000000"];
    [tmpDummyDataArr addObject:@"1010FD014D03015C04012D03019E03016603"];
    [tmpDummyDataArr addObject:@"100FFC00010A280A290A280A2B0A2D0A2C00"];
    [tmpDummyDataArr addObject:@"100FFC00020A280A290A280A2B0A2D0A2C00"];//
    [tmpDummyDataArr addObject:@"100FFC00030A280A290A280A2B0A2D0A2C00"];//
    [tmpDummyDataArr addObject:@"100FFC00040A280A290A280A2B0A2D0A2C00"];//
    [tmpDummyDataArr addObject:@"100FFC00050A280A290A280A2B0A2D0A2C00"];//
    [tmpDummyDataArr addObject:@"100FFC00060A280A290A280A2B0A2D0A2C00"];//
    [tmpDummyDataArr addObject:@"100FFC00070A280A290A280A2B0A2D0A2C00"];//
    [tmpDummyDataArr addObject:@"100FFC00080A280A290A280A2B0A2D0A2C00"];//
    [tmpDummyDataArr addObject:@"100FFC00090A280A290A280A2B0A2D0A2C00"];//
    [tmpDummyDataArr addObject:@"100FFC000A0A280A290A280A2B0A2D0A2C00"];//
    [tmpDummyDataArr addObject:@"100FFC000B0A280A290A280A2B0A2D0A2C00"];
    [tmpDummyDataArr addObject:@"100BFC000C0A280A290A280A2B0000000000"];
    [tmpDummyDataArr addObject:@"1002FB01"];
}

-(NSString*)stringFroHex:(NSString *)hexStr
{
    unsigned long long startlong;
    NSScanner* scanner1 = [NSScanner scannerWithString:hexStr];
    [scanner1 scanHexLongLong:&startlong];
    double unixStart = startlong;
    NSNumber * startNumber = [[NSNumber alloc] initWithDouble:unixStart];
    return [startNumber stringValue];
}

@end
/*
 
 @"100DFF01000000016c453245000205000000",
@"1005FE546573740000000000000000000000",
 @"1010FD014D03015C04012D03019E03016603",
 @"100FFC00010A280A290A280A2B0A2D0A2C00",
 
 
 @"100FFC00020A280A290A280A2B0A2D0A2C00",
 
 @"100FFC00030A280A290A280A2B0A2D0A2C00",
 
 @"100FFC00040A280A290A280A2B0A2D0A2C00",
 
 @"100FFC00050A280A290A280A2B0A2D0A2C00",
 
 @"100FFC00060A280A290A280A2B0A2D0A2C00",
 
 @"100FFC00070A280A290A280A2B0A2D0A2C00",
 
 @"100FFC00080A280A290A280A2B0A2D0A2C00",
 
 @"100FFC00090A280A290A280A2B0A2D0A2C00",
 
 @"100FFC000A0A280A290A280A2B0A2D0A2C00",
 
 @"100FFC000B0A280A290A280A2B0A2D0A2C00",
 @"100BFC000C0A280A290A280A2B0000000000",
 @"1002FB01"

 10  0D  FF 01 00 00 00 01 6c 45 32 45 00 02 05 00 00 00
 10  05  FE 54 65 73 74 00 00 00 00 00 00 00 00 00 00 00
 
 10  10  FD     01 4D 03     015C04       012D03     019E03   01 66 03
 
 10  0F  FC 00 01 0A 28 0A 29 0A 28 0A 2B 0A 2D 0A 2C 00
 10  0F  FC 00 02 0A 28 0A 29 0A 28 0A 2B 0A 2D 0A 2C 00
 10  0F  FC 00 03 0A 28 0A 29 0A 28 0A 2B 0A 2D 0A 2C 00
 10  0F  FC 00 04 0A 28 0A 29 0A 28 0A 2B 0A 2D 0A 2C 00
 10  0F  FC 00 05 0A 28 0A 29 0A 28 0A 2B 0A 2D 0A 2C 00
 10  0F  FC 00 06 0A 28 0A 29 0A 28 0A 2B 0A 2D 0A 2C 00
 10  0F  FC 00 07 0A 28 0A 29 0A 28 0A 2B 0A 2D 0A 2C 00
 10  0F  FC 00 08 0A 28 0A 29 0A 28 0A 2B 0A 2D 0A 2C 00
 10  0F  FC 00 09 0A 28 0A 29 0A 28 0A 2B 0A 2D 0A 2C 00
 10  0F  FC 00 0A 0A 28 0A 29 0A 28 0A 2B 0A 2D 0A 2C 00
 10  0F  FC 00 0B 0A 28 0A 29 0A 28 0A 2B 0A 2D 0A 2C 00
 10  0B  FC 00 0C 0A 28 0A 29 0A 28 0A 2B 00 00 00 00 00
 10 02  FB 01
 "
 
 
 00010201601a3bc4601a60fbffffff00
 00020102601a3bc4601a6156ffffff00
 */
    
   






