//
//  AddSensorVC.m
//  HQ-INC App
//
//  Created by Ashwin on 8/27/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "AddSensorVC.h"
#import "AddSensorCell.h"
#import "BLEService.h"

@interface AddSensorVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    NSString * strName;
    NSMutableArray *arrySensors,*arrBlrID,* arrdata,*arrSnrType;
    NSInteger selectedIndex;
    NSMutableDictionary * dictData;
    NSArray *indexes;
    NSTimer * connectionTimer,*timeoutforAddSensor,*timerSave,*tmScan;
    UIButton * btnCanceldown,*btnDone;
    BOOL isAnyAdded;
}
@end

@implementation AddSensorVC

- (void)viewDidLoad
{
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = UIColor.blackColor;//[UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    
//    [APP_DELEGATE startHudProcess:@"Scanning Sensors"];
//    connectionTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(ConnectionTimeOutMethod) userInfo:nil repeats:NO];
    
    UIColor * btnBgClor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    
    btnCanceldown = [[UIButton alloc]initWithFrame:CGRectMake(100, DEVICE_HEIGHT-60, 150, 50)];
    [self setButtonProperties:btnCanceldown withTitle:@"Cancel" backColor:btnBgClor textColor:UIColor.whiteColor txtSize:25];
    btnCanceldown.layer.cornerRadius = 5;
    [btnCanceldown addTarget:self action:@selector(btnCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCanceldown];
        
    btnDone = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-250, DEVICE_HEIGHT-60, 150, 50)];
    [self setButtonProperties:btnDone withTitle:@"Done" backColor:btnBgClor textColor:UIColor.whiteColor txtSize:25];
    btnDone.layer.cornerRadius = 5;
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    btnDone.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    [btnDone addTarget:self action:@selector(btnDoneClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnDone];

    
    [APP_DELEGATE startHudProcess:@"Lo0king for Sensors..."];
    
    tmScan = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(timeOutAddSensor) userInfo:nil repeats:NO];


    [self setNavigationViewFrames];
    
    //Send Start Searching Sensor Command...
    [self StartSensorsScanning];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)timeOutAddSensor
{
    [APP_DELEGATE endHudProcess];
//    [self AlertViewFCTypeCautionCheck:@"Something wnt wrong please try agin later"];
}
-(void)ConnectionTimeOutMethod
{
    [APP_DELEGATE endHudProcess];
    tblDeviceList.hidden= false;
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    int yy = 64;
    
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, yy )];
    [viewHeader setBackgroundColor: UIColor.blackColor];//[UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1]];
    [self.view addSubview:viewHeader];
    
    UIColor * lbltxtClor = [UIColor colorWithRed:180.0/255 green:245.0/255 blue:254.0/255 alpha:1];
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, DEVICE_WIDTH-100, yy)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [self setLabelProperties:lblTitle withText:@"ADD SENSOR" backColor:UIColor.clearColor textColor:lbltxtClor textSize:25];
    [viewHeader addSubview:lblTitle];

    UIButton * btnRefresh = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRefresh setFrame:CGRectMake(DEVICE_WIDTH-60, globalStatusHeight-5, 50, 50)];
    btnRefresh.backgroundColor = UIColor.clearColor;
    [btnRefresh setImage:[UIImage imageNamed:@"reload.png"] forState:UIControlStateNormal];
    [btnRefresh addTarget:self action:@selector(refreshBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnRefresh];
        
    UILabel * line = [[UILabel alloc] initWithFrame:CGRectMake(0, viewHeader.frame.size.height, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [viewHeader addSubview:line];
    
    UIColor * btnBgClor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    UILabel * lblheader = [[UILabel alloc] initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH, 50)];
    [lblheader setBackgroundColor:[UIColor clearColor]];
    [lblheader setText:@" Tap on add button to add with device"];
    [lblheader setTextAlignment:NSTextAlignmentCenter];
    [lblheader setFont:[UIFont fontWithName:CGRegular size:textSize+1]];
    [lblheader setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblheader];
    
    tblDeviceList = [[UITableView alloc] initWithFrame:CGRectMake(0, yy+51, DEVICE_WIDTH, DEVICE_HEIGHT-yy-152)];
    tblDeviceList.delegate = self;
    tblDeviceList.dataSource= self;
    tblDeviceList.backgroundColor = UIColor.clearColor;
    [tblDeviceList setShowsVerticalScrollIndicator:NO];
    tblDeviceList.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblDeviceList.separatorColor = [UIColor darkGrayColor];
    tblDeviceList.hidden = true;
    [self.view addSubview:tblDeviceList];
  
    arrSnrType = [NSMutableArray arrayWithObjects:@"Dermal",@"Ingestible",nil];
    arrySensors = [[NSMutableArray alloc] init];
    arrBlrID = [NSMutableArray arrayWithObjects:@"BLE1234000000EE",@"BLE100340000000",nil];
    
//    for (int i =0; i < [arrBlrID count]; i++)
//    {
//        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
//        [dict setValue:[arrBlrID objectAtIndex:i] forKey:@"id"];
//        [dict setValue:[arrSnrType objectAtIndex:i] forKey:@"type"];
//        [dict setValue:@"" forKey:@"name"];
//        [dict setValue:@"0" forKey:@"isAdded"];
//        [arrySensors addObject:dict];
//    }
}
#pragma mark- UITableView Methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    UIColor * btnBgClor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    UIView * headerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    headerView.backgroundColor = btnBgClor;
        
    UILabel *lblmenu=[[UILabel alloc]initWithFrame:CGRectMake(10,0, DEVICE_WIDTH/3-10, 50)];
    lblmenu.text = @"Sensors ID (Type)";
    [lblmenu setTextColor:[UIColor whiteColor]];
    lblmenu.font = [UIFont fontWithName:CGRegular size:textSize+2];
    lblmenu.backgroundColor = UIColor.clearColor;
    lblmenu.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:lblmenu];
    
    UILabel *lblName =[[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH/3*2-140,0, DEVICE_WIDTH/3, 50)]; // overlapping
    lblName.text = @"Name";
    [lblName setTextColor:[UIColor whiteColor]];
    lblName.font = [UIFont fontWithName:CGRegular size:textSize+2];
    lblName.backgroundColor = UIColor.clearColor;
    lblName.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:lblName];
        
    return headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrySensors.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    AddSensorCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[AddSensorCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    
    [APP_DELEGATE endHudProcess];
    
    cell.lblAddress.text =[NSString stringWithFormat:@"%@ (%@)",[[arrySensors objectAtIndex:indexPath.row] valueForKey:@"sensor_id"],[[arrySensors objectAtIndex:indexPath.row] valueForKey:@"sensor_type"]] ;
    cell.lblDeviceName.text = [[arrySensors objectAtIndex:indexPath.row] valueForKey:@"name"];
    
    if ([[[arrySensors objectAtIndex:indexPath.row] valueForKey:@"isAdded"] isEqualToString:@"1"])
    {
         [APP_DELEGATE endHudProcess];
        
        cell.lblConnect.text = @"Added";
        [cell.lblConnect setBackgroundColor:[UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1]];
        cell.lblConnect.textColor = UIColor.whiteColor;
    }
    else
    {
        cell.lblConnect.text = @"Add";
        [cell.lblConnect setBackgroundColor:[UIColor clearColor]];
        cell.lblConnect.textColor = UIColor.blackColor;
    }

    if (indexPath.row % 2 == 0)
    {
        cell.backgroundColor = [UIColor colorWithRed:230.0/255.0f green:230.0/255.0f blue:230.0/255.0f alpha:1];
    }
    else
    {
        cell.backgroundColor = [UIColor lightGrayColor];
    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if ([arrySensors count] > indexPath.row)
    {
        if ([[[arrySensors objectAtIndex:indexPath.row] valueForKey:@"isAdded"] isEqualToString:@"0"])
        {
            selectedIndex = indexPath.row;
            [APP_DELEGATE startHudProcess:@"Connecting sensor"];
            [timeoutforAddSensor invalidate];
            timeoutforAddSensor = nil;
            timeoutforAddSensor = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timeOutRequestforAddSensor) userInfo:nil repeats:NO];
            NSInteger intOpCode = [@"8" integerValue];
            NSData * dataOpcode = [[NSData alloc] initWithBytes:&intOpCode length:1];

            NSInteger intLength = [@"2" integerValue];
            NSData * dataLength = [[NSData alloc] initWithBytes:&intLength length:1];
            
            NSString * strId = [[arrySensors objectAtIndex:indexPath.row] valueForKey:@"sensor_id"];
            NSInteger intSensorId = [strId integerValue];
            NSData * dataSensorId = [[NSData alloc] initWithBytes:&intSensorId length:2];
            
            NSMutableData * finalData = [dataOpcode mutableCopy];
            [finalData appendData:dataLength];
            [finalData appendData:dataSensorId];
            
            NSLog(@"Wrote Command for Adding Sensor---==%@",finalData);
            [[BLEService sharedInstance] WriteValuestoDevice:dataSensorId withOcpde:@"8" withLength:@"2" with:globalPeripheral];
        }
        else if ([[[arrySensors objectAtIndex:indexPath.row] valueForKey:@"isAdded"] isEqualToString:@"1"])
        {
            [self setupForAddSensor];
        }
    }
}
-(void)nametimer
{
    [timeoutforAddSensor invalidate];
    timeoutforAddSensor = nil;
    [APP_DELEGATE endHudProcess];
    [self setupForAddSensor];
    [arrdata addObject:dictData];
    NSLog(@"%@",dictData);
}
-(void)timeOutRequestforAddSensor
{
    [APP_DELEGATE endHudProcess];
    [timeoutforAddSensor invalidate];
    timeoutforAddSensor = nil;
   
}
#pragma mark- Button Click Events
-(void)btnCancelClick
{
    if (isAnyAdded == YES)
    {
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeWarning];
        [alert addButton:@"Move Back" withActionBlock:
         ^{
            [self StopSensorsScanning];
            for (int i = 0; i< [self->arrySensors count]; i++)
            {
                if ([[[self->arrySensors objectAtIndex:i] valueForKey:@"isAdded"] isEqualToString:@"1"])
                {
                 
                    NSString * strSensorId = [[self->arrySensors objectAtIndex:i] valueForKey:@"sensor_id"];
                    NSInteger intOpCode = [@"10" integerValue];
                    NSData * dataOpcode = [[NSData alloc] initWithBytes:&intOpCode length:1];

                    NSInteger intLength = [@"2" integerValue];
                    NSData * dataLength = [[NSData alloc] initWithBytes:&intLength length:1];
                    
                    NSInteger intSensorId = [strSensorId integerValue];
                    NSData * dataSensorId = [[NSData alloc] initWithBytes:&intSensorId length:2];
                    
                    NSMutableData * finalData = [dataOpcode mutableCopy];
                    [finalData appendData:dataLength];
                    [finalData appendData:dataSensorId];

                    NSLog(@"Wrote Command for Delete Sensor---==%@",finalData);
                    [[BLEService sharedInstance] WriteValuestoDevice:dataSensorId withOcpde:@"10" withLength:@"2" with:globalPeripheral];
                }
            }
            [self.navigationController popViewControllerAnimated:TRUE];
            //Delete one by one all the Added Sensors
        }];
        [alert showAlertInView:self
                     withTitle:@"HQ-Inc App"
                  withSubtitle:@"Are you sure want to move back without Saving Sensors. Sensors will not be added if you move back without Saving."
               withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
           withDoneButtonTitle:@"Cancel" andButtons:nil];
    }
    else
    {
        [self StopSensorsScanning];
        [self.navigationController popViewControllerAnimated:TRUE];
    }
}
-(void)btnDoneClick
{
    NSMutableArray * tmpArry = [[NSMutableArray alloc] init];
    for (int i = 0; i< [arrySensors count]; i++)
    {
        if ([[[arrySensors objectAtIndex:i] valueForKey:@"isAdded"] isEqualToString:@"1"])
        {
            [tmpArry addObject:[arrySensors objectAtIndex:i]];
        }
    }
    
    if (isAnyAdded == YES)
    {
        if ([tmpArry count] > 0)
        {
            arrGlobalSensorsAdded = [tmpArry mutableCopy];
            [globalSbuSetupVC SetupDemoFromAddSensorData:tmpArry]; // Added Sensors passing to Previous View
        }
//        [self StopSensorsScanning];
        [self AddSensorsComplete];
        [self.navigationController popViewControllerAnimated:true];
    }
    else
    {
        if ([tmpArry count] > 0)
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeWarning];
            [alert addButton:@"Move Back" withActionBlock:
             ^{
                //Delete one by one all the Added Sensors
            }];
            [alert showAlertInView:self
                         withTitle:@"HQ-Inc App"
                      withSubtitle:@"Please Add atleast one Sensor to Complete Or Tap on Calcel to move back."
                   withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
               withDoneButtonTitle:@"Ok" andButtons:nil];
        }
        else
        {
//            [self StopSensorsScanning];
            [self.navigationController popViewControllerAnimated:true];
        }
    }
}

