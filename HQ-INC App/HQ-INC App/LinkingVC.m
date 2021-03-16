//
//  LinkingVC.m
//  HQ-INC App
//
//  Created by Ashwin on 3/27/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "LinkingVC.h"
#import "HomeCell.h"
#import "BLEService.h"
#import "HomeCell.h"
#import "BleTestClass.h"
#import "SessionPlayersVC.h"

@import iOSDFULibrary;

@interface LinkingVC ()<UITableViewDelegate,UITableViewDataSource, CBCentralManagerDelegate, FCAlertViewDelegate, BLEServiceDelegate>
{
    NSTimer * connectionTimer, * advertiseTimer;;
    CBCentralManager * centralManager;
    CBPeripheral * classPeripheral;
    NSMutableDictionary * dictConnectedPeripheral;
    UIButton *btnCanceldown,*btnDone;
    
    NSMutableDictionary * dictSessionData;
    int sensorCount;
    NSMutableArray * arrSessionData, * arrSensorsofSessions, * arrSessions;
    NSString * strCurrentSequence;
    int indexofSession;

}
@end

@implementation LinkingVC

- (void)viewDidLoad
{
    
    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = UIColor.blackColor;
    [self setNeedsStatusBarAppearanceUpdate];

    [self setNavigationViewFrames];
    arrGlobalDevices = [[NSMutableArray alloc] init];

    arrSessions = [[NSMutableArray alloc] init];
    dictSessionData = [[NSMutableDictionary alloc] init];
    arrSessionData = [[NSMutableArray alloc] init];
    arrSensorsofSessions = [[NSMutableArray alloc] init];

    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    /*[advertiseTimer invalidate];
    advertiseTimer = nil;
    advertiseTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(AdvertiseTimerMethod) userInfo:nil repeats:NO];*/

    [APP_DELEGATE endHudProcess];
//    [APP_DELEGATE startHudProcess:@"Scanning..."];

    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Sync Sessions"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize+5]];
    [lblTitle setTextColor:lbltxtClor];
    [viewHeader addSubview:lblTitle];
        
    UIButton * btnRefresh = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRefresh setFrame:CGRectMake(DEVICE_WIDTH-60, 10, 50, 55)];
    btnRefresh.backgroundColor = UIColor.clearColor;
    [btnRefresh setImage:[UIImage imageNamed:@"reload.png"] forState:UIControlStateNormal];
    [btnRefresh addTarget:self action:@selector(refreshBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnRefresh];
    
    
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
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, globalStatusHeight + yy - 1, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [viewHeader addSubview:line];
    
    tblDeviceList = [[UITableView alloc] initWithFrame:CGRectMake(0, yy+globalStatusHeight, DEVICE_WIDTH, DEVICE_HEIGHT-yy-globalStatusHeight-100)];
    tblDeviceList.delegate = self;
    tblDeviceList.dataSource= self;
    tblDeviceList.backgroundColor = UIColor.clearColor;
    tblDeviceList.separatorStyle = UITableViewCellSelectionStyleNone;
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
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
#pragma mark - Buttons
-(void)btnAddClick
{
    
}
-(void)btnCancelClick
{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)btnDoneClick
{
    
}
#pragma mark- UITableView Methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
{
        UIView * headerView =[[UIView alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-20, 50)];
        headerView.backgroundColor = [UIColor clearColor];
        
        UILabel *lblmenu=[[UILabel alloc]initWithFrame:CGRectMake(10,0, DEVICE_WIDTH-20, 50)];
        lblmenu.text = @" Tap on Connect button to pair with device";
        [lblmenu setTextColor:[UIColor whiteColor]];
        [lblmenu setFont:[UIFont fontWithName:CGRegular size:textSize-1]];
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = UIColor.clearColor;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        [APP_DELEGATE endHudProcess];
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
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        FCAlertView *alert = [[FCAlertView alloc] init];
        [alert makeAlertTypeSuccess];
        alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSize];
        [alert showAlertWithTitle:@"HQ-INC" withSubtitle:@"Monitor connected successfully.." withCustomImage:[UIImage imageNamed:@"alert-round.png"] withDoneButtonTitle:@"OK" andButtons:nil];
        [alert doneActionBlock:^{
            [globalSbuSetupVC ConnectedMonitorDetail:self->dictConnectedPeripheral];
            [[BLEManager sharedManager] stopScan];

            [APP_DELEGATE startHudProcess:@"Fetching Sessions..."];
                [[BLEService sharedInstance] setDelegate:self];
            //    [self generateDummyData];
                [self WriteCommandtoGetStoredSessions];
        }];
    });
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
//    [APP_DELEGATE endHudProcess];

    if (classPeripheral.state == CBPeripheralStateConnected)
    {
    }
    else
    {
        if (classPeripheral == nil)
        {
            return;
        }
//        [APP_DELEGATE endHudProcess];
//        FCAlertView *alert = [[FCAlertView alloc] init];
//        [alert makeAlertTypeCaution];
//        alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSize];
//        [alert showAlertWithTitle:@"HQ-INC" withSubtitle:@"Something went wrong. Please try again later." withCustomImage:[UIImage imageNamed:@"alert-round.png"] withDoneButtonTitle:@"OK" andButtons:nil];
    }
}
-(void)AdvertiseTimerMethod
{
//    [APP_DELEGATE endHudProcess];
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
-(void)setButtonProperties:(UIButton *)btn withTitle:(NSString *)strText backColor:(UIColor *)backColor textColor:(UIColor *)txtColor txtSize:(int)txtSize
{
    [btn setTitle:strText forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize];
    [btn setTitleColor:txtColor forState:UIControlStateNormal];
    btn.backgroundColor = backColor;
    btn.clipsToBounds = true;
}


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
-(void)RecieveSensofrInformationofSession:(NSMutableArray *)arrSensors;
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
            [arrSessionData addObject:dict];
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
        
        [APP_DELEGATE endHudProcess];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            FCAlertView *alert = [[FCAlertView alloc] init];
            [alert makeAlertTypeSuccess];
            alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSize];
            [alert showAlertWithTitle:@"HQ-INC" withSubtitle:@"All Sessions Synced Successfully.." withCustomImage:[UIImage imageNamed:@"alert-round.png"] withDoneButtonTitle:@"OK" andButtons:nil];
            [alert doneActionBlock:^{

                SessionPlayersVC * sessionlist = [[SessionPlayersVC alloc] init];
                [self.navigationController pushViewController:sessionlist animated:YES];
            }];
        });
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
//        [[DataBaseManager dataBaseManager] execute:strInsertSession];
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
        
        NSString * strFinalType = @"Ingestible";
        if ([strSensorType isEqualToString:@"4"])
        {
            strFinalType = @"Dermal";
        }

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
            NSString * strDataQuery = [NSString stringWithFormat:@"insert into 'Session_data' ('session_id', 'temp', 'timestamp', 'sensor_type', 'sensor_id', 'packet') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",strSessionId,strTemp,strDataTime,strFinalType,strSensorId,strPacket];
//            [[DataBaseManager dataBaseManager] execute:strDataQuery];
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
    NSMutableArray * tmpDummyDataArr = [[NSMutableArray alloc] init];
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
    
