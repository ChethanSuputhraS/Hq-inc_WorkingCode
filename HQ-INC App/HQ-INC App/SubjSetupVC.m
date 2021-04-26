//
//  SubjSetupVC.m
//  HQ-INC App
//
//  Created by Ashwin on 3/25/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//
#import "PlayerSubjVC.h"
#import "SubjSetupVC.h"
#import "PlayerSubjVC.h"
#import "SubjectSetUpCELL.h"
#import "HomeVC.h"
#import "AddSensorVC.h"

@interface SubjSetupVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,UIScrollViewDelegate,UITextViewDelegate,UIPickerViewDelegate,UITableViewDelegate,UITableViewDataSource>

@end

@implementation SubjSetupVC  
@synthesize dataDict,isFromEdit;

UILabel * lblNote , * lblAddmonitorConnect,*lblNosensor;
NSString * strMsg;
bool isBtnSkinSelected;
bool isRemoveSnrSelect;
NSMutableArray *tmpArryMonitor,*arrPlayers,*tmpArrySensor;
NSInteger selectedIndex;

- (void)viewDidLoad
{
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = UIColor.blackColor;
    
    UIColor * lbltxtClor = [UIColor colorWithRed:180.0/255 green:245.0/255 blue:254.0/255 alpha:1];
    lblSubject = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, DEVICE_WIDTH, 40)];
    [self setLabelProperties:lblSubject withText:@"SUBJECT SETUP" backColor:UIColor.clearColor textColor:lbltxtClor textSize:25];
    [self.view addSubview:lblSubject];
      
    lbladdsetup = [[UILabel alloc]initWithFrame:CGRectMake(40, 60, DEVICE_WIDTH, 45)];
    [self setLabelProperties:lbladdsetup withText:@"Add Setup" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:30];
    lbladdsetup.font = [UIFont fontWithName:CGBold size:30];
    lbladdsetup.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:lbladdsetup];
    
    UIColor * btnBgClor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(100, DEVICE_HEIGHT-60, 150, 50)];
    [self setButtonProperties:btnCancel withTitle:@"Cancel" backColor:btnBgClor textColor:UIColor.whiteColor txtSize:25];
    btnCancel.layer.cornerRadius = 5;
    [btnCancel addTarget:self action:@selector(btnCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCancel];
        
    btnDone = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-250, DEVICE_HEIGHT-60, 150, 50)];
    [self setButtonProperties:btnDone withTitle:@"Done" backColor:btnBgClor textColor:UIColor.whiteColor txtSize:25];
    btnDone.layer.cornerRadius = 5;
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    btnDone.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    [btnDone addTarget:self action:@selector(btnDoneClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnDone];

    arrSensors = [[NSMutableArray alloc] init];
    arrPlayers = [[NSMutableArray alloc] init];
    NSString * sqlquery = [NSString stringWithFormat:@"select * from Subject_Table"];
    [[DataBaseManager dataBaseManager] execute:sqlquery resultsArray:arrPlayers];
    
//    if (isCClicked == YES)
//     {
//         txtIngesTmpHigh.text = [NSString stringWithFormat:@"%.02f",highIngstC];
//         txtlngeslowTmpAl.text = [NSString stringWithFormat:@"%.02f",lowIngestC];
//         txtDermalLowTmp.text = [NSString stringWithFormat:@"%.02f",highDermalC];
//         txtDemalTmpHigh.text = [NSString stringWithFormat:@"%.02f",lowDermalC];
//     }
//     else
//     {
//         txtIngesTmpHigh.text = [NSString stringWithFormat:@"%.02f",highIngstF];
//         txtlngeslowTmpAl.text = [NSString stringWithFormat:@"%.02f",lowIngestF];
//         txtDermalLowTmp.text = [NSString stringWithFormat:@"%.02f",lowDermalF];
//         txtDemalTmpHigh.text = [NSString stringWithFormat:@"%.02f",highDermalF];
//     }
    
    [self setupProfileImageView];
    [self setupforSensorView];
    [self setupAlarmView];
    [self fromDataDict];
    [self gettingImg];

    [super viewDidLoad];
    dict = [NSMutableDictionary dictionary];
    
    globalSubjectDetailVC = [[SubjDetailsVC alloc]init];
    tmpArrySensor = [[NSMutableArray alloc] init];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
#pragma mark - Setup for Profile Image View
-(void)setupProfileImageView
{
    double setupW = (320 * DEVICE_WIDTH)/ 768;
    addSetUpView = [[UIView alloc]init];
    addSetUpView.frame = CGRectMake(40, 100, setupW, (300 * setupW)/320);
    addSetUpView.layer.cornerRadius = 5;
    addSetUpView.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];
    [self.view addSubview:addSetUpView];
    
    double imgHeight = addSetUpView.frame.size.height-120;
    
    imgViewProPic = [[UIImageView alloc]init]; // UIImageView
    imgViewProPic.frame = CGRectMake((addSetUpView.frame.size.width - imgHeight)/2,20,imgHeight,imgHeight);
    imgViewProPic.backgroundColor = UIColor.whiteColor;
    imgViewProPic.userInteractionEnabled = YES;
    imgViewProPic.contentMode = UIViewContentModeScaleAspectFill;
    imgViewProPic.layer.masksToBounds = true;
//    imgViewProPic.contentMode = UIViewContentModeScaleAspectFit;

    [addSetUpView addSubview:imgViewProPic];
    
    btnCamera = [[UIButton alloc]init];
    btnCamera.frame = CGRectMake((imgViewProPic.frame.size.width-104)/2,(imgViewProPic.frame.size.height-104)/2,104,104);
    [btnCamera addTarget:self action:@selector(BtnCameraClick) forControlEvents:UIControlEventTouchUpInside];
    [imgViewProPic addSubview:btnCamera];
    
    if (dataDict.count == 0)
    {
        UIImage *btncmr = [UIImage imageNamed:@"camera.png"];
        [btnCamera setImage:btncmr forState:normal];
    }
    txtFullName = [[UITextField alloc]initWithFrame:CGRectMake(20, addSetUpView.frame.size.height - 70, addSetUpView.frame.size.width-130, 60)];
    [self setTextfieldProperties:txtFullName withPlaceHolderText:@"Full Name" withTextSize:30];
    txtFullName.returnKeyType = UIReturnKeyNext;
    [addSetUpView addSubview:txtFullName];

    txtHash = [[UITextField alloc]initWithFrame:CGRectMake(addSetUpView.frame.size.width-100, addSetUpView.frame.size.height - 70, 90, 60)];
    [self setTextfieldProperties:txtHash withPlaceHolderText:@"#" withTextSize:30];
    txtHash.layer.cornerRadius = 6;
    txtHash.keyboardType = UIKeyboardTypeNumberPad;
    txtHash.returnKeyType = UIReturnKeyNext;
    [addSetUpView addSubview:txtHash];
}
#pragma mark - Setup for for SensorView
-(void)setupforSensorView
{
    addSensorView = [[UIView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-addSetUpView.frame.size.width - 40 , 100, (addSetUpView.frame.size.width), 450)];
    addSensorView.frame = CGRectMake(DEVICE_WIDTH - addSetUpView.frame.size.width - 40 , 100, (addSetUpView.frame.size.width), 450);
    addSensorView.layer.cornerRadius = 6;
    addSensorView.layer.borderWidth = 2;
    addSensorView.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];
    [self.view addSubview:addSensorView];
        
    UIColor * typeColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];

    UILabel * lblAddmonitor = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, addSensorView.frame.size.width-40, 45)];
    [self setLabelProperties:lblAddmonitor withText:@"Add monitor" backColor:UIColor.clearColor textColor:UIColor.blackColor textSize:30];
    lblAddmonitor.textAlignment = NSTextAlignmentLeft;
    [addSensorView addSubview:lblAddmonitor];
    
    UIButton * btnAddMonitor = [[UIButton alloc]initWithFrame:CGRectMake(200, 5, 50, 45)];
    [btnAddMonitor setImage:[UIImage imageNamed:@"addBlack.png"] forState:normal];
    [btnAddMonitor addTarget:self action:@selector(btnMonitorClick) forControlEvents:UIControlEventTouchUpInside];
    btnAddMonitor.layer.cornerRadius = 25;
    btnAddMonitor.backgroundColor = UIColor.whiteColor;
    [addSensorView addSubview:btnAddMonitor];
    
    lblAddmonitorConnect = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, addSensorView.frame.size.width-40, 30)];
    [self setLabelProperties:lblAddmonitorConnect withText:@"Monitor not added" backColor:UIColor.clearColor textColor:UIColor.lightGrayColor textSize:20];
    lblAddmonitorConnect.textAlignment = NSTextAlignmentLeft;
    [addSensorView addSubview:lblAddmonitorConnect];

          int btnyy = 90;
    UIButton * btnAddSensor = [[UIButton alloc]initWithFrame:CGRectMake(200, btnyy, 50, 45)];
    [btnAddSensor setImage:[UIImage imageNamed:@"addBlack.png"] forState:normal];
    [btnAddSensor addTarget:self action:@selector(btnAddSensorClick) forControlEvents:UIControlEventTouchUpInside];
    btnAddSensor.layer.cornerRadius = 25;
    btnAddSensor.backgroundColor = UIColor.whiteColor;
    [addSensorView addSubview:btnAddSensor];

  
    UILabel * lblAddSensor = [[UILabel alloc]initWithFrame:CGRectMake(10, btnyy, addSensorView.frame.size.width-40, 45)];
    [self setLabelProperties:lblAddSensor withText:@"Add Sensor" backColor:UIColor.clearColor textColor:UIColor.blackColor textSize:30];
    lblAddSensor.textAlignment = NSTextAlignmentLeft;
    [addSensorView addSubview:lblAddSensor];
    
    lblNosensor = [[UILabel alloc]initWithFrame:CGRectMake(10, btnyy+45, addSensorView.frame.size.width-40, 30)];
    [self setLabelProperties:lblNosensor withText:@"Sensor not added" backColor:UIColor.clearColor textColor:UIColor.lightGrayColor textSize:20];
    lblNosensor.textAlignment = NSTextAlignmentLeft;
    [addSensorView addSubview:lblNosensor];
    
    btnyy = btnyy +100;
    UIButton * btnViewAllSnr = [[UIButton alloc]initWithFrame:CGRectMake(10, btnyy, addSensorView.frame.size.width-20 , 60)];
    [self setButtonProperties:btnViewAllSnr withTitle:@"View sensors" backColor:typeColor textColor:UIColor.whiteColor txtSize:20];
    [btnViewAllSnr addTarget:self action:@selector(btnViewAlSnrClick) forControlEvents:UIControlEventTouchUpInside];
    btnViewAllSnr.layer.cornerRadius = 5;
    btnViewAllSnr.titleLabel.numberOfLines = 2;
    [addSensorView addSubview:btnViewAllSnr];
    
    UIButton * btnRemoveSensors = [[UIButton alloc]initWithFrame:CGRectMake(10 , btnyy+80, addSensorView.frame.size.width-20, 60)];
    [self setButtonProperties:btnRemoveSensors withTitle:@"Remove sensors" backColor:typeColor textColor:UIColor.whiteColor txtSize:20];
    [btnRemoveSensors addTarget:self action:@selector(btnRemoveSnrClick) forControlEvents:UIControlEventTouchUpInside];
    btnRemoveSensors.layer.cornerRadius = 5;
    btnRemoveSensors.titleLabel.numberOfLines = 2;
    [addSensorView addSubview:btnRemoveSensors];

    
    UILabel *lblSensorCheck = [[UILabel alloc]init];
    lblSensorCheck.frame = CGRectMake(15, btnyy+170, addSensorView.frame.size.width-100, 50);
    [self setLabelProperties:lblSensorCheck withText:@"Sensor Check" backColor:UIColor.clearColor textColor:UIColor.blackColor textSize:25];
    lblSensorCheck.textAlignment = NSTextAlignmentLeft;
    lblSensorCheck.font  = [UIFont boldSystemFontOfSize:25];
    [addSensorView addSubview:lblSensorCheck];
    
    UIColor * btOkBGC = [UIColor colorWithRed:27.0/255 green:157.0/255 blue:25.0/255 alpha:1];
    UIButton *  btnOk = [[UIButton alloc]initWithFrame:CGRectMake(190, btnyy+170, 50, 50)];
    [self setButtonProperties:btnOk withTitle:@"OK" backColor:btOkBGC textColor:UIColor.whiteColor txtSize:20];
    btnOk.layer.cornerRadius = 25;
    [addSensorView addSubview:btnOk];
    
    lblType1 = [[UILabel alloc]initWithFrame:CGRectMake(10, btnyy, 150, 45)];
    [self setLabelProperties:lblType1 withText:@"--NA--" backColor:typeColor textColor:UIColor.whiteColor textSize:20];