-(void)btnCancelSensorView
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

-(void)btnSaveClick
{
    if ([txtNameSnr.text isEqual:@""])
    {
        [self AlertViewFCTypeCautionCheck:@"Please enter sensor name."];
    }
    else
    {
        if ([arrySensors count] > selectedIndex)
        {
            [[arrySensors objectAtIndex:selectedIndex] setValue:txtNameSnr.text forKey:@"name"];
            [[arrySensors objectAtIndex:selectedIndex] setValue:@"1" forKey:@"isAdded"];
            [tblDeviceList reloadData];

            NSMutableArray * tmpArry = [[NSMutableArray alloc] init];
            tmpArry = [self->arrySensors objectAtIndex:self->selectedIndex];
        }
        
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
-(void)refreshBtnClick
{
    [self StartSensorsScanning];
    tmScan = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(timeOutAddSensor) userInfo:nil repeats:NO];

}
#pragma mark- Add Sensor Setup
-(void)setupForAddSensor
{
    viewForAddSensor = [[UIView alloc]init];
    viewForAddSensor.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    viewForAddSensor.backgroundColor = [UIColor colorWithRed:0 green:(CGFloat)0 blue:0 alpha:0.8];
    [self.view addSubview:viewForAddSensor];
        
        viewForSensorNameNum = [[UIView alloc]init];
        viewForSensorNameNum.frame = CGRectMake(150, (DEVICE_HEIGHT), DEVICE_WIDTH-300, 300);
        viewForSensorNameNum.backgroundColor = UIColor.whiteColor;
        viewForSensorNameNum.layer.cornerRadius = 6;
        viewForSensorNameNum.clipsToBounds = true;
        [viewForAddSensor addSubview:viewForSensorNameNum];
        
        UIView *bgView = [[UIView alloc]init];
        bgView.frame = CGRectMake(0, 0, viewForSensorNameNum.frame.size.width, 70);
        bgView.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
        [viewForSensorNameNum addSubview:bgView];
        
        btnCancel = [[UIButton alloc]init];
        btnCancel.frame = CGRectMake(10, 0, 110, 70);
        [btnCancel addTarget:self action:@selector(btnCancelSensorView) forControlEvents:UIControlEventTouchUpInside];
        [btnCancel setTitle:@"Cancel" forState:normal];
        [btnCancel setTitleColor:UIColor.whiteColor forState:normal];
        btnCancel.backgroundColor = UIColor.clearColor;
        btnCancel.titleLabel.font = [UIFont fontWithName:CGRegular size:22];
        [bgView addSubview:btnCancel];
               
        btnSave = [[UIButton alloc]init];
        btnSave.frame = CGRectMake(viewForSensorNameNum.frame.size.width-100, 0, 100, 70);
        [btnSave addTarget:self action:@selector(btnSaveClick) forControlEvents:UIControlEventTouchUpInside];
        [btnSave setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        btnSave.backgroundColor = UIColor.clearColor;
        [btnSave setTitle:@"Save" forState:normal];
        btnSave.titleLabel.font = [UIFont fontWithName:CGRegular size:22];
        [bgView addSubview:btnSave];
        
        int yy = 80;
        UILabel * lblAddSnr = [[UILabel alloc]init];
        lblAddSnr.frame = CGRectMake(0, yy, viewForSensorNameNum.frame.size.width, 50);
        lblAddSnr.text = @"Save Sensor Name";
        lblAddSnr.textAlignment = NSTextAlignmentCenter;
        lblAddSnr.font = [UIFont fontWithName:CGRegular size:28];
        [viewForSensorNameNum addSubview:lblAddSnr];
        
        yy = yy + 80;
        txtNameSnr = [[UITextField alloc]initWithFrame:CGRectMake(40, yy, viewForSensorNameNum.frame.size.width-80, 70)];
        txtNameSnr.delegate = self;
        txtNameSnr.layer.cornerRadius = 6;
        txtNameSnr.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];
        txtNameSnr.textAlignment = NSTextAlignmentLeft;
        txtNameSnr.returnKeyType = UIReturnKeyDone;
        txtNameSnr.placeholder = @" Enter sensor Name";
        txtNameSnr.font = [UIFont fontWithName:CGRegular size:28];
        [viewForSensorNameNum addSubview:txtNameSnr];

    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        self->viewForSensorNameNum.frame = CGRectMake(150, (DEVICE_HEIGHT-300)/2, DEVICE_WIDTH-300, 300);
    }
                    completion:NULL];
}
#pragma mark-TextField method inside Connect
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtNameSnr)
     {
         [txtNameSnr resignFirstResponder];
     }
    return YES;
}
-(void)saveTimer
{
    [APP_DELEGATE endHudProcess];
    if ([arrySensors count] > selectedIndex)
     {
         [[arrySensors objectAtIndex:selectedIndex] setValue:txtNameSnr.text forKey:@"name"];
         [[arrySensors objectAtIndex:selectedIndex] setValue:@"1" forKey:@"isAdded"];
         [tblDeviceList reloadData];
     }
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeSuccess];
    [alert showAlertWithTitle:@"HQ-Inc App" withSubtitle:@"Sensor added Successfully" withCustomImage:[UIImage imageNamed:@"logo.png"] withDoneButtonTitle:OK_BTN andButtons:nil];
    [alert doneActionBlock:^{
    }];
}
-(void)AlertViewFCTypeCautionCheck:(NSString *)strMsg
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
-(NSString *)checkforValidString:(NSString *)strRequest
{
    NSString * strValid;
    if (![strRequest isEqual:[NSNull null]])
    {
        if (strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""])
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
    [btn setTitleColor:txtColor forState:UIControlStateNormal];
    btn.backgroundColor = backColor;
    btn.clipsToBounds = true;
}
#pragma mark - BLE Methods
-(void)StartSensorsScanning
{
    [APP_DELEGATE startHudProcess:@"Looking for Sensors..."];
    
    NSInteger intMsg = [@"0" integerValue];
    NSData * dataMsg = [[NSData alloc] initWithBytes:&intMsg length:1];

    NSLog(@"Wrote Command for Start Scanning Sensors---==%@",dataMsg);
    [[BLEService sharedInstance] WriteValuestoDevice:dataMsg withOcpde:@"21" withLength:@"0" with:globalPeripheral];
}
-(void)StopSensorsScanning
{
    NSInteger intMsg = [@"0" integerValue];
    NSData * dataMsg = [[NSData alloc] initWithBytes:&intMsg length:1];

    NSLog(@"Wrote Command for Stop Scanning Sensors---==%@",dataMsg);
    [[BLEService sharedInstance] WriteValuestoDevice:dataMsg withOcpde:@"22" withLength:@"0" with:globalPeripheral];
}
-(void)AddSensorsComplete
{
    NSInteger intMsg = [@"0" integerValue];
    NSData * dataMsg = [[NSData alloc] initWithBytes:&intMsg length:1];

    NSLog(@"Wrote Command for Add Sensors Complete---==%@",dataMsg);
    [[BLEService sharedInstance] WriteValuestoDevice:dataMsg withOcpde:@"09" withLength:@"0" with:globalPeripheral];
}

