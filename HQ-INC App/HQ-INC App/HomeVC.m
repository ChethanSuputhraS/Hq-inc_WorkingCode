//
//  HomeVC.m
//  HoldItWrite
//
//  Created by Ashwin on 7/28/20.
//  Copyright © 2020 Chethan. All rights reserved.
//
#import "HomeVC.h"
#import "HomeCell.h"
#import "BLEService.h"
#import "HomeCell.h"
#import "BleTestClass.h"


@interface HomeVC ()<UITableViewDelegate,UITableViewDataSource,FCAlertViewDelegate,CBCentralManagerDelegate,UITextFieldDelegate, BLEConnectionDelegate>
{
    NSTimer * connectionTimer, * advertiseTimer;;
    CBCentralManager * centralManager;
    CBPeripheral * classPeripheral;
    NSMutableDictionary * dictConnectedPeripheral, * dictLiveSessionData;
    UIButton *btnCanceldown,*btnDone;
    FCAlertView *alertConnection;
    NSInteger totalSensorsofLiveSession;
    NSMutableArray * arrSensorsofSessions;
}
@end

@implementation HomeVC

- (void)viewDidLoad
{
    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = UIColor.blackColor;
    [self setNeedsStatusBarAppearanceUpdate];

    [self setNavigationViewFrames];
    arrGlobalDevices = [[NSMutableArray alloc] init];

    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    arrSensorsofSessions = [[NSMutableArray alloc] init];
    /*[advertiseTimer invalidate];
    advertiseTimer = nil;
    advertiseTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(AdvertiseTimerMethod) userInfo:nil repeats:NO];*/

    [APP_DELEGATE endHudProcess];
//    [APP_DELEGATE startHudProcess:@"Scanning..."];

    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(void)viewWillAppear:(BOOL)animated
{
    [self InitialBLE];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AuthenticationCompleted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AuthenticationCompleted:) name:@"AuthenticationCompleted" object:nil];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateUTCtime" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateCurrentGPSlocation" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AuthenticationCompleted" object:nil];
    [super viewWillDisappear:YES];
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    int yy = 64;
    
    self.view.backgroundColor = UIColor.blackColor;
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, yy )];
    [viewHeader setBackgroundColor:UIColor.clearColor];//[UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1]];
    [self.view addSubview:viewHeader];
    
    UIColor * lbltxtClor = [UIColor colorWithRed:180.0/255 green:245.0/255 blue:254.0/255 alpha:1];

    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, DEVICE_WIDTH, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Add Monitor"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize-6]];
    [lblTitle setTextColor:lbltxtClor];
    [viewHeader addSubview:lblTitle];
        
    UIButton * btnRefresh = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRefresh setFrame:CGRectMake(DEVICE_WIDTH-50, 20, 44, 44)];
    btnRefresh.backgroundColor = UIColor.clearColor;
    [btnRefresh setImage:[UIImage imageNamed:@"reload.png"] forState:UIControlStateNormal];
    [btnRefresh addTarget:self action:@selector(refreshBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnRefresh];
    
    
    UIColor * btnBgClor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
     
    btnCanceldown = [[UIButton alloc]initWithFrame:CGRectMake(10, DEVICE_HEIGHT-60, 60, 44)];
    [self setButtonProperties:btnCanceldown withTitle:@"Cancel" backColor:btnBgClor textColor:UIColor.whiteColor txtSize:textSize-6];
    btnCanceldown.layer.cornerRadius = 5;
    [btnCanceldown addTarget:self action:@selector(btnCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCanceldown];
        
    btnDone = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-80, DEVICE_HEIGHT-60, 60, 44)];
    [self setButtonProperties:btnDone withTitle:@"Done" backColor:btnBgClor textColor:UIColor.whiteColor txtSize:textSize-6];
    btnDone.layer.cornerRadius = 5;
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    btnDone.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    [btnDone addTarget:self action:@selector(btnDoneClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnDone];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0,  yy - 1, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [viewHeader addSubview:line];
    
    tblDeviceList = [[UITableView alloc] initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH, DEVICE_HEIGHT-yy-50)];
    tblDeviceList.delegate = self;
    tblDeviceList.dataSource= self;
    tblDeviceList.backgroundColor = UIColor.clearColor;