//    [addSensorView addSubview:lblType1];
        
    lblNameNo1 = [[UILabel alloc]initWithFrame:CGRectMake(170, btnyy, addSensorView.frame.size.width-180, 45)];
    [self setLabelProperties:lblNameNo1 withText:@"Name / Number" backColor:UIColor.whiteColor textColor:UIColor.blackColor textSize:18];
//    [addSensorView addSubview:lblNameNo1];
        
    lblType2 = [[UILabel alloc]initWithFrame:CGRectMake(10, btnyy+50, 150, 45)];
    [self setLabelProperties:lblType2 withText:@"--NA--" backColor:typeColor textColor:UIColor.whiteColor textSize:20];
//    [addSensorView addSubview:lblType2];
            
    lblNameNo2 = [[UILabel alloc]initWithFrame:CGRectMake(170, btnyy+50, addSensorView.frame.size.width-180, 45)];
    [self setLabelProperties:lblNameNo2 withText:@"Name / Number" backColor:UIColor.whiteColor textColor:UIColor.blackColor textSize:18];
//    [addSensorView addSubview:lblNameNo2];
        

            
    UILabel *lblLineSep =[[UILabel alloc] init];
    lblLineSep.frame= CGRectMake(15, btnyy+260, addSensorView.frame.size.width-30, 2);
    lblLineSep.layer.borderWidth = 2;
    lblLineSep.layer.borderColor = UIColor.lightGrayColor.CGColor;
//    [addSensorView addSubview:lblLineSep];
        
    UILabel *lblAddMonitor = [[UILabel alloc]init];
    lblAddMonitor.frame = CGRectMake(15, btnyy+270, 175, 44);
    lblAddMonitor.text = @"Add Monitor";
    lblAddMonitor.font  = [UIFont boldSystemFontOfSize:20];
//    [addSensorView addSubview:lblAddMonitor];

}
#pragma mark - Setup Alarm View
-(void)setupAlarmView
{
    UILabel *lblIndividulsettng = [[UILabel alloc]initWithFrame:CGRectMake(40, addSensorView.frame.size.height+60, DEVICE_WIDTH, 50)];
    [self setLabelProperties:lblIndividulsettng withText:@"Individual Settings" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:30];
    lblIndividulsettng.textAlignment = NSTextAlignmentLeft;
    lblIndividulsettng.font = [UIFont fontWithName:CGBold size:30];
    [self.view addSubview:lblIndividulsettng];

    UIView*indiVisualView = [[UIView alloc] initWithFrame:CGRectMake(40, addSensorView.frame.size.height+105, DEVICE_WIDTH-80, DEVICE_HEIGHT-addSensorView.frame.size.height-180)];
    indiVisualView.backgroundColor = UIColor.blackColor;
    indiVisualView.clipsToBounds = true;
    indiVisualView.layer.cornerRadius = 6;
    [self.view addSubview:indiVisualView];
        
    addAlarmsView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH-80, indiVisualView.frame.size.height/1.6)];
    addAlarmsView.layer.cornerRadius = 6;
    addAlarmsView.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];
    [indiVisualView addSubview:addAlarmsView];
        
    lblAddAlarms = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, DEVICE_WIDTH, 50)];
    [self setLabelProperties:lblAddAlarms withText:@"Add Alarms" backColor:UIColor.clearColor textColor:UIColor.blackColor textSize:30];
    lblAddAlarms.textAlignment = NSTextAlignmentLeft;
    [addAlarmsView addSubview:lblAddAlarms];
          
    int y = 50;
    lblType2iblSenAlarm = [[UILabel alloc]initWithFrame:CGRectMake(20, y, DEVICE_WIDTH, 50)];
    [self setLabelProperties:lblType2iblSenAlarm withText:@"Ingestible Sensor Alarms" backColor:UIColor.clearColor textColor:UIColor.blackColor textSize:20.0];
    lblType2iblSenAlarm.textAlignment = NSTextAlignmentLeft;
    lblType2iblSenAlarm.font = [UIFont boldSystemFontOfSize:20.0];
    [addAlarmsView addSubview:lblType2iblSenAlarm];
        
    
    lblHighTempAlarm = [[UILabel alloc]initWithFrame:CGRectMake(20, y+40, 150, 55)];
    [self setLabelProperties:lblHighTempAlarm withText:@"High Temp Alarm" backColor:UIColor.clearColor textColor:UIColor.blackColor textSize:17];
    [addAlarmsView addSubview:lblHighTempAlarm];
         
    txtIngesTmpHigh = [[UITextField alloc]initWithFrame:CGRectMake(170, y+40, 100, 55)];
    [self setTextfieldProperties:txtIngesTmpHigh withPlaceHolderText:@" 100.0ºF" withTextSize:25.0];
    txtIngesTmpHigh.placeholder = @" 100.0ºF";
    txtIngesTmpHigh.keyboardType = UIKeyboardTypeNumberPad;
    txtIngesTmpHigh.returnKeyType = UIReturnKeyNext;
    [addAlarmsView addSubview:txtIngesTmpHigh];

    lblLowTempAlarm = [[UILabel alloc]initWithFrame:CGRectMake(addAlarmsView.frame.size.width-350, y+40, 200, 55)];
    [self setLabelProperties:lblLowTempAlarm withText:@"Low Temp Alarm" backColor:UIColor.clearColor textColor:UIColor.blackColor textSize:17];
    [addAlarmsView addSubview:lblLowTempAlarm];
         
    txtlngeslowTmpAl = [[UITextField alloc]initWithFrame:CGRectMake(addAlarmsView.frame.size.width-170, y+40, 100, 55)];
    [self setTextfieldProperties:txtlngeslowTmpAl withPlaceHolderText:@"94.0ºF" withTextSize:25.0];
    txtlngeslowTmpAl.keyboardType = UIKeyboardTypeNumberPad;
    txtlngeslowTmpAl.returnKeyType = UIReturnKeyNext;
    [addAlarmsView addSubview:txtlngeslowTmpAl];
         
    //1 Dermal
    
    int yy = addAlarmsView.frame.size.height-110 ;
    lblDermalSensorAlram = [[UILabel alloc]initWithFrame:CGRectMake(20, yy+10, DEVICE_WIDTH, 30)];
    [self setLabelProperties:lblDermalSensorAlram withText:@"Dermal Sensor Alarms" backColor:UIColor.clearColor textColor:UIColor.blackColor textSize:20.0];
    lblDermalSensorAlram.textAlignment = NSTextAlignmentLeft;
    lblDermalSensorAlram.font = [UIFont boldSystemFontOfSize:20.0];
    [addAlarmsView addSubview:lblDermalSensorAlram];
        
    UILabel * lblHighTempAlarm1;
    lblHighTempAlarm1 = [[UILabel alloc]initWithFrame:CGRectMake(20, yy+45, 150, 55)];
    [self setLabelProperties:lblHighTempAlarm1 withText:@"High Temp Alarm" backColor:UIColor.clearColor textColor:UIColor.blackColor textSize:17];
    [addAlarmsView addSubview:lblHighTempAlarm1];
        
    txtDemalTmpHigh = [[UITextField alloc]initWithFrame:CGRectMake(170, yy+45, 100, 55)];
    [self setTextfieldProperties:txtDemalTmpHigh withPlaceHolderText:@" 100.0ºF" withTextSize:25.0];
