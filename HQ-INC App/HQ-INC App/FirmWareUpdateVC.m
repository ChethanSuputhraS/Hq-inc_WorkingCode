//
//  FirmWareUpdateVC.m
//  HQ-INC App
//
//  Created by Vithamas Technologies on 19/02/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import "FirmWareUpdateVC.h"
#import "MNMPullToRefreshManager.h"
#import "BLEService.h"
#import "BLEManager.h"
#import "HomeCell.h"


@import iOSDFULibrary;


@interface FirmWareUpdateVC ()< UITableViewDelegate,UITableViewDataSource, CBCentralManagerDelegate, BLEServiceDelegate,UIDocumentPickerDelegate,LoggerDelegate,DFUServiceDelegate,DFUProgressDelegate,DFUPeripheralSelectorDelegate>
{
    UITableView * tblMonitorList;
    MNMPullToRefreshManager * topPullToRefreshManager;
    UILabel * lblScanning,*lblNoDevice;
    NSTimer * connectionTimer, * advertiseTimer,* updatingTimer;;
    CBCentralManager * centralManager;
    CBPeripheral * classPeripheral;
    NSMutableDictionary * dictConnectedPeripheral;
    UIButton * btnUpdateFirmWare;

}


@end

@implementation FirmWareUpdateVC

- (void)viewDidLoad
{
    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = UIColor.blackColor;
    [self setNeedsStatusBarAppearanceUpdate];
    
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];

    [self setNavigationViewFrames];
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
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
    [lblTitle setText:@"Firmware update"];
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
     
     UIButton * btnCanceldown = [[UIButton alloc]initWithFrame:CGRectMake(100, DEVICE_HEIGHT-60, 150, 50)];
     [self setButtonProperties:btnCanceldown withTitle:@"Cancel" backColor:btnBgClor textColor:UIColor.whiteColor txtSize:25];
     btnCanceldown.layer.cornerRadius = 5;
     [btnCanceldown addTarget:self action:@selector(btnCancelClick) forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:btnCanceldown];
         
     UIButton * btnDone = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-250, DEVICE_HEIGHT-60, 150, 50)];
     [self setButtonProperties:btnDone withTitle:@"Done" backColor:btnBgClor textColor:UIColor.whiteColor txtSize:25];
     btnDone.layer.cornerRadius = 5;
     [btnDone setTitle:@"Done" forState:UIControlStateNormal];
     btnDone.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
     [btnDone addTarget:self action:@selector(btnDoneClick) forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:btnDone];
    
    btnUpdateFirmWare = [[UIButton alloc]initWithFrame:CGRectMake(10, DEVICE_HEIGHT-120, DEVICE_WIDTH-20, 50)];
    [self setButtonProperties:btnDone withTitle:@"Open file" backColor:btnBgClor textColor:UIColor.whiteColor txtSize:25];
    btnUpdateFirmWare.layer.cornerRadius = 5;
    [btnUpdateFirmWare setTitle:@"Open file" forState:UIControlStateNormal];
    btnUpdateFirmWare.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    [btnUpdateFirmWare addTarget:self action:@selector(btnOpenfileClick) forControlEvents:UIControlEventTouchUpInside];
    btnUpdateFirmWare.hidden = true;
    [self.view addSubview:btnUpdateFirmWare];
    
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, globalStatusHeight + yy - 1, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [viewHeader addSubview:line];
    
    tblMonitorList = [[UITableView alloc] initWithFrame:CGRectMake(0, yy+globalStatusHeight, DEVICE_WIDTH, DEVICE_HEIGHT-yy-globalStatusHeight-100)];
    tblMonitorList.delegate = self;
    tblMonitorList.dataSource= self;
    tblMonitorList.backgroundColor = UIColor.clearColor;