-(void)AddSensortoList:(NSString *)strSensorId withType:(NSString *)strSensorType
{
    if ([arrySensors count] > 0)
    {
        if (![[arrySensors valueForKey:@"sensor_id"] containsObject:strSensorId])
        {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:strSensorId,@"sensor_id",strSensorType,@"sensor_type",@"0",@"isAdded",@"",@"name", nil];
            [arrySensors addObject:dict];
        }
    }
    else
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:strSensorId,@"sensor_id",strSensorType,@"sensor_type",@"0",@"isAdded",@"",@"name", nil];
        [arrySensors addObject:dict];
    }
    tblDeviceList.hidden = NO;
    [tblDeviceList reloadData];
}
-(void)FailedtoAddSensor:(NSString *)strErrorCode withSensorID:(NSString *)strSensorID
{
    [APP_DELEGATE endHudProcess];
    NSString * strMsg = [NSString stringWithFormat:@"Sensor (%@) is having battery issue.",strSensorID];
    if ([strErrorCode isEqualToString:@"38"])
    {
        strMsg = [NSString stringWithFormat:@"Something went wrong. Not able to read temperature of Sensor(%@)",strSensorID];
    }
    else if([strErrorCode isEqualToString:@"66"])
    {
        strMsg = [NSString stringWithFormat:@"Sensor (%@) is having communication Error.",strSensorID];
    }

    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeWarning];
    [alert showAlertWithTitle:@"HQ-Inc App" withSubtitle:strMsg withCustomImage:[UIImage imageNamed:@"logo.png"] withDoneButtonTitle:OK_BTN andButtons:nil];
    [alert doneActionBlock:^{
    }];
}
-(void)SuccesfullyAddedSensor:(NSMutableDictionary *)dictData withSensorID:(NSString *)strSensorID
{
    if ([[arrySensors valueForKey:@"sensor_id"] containsObject:strSensorID])
    {
        NSInteger foundIndex = [[arrySensors valueForKey:@"sensor_id"] indexOfObject:strSensorID];
        if (foundIndex != NSNotFound)
        {
            if ([arrySensors count] > foundIndex)
            {
                [dictData setValue:@"1" forKey:@"isAdded"];
                [arrySensors replaceObjectAtIndex:foundIndex withObject:dictData];
                [self AlertViewFCTypeSuccess:@"Sensor added succesfully"];
                [tblDeviceList reloadData];
                isAnyAdded = YES;
            }
        }
    }
}

@end