//    txtDemalTmpHigh.placeholder = @" 102.0ºF";
    txtDemalTmpHigh.keyboardType = UIKeyboardTypeNumberPad;
    txtDemalTmpHigh.returnKeyType = UIReturnKeyNext;
    [addAlarmsView addSubview:txtDemalTmpHigh];

    UILabel * lblLowTempAlarm1 = [[UILabel alloc]initWithFrame:CGRectMake(addAlarmsView.frame.size.width-350, yy+45, 200, 55)];
    [self setLabelProperties:lblLowTempAlarm1 withText:@"Low Temp Alarm" backColor:UIColor.clearColor textColor:UIColor.blackColor textSize:17];
    [addAlarmsView addSubview:lblLowTempAlarm1];
         
    txtDermalLowTmp = [[UITextField alloc]initWithFrame:CGRectMake(addAlarmsView.frame.size.width-170, yy+45, 100, 55)];
    [self setTextfieldProperties:txtDermalLowTmp withPlaceHolderText:@" 94.0ºF" withTextSize:25.0];
//    txtDermalLowTmp.placeholder = @" 92.0ºF";
    txtDermalLowTmp.keyboardType = UIKeyboardTypeNumberPad;
    txtDermalLowTmp.returnKeyType = UIReturnKeyNext;
    [addAlarmsView addSubview:txtDermalLowTmp];

    lblNote = [[UILabel alloc]initWithFrame:CGRectMake(10, indiVisualView.frame.size.height/1.5, DEVICE_WIDTH, 35)];
    [self setLabelProperties:lblNote withText:@"Notes" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:30];
    lblNote.textAlignment = NSTextAlignmentLeft;
    lblNote.font = [UIFont fontWithName:CGBold size:30];
    [indiVisualView addSubview:lblNote];
        
    txtViewNote = [[UITextView alloc]initWithFrame:CGRectMake(0, indiVisualView.frame.size.height/1.5+35, indiVisualView.frame.size.width, indiVisualView.frame.size.height)];
    txtViewNote.clipsToBounds = true;
    txtViewNote.layer.cornerRadius = 6;
    txtViewNote.font = [UIFont fontWithName:CGRegular size:26.0];
    txtViewNote.textColor = [UIColor blackColor];
    txtViewNote.delegate = self;
    txtViewNote.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];
    [indiVisualView addSubview:txtViewNote];
    
   NSMutableArray * arrAlarm = [[NSMutableArray alloc] init];
    NSString * sqlquery = [NSString stringWithFormat:@"select * from Alarm_Table"];
    [[DataBaseManager dataBaseManager] execute:sqlquery resultsArray:arrAlarm];
    
    if ([arrAlarm objectAtIndex:selectedIndex])
    {
        if ([[[arrAlarm objectAtIndex:selectedIndex] valueForKey:@"celciusSelect"] isEqual:@"1"])
        {
            [self setTextfieldProperties:txtIngesTmpHigh withPlaceHolderText:@" 36.0ºC" withTextSize:25.0];
            [self setTextfieldProperties:txtlngeslowTmpAl withPlaceHolderText:@"32.0ºC" withTextSize:25.0];
            [self setTextfieldProperties:txtDermalLowTmp withPlaceHolderText:@" 32.0ºC" withTextSize:25.0];
            [self setTextfieldProperties:txtDemalTmpHigh withPlaceHolderText:@" 36.0ºC" withTextSize:25.0];
        }
    }
}
#pragma mark - Buttons
-(void)BtnCameraClick
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"HQ-INC-App" message:@""
     preferredStyle:UIAlertControllerStyleAlert];

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:nil];

        }];
        UIAlertAction* defau = [UIAlertAction actionWithTitle:@"Photo Album" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            self->pickerImg = [[UIImagePickerController alloc]init];
            self-> pickerImg.delegate = self;
            self-> pickerImg.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            [self presentViewController:self->pickerImg animated:true completion:nil];
        }];
        [alert addAction:defaultAction];
        [alert addAction:defau];
    }
    
    UIAlertAction* defaultAc = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAc];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<UIImagePickerControllerInfoKey, id> *)editingInfo API_DEPRECATED("", ios(2.0, 3.0));
{
    if (image.size.width > 1000 || image.size.height > 1000)
    {
        image = [self scaleMyImage:image withNewWidth:1000 newHeight:1000];
    }
    isImageEdited = YES;
    imgViewProPic.image = image;
    imgViewProPic.image = [self scaleMyImage:image withNewWidth:300 newHeight:300];
    imgViewProPic.contentMode = UIViewContentModeScaleAspectFill;
    imgViewProPic.layer.masksToBounds = true;
    [btnCamera setImage:[UIImage imageNamed:@" "] forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
}
-(NSString *)saveImagetoDocumentDirectoryIsforthumbNail:(BOOL)isThumbNail
{
    NSString * imageName;
    // to give unique name based on time stamp
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSNumber *timeStampObj = [NSNumber numberWithInteger: timeStamp];
    
    //taking random no and assigning to make it more unique
    int randomID = arc4random() % 9000 + 1000;
    imageName = [NSString stringWithFormat:@"/player-%@-%d%@.jpg", CURRENT_USER_ID,randomID,timeStampObj];
    imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString * stringPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"PlayerPhoto"]; // New Folder is your folder name
    NSError *error = nil;
    UIImage * givenImg = imgViewProPic.image;
    if (isThumbNail)
    {
        givenImg = [self scaleMyImage:givenImg withNewWidth:250 newHeight:250];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:stringPath])        [[NSFileManager defaultManager] createDirectoryAtPath:stringPath withIntermediateDirectories:NO attributes:nil error:&error];
    NSString *fileName = [stringPath stringByAppendingString:imageName];
    NSData *data = UIImageJPEGRepresentation(givenImg, 0.2);
    [data writeToFile:fileName atomically:YES];
    
    return imageName;
}
-(void)btnCancelClick
{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)btnDoneClick
{
     BOOL isValidEntrys = NO;
//    if  (imgViewProPic.image == nil)
//    {
//        strMsg = @"Please add player image";
//    }
//    else
    if ([txtFullName.text  isEqual: @""])
     {
        strMsg = @"Enter Full Name";
     }
    else if ([txtHash.text isEqual:@""])
    {
        strMsg = @"Enter  Number";
    }
    else if ([txtIngesTmpHigh.text isEqual:@""])
    {
        strMsg = @"Enter Ingestible sensor alarm";
    }
    else if ([txtlngeslowTmpAl.text isEqual:@""])
    {
        strMsg = @"Enter Ingestible sensor alarm";
    }
    else if ([txtDemalTmpHigh.text isEqual:@""])
    {
         strMsg = @"Enter Dermal sensor alarm";
    }
    else if ([txtDermalLowTmp.text isEqual:@""])
    {
        strMsg = @"Enter Ingestible sensor alarm";
    }
    else
    {
        int higIngest;
        int lowIngest;
        int HighDermal;
        int lowDermal;
        higIngest = txtIngesTmpHigh.text.intValue;
        lowIngest = txtlngeslowTmpAl.text.intValue;
        HighDermal = txtDemalTmpHigh.text.intValue;
        lowDermal = txtDermalLowTmp.text.intValue;

//        if(higIngest > 100.4)
//        {
//            strMsg = @"Entered wrong Ingest High Tmp";
//        }
//        else if (lowIngest > 100.4)
//        {
//            strMsg = @"Entered wrong Ingest low Tmp";
//        }
//        else if (HighDermal > 100.4)
//        {
//            strMsg = @"Entered wrong Deraml High Tmp";
//        }
//        else if (lowDermal > 100.4)
//        {
//            strMsg = @"Entered wrong Deraml low Tmp";
//        }
//        else if (higIngest < 94)
//        {
//            strMsg = @"High Ingest enter valid Temp.";
//        }
//        else if (lowIngest < 94)
//        {
//            strMsg = @"Low Ingest enter valid Temp.";
//        }
//        else if (HighDermal < 94)
//        {
//            strMsg = @"High Dermal enter valid Temp.";
//        }
//        else if (lowDermal < 94)
//        {
//            strMsg = @"Low Dermal enter valid Temp.";
//        }
        
        if([self isNumberUnique:txtHash.text] == NO)
        {
            strMsg =@"Player number alredy exits. Please enter diffrent number.";
        }
       else
       {
           isValidEntrys = YES;
           NSString * strImagePath = @"NA";
           NSString * strThumbNail = @"NA";
           if (imgViewProPic.image != nil)
           {
               strImagePath =  [self saveImagetoDocumentDirectoryIsforthumbNail:NO];
               strThumbNail = [self saveImagetoDocumentDirectoryIsforthumbNail:YES];
           }
           else
           {
               strImagePath =  @"nil";
               strThumbNail = @"nil";
           }
           NSString * strName = [APP_DELEGATE checkforValidString:txtFullName.text];
           NSString * strNum = [APP_DELEGATE checkforValidString:txtHash.text];
           NSString * strIngHigh = [APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%f",highIngstF]];
           NSString * strIngLow = [APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%f",lowIngestF]];
           NSString * strDrmlLow = [APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%f",highDermalF]];
           NSString * strDrmlHigh = [APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%f",lowDermalF]];
           NSString * strNotes = [APP_DELEGATE checkforValidString:txtViewNote.text];
           NSString * strIngstHighC = [APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%f",highIngstC]]; // text field entry or else calulation for c and insert to the data base.
           NSString * strIngstLowC = [APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%f",lowIngestC]];
           NSString * strDermlHighC = [APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%f",highDermalC]];
           NSString * strDermlLowC = [APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%f",lowDermalC]];
           NSString * strUserId = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
           NSString * requestStr1 = @"NA";
           if (isFromEdit == YES)
           {
               strImagePath = [dataDict valueForKey:@"photo_URL"];
               strThumbNail = [dataDict valueForKey:@"photo_URLThumbNail"];
               if (isImageEdited)
               {
                   if (imgViewProPic.image != nil)
                   {
                       strImagePath =  [self saveImagetoDocumentDirectoryIsforthumbNail:NO];
                       strThumbNail = [self saveImagetoDocumentDirectoryIsforthumbNail:YES];
                   }
                   else
                   {
                       strImagePath =  @"nil";
                       strThumbNail = @"nil";
                   }
               }
               requestStr1 =  [NSString stringWithFormat:@"update Subject_Table set name = \"%@\", number = \"%@\", photo_URl = \"%@\", photo_URLThumbNail = \"%@\", ing_highF = \"%@\", ing_lowF = \"%@\", drml_highF = \"%@\", drml_lowF = \"%@\", ing_highC = \"%@\", ing_lowC = \"%@\", drml_highC = \"%@\", drml_lowC = \"%@\", notes = '%@' where id =\"%@\"",strName,strNum,strImagePath,strThumbNail,strIngHigh,strIngLow,strDrmlHigh,strDrmlLow,strIngstHighC,strIngstLowC,strDermlHighC,strDermlLowC,strNotes,[dataDict valueForKey:@"id"]];
           }
           else
           {
               requestStr1 =  [NSString stringWithFormat:@"insert into 'Subject_Table'('name','number','photo_URL','photo_URLThumbNail','ing_highF','ing_lowF','drml_highF','drml_lowF','ing_highC','ing_lowC','drml_highC','drml_lowC','notes', 'user_id') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\", \"%@\")",strName,strNum,strImagePath,strThumbNail,strIngLow,strIngHigh,strDrmlLow,strDrmlHigh,strIngstHighC,strIngstLowC,strDermlHighC,strDermlLowC,strNotes, strUserId];
           }
           
           [[DataBaseManager dataBaseManager] executeSw:requestStr1];
           [self.navigationController popViewControllerAnimated:YES];
       }
    }
    if (isValidEntrys == NO)
    {
        [self AlertViewFCTypeCautionCheck];
    }
    
    if (globalSubjectDetailVC)
    {
        if ([tmpArrySensor count] > 0)
        {
            [globalSubjectDetailVC ReceiveSensorDetails:tmpArrySensor];
        }
    }
}
-(BOOL)isNumberUnique:(NSString *)strCurrentNumber
{
    NSString * strQuery = [NSString stringWithFormat:@"select * from Subject_Table where number = '%@' and id != '%@'",strCurrentNumber, [dataDict valueForKey:@"id"]];
    NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:tmpArr];
    if ([tmpArr count]==0)
    {
        return YES;
    }
    else
    {
        return NO;;
    }
}
-(void)btnAddSensorClick
{
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        globalAddSensor = [[AddSensorVC alloc] init];
        [self.navigationController pushViewController:globalAddSensor animated:true];
    }
    else
    {
        [self AlertViewFCTypeCaution:@"Please make sure Monitor is connected with App and then try again to Add Sensors."];
    }
}
-(void)btnViewAlSnrClick
{
    if (tmpArrySensor.count == 0)
    {
        [self AlertViewFCTypeCaution:@"Sensor not added."];
    }
    else
    {
        isRemoveSnrSelect = NO;
        [self setupForViewAllSensors];
    }
}
-(void)btnMonitorClick
{
    HomeVC *hvn = [[HomeVC alloc] init];
    [self.navigationController pushViewController:hvn animated:true];
    
     [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"isMonitorSelect"];
     [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark- Textview method
- (void)textViewDidBeginEditing:(UITextView *)textView
{
 self.view.frame = CGRectMake(0, -275, DEVICE_WIDTH, DEVICE_HEIGHT);
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.view.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
}
#pragma mark-TextField method
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtFullName)
     {
         [txtFullName resignFirstResponder];
         [txtHash becomeFirstResponder];
     }
     else  if (textField == txtHash)
     {
         int txtNo = [txtHash.text intValue];
         txtHash.text = [NSString stringWithFormat:@"%d",txtNo];
         [txtHash resignFirstResponder];
         [txtIngesTmpHigh becomeFirstResponder];
     }
     else if (textField == txtIngesTmpHigh)
     {
         [txtIngesTmpHigh resignFirstResponder];
         [txtlngeslowTmpAl becomeFirstResponder];
     }
     else if (textField == txtlngeslowTmpAl)
     {
         [txtlngeslowTmpAl resignFirstResponder];
         [txtDemalTmpHigh becomeFirstResponder];
     }
    else if (textField == txtlngeslowTmpAl)
    {
        [txtlngeslowTmpAl resignFirstResponder];
        [txtDemalTmpHigh becomeFirstResponder];
    }
    else if (textField == txtDemalTmpHigh)
    {
        [txtDemalTmpHigh resignFirstResponder];
        [txtDermalLowTmp becomeFirstResponder];
    }
    else if (textField == txtDermalLowTmp)
    {
        [txtDermalLowTmp resignFirstResponder];
        [txtViewNote becomeFirstResponder];
        [txtViewNote resignFirstResponder];
    }
    else if (textField == txtNameSnr)
    {
        [txtNameSnr resignFirstResponder];
        [txtNumberSnr becomeFirstResponder];
    }
    else if (textField == txtNumberSnr)
    {
        [txtNumberSnr resignFirstResponder];
    }
    return true;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == txtIngesTmpHigh)
    {
      self.view.frame = CGRectMake(0, -250, DEVICE_WIDTH, DEVICE_HEIGHT);
    }
    if (textField == txtlngeslowTmpAl)
    {
      self.view.frame = CGRectMake(0, -250, DEVICE_WIDTH, DEVICE_HEIGHT);
    }
    if (textField == txtDemalTmpHigh)
    {
      self.view.frame = CGRectMake(0, -250, DEVICE_WIDTH, DEVICE_HEIGHT);
    }
    if (textField == txtDermalLowTmp)
    {
      self.view.frame = CGRectMake(0, -250, DEVICE_WIDTH, DEVICE_HEIGHT);
    }
     if (textField == txtNameSnr || txtNumberSnr)
    {
        self.view.frame = CGRectMake(0, -60, DEVICE_WIDTH, DEVICE_HEIGHT);
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == txtHash)
    {
        int txtNo = [txtHash.text intValue];
        txtHash.text = [NSString stringWithFormat:@"%d",txtNo];
    }
    self.view.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    
    if ([[APP_DELEGATE checkforValidString:textField.text] isEqualToString:@"NA"])
    {
        strMsg = @"Please Enter values";
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
            NSMutableArray * arrAlarm = [[NSMutableArray alloc] init];
             NSString * sqlquery = [NSString stringWithFormat:@"select * from Alarm_Table"];
             [[DataBaseManager dataBaseManager] execute:sqlquery resultsArray:arrAlarm];
             
             if (arrAlarm.count > 0)
             {
                 if ([[[arrAlarm objectAtIndex:0] valueForKey:@"celciusSelect"] isEqual:@"1"])
                 {
                     if (textField == txtIngesTmpHigh)
                     {
                         highIngstF = [[arrVal objectAtIndex:0] floatValue];
                         highIngstC = [[arrVal objectAtIndex:1] floatValue];
                         txtIngesTmpHigh.text = [NSString stringWithFormat:@"%.f ºC",highIngstF];
                     }
                     else  if (textField == txtlngeslowTmpAl)
                     {
                         lowIngestF = [[arrVal objectAtIndex:0] floatValue];
                         lowIngestC = [[arrVal objectAtIndex:1] floatValue];
                         txtlngeslowTmpAl.text = [NSString stringWithFormat:@"%.f ºC",lowIngestF];
                     }
                     else  if (textField == txtDemalTmpHigh)
                     {
                         highDermalF = [[arrVal objectAtIndex:0] floatValue];
                         highDermalC = [[arrVal objectAtIndex:1] floatValue];
                         txtDemalTmpHigh.text = [NSString stringWithFormat:@"%.f ºC",highDermalF];
                     }
                     else  if (textField == txtDermalLowTmp)
                     {
                         lowDermalF = [[arrVal objectAtIndex:0] floatValue];
                         lowDermalC = [[arrVal objectAtIndex:1] floatValue];
                         txtDermalLowTmp.text = [NSString stringWithFormat:@"%.f ºC",lowDermalF];
                     }
                 }
             }
            
            
                if (textField == txtIngesTmpHigh)
                {
                    highIngstF = [[arrVal objectAtIndex:0] floatValue];
                    highIngstC = [[arrVal objectAtIndex:1] floatValue];
                    txtIngesTmpHigh.text = [NSString stringWithFormat:@"%.f ºF",highIngstF];
                }
                else  if (textField == txtlngeslowTmpAl)
                {
                    lowIngestF = [[arrVal objectAtIndex:0] floatValue];
                    lowIngestC = [[arrVal objectAtIndex:1] floatValue];
                    txtlngeslowTmpAl.text = [NSString stringWithFormat:@"%.f ºF",lowIngestF];
                }
                else  if (textField == txtDemalTmpHigh)
                {
                    highDermalF = [[arrVal objectAtIndex:0] floatValue];
                    highDermalC = [[arrVal objectAtIndex:1] floatValue];
                    txtDemalTmpHigh.text = [NSString stringWithFormat:@"%.f ºF",highDermalF];
                }
                else  if (textField == txtDermalLowTmp)
                {
                    lowDermalF = [[arrVal objectAtIndex:0] floatValue];
                    lowDermalC = [[arrVal objectAtIndex:1] floatValue];
                    txtDermalLowTmp.text = [NSString stringWithFormat:@"%.f ºF",lowDermalF];
                }
            
        }
     }
   }
}
-(BOOL)ChecktemperatureValues:(float)valC withfernhite:(float)valF  withTextfield:(UITextField *)txtfld
{
    BOOL isValidValue = YES;
    NSString * strErrMsg = @"NA";
    if(isCClicked == YES)
    {
        if(valC > 38.1)
        {
            isValidValue = NO;
            strErrMsg = @"Maximum value Exceed for temperature in ºC";
        }
        else if (valC < 36.1)
        {
            isValidValue = NO;
            strErrMsg = @"Temperature can't be less than 36.1 ºC";
        }
    }
    else
    {
        if(valF > 100.5)
        {
            isValidValue = NO;
            strErrMsg = @"Maximum value Exceed for temperature in ºF";
        }
        else if (valF < 97)
        {
            isValidValue = NO;
            strErrMsg = @"Temperature can't be less than 97 ºF";
        }
        isValidValue = YES;
    }
    if (isValidValue == NO)
    {
         strErrMsg = @"Temperature can't be less than 97 ºF";
        [self AlertViewFCTypeCaution:strErrMsg];

    }
    return isValidValue;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!string.length)
        return YES;

    if (textField == txtHash || textField == txtNumberSnr)
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString options:0 range:NSMakeRange(0, [newString length])];
        if (numberOfMatches == 0)
            return NO;
    }
   else if (textField == txtIngesTmpHigh || textField == txtlngeslowTmpAl || textField == txtDemalTmpHigh || textField == txtDermalLowTmp)
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
        options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString options:0 range:NSMakeRange(0, [newString length] )];
        if (numberOfMatches == 0)
                return NO;
        }
    //   in tis formate  100.00˚F
    NSUInteger decimalPlacesLimit = 2;
    NSRange rangeDot = [textField.text rangeOfString:@"." options:NSCaseInsensitiveSearch];
    NSRange rangeComma = [textField.text rangeOfString:@"," options:NSCaseInsensitiveSearch];
    if (rangeDot.length > 0 || rangeComma.length > 0){
        if([string isEqualToString:@"."]) {
            NSLog(@"textField already contains a separator");
            return NO;
        }
        else
        {
            NSArray *explodedString = [textField.text componentsSeparatedByString:@"."];
            NSString *decimalPart = explodedString[1];
            if (decimalPart.length >= decimalPlacesLimit && ![string isEqualToString:@""]) {
                NSLog(@"textField already contains %lu decimal places", (unsigned long)decimalPlacesLimit);
                return NO;
            }
        }
    }
    return YES;
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
-(void)showAlertForEmptyTextField:(UITextField *)txtfild
{
    if(txtfild == txtIngesTmpHigh)
        {
            strMsg = @"Please enater High Ingest value.";
        }
        else if (txtfild == txtlngeslowTmpAl)
        {
            strMsg = @"Please enter Low Ingest Vlaue.";
        }
        else if (txtfild == txtDemalTmpHigh)
        {
            strMsg = @"Please enter High Dermal value.";
        }
        else if (txtfild == txtDermalLowTmp)
        {
            strMsg = @"Please enter Low Dermal value.";
        }
        else if (txtfild == txtHash)
        {
        strMsg = @"Please enter number.";
        }
        else if (txtfild == txtFullName)
        {
        strMsg = @"Pleasse enter name.";
        }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.view.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    [self.view endEditing:YES];
}
#pragma mark- Add Sensor Setup
-(void)setupForAddSensor
{
    viewForAddSensor = [[UIView alloc]init];
    viewForAddSensor.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    viewForAddSensor.backgroundColor = [UIColor colorWithRed:0 green:(CGFloat)0 blue:0 alpha:0.8];
    [self.view addSubview:viewForAddSensor];
    
    viewForSensorNameNum = [[UIView alloc]init];
    viewForSensorNameNum.frame = CGRectMake(150, (DEVICE_HEIGHT), DEVICE_WIDTH-300, 500);
    viewForSensorNameNum.backgroundColor = UIColor.whiteColor;
    viewForSensorNameNum.layer.cornerRadius = 6;
    viewForSensorNameNum.clipsToBounds = true;
    [viewForAddSensor addSubview:viewForSensorNameNum];
    
    UIView *bgView = [[UIView alloc]init];
    bgView.frame = CGRectMake(0, 0, viewForSensorNameNum.frame.size.width, 70);
    bgView.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    [viewForSensorNameNum addSubview:bgView];
    
    btnCancelSnr = [[UIButton alloc]init];
    btnCancelSnr.frame = CGRectMake(10, 0, 100, 70);
    [btnCancelSnr addTarget:self action:@selector(btnCancelSnrClick) forControlEvents:UIControlEventTouchUpInside];
    [btnCancelSnr setTitle:@"Cancel" forState:normal];
    [btnCancelSnr setTitleColor:UIColor.whiteColor forState:normal];
    btnCancelSnr.backgroundColor = UIColor.clearColor;
    btnCancelSnr.titleLabel.font = [UIFont fontWithName:CGRegular size:28];
    [bgView addSubview:btnCancelSnr];
           
    btnSave = [[UIButton alloc]init];
    btnSave.frame = CGRectMake(viewForSensorNameNum.frame.size.width-100, 0, 100, 70);
    [btnSave addTarget:self action:@selector(btnSaveClick) forControlEvents:UIControlEventTouchUpInside];
    [btnSave setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnSave.backgroundColor = UIColor.clearColor;
    [btnSave setTitle:@"Save" forState:normal];
    //       [btnDone setTitleColor:UIColor.blueColor forState:normal];
    btnSave.titleLabel.font = [UIFont fontWithName:CGRegular size:28];
    [bgView addSubview:btnSave];
    
    int yy = 80;
    UILabel * lblAddSnr = [[UILabel alloc]init];
    lblAddSnr.frame = CGRectMake(0, yy, viewForSensorNameNum.frame.size.width, 50);
    lblAddSnr.text = @"Add Sensor";
    lblAddSnr.textAlignment = NSTextAlignmentCenter;
    lblAddSnr.font = [UIFont fontWithName:CGRegular size:28];
    [viewForSensorNameNum addSubview:lblAddSnr];
    
    yy = yy + 80;
    txtNameSnr = [[UITextField alloc]initWithFrame:CGRectMake(40, yy, viewForSensorNameNum.frame.size.width-80, 70)];
    [self setTextfieldProperties:txtNameSnr withPlaceHolderText:@"Sensor Name" withTextSize:30];
    txtNameSnr.layer.cornerRadius = 6;
    txtNameSnr.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];
    txtNameSnr.textAlignment = NSTextAlignmentLeft;
    txtNameSnr.returnKeyType = UIReturnKeyNext;
    [viewForSensorNameNum addSubview:txtNameSnr];
    
    yy = yy + 90;
    txtNumberSnr  = [[UITextField alloc] initWithFrame:CGRectMake(40, yy, viewForSensorNameNum.frame.size.width-80, 70)];
    [self setTextfieldProperties:txtNumberSnr withPlaceHolderText:@"Senesor Number" withTextSize:30];
    txtNumberSnr.layer.cornerRadius = 6;
    txtNumberSnr.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];
    txtNumberSnr.keyboardType = UIKeyboardTypeNumberPad;
    txtNumberSnr.textAlignment = NSTextAlignmentLeft;
    txtNumberSnr.returnKeyType = UIReturnKeyDone;
    [viewForSensorNameNum addSubview:txtNumberSnr];
    
    yy = yy + 100;
    btnSkinAddSnr = [[UIButton alloc]initWithFrame:CGRectMake(40, yy, (viewForSensorNameNum.frame.size.width-50)/2-5, 55)];
    
    UIColor * btnSkinINgBGC = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    [self setButtonProperties:btnSkinAddSnr withTitle:@"Skin" backColor:btnSkinINgBGC textColor:UIColor.whiteColor txtSize:25];
    [btnSkinAddSnr addTarget:self action:@selector(btnSKinAddSnrClick:) forControlEvents:UIControlEventTouchUpInside];
    btnSkinAddSnr.layer.borderWidth = 1;
    [viewForSensorNameNum addSubview:btnSkinAddSnr];
    
    btnIngsetAddSnr = [[UIButton alloc]initWithFrame:CGRectMake((viewForSensorNameNum.frame.size.width-50)/2+30, yy, (viewForSensorNameNum.frame.size.width-50)/2-20, 55)];
    [self setButtonProperties:btnIngsetAddSnr withTitle:@"Ingestible" backColor:UIColor.whiteColor textColor:btnSkinINgBGC txtSize:25];
    [btnIngsetAddSnr addTarget:self action:@selector(btnIngestAddSnrClick) forControlEvents:UIControlEventTouchUpInside];
    btnIngsetAddSnr.layer.borderWidth = 1;
    [viewForSensorNameNum addSubview:btnIngsetAddSnr];

    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        self->viewForSensorNameNum.frame = CGRectMake(150, (DEVICE_HEIGHT/2)-200, DEVICE_WIDTH-300, 450);
    }
        completion:NULL];
    }