//    tblMonitorList.separatorStyle = UITableViewCellSelectionStyleNone;
    [tblMonitorList setShowsVerticalScrollIndicator:NO];
    tblMonitorList.backgroundColor = [UIColor clearColor];
    tblMonitorList.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblMonitorList.separatorColor = [UIColor darkGrayColor];
    [self.view addSubview:tblMonitorList];
    
    
    topPullToRefreshManager = [[MNMPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:tblMonitorList withClient:self];
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
    
    if ( IS_IPHONE_4 || IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_6plus)
    {
        lblTitle.frame = CGRectMake(0, 20, DEVICE_WIDTH, 50);
        lblTitle.font = [UIFont fontWithName:CGRegular size:textSize-6];
        
        line.frame = CGRectMake(0, 60 - 1, DEVICE_WIDTH, 0.5);

        btnUpdateFirmWare.frame = CGRectMake(10, DEVICE_HEIGHT-100, DEVICE_WIDTH-20, 35);
        btnUpdateFirmWare.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize-6];
        
        tblMonitorList.frame = CGRectMake(0, 60, DEVICE_WIDTH, DEVICE_HEIGHT-yy-40);

        btnRefresh.frame = CGRectMake(DEVICE_WIDTH-40, 10, 30, 30);
        btnRefresh.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize-6];

        btnCanceldown.frame = CGRectMake(10, DEVICE_HEIGHT-40, 60, 35);
        btnCanceldown.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize-6];

        btnDone.frame = CGRectMake(DEVICE_WIDTH-80, DEVICE_HEIGHT-40, 60, 35);
        btnDone.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize-6];

    }
    
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
        [tblMonitorList reloadData];
    }
}
-(void)NotifiyDiscoveredDevices:(NSNotification*)notification//Update peripheral
{
dispatch_async(dispatch_get_main_queue(), ^(void){
    
    if ( [[[BLEManager sharedManager] foundDevices] count] >0){
        self->tblMonitorList.hidden = false;
        self->lblNoDevice.hidden = true;
        [self->tblMonitorList reloadData];
//        [self->advertiseTimer invalidate];
//        self->advertiseTimer = nil;
        [APP_DELEGATE endHudProcess];
    }
    else
    {
        self->tblMonitorList.hidden = true;
        self->lblNoDevice.hidden = false;}
        [self->tblMonitorList reloadData];});
}
-(void)DeviceDidConnectNotification:(NSNotification*)notification//Connect periperal
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [APP_DELEGATE endHudProcess];
        [self->tblMonitorList reloadData];
    });
}
-(void)DeviceDidDisConnectNotification:(NSNotification*)notification//Disconnect periperal
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [[[BLEManager sharedManager] foundDevices] removeAllObjects];
        [[BLEManager sharedManager] rescan];
        [self->tblMonitorList reloadData];
        [APP_DELEGATE endHudProcess];});
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
    dispatch_async(dispatch_get_main_queue(), ^(void){
        
        FCAlertView *alert = [[FCAlertView alloc] init];
        [alert makeAlertTypeSuccess];
        alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSize];
        [alert showAlertWithTitle:@"HQ-INC" withSubtitle:@"Monitor connected successfully.." withCustomImage:[UIImage imageNamed:@"alert-round.png"] withDoneButtonTitle:@"OK" andButtons:nil];
        [alert doneActionBlock:^{
            
            [[BLEManager sharedManager] stopScan];
            self->btnUpdateFirmWare.hidden = false;

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
    
    if ( IS_IPHONE_4 || IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_6plus)
    {
        headerView.frame = CGRectMake(5, 0, self.view.frame.size.width-20, 40);
        lblmenu.frame = CGRectMake(5,0, DEVICE_WIDTH-10, 40);
        [lblmenu setFont:[UIFont fontWithName:CGRegular size:textSize-6]];

    }
        return headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ( IS_IPHONE_4 || IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_6plus)
    {
        return 40;
    }
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
    if ( IS_IPHONE_4 || IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_6plus)
    {
        return 65;
    }
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
        [self->tblMonitorList insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
    });
}
-(void)btnCancelClick
{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)btnDoneClick
{
    
}
#pragma mark- Properties of Button and Lable
-(void)setButtonProperties:(UIButton *)btn withTitle:(NSString *)strText backColor:(UIColor *)backColor textColor:(UIColor *)txtColor txtSize:(int)txtSize
{
    [btn setTitle:strText forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn setTitleColor:txtColor forState:UIControlStateNormal];
    btn.backgroundColor = backColor;
    btn.layer.cornerRadius = 5;
    btn.clipsToBounds = true;
}
-(void)btnOpenfileClick
{
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.item"]
                      inMode:UIDocumentPickerModeImport];
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;

    [self presentViewController:documentPicker animated:YES completion:nil];
}
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
    NSLog(@"FilePath======>>>>>>>%@",urls);
    
    NSString * result = [[urls valueForKey:@"description"] componentsJoinedByString:@""];//description
    NSString * strfilePath =  [result substringWithRange:NSMakeRange(8, result.length-8)];
    
    NSURL *uRL = [NSURL URLWithString:strfilePath];
    DFUFirmware *selectedFirmware = [[DFUFirmware alloc] initWithUrlToZipFile:uRL type:DFUFirmwareTypeApplication];
    NSLog(@"Selected Firmware========>>>>>>>%@",selectedFirmware);
  
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    DFUServiceInitiator *initiator = [[DFUServiceInitiator alloc] initWithQueue:queue];
    [initiator withFirmware:selectedFirmware];
    
    initiator.logger = self; //
    initiator.delegate = self; //
    initiator.progressDelegate = self;
    DFUServiceController * controller1 = [initiator startWithTarget:classPeripheral];
    connectionTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(ConnectionTimeOutDfu) userInfo:nil repeats:NO];

    [APP_DELEGATE startHudProcess:@"Updating..."];
}
-(void)ConnectionTimeOutDfu
{
    [APP_DELEGATE endHudProcess];
    [self AlertViewFCTypeCautionCheck:@"Please check selected file \n Ex. (.ZIP file)"];
}
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    
}
- (void)dfuStateDidChangeTo:(enum DFUState)state
{
    
}
- (void)dfuProgressDidChangeFor:(NSInteger)part outOf:(NSInteger)totalParts to:(NSInteger)progress currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond
{
    
}
- (void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString *)message
{
    
}
-(void)logWith:(enum LogLevel)level message:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
    NSLog(@"LogWith Message=%@",message);
    