//    tblDeviceList.separatorStyle = UITableViewCellSelectionStyleNone;
    [tblDeviceList setShowsVerticalScrollIndicator:NO];
    tblDeviceList.backgroundColor = [UIColor clearColor];
    tblDeviceList.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblDeviceList.separatorColor = [UIColor darkGrayColor];
    [self.view addSubview:tblDeviceList];
    
    topPullToRefreshManager = [[MNMPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:tblDeviceList withClient:self];
    [topPullToRefreshManager setPullToRefreshViewVisible:YES];
    [topPullToRefreshManager tableViewReloadFinishedAnimated:YES];
    
    yy = yy+30;
    
    lblScanning = [[UILabel alloc] initWithFrame:CGRectMake((DEVICE_WIDTH/2)-50, yy, 100, 44)];
    [lblScanning setBackgroundColor:[UIColor clearColor]];
    [lblScanning setText:@"Scanning..."];
    [lblScanning setTextAlignment:NSTextAlignmentCenter];
    [lblScanning setFont:[UIFont fontWithName:CGRegular size:textSize]];
    [lblScanning setTextColor:[UIColor blackColor]];
    lblScanning.hidden = true;
    [self.view addSubview:lblScanning];

    lblNoDevice = [[UILabel alloc]initWithFrame:CGRectMake(30, (DEVICE_HEIGHT/2)-90, (DEVICE_WIDTH)-60, 100)];
    lblNoDevice.backgroundColor = UIColor.clearColor;
    [lblNoDevice setTextAlignment:NSTextAlignmentCenter];
    [lblNoDevice setFont:[UIFont fontWithName:CGRegular size:textSize+2]];
    [lblNoDevice setTextColor:[UIColor blackColor]];
    lblNoDevice.text = @"Looking for Monitor.";
    [self.view addSubview:lblNoDevice];
}
#pragma mark- UITableView Methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
{
    UIView * headerView =[[UIView alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-20, 50)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *lblmenu=[[UILabel alloc]initWithFrame:CGRectMake(10,0, DEVICE_WIDTH-20, 50)];
    lblmenu.text = @" Tap on Connect button to pair with device";
    [lblmenu setTextColor:[UIColor whiteColor]];
    [lblmenu setFont:[UIFont fontWithName:CGRegular size:textSize-6]];
    lblmenu.backgroundColor = UIColor.clearColor;
    lblmenu.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:lblmenu];
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
    return [[[BLEManager sharedManager] foundDevices] count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[HomeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
        
    NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
    arrayDevices =[[BLEManager sharedManager] foundDevices];
    cell.lblConnect.text= @"Connect";
    CBPeripheral * p = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"peripheral"];
    if (p.state == CBPeripheralStateConnected)
    {
        cell.lblConnect.frame = CGRectMake(DEVICE_WIDTH-150, 0, 150, 70);
        cell.lblConnect.text= @"Disconnect";
    }
    cell.lblDeviceName.text = [[arrayDevices  objectAtIndex:indexPath.row]valueForKey:@"name"];
    cell.lblAddress.text = [[arrayDevices  objectAtIndex:indexPath.row]valueForKey:@"bleAddress"];
    
    if (indexPath.row % 2 == 0)
    {
        cell.backgroundColor = [UIColor colorWithRed:230.0/255.0f green:230.0/255.0f blue:230.0/255.0f alpha:1];
    }
    else
    {
        cell.backgroundColor = [UIColor lightGrayColor];
    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = UIColor.clearColor;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
    arrayDevices =[[BLEManager sharedManager] foundDevices];
    if ([[[arrayDevices  objectAtIndex:indexPath.row]valueForKey:@"name"] isEqualToString:@"log"])
    {
        return;
    }
    if ([arrayDevices count]> indexPath.row)
    {
        CBPeripheral * p = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"peripheral"];
        if (p.state == CBPeripheralStateConnected)
        {
            connectionTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(ConnectionTimeOutMethod) userInfo:nil repeats:NO];
            [APP_DELEGATE startHudProcess:@"Disconnecting..."];
            [[BLEManager sharedManager] disconnectDevice:p];
        }
        else
        {
            [[BLEService sharedInstance] setBleConnectdelegate:self];

            [connectionTimer invalidate];
            connectionTimer = nil;
            connectionTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(ConnectionTimeOutMethod) userInfo:nil repeats:NO];
            isConnectedtoAdd = YES;
            classPeripheral = p;
            [APP_DELEGATE startHudProcess:@"Connecting..."];
            [[BLEManager sharedManager] connectDevice:p];
            dictConnectedPeripheral = [[NSMutableDictionary alloc] init];
            dictConnectedPeripheral = [arrayDevices objectAtIndex:indexPath.row];
        }
    }
}
-(void)AddTestingRecords:(NSDictionary *)dict
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [[[BLEManager sharedManager] foundDevices] addObject:dict];
        NSIndexPath *index = [NSIndexPath indexPathForRow:([[[BLEManager sharedManager] foundDevices] count] - 1) inSection:0];
        [self->tblDeviceList insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
    });
}
#pragma mark - BLE Methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (@available(iOS 10.0, *)) {
        if (central.state == CBManagerStatePoweredOff)
        {
            [APP_DELEGATE endHudProcess];
            [self GlobalBLuetoothCheck];
        }
    } else
    {
        
    }
}
-(void)InitialBLE
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotifiyDiscoveredDevices" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidConnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidDisConnectNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NotifiyDiscoveredDevices:) name:@"NotifiyDiscoveredDevices" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidConnectNotification:) name:@"DeviceDidConnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidDisConnectNotification:) name:@"DeviceDidDisConnectNotification" object:nil];
    
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        NSMutableArray * arrDevices = [[NSMutableArray alloc] init];
        arrDevices =[[BLEManager sharedManager] foundDevices];
        if (![[arrDevices valueForKey:@"peripheral"] containsObject:globalPeripheral])
        {
            if ([[arrGlobalDevices valueForKey:@"peripheral"] containsObject:globalPeripheral])
            {
                NSInteger foundIndex = [[arrGlobalDevices valueForKey:@"peripheral"] indexOfObject:globalPeripheral];
                if (foundIndex != NSNotFound)
                {
                    if ([arrGlobalDevices count] > foundIndex)
                    {
                        [[[BLEManager sharedManager] foundDevices] addObject:[arrGlobalDevices objectAtIndex:foundIndex]];
                    }
                }
            }
            else
            {
                NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:globalPeripheral.identifier,@"identifier",globalPeripheral,@"peripheral",globalPeripheral.name,@"name",@"NA",@"bleAddress", nil];
                [[[BLEManager sharedManager] foundDevices] addObject:dict];
            }
        }
        [tblDeviceList reloadData];
    }
}
-(void)NotifiyDiscoveredDevices:(NSNotification*)notification//Update peripheral
{
dispatch_async(dispatch_get_main_queue(), ^(void){
    
    if ( [[[BLEManager sharedManager] foundDevices] count] >0){
        self->tblDeviceList.hidden = false;
        self->lblNoDevice.hidden = true;
        [self->tblDeviceList reloadData];
//        [self->advertiseTimer invalidate];
//        self->advertiseTimer = nil;
        [APP_DELEGATE endHudProcess];
    }
    else
    {
        self->tblDeviceList.hidden = true;
        self->lblNoDevice.hidden = false;}
        [self->tblDeviceList reloadData];});
}
-(void)DeviceDidConnectNotification:(NSNotification*)notification//Connect periperal
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
//        [APP_DELEGATE endHudProcess];
        [self->tblDeviceList reloadData];
    });
}
-(void)DeviceDidDisConnectNotification:(NSNotification*)notification//Disconnect periperal
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        [[[BLEManager sharedManager] foundDevices] removeAllObjects];
        [[BLEManager sharedManager] rescan];
        [self->tblDeviceList reloadData];
        [APP_DELEGATE endHudProcess];
    });
}
-(void)AuthenticationCompleted:(NSNotification *)notify
{
}
-(void)GlobalBLuetoothCheck
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Geofence Alert" message:@"Please enable Bluetooth Connection. Tap on enable Bluetooth icon by swiping Up." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
    [alertController addAction:defaultAction];
    [self presentViewController:alertController animated:true completion:nil];
}