-(void)btnSaveClick
{
    if ([txtNameSnr.text isEqual:@""])
    {
        strMsg = @"Please enter sensor Name";
        [self AlertViewFCTypeCautionCheck];
    }
    else if ([txtNumberSnr.text isEqual:@""])
    {
        strMsg = @"Please enter sensor Number";
        [self AlertViewFCTypeCautionCheck];
    }
    else
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setObject:txtNameSnr.text forKey:@"name"];
        [dict setObject:txtNumberSnr.text forKey:@"number"];
        if (isBtnSkinSelected == YES)
        {
            [dict setObject:@"Skin" forKey:@"type"];
        }
        else
        {
            [dict setObject:@"Ingestible" forKey:@"type"];
        }
        [dict setObject:@"0" forKey:@"isSelected"];
        [tmpArrySensor addObject:dict];
//        [self UpdateSensorsLabels];
        
       // inserting data

       /* NSString * strbleaddress = [APP_DELEGATE checkforValidString:[dict valueForKey:@"--NA--"]];
        NSString * strName = [APP_DELEGATE checkforValidString:[dict valueForKey:@"name"]];
        NSString * strNumber = [APP_DELEGATE checkforValidString:[dict valueForKey:@"number"]];
        NSString * strIsActive = [APP_DELEGATE checkforValidString:[dict valueForKey:@"--NA--"]];
        NSString * strMonitorId = [APP_DELEGATE checkforValidString:[dict valueForKey:@"--NA--"]];
        NSString * strSubID = [APP_DELEGATE checkforValidString:[dict valueForKey:@"--NA--"]];
        NSString * strType = [APP_DELEGATE checkforValidString:[dict valueForKey:@"type"]];

        NSString * requestStr =  [NSString stringWithFormat:@"insert into 'Sensor_Table'('ble_address','name','number','is_active','monitor_id','subject_id','type') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",strbleaddress,strName,strNumber,strIsActive,strMonitorId,strSubID,strType];
        [[DataBaseManager dataBaseManager] executeSw:requestStr];*/
        
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
    self-> viewForSensorNameNum.frame = CGRectMake(150, DEVICE_HEIGHT, DEVICE_WIDTH-300, 500);
    }
        completion:(^(BOOL finished)
      {
        [self-> viewForAddSensor removeFromSuperview];
    })];
    }
    }