//    if ([[APP_DELEGATE checkforValidString:message] isEqualToString:@"=Upload completed in"])
//    {
        [APP_DELEGATE endHudProcess];
//    }
    });
}
#pragma mark- Buttons
-(void)refreshBtnClick
{
    //[self setupForAddSensor];
    [[[BLEManager sharedManager] foundDevices] removeAllObjects];
    [[BLEManager sharedManager] rescan];
    [tblMonitorList reloadData];
    
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
        [tblMonitorList reloadData];
    }
    if ( [[[BLEManager sharedManager] foundDevices] count] >0)
    {
        tblMonitorList.hidden = false;
        lblNoDevice.hidden = true;
//        [advertiseTimer invalidate];
//        advertiseTimer = nil;
        [tblMonitorList reloadData];
    }
    else
    {
        tblMonitorList.hidden = true;
        lblNoDevice.hidden = false;
//        [advertiseTimer invalidate];
//        advertiseTimer = nil;
//        advertiseTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(AdvertiseTimerMethod) userInfo:nil repeats:NO];
    }
}
#pragma mark - Timer Methods
-(void)ConnectionTimeOutMethod
{
    if (classPeripheral.state == CBPeripheralStateConnected)
    {
    }
    else
    {
        if (classPeripheral == nil)
        {
            return;
        }
    }
}
-(void)AdvertiseTimerMethod
{
//    [APP_DELEGATE endHudProcess];
    if ( [[[BLEManager sharedManager] foundDevices] count] >0)
    {
        self->tblMonitorList.hidden = false;
        self->lblNoDevice.hidden = true;
        [self->tblMonitorList reloadData];
    }
    else
    {
        self->tblMonitorList.hidden = true;
        self->lblNoDevice.hidden = false;
    }
        [self->tblMonitorList reloadData];
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
@end