-(void)TurnonLED
{
    
}
#pragma mark - Timer Methods
-(void)ConnectionTimeOutMethod
{
    [APP_DELEGATE endHudProcess];

    if (classPeripheral.state == CBPeripheralStateConnected)
    {
    }
    else
    {
        if (classPeripheral == nil)
        {
            return;
        }
        [APP_DELEGATE endHudProcess];
//        FCAlertView *alert = [[FCAlertView alloc] init];
//        [alert makeAlertTypeCaution];
//        alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSize];
//        [alert showAlertWithTitle:@"HQ-INC" withSubtitle:@"Something went wrong. Please try again later." withCustomImage:[UIImage imageNamed:@"alert-round.png"] withDoneButtonTitle:@"OK" andButtons:nil];
    }
}
-(void)AdvertiseTimerMethod
{
    [APP_DELEGATE endHudProcess];
    if ( [[[BLEManager sharedManager] foundDevices] count] >0){
        self->tblDeviceList.hidden = false;
        self->lblNoDevice.hidden = true;
        [self->tblDeviceList reloadData];
    }
    else
    {
        self->tblDeviceList.hidden = true;
        self->lblNoDevice.hidden = false;
    }
        [self->tblDeviceList reloadData];
}

#pragma mark- Buttons
-(void)refreshBtnClick
{
    //[self setupForAddSensor];
    [[[BLEManager sharedManager] foundDevices] removeAllObjects];
    [[BLEManager sharedManager] rescan];
    [tblDeviceList reloadData];
    
    NSArray * tmparr = [[BLEManager sharedManager]getLastConnected];
    for (int i=0; i<tmparr.count; i++)
    {
        CBPeripheral * p = [tmparr objectAtIndex:i];
        NSString * strCurrentIdentifier = [NSString stringWithFormat:@"%@",p.identifier];
        if ([[arrGlobalDevices valueForKey:@"identifier"] containsObject:strCurrentIdentifier])
        {
            NSInteger  foudIndex = [[arrGlobalDevices valueForKey:@"identifier"] indexOfObject:strCurrentIdentifier];
            if (foudIndex != NSNotFound)
            {
                if ([arrGlobalDevices count] > foudIndex)
                {
                    if (![[[[BLEManager sharedManager] foundDevices] valueForKey:@"identifier"] containsObject:strCurrentIdentifier])
                    {
                        [[[BLEManager sharedManager] foundDevices] addObject:[arrGlobalDevices objectAtIndex:foudIndex]];
                    }
                }
            }
        }
    }
    
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        NSMutableArray * arrDevices = [[NSMutableArray alloc] init];
        arrDevices =[[BLEManager sharedManager] foundDevices];
        if (![[arrDevices valueForKey:@"peripheral"] containsObject:globalPeripheral])
        {
            if ([[arrGlobalDevices valueForKey:@"peripheral"] containsObject:globalPeripheral])
            {
                NSInteger foundIndex = [[arrGlobalDevices valueForKey:@"peripheral"] indexOfObject:globalPeripheral];
                if (foundIndex != NSNotFound)
                {
                    if ([arrGlobalDevices count] > foundIndex)
                    {
                        [[[BLEManager sharedManager] foundDevices] addObject:[arrGlobalDevices objectAtIndex:foundIndex]];
                    }
                }
            }
            else
            {
                NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:globalPeripheral.identifier,@"identifier",globalPeripheral,@"peripheral",globalPeripheral.name,@"name",@"NA",@"bleAddress", nil];
                [[[BLEManager sharedManager] foundDevices] addObject:dict];
            }
        }
        [tblDeviceList reloadData];
    }
    if ( [[[BLEManager sharedManager] foundDevices] count] >0)
    {
        tblDeviceList.hidden = false;
        lblNoDevice.hidden = true;
//        [advertiseTimer invalidate];
//        advertiseTimer = nil;
        [tblDeviceList reloadData];
    }
    else
    {
        tblDeviceList.hidden = true;
        lblNoDevice.hidden = false;
//        [advertiseTimer invalidate];
//        advertiseTimer = nil;
//        advertiseTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(AdvertiseTimerMethod) userInfo:nil repeats:NO];
    }
}
-(void)btnDoneClick
{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)btnCancelClick
{
    [self.navigationController popViewControllerAnimated:true];
}
#pragma mark - MEScrollToTopDelegate Methods
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [topPullToRefreshManager tableViewScrolled];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y >=360.0f)
    {
    }
    else
        [topPullToRefreshManager tableViewReleased];
}
- (void)pullToRefreshTriggered:(MNMPullToRefreshManager *)manager
{
    [self performSelector:@selector(stoprefresh) withObject:nil afterDelay:1.5];
}
-(void)stoprefresh
{
    [self refreshBtnClick];
    [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];
}
-(NSString *)base64String:(NSString *)str
{
    NSData *theData = [str dataUsingEncoding: NSASCIIStringEncoding];
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++)
        {
            value <<= 8;
            if (j < length) {
                
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
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
    lblAddSnr.text = @"Add Sensor Name";
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
    txtNameSnr.placeholder = @"Sensor Name";
    txtNameSnr.font = [UIFont fontWithName:CGRegular size:28];
    [viewForSensorNameNum addSubview:txtNameSnr];
    

    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        self->viewForSensorNameNum.frame = CGRectMake(150, (DEVICE_HEIGHT-300)/2, DEVICE_WIDTH-300, 300);
    }
        completion:NULL];
    }