-(void)btnSKinAddSnrClick:(id)sender
{
    isBtnSkinSelected = YES;
    btnSkinAddSnr.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    [btnSkinAddSnr setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btnIngsetAddSnr setTitleColor:[UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1] forState:UIControlStateNormal];
    btnIngsetAddSnr.backgroundColor = UIColor.whiteColor;
}
-(void)btnCancelSnrClick
{
     [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
        {
            self-> viewForSensorNameNum.frame = CGRectMake(150, DEVICE_HEIGHT, DEVICE_WIDTH-300, 500);
        }
                     completion:(^(BOOL finished)
    {
         [self-> viewForAddSensor removeFromSuperview];
     })];
}
-(void)btnIngestAddSnrClick
{
    isBtnSkinSelected = NO;
    btnIngsetAddSnr.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    [btnIngsetAddSnr setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btnSkinAddSnr setTitleColor:[UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1] forState:UIControlStateNormal];
    btnSkinAddSnr.backgroundColor = UIColor.whiteColor;
}
#pragma mark-View All Sensor Methoda
-(void)setupForViewAllSensors
{
    viewAllSensor = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    viewAllSensor.backgroundColor = [UIColor colorWithRed:0 green:(CGFloat)0 blue:0 alpha:0.8];
    [self.view addSubview:viewAllSensor];

    viewForListOfSensor = [[UIView alloc]initWithFrame:CGRectMake(40, (DEVICE_HEIGHT), DEVICE_WIDTH-80, DEVICE_HEIGHT-40)];
    viewForListOfSensor.backgroundColor = UIColor.whiteColor;
    viewForListOfSensor.layer.cornerRadius = 6;
    viewForListOfSensor.clipsToBounds = true;
    [viewAllSensor addSubview:viewForListOfSensor];

    UIView * viewForBgAllSnr = [[UIView alloc]initWithFrame:CGRectMake(0, 0, viewAllSensor.frame.size.width, 60)];
    viewForBgAllSnr.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    [viewForListOfSensor addSubview:viewForBgAllSnr];
    
    lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewAllSensor.frame.size.width-100, 60)];
    [self setLabelProperties:lblHeader withText:@"Please select any  sensors" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:25];
    lblHeader.textAlignment = NSTextAlignmentCenter;
