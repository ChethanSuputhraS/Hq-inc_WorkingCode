//
//  SessionAddVC.m
//  HQ-INC App
//
//  Created by Ashwin on 10/28/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "SessionAddVC.h"
#import "SessionReadVC.h"
#import "SessionCell.h"
#import "AddMonitorVC.h"
#import "AddSensorVC.h"
#import "HomeVC.h"


@interface SessionAddVC ()<UITableViewDelegate,UITableViewDataSource>
{
    UIView * viewAllSensor,*viewForListOfSensor;
    UITableView * tblListOfSensor;
    BOOL isRemoveSnrSelect;
    NSMutableArray * arrLiveDataSensors, * arrAddedSensors;
    NSInteger selectedIndex;
    UIButton * btnaddMonitor;
}
@end

@implementation SessionAddVC

- (void)viewDidLoad
{
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = UIColor.blackColor;
    
    
    UIColor *lblTxtClr = [UIColor colorWithRed:180.0/255 green:245.0/255 blue:254.0/255 alpha:1];
    
    lblHeader = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, DEVICE_WIDTH, 50)];
    [self setLabelProperties:lblHeader withText:@"SESSION" backColor:UIColor.clearColor textColor:lblTxtClr textSize:25];
    lblHeader.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lblHeader];
    
    UIButton * btnBck = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBck setFrame:CGRectMake(10, globalStatusHeight-5, 50, 50)];
    btnBck.backgroundColor = UIColor.clearColor;