#pragma mark-TextField method
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtNameSnr)
     {
         [txtNameSnr resignFirstResponder];
     }
    return textField;
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
-(void)btnSaveClick
{
    if ([txtNameSnr.text isEqual:@""])
    {
        [self AlertViewFCTypeCautionCheck:@"Please enter sensor name."];
    }
    else
    {
      // sensor name adding process
        
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
-(void)setButtonProperties:(UIButton *)btn withTitle:(NSString *)strText backColor:(UIColor *)backColor textColor:(UIColor *)txtColor txtSize:(int)txtSize
{
    [btn setTitle:strText forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize];
    [btn setTitleColor:txtColor forState:UIControlStateNormal];
    btn.backgroundColor = backColor;
    btn.clipsToBounds = true;
}
-(void)MonitorConnnectedIsSessionActive:(BOOL)isSessionActive;
{
    if (isSessionActive == NO)
    {
        [APP_DELEGATE endHudProcess];

        globalPeripheral = classPeripheral;
        NSMutableArray * tmpArr = [[BLEManager sharedManager] foundDevices];
        if ([[tmpArr valueForKey:@"peripheral"] containsObject:globalPeripheral])
        {
            NSInteger  foudIndex = [[tmpArr valueForKey:@"peripheral"] indexOfObject:globalPeripheral];
            if (foudIndex != NSNotFound)
            {
                if ([tmpArr count] > foudIndex)
                {
                    NSString * strCurrentIdentifier = [NSString stringWithFormat:@"%@",globalPeripheral.identifier];
                    NSString * strName = [[tmpArr  objectAtIndex:foudIndex]valueForKey:@"name"];
                    NSString * strAddress = [[tmpArr  objectAtIndex:foudIndex]valueForKey:@"bleAddress"];

                    if (![[arrGlobalDevices valueForKey:@"identifier"] containsObject:strCurrentIdentifier])
                    {
                        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:strCurrentIdentifier,@"identifier",globalPeripheral,@"peripheral",strName,@"name",strAddress,@"bleAddress", nil];
                        [arrGlobalDevices addObject:dict];
                        NSLog(@"AuthenticationCompleted with Global Devices=%@",arrGlobalDevices);
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            [self->alertConnection removeFromSuperview];
            self->alertConnection = [[FCAlertView alloc] init];
            [self->alertConnection makeAlertTypeSuccess];
            self->alertConnection.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSize];
            [self->alertConnection showAlertWithTitle:@"HQ-INC" withSubtitle:@"Monitor connected successfully.." withCustomImage:[UIImage imageNamed:@"alert-round.png"] withDoneButtonTitle:@"OK" andButtons:nil];
            [self->alertConnection doneActionBlock:^{
                [globalSbuSetupVC ConnectedMonitorDetail:self->dictConnectedPeripheral];
                [[BLEManager sharedManager] stopScan];

                [self.navigationController popViewControllerAnimated:true];
            }];
        });

    }
    else
    {
        globalPeripheral = classPeripheral;

        arrSensorsofSessions = [[NSMutableArray alloc] init];
    }
}
-(void)RecieveLiveSessionInformation:(NSMutableDictionary *)dictDetail
{
    dictLiveSessionData = [[NSMutableDictionary alloc] init];
    dictLiveSessionData = [dictDetail mutableCopy];
    if ([[dictDetail allKeys] containsObject:@"no_of_sensor"])
    {
        totalSensorsofLiveSession = [[dictLiveSessionData valueForKey:@"no_of_sensor"] integerValue];
    }
}
-(void)RecieveLiveSessionPlayerName:(NSString *)strPlayerName
{
    
}
-(void)RecieveLiveSensorInformationofSession:(NSMutableArray *)arrSensors
{
    NSLog(@"====RecieveLiveSensorInformationofSession===%@",arrSensors);
    for (int i = 0; i < arrSensors.count; i++)
    {
        [arrSensorsofSessions addObject:[arrSensors objectAtIndex:i]];
    }
    
    if (self->alertConnection)
    {
            [self->alertConnection removeFromSuperview];
    }
    [APP_DELEGATE endHudProcess];

    if ([arrSensorsofSessions count] == totalSensorsofLiveSession)
    {
        if ([[dictLiveSessionData allKeys] containsObject:@"player_id"])
        {
            NSString * strPlayerId = [self checkforValidString:[dictLiveSessionData valueForKey:@"player_id"]];
            NSString * strPlayerName = [self checkforValidString:[dictLiveSessionData valueForKey:@"player_name"]];
            NSString * strQyery = [NSString stringWithFormat:@"select * from Subject_Table where user_id = '%@'",strPlayerId];
            NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
            [[DataBaseManager dataBaseManager] execute:strQyery resultsArray:tmpArr];
            NSString * strMsg = @"";
            NSString * strButtonTitle = @"OK";
            BOOL isPlayerFound = NO;
            if ([tmpArr count] > 0 )
            {
                isPlayerFound = YES;
                strButtonTitle = @"No";
                strMsg = [NSString stringWithFormat:@"Monitor is doing Live Session for %@. Do you want to see Live Reading of Session?",strPlayerName];
            }
            else
            {
                strMsg = [NSString stringWithFormat:@"Monitor is busy with Live Session. Please connect later."];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                FCAlertView *alert = [[FCAlertView alloc] init];
                [alert makeAlertTypeWarning];
                alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSize];
                [alert showAlertWithTitle:@"HQ-INC" withSubtitle:strMsg withCustomImage:[UIImage imageNamed:@"alert-round.png"] withDoneButtonTitle:strButtonTitle andButtons:nil];
                [alert doneActionBlock:^{
                        [[BLEManager sharedManager] disconnectDevice:self->classPeripheral];
                        [self.navigationController popToRootViewControllerAnimated:YES];

                
                    
                }];
                
                if (isPlayerFound)
                {
                    [alert addButton:@"Yes" withActionBlock:
                     ^{
                        {
                            for (UIViewController *vc in self.navigationController.viewControllers)
                            {
                                if ([vc isKindOfClass:[SubjDetailsVC class]])
                                {
                                    if (vc == globalSubjectDetailVC)
                                    {
                                        [globalSubjectDetailVC ReceiveSensorDetails:self->arrSensorsofSessions];
                                        [globalSubjectDetailVC LiveSessionReadingStarted:self->dictLiveSessionData];
                                    }
                                    [self.navigationController popToViewController:vc animated:YES];
                                }
                            }

                        }
                    }];
                }
            });
        }
    }
}
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

@end