//    [viewForBgAllSnr addSubview:lblHeader];

//    if (isRemoveSnrSelect == YES)
//    {
//         lblHeader.text = @"Select to Remove sensor";
//    }

    UIButton *btnCancelSlSnr = [[UIButton alloc]initWithFrame:CGRectMake(5, 0, 100, 60)];
    [self setButtonProperties:btnCancelSlSnr withTitle:@"Close" backColor:UIColor.clearColor textColor:UIColor.whiteColor txtSize:25];
    [btnCancelSlSnr addTarget:self action:@selector(btnCancelSlClick) forControlEvents:UIControlEventTouchUpInside];
    btnCancelSlSnr.layer.cornerRadius = 5;
    [viewForBgAllSnr addSubview:btnCancelSlSnr];

    UIButton *btnSelectOk = [[UIButton alloc]initWithFrame:CGRectMake(viewForListOfSensor.frame.size.width-60, 0, 50, 60)];
    [self setButtonProperties:btnSelectOk withTitle:@"" backColor:UIColor.clearColor textColor:UIColor.whiteColor txtSize:25];
    [btnSelectOk addTarget:self action:@selector(btnOkSelClick) forControlEvents:UIControlEventTouchUpInside];
    [viewForBgAllSnr addSubview:btnSelectOk];

    if(isRemoveSnrSelect == YES)
    {
        [tmpArrySensor setValue:@"0" forKey:@"isRemoveSelected"];
        btnSelectOk.frame = CGRectMake(viewForListOfSensor.frame.size.width-150, 0, 150, 60);
        [btnSelectOk setTitle:@"Remove" forState:UIControlStateNormal];
    }
    tblListOfSensor = [[UITableView alloc]initWithFrame: CGRectMake(0, 125, viewForListOfSensor.frame.size.width, viewForListOfSensor.frame.size.height-250) style:UITableViewStylePlain];
    tblListOfSensor.frame = CGRectMake(0, 60, viewForListOfSensor.frame.size.width, viewForListOfSensor.frame.size.height);
    tblListOfSensor.backgroundColor = UIColor.whiteColor;
    tblListOfSensor.delegate= self;
    tblListOfSensor.dataSource = self;
    [viewForListOfSensor addSubview:tblListOfSensor];

    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        self->viewForListOfSensor.frame = CGRectMake(40, 125, DEVICE_WIDTH-80, DEVICE_HEIGHT-240);
        [self->tblListOfSensor reloadData];
        [self->viewForAddSensor removeFromSuperview];
    }
                    completion:NULL];
}
-(void)btnCancelSlClick
{
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        self-> viewForListOfSensor.frame = CGRectMake(40, DEVICE_HEIGHT, DEVICE_WIDTH-80, DEVICE_HEIGHT-40);
    }
                    completion:(^(BOOL finished)
    {
                    [self-> viewAllSensor removeFromSuperview];
    })];
}
-(void)btnOkSelClick
{
    if (isRemoveSnrSelect == NO)
    {
        [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
        {
            self-> viewForListOfSensor.frame = CGRectMake(40, DEVICE_HEIGHT, DEVICE_WIDTH-80, DEVICE_HEIGHT-40);
//            [self UpdateSensorsLabels];
            }
                        completion:(^(BOOL finished)
        {
            [self-> viewAllSensor removeFromSuperview];
        })];
    }
    else if (isRemoveSnrSelect == YES)
    {
        int selectCount = 0;
        for (int i = 0; i<tmpArrySensor.count; i++)
        {
            if ([[[tmpArrySensor objectAtIndex:i] valueForKey:@"isRemoveSelected"] isEqualToString:@"1"])
            {
                selectCount = selectCount + 1;
            }
        }
        if (selectCount <= 0)
        {
            [self AlertViewFCTypeCaution:@"Please select any senesors to Remove"];
        }
        else
        {
            NSString * strName = [[tmpArrySensor objectAtIndex:selectedIndex] valueForKey:@"name"];
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeWarning];
            [alert addButton:@"Remove" withActionBlock:
             ^{
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeSuccess];
                [alert showAlertInView:self
                             withTitle:@"HQ-Inc App"
                          withSubtitle:[NSString stringWithFormat:@"%@ sensor removed successfully",strName]
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
                
                NSMutableArray * tmparr = [[NSMutableArray alloc] init];
                for (int i = 0; i<[tmpArrySensor count]; i++)
                {
                    if ([[[tmpArrySensor objectAtIndex:i] objectForKey:@"isRemoveSelected"] isEqualToString:@"1"])
                    {
                        [tmparr addObject:[tmpArrySensor objectAtIndex:i]];
                    }
                }
                for (int k = 0; k<tmparr.count; k++)
                {
                    NSInteger foundIndex = [tmpArrySensor indexOfObject:[tmparr objectAtIndex:k]];
                    if (foundIndex != NSNotFound)
                    {
                        if (tmpArrySensor.count > foundIndex)
                        {
                            [tmpArrySensor removeObjectAtIndex:foundIndex];
                            lblNosensor.text = [NSString stringWithFormat:@"%lu Sensor Added",(unsigned long)tmpArrySensor.count];
                        }
                    }
                }
//                [self UpdateSensorsLabels];
                [self->tblListOfSensor reloadData];
                }];
            
//            [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
//            {
//                self-> viewForListOfSensor.frame = CGRectMake(40, (DEVICE_HEIGHT), DEVICE_WIDTH-80, DEVICE_HEIGHT-40);
//            }
//                            completion:(^(BOOL finished)
//            {
//                [self-> viewAllSensor removeFromSuperview];
//            })];
            
            [alert showAlertInView:self
                         withTitle:@"HQ-Inc App"
                      withSubtitle:[NSString stringWithFormat:@"Are you sure want to remove %@ Sensors ?",strName]
                   withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
               withDoneButtonTitle:@"Cancel" andButtons:nil];
        }
    }
}
#pragma mark- To Update Sensors lables with Type after selection
-(void)UpdateSensorsLabels
{
    if (arrSensors.count == 0)
    {
        lblType1.text = @"--NA--";
        lblType2.text = @"--NA--";
        lblNameNo1.text = @"--NA--";
        lblNameNo2.text = @"--NA--";
    }
    else if (arrSensors.count == 1)
         {
             lblNameNo1.text = [NSString stringWithFormat:@"%@ / %@",[[arrSensors objectAtIndex:0] valueForKey:@"name"], [[arrSensors objectAtIndex:0] valueForKey:@"number"]];
             lblType1.text = [[arrSensors objectAtIndex:0] valueForKey:@"type"];
             [[arrSensors objectAtIndex:0] setObject:@"1" forKey:@"isSelected"];
         }
         else if (arrSensors.count == 2)
         {
             //For First part
              lblNameNo1.text = [NSString stringWithFormat:@"%@/%@",[[arrSensors objectAtIndex:0] valueForKey:@"name"], [[arrSensors objectAtIndex:0] valueForKey:@"number"]];
              lblType1.text = [[arrSensors objectAtIndex:0] valueForKey:@"type"];
              [[arrSensors objectAtIndex:0] setObject:@"1" forKey:@"isSelected"];
             
             //for Second part
             lblNameNo2.text = [NSString stringWithFormat:@"%@/%@",[[arrSensors objectAtIndex:1] valueForKey:@"name"], [[arrSensors objectAtIndex:1] valueForKey:@"number"]];
             lblType2.text = [[arrSensors objectAtIndex:1] valueForKey:@"type"];
             [[arrSensors objectAtIndex:1] setObject:@"1" forKey:@"isSelected"];
         }
         else if (arrSensors.count > 0)
         {
             int lblCount = 0;
             for (int i=0; i<arrSensors.count; i++)
             {
                 if ([[[arrSensors objectAtIndex:i] valueForKey:@"isSelected"] isEqualToString:@"1"])
                 {
                     if (lblCount == 0)
                     {
                         lblNameNo1.text = [NSString stringWithFormat:@"%@/%@",[[arrSensors objectAtIndex:i] valueForKey:@"name"], [[arrSensors objectAtIndex:i] valueForKey:@"number"]];
                         lblType1.text = [[arrSensors objectAtIndex:i] valueForKey:@"type"];
                         lblCount = 1;
                     }
                     else if(lblCount ==1)
                     {
                         lblNameNo2.text = [NSString stringWithFormat:@"%@/%@",[[arrSensors objectAtIndex:i] valueForKey:@"name"], [[arrSensors objectAtIndex:i] valueForKey:@"number"]];
                         lblType2.text = [[arrSensors objectAtIndex:i] valueForKey:@"type"];
                         lblCount = 2;
                         break;
                     }
                 }
             }
         }
    }