//    [btnBck setImage:[UIImage imageNamed:@"backArr.png"] forState:UIControlStateNormal];
    [btnBck addTarget:self action:@selector(btnBckClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnBck];
    
    UIImageView * imgBack = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
    imgBack.image = [UIImage imageNamed:@"backArr.png"];
    [btnBck addSubview:imgBack];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, globalStatusHeight + 60 - 1, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line];
    
    int yy = 85;
     UIColor *btnBGColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    
    btnaddMonitor = [[UIButton alloc]initWithFrame:CGRectMake(5, yy, DEVICE_WIDTH/3-10, 70)];
    [self setButtonProperties:btnaddMonitor withTitle:@"Connect \n monitor" backColor:btnBGColor textColor:UIColor.whiteColor txtSize:25];
    [btnaddMonitor addTarget:self action:@selector(btnaddMonitorClick) forControlEvents:UIControlEventTouchUpInside];
    btnaddMonitor.layer.cornerRadius = 5;
    [self.view addSubview:btnaddMonitor];
    
     UIButton * btnaddsnr = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH/3, yy,  DEVICE_WIDTH/3-5, 70)];
     [self setButtonProperties:btnaddsnr withTitle:@"Add \n sensor" backColor:btnBGColor textColor:UIColor.whiteColor txtSize:25];
     [btnaddsnr addTarget:self action:@selector(btnaddSenesorClick) forControlEvents:UIControlEventTouchUpInside];
     btnaddsnr.layer.cornerRadius = 5;
     [self.view addSubview:btnaddsnr];
    
    UIButton * btnviewSensor = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH/3*2, yy,  DEVICE_WIDTH/3-5, 70)];
    [self setButtonProperties:btnviewSensor withTitle:@"view / Remove \n sensor" backColor:btnBGColor textColor:UIColor.whiteColor txtSize:25];
    [btnviewSensor addTarget:self action:@selector(btnViewSensorClick) forControlEvents:UIControlEventTouchUpInside];
    btnviewSensor.layer.cornerRadius = 5;
    [self.view addSubview:btnviewSensor];
    
    yy = yy+90;
    
    UIButton * btnstartSession = [[UIButton alloc]initWithFrame:CGRectMake(5, yy, DEVICE_WIDTH/2-10, 70)];
    [self setButtonProperties:btnstartSession withTitle:@"Start session" backColor:btnBGColor textColor:UIColor.whiteColor txtSize:25];
    [btnstartSession addTarget:self action:@selector(btnStartSessionClick) forControlEvents:UIControlEventTouchUpInside];
    btnstartSession.layer.cornerRadius = 5;
    [self.view addSubview:btnstartSession];

    UIButton * btnEndSession = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH/2, yy, DEVICE_WIDTH/2-5, 70)];
    [self setButtonProperties:btnEndSession withTitle:@"Stop session" backColor:btnBGColor textColor:UIColor.whiteColor txtSize:25];
    [btnEndSession addTarget:self action:@selector(btnStopSessionClick) forControlEvents:UIControlEventTouchUpInside];
    btnEndSession.layer.cornerRadius = 5;
    [self.view addSubview:btnEndSession];
    
    yy = yy +150;
    tbladdSession = [[UITableView alloc]initWithFrame: CGRectMake(5, yy, DEVICE_WIDTH-10, DEVICE_HEIGHT-yy) style:UITableViewStylePlain];
    tbladdSession.frame = CGRectMake(5, yy, DEVICE_WIDTH-10, DEVICE_HEIGHT-yy);
    tbladdSession.delegate = self;
    tbladdSession.dataSource = self;
    tbladdSession.allowsMultipleSelection = true;
    tbladdSession.backgroundColor = UIColor.clearColor;
    tbladdSession.separatorStyle = UITableViewScrollPositionNone;
    [self.view addSubview:tbladdSession];
    
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)btnBckClick
{
    [self.navigationController popViewControllerAnimated:true];
}
#pragma mark-tableview method
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}
#pragma mark- UITableView Methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    UIColor * btnBgClor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    UIView * headerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    headerView.backgroundColor = btnBgClor;
        
    UILabel *lblmenu=[[UILabel alloc]initWithFrame:CGRectMake(10,0, DEVICE_WIDTH/3, 50)];
    lblmenu.text = @"Sensors name";
    [lblmenu setTextColor:[UIColor whiteColor]];
    lblmenu.font = [UIFont fontWithName:CGRegular size:textSize+2];
    lblmenu.backgroundColor = UIColor.clearColor;
    lblmenu.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:lblmenu];
    
    UILabel *lblName =[[UILabel alloc]initWithFrame:CGRectMake(tbladdSession.frame.size.width/2,0, tbladdSession.frame.size.width/2-10, 50)];
    lblName.text = @"Temperature";
    [lblName setTextColor:[UIColor whiteColor]];
    lblName.font = [UIFont fontWithName:CGRegular size:textSize+2];
    lblName.backgroundColor = UIColor.clearColor;
    lblName.textAlignment = NSTextAlignmentRight;
    [headerView addSubview:lblName];
    
    if (tableView == tblListOfSensor)
    {
        lblName.frame = CGRectMake(tblListOfSensor.frame.size.width/2,0, tblListOfSensor.frame.size.width/2-10, 50);
        lblName.hidden = true;
        
    }
        
    return headerView;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblListOfSensor)
    {
        return arrAddedSensors.count;
    }
    else
    {
        return arrLiveDataSensors.count;
    }
    return true;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    SessionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[SessionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }


    if (tableView == tblListOfSensor)
    {
        cell.lblname.text = [NSString stringWithFormat:@"%@ (%@)",[[arrAddedSensors objectAtIndex:indexPath.row] valueForKey:@"sensor_id"],[[arrAddedSensors objectAtIndex:indexPath.row] valueForKey:@"sensor_type"]];
        cell.lblTemp.text = [[arrAddedSensors objectAtIndex:indexPath.row] valueForKey:@"name"];

        cell.lblTemp.frame = CGRectMake(DEVICE_WIDTH/2-10, 0, DEVICE_WIDTH/3, 60);
        cell.viewSelect.frame = CGRectMake(tableView.frame.size.width - 40, 17, 30, 30);
        
        if ([[[arrLiveDataSensors objectAtIndex:indexPath.row] valueForKey:@"isRemoveSelected"] isEqualToString:@"1"])
         {
             cell.viewSelect.image = [UIImage imageNamed:@"greenSelected.png"];
         }
         else
         {
             cell.viewSelect.image = [UIImage imageNamed:@"radioUnselected.png"];
         }
    }
    else
    {
        cell.lblname.text = @"Sensor1";
        cell.lblTemp.text = @"100ºF";

    }

    if (indexPath.row % 2 == 0)
    {
        cell.backgroundColor = [UIColor colorWithRed:230.0/255.0f green:230.0/255.0f blue:230.0/255.0f alpha:1];
    }
    else
    {
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    cell.backgroundColor = UIColor.clearColor;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = indexPath.row;
    if (tableView == tblListOfSensor)
    {
        if ([[[arrAddedSensors objectAtIndex:indexPath.row] valueForKey:@"isRemoveSelected"] isEqualToString:@"0"])
        {
            [[arrAddedSensors objectAtIndex:indexPath.row] setObject:@"1" forKey:@"isRemoveSelected"];
        }
        else if ([[[arrAddedSensors objectAtIndex:indexPath.row] valueForKey:@"isRemoveSelected"] isEqualToString:@"1"])
        {
            [[arrAddedSensors objectAtIndex:indexPath.row] setObject:@"0" forKey:@"isRemoveSelected"];
        }
        [tblListOfSensor reloadData];
    }
}
#pragma mark- Buttons method
-(void)btnaddSenesorClick
{
    AddSensorVC * addvc = [[AddSensorVC alloc] init];
    [self.navigationController pushViewController:addvc animated:true];
}
-(void)btnaddMonitorClick
{
    HomeVC * addMVC = [[HomeVC alloc] init];
    [self.navigationController pushViewController:addMVC animated:true];
}
-(void)btnViewSensorClick
{
//    if (arrLiveDataSensors.count == 0)
//    {
//        [self AlertViewFCTypeCaution:@"Sensor not added."];
//    }
//    else
//    {
//        isRemoveSnrSelect = NO;
        [self setupForViewAllSensors];
//    }
}
-(void)btnStartSessionClick
{
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        [self StartSessionCommandtoDevice];
    }
    else
    {
        [self AlertViewFCTypeCaution:@"Please make sure Monitor is connected with App and then try again to Start Session."];
    }
}
-(void)btnStopSessionClick
{
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        [self StopSessionCommandtoDevice];
    }

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

    UIButton *btnSelectOk = [[UIButton alloc]initWithFrame:CGRectMake(viewForListOfSensor.frame.size.width-120, 0, 110, 60)]; // (viewForListOfSensor.frame.size.width-60, 0, 50, 60)
    [self setButtonProperties:btnSelectOk withTitle:@"Remove" backColor:UIColor.clearColor textColor:UIColor.whiteColor txtSize:25];
    [btnSelectOk addTarget:self action:@selector(btnOkSelClick) forControlEvents:UIControlEventTouchUpInside];
    [viewForBgAllSnr addSubview:btnSelectOk];