#pragma mark- Table view Method

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tblListOfSensor)
    {
        return tmpArrySensor.count;
    }
  
    return true;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellSensor = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    SubjectSetUpCELL  *cell = [tableView dequeueReusableCellWithIdentifier:cellSensor];
    cell = [[SubjectSetUpCELL alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellSensor];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    //@"Dummy";//[NSString stringWithFormat:@"%@",[[tmpArryMonitor objectAtIndex:indexPath.row] valueForKey:@"id"]];//,[[arrSensors objectAtIndex:indexPath.row] valueForKey:@"number"]];

    cell.lblSensor.frame = CGRectMake(20, 0, tableView.frame.size.width/2, 70);
    cell.lblNameSnr.frame = CGRectMake(tableView.frame.size.width/2, 0, tableView.frame.size.width/2-60, 70);
    
    cell.lblSensor.text = [NSString stringWithFormat:@"%@ (%@)",[[tmpArrySensor objectAtIndex:indexPath.row] valueForKey:@"sensor_id"],[[tmpArrySensor objectAtIndex:indexPath.row] valueForKey:@"sensor_type"]];
    
    cell.lblNameSnr.text= [[tmpArrySensor objectAtIndex:indexPath.row] valueForKey:@"name"];
    
    if (isRemoveSnrSelect == YES)
    {
        cell.viewSelect.frame = CGRectMake(tableView.frame.size.width - 50, 17, 30, 30);
        cell.viewSelect.hidden = false;
        
        if ([[[tmpArrySensor objectAtIndex:indexPath.row] valueForKey:@"isRemoveSelected"] isEqualToString:@"1"])
        {
            cell.viewSelect.image = [UIImage imageNamed:@"greenSelected.png"];
        }
        else
        {
            cell.viewSelect.image = [UIImage imageNamed:@"radioUnselected.png"];
        }
    }
    else if (isRemoveSnrSelect == NO)
    {
//        if ([[[tmpArryMonitor objectAtIndex:indexPath.row] valueForKey:@"isAdded"] isEqualToString:@"1"])
//        {
//            cell.viewSelect.image = [UIImage imageNamed:@"greenSelected.png"];
//        }
//        else
//        {
//            cell.viewSelect.image = [UIImage imageNamed:@"radioUnselected.png"];
//        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    selectedIndex = indexPath.row;
    if (isRemoveSnrSelect == NO)
    {
        if ([[[tmpArrySensor objectAtIndex:indexPath.row] valueForKey:@"isSelected"] isEqualToString:@"1"])
        {
            [[tmpArrySensor objectAtIndex:indexPath.row] setObject:@"0" forKey:@"isSelected"];
        }
        else
        {
            int selectCount = 0;
            for (int i = 0; i<tmpArrySensor.count; i++)
            {
                if ([[[tmpArrySensor objectAtIndex:i] valueForKey:@"isSelected"] isEqualToString:@"1"])
                {
                    selectCount = selectCount + 1;
                }
            }
            if (selectCount >= 2)
            {
                //show alert popup
                [self AlertViewFCTypeCaution:@"selected two sensor, if you want another uncheck the selected"];
          }
          else
          {
              if ([[[tmpArrySensor objectAtIndex:indexPath.row] valueForKey:@"isSelected"] isEqualToString:@"1"])
              {
                  [[tmpArrySensor objectAtIndex:indexPath.row] setObject:@"0" forKey:@"isSelected"];
              }
              else
              {
                  [[tmpArrySensor objectAtIndex:indexPath.row] setObject:@"1" forKey:@"isSelected"];
              }
          }
            [tblListOfSensor reloadData];
        }
    }
    else if (isRemoveSnrSelect == YES)
    {
        if ([[[tmpArrySensor objectAtIndex:indexPath.row] valueForKey:@"isRemoveSelected"] isEqualToString:@"0"])
        {
            [[tmpArrySensor objectAtIndex:indexPath.row] setObject:@"1" forKey:@"isRemoveSelected"];
        }
        else if ([[[tmpArrySensor objectAtIndex:indexPath.row] valueForKey:@"isRemoveSelected"] isEqualToString:@"1"])
        {
            [[tmpArrySensor objectAtIndex:indexPath.row] setObject:@"0" forKey:@"isRemoveSelected"];
        }
    }
    [tblListOfSensor reloadData];
}
 -(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView*viewHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tblListOfSensor.frame.size.width, 60)];
    viewHeader.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];
    UIColor * lblBGC = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];
    
    UILabel *lblType = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH/2, 60)];
    [self setLabelProperties:lblType withText:@"Sensor ID(Type)" backColor:lblBGC textColor:UIColor.blackColor textSize:25];
    lblType.textAlignment = NSTextAlignmentLeft;
    [viewHeader addSubview:lblType];

    
    UILabel *lblNameAndNum = [[UILabel alloc] initWithFrame:CGRectMake(tblListOfSensor.frame.size.width/2, 0, tblListOfSensor.frame.size.width/2-60, 60)];
    [self setLabelProperties:lblNameAndNum withText:@"Name" backColor:lblBGC textColor:UIColor.blackColor textSize:25];
    lblNameAndNum.textAlignment = NSTextAlignmentCenter;
    [viewHeader addSubview:lblNameAndNum];

         return viewHeader;
     }
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}
#pragma mark- remove Sensor Method
-(void)btnRemoveSnrClick
{
    if (tmpArrySensor.count == 0)
    {
    [self AlertViewFCTypeCaution:@"Sensor not added."];
    }
    else
    {
        isRemoveSnrSelect = YES;
        [self setupForViewAllSensors];
    }
}
-(void)setupRemoveSensor
{
    [UIView transitionWithView:self.view duration:0. options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         self-> viewForAddSensor.frame = CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, DEVICE_HEIGHT);
     }completion:(^(BOOL finished){
         [self-> viewForAddSensor removeFromSuperview];
    })];
    [tblListOfSensor reloadData];
}
#pragma mark- Assiging  fielsd from data dict
-(void)fromDataDict
{
    if (dataDict.count > 0)
    {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
        tmpDict = [arrPlayers objectAtIndex:0];
            
        highIngstF = [[tmpDict valueForKey:@"ing_highF"] floatValue];
        lowIngestF = [[tmpDict valueForKey:@"ing_lowF"] floatValue];
        highDermalF = [[tmpDict valueForKey:@"drml_highF"] floatValue];
        lowDermalF = [[tmpDict valueForKey:@"drml_lowF"] floatValue];
      
        
        txtFullName.text = [dataDict valueForKey:@"name"];
        txtHash.text = [dataDict valueForKey:@"number"];
        
        highIngstF = [[dataDict valueForKey:@"ing_lowF"] floatValue];
        lowIngestF = [[dataDict valueForKey:@"ing_highF"] floatValue];
        highDermalF = [[dataDict valueForKey:@"drml_highF"] floatValue];
        lowDermalF = [[dataDict valueForKey:@"drml_lowF"] floatValue];

//             highIngstF = [[tmpDict valueForKey:@"ing_highF"] floatValue];
//             lowIngestF = [[tmpDict valueForKey:@"ing_lowF"] floatValue];
//             highDermalF = [[tmpDict valueForKey:@"drml_highF"] floatValue];
//             lowDermalF = [[tmpDict valueForKey:@"drml_lowF"] floatValue];
        
        highIngstC = [[tmpDict valueForKey:@"ing_highC"] floatValue];
        lowIngestC = [[tmpDict valueForKey:@"ing_lowC"] floatValue];
        highDermalC = [[tmpDict valueForKey:@"drml_highC"] floatValue];
        lowDermalC = [[tmpDict valueForKey:@"drml_lowC"] floatValue];
        txtViewNote.text = [dataDict valueForKey:@"notes"];
        
        txtIngesTmpHigh.text = [NSString stringWithFormat:@"%.02f",highIngstF];
        txtlngeslowTmpAl.text = [NSString stringWithFormat:@"%.02f",lowIngestF];
        txtDermalLowTmp.text = [NSString stringWithFormat:@"%.02f",lowDermalF];
        txtDemalTmpHigh.text = [NSString stringWithFormat:@"%.02f",highDermalF];
    }
}
#pragma mark- Img Scalling
-(void)gettingImg
{
    NSString * filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"PlayerPhoto/%@", [dataDict valueForKey:@"photo_URL"]]];
    NSData *pngData = [NSData dataWithContentsOfFile:filePath];
    UIImage * mainImage = [UIImage imageWithData:pngData];
    UIImage * image = [self scaleMyImage:mainImage withNewWidth:300 newHeight:300];
    imgViewProPic.image = image;
}
-(UIImage *)scaleMyImage:(UIImage *)newImg withNewWidth:(double)newWidth newHeight:(double)newHeight
{
    double originalW = newImg.size.width;
    double originalH = newImg.size.height;
    double updateH = (newHeight * originalH)/ originalW;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth,updateH));
    [newImg drawInRect: CGRectMake(0, 0, newWidth, updateH)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return smallImage;
}
#pragma mark-textField and Lables And Button Properties
-(void)setTextfieldProperties:(UITextField *)txtfld withPlaceHolderText:(NSString *)strText withTextSize:(int)textSize
{
    txtfld.delegate = self;
    txtfld.attributedPlaceholder = [[NSAttributedString alloc] initWithString:strText attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor],NSFontAttributeName: [UIFont fontWithName:CGRegular size:textSize]}];
    txtfld.textAlignment = NSTextAlignmentCenter;
    txtfld.textColor = [UIColor blackColor];
    txtfld.backgroundColor= UIColor.whiteColor;
    txtfld.autocorrectionType = UITextAutocorrectionTypeNo;
    txtfld.layer.cornerRadius = 6;
    txtfld.font = [UIFont boldSystemFontOfSize:textSize];
    txtfld.font = [UIFont fontWithName:CGRegular size:textSize];
    txtfld.clipsToBounds = true;
    txtfld.delegate = self;
}
-(void)setLabelProperties:(UILabel *)lbl withText:(NSString *)strText backColor:(UIColor *)backColor textColor:(UIColor *)txtColor textSize:(int)txtSize
{
    lbl.text = strText;
    lbl.textColor = txtColor;
    lbl.backgroundColor = backColor;
    lbl.clipsToBounds = true;
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.layer.cornerRadius = 5;
    lbl.font = [UIFont fontWithName:CGRegular size:txtSize];
}
-(void)setButtonProperties:(UIButton *)btn withTitle:(NSString *)strText backColor:(UIColor *)backColor textColor:(UIColor *)txtColor txtSize:(int)txtSize
{
    [btn setTitle:strText forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize];
//    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
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
-(void)AlertViewFCTypeCautionCheck
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeCaution];
    [alert showAlertInView:self
                 withTitle:@"HQ-Inc"
              withSubtitle:strMsg
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
-(void)ConnectedMonitorDetail:(NSMutableDictionary *)arryFromAddMonitor
{
    NSString * strDeviceName = @"Monitor";
    if (![[APP_DELEGATE checkforValidString:[arryFromAddMonitor valueForKey:@"name"]] isEqualToString:@"NA"])
    {
        strDeviceName = [arryFromAddMonitor valueForKey:@"name"];
        if (![[APP_DELEGATE checkforValidString:[arryFromAddMonitor valueForKey:@"bleAddress"]] isEqualToString:@"NA"])
        {
            strDeviceName = [NSString stringWithFormat:@"%@",[arryFromAddMonitor valueForKey:@"name"]];
        }
    }
    lblAddmonitorConnect.text = [NSString stringWithFormat:@"%@ Added",strDeviceName];
}
-(void)SetupDemoFromAddSensorData:(NSMutableArray *)arryData
{
    NSLog(@"Subject Setup Sensor Data==%@",arryData);
    tmpArrySensor = arryData;
    NSMutableArray * arryTmp = [[NSMutableArray alloc] init];
    arryTmp = [arryData valueForKey:@"sensor_id"];

    NSMutableArray * arrtmp = [[NSMutableArray alloc] init];
    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
    [arrtmp addObject:tmpDict];

    for (id key in [tmpDict allKeys])
    {
        NSString *numberOfMovement = tmpDict[key][@"id"];
        NSLog(@"Your pair: %@, %@", key, numberOfMovement);
    }

    arryTmp =  [arryData valueForKey:@"isAdded"];
    int addedMonitor = 0;

    for(NSString *string in arryTmp)
    {
        addedMonitor += ([string isEqualToString:@"1"]?1:0);
    }

    if (arryTmp.count > 0)
    {
        lblNosensor.text = [NSString stringWithFormat:@"%d Sensor added",addedMonitor];
    }
}
@end