//    if(isRemoveSnrSelect == YES)
//    {
//        [arrLiveDataSensors setValue:@"0" forKey:@"isRemoveSelected"];
//        btnSelectOk.frame = CGRectMake(viewForListOfSensor.frame.size.width-120, 0, 100, 60);
//        [btnSelectOk setTitle:@"Remove" forState:UIControlStateNormal];
//    }
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
        for (int i = 0; i<arrLiveDataSensors.count; i++)
        {
            if ([[[arrLiveDataSensors objectAtIndex:i] valueForKey:@"isRemoveSelected"] isEqualToString:@"1"])
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
            NSString * strName = [[arrLiveDataSensors objectAtIndex:selectedIndex] valueForKey:@"name"];
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
                for (int i = 0; i<[self->arrLiveDataSensors count]; i++)
                {
                    if ([[[self->arrLiveDataSensors objectAtIndex:i] objectForKey:@"isRemoveSelected"] isEqualToString:@"1"])
                    {
                        [tmparr addObject:[self->arrLiveDataSensors objectAtIndex:i]];
                    }
                }
                for (int k = 0; k<tmparr.count; k++)
                {
                    NSInteger foundIndex = [self->arrLiveDataSensors indexOfObject:[tmparr objectAtIndex:k]];
                    if (foundIndex != NSNotFound)
                    {
                        if (self->arrLiveDataSensors.count > foundIndex)
                        {
                            [self->arrLiveDataSensors removeObjectAtIndex:foundIndex];
//                            lblNosensor.text = [NSString stringWithFormat:@"%lu Sensor Added",(unsigned long)arrLiveDataSensors.count];
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
    btn.titleLabel.numberOfLines = 0;
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
//    lblAddmonitorConnect.text = [NSString stringWithFormat:@"%@ Added",strDeviceName];
    [self setButtonProperties:btnaddMonitor withTitle:@"Monitor\nConnected" backColor:[UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1] textColor:UIColor.whiteColor txtSize:25];

}
-(void)SetupDemoFromAddSensorData:(NSMutableArray *)arryData
{
    arrAddedSensors = [[NSMutableArray alloc] init];
    arrAddedSensors = arryData;
}
#pragma mark-BLE  Methoda
-(void)StartSessionCommandtoDevice
{
    NSInteger intMsg = [@"0" integerValue];
    NSData * dataMsg = [[NSData alloc] initWithBytes:&intMsg length:1];

    NSLog(@"Wrote Command for Start Session---==%@",dataMsg);
    [[BLEService sharedInstance] WriteValuestoDevice:dataMsg withOcpde:@"12" withLength:@"0" with:globalPeripheral];
}
-(void)StopSessionCommandtoDevice
{
    NSInteger intMsg = [@"0" integerValue];
    NSData * dataMsg = [[NSData alloc] initWithBytes:&intMsg length:1];

    NSLog(@"Wrote Command for Start Session---==%@",dataMsg);
    [[BLEService sharedInstance] WriteValuestoDevice:dataMsg withOcpde:@"13" withLength:@"0" with:globalPeripheral];
}

-(void)StartSessionConfirmation:(BOOL)isSessionStartSuccess;
{
    if (isSessionStartSuccess == NO)
    {
        [self AlertViewFCTypeCaution:@"Something went wrong with Start Session. Please try again."];
    }
    else
    {
        FCAlertView *alert = [[FCAlertView alloc] init];
         alert.colorScheme = [UIColor blackColor];
         [alert makeAlertTypeSuccess];
         [alert showAlertInView:self
                      withTitle:@"HQ-Inc"
                   withSubtitle:@"Session has started successfully."
                withCustomImage:[UIImage imageNamed:@"logo.png"]
            withDoneButtonTitle:nil
                     andButtons:nil];
    }
}
@end
