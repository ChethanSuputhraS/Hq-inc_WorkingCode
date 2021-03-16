//
//  SGFManager.m
//  SGFindSDK
//
//  Created by Kalpesh Panchasara on 7/11/14.
//  Copyright (c) 2014 Kalpesh Panchasara, Ind. All rights reserved.
//

#import "AppDelegate.h"
#import "BLEManager.h"
#import "Constant.h"


static BLEManager    *sharedManager    = nil;
//BLEManager    *sharedManager    = nil;

@interface BLEManager()
{
    NSMutableArray *disconnectedPeripherals;
    NSMutableArray *connectedPeripherals;
    NSMutableArray *peripheralsServices;
    CBCentralManager    *centralManager;
    BLEService * blutoothService;
    BOOL isVitDeviceFound;
    NSTimer * checkDeviceTimer;
}
@end

@implementation BLEManager
@synthesize delegate,foundDevices,connectedServices,centralManager,nonConnectArr;

#pragma mark- Self Class Methods
-(id)init
{
    if(self = [super init])
    {
        [self initialize];
    }
    return self;
}

#pragma mark --> Initilazie
-(void)initialize
{
    //  NSLog(@"bleManager initialized");
    centralManager=[[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)];
    centralManager.delegate = self;
    blutoothService.delegate = self;
    [foundDevices removeAllObjects];
    [nonConnectArr removeAllObjects];
    if(!foundDevices)foundDevices = [[NSMutableArray alloc] init];
    if(!nonConnectArr)nonConnectArr = [[NSMutableArray alloc] init];
    if(!connectedServices)connectedServices = [[NSMutableArray alloc] init];
    if(!disconnectedPeripherals)disconnectedPeripherals = [NSMutableArray new];
}

+ (BLEManager*)sharedManager
{
    if (!sharedManager)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedManager = [[BLEManager alloc] init];
        });
    }
    return sharedManager;
}
-(NSArray *)getLastConnected
{
    return [centralManager retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:@"0000ab00-2687-4433-2208-abf9b34fb000"]]];
}
#pragma mark- Scanning Method
-(void)startScan
{
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:NO], CBCentralManagerScanOptionAllowDuplicatesKey,nil];
    [centralManager scanForPeripheralsWithServices:nil options:options];
}
#pragma mark - > Rescan Method
-(void) rescan
{
    centralManager.delegate = self;
    blutoothService.delegate = self;
    self.serviceDelegate = self;
    
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:NO], CBCentralManagerScanOptionAllowDuplicatesKey,
                              nil];
    [centralManager scanForPeripheralsWithServices:nil options:options];
}

#pragma mark - Stop Method
-(void)stopScan
{
    self.delegate = nil;
    self.serviceDelegate = nil;
    blutoothService.delegate = nil;
    blutoothService = nil;
    centralManager.delegate = nil;
    [foundDevices removeAllObjects];
    [centralManager stopScan];
    [blutoothSearchTimer invalidate];
    
}

#pragma mark - Central manager delegate method stop
-(void)centralmanagerScanStop
{
    [centralManager stopScan];
}
#pragma mark - Connect Ble device
- (void) connectDevice:(CBPeripheral*)device{
    
    if (device == nil)
    {
        return;
    }
    else
    {//3.13.1 is live or testlgijt ?
        if ([disconnectedPeripherals containsObject:device])
        {
            [disconnectedPeripherals removeObject:device];
        }
        [self connectPeripheral:device];
    }
}

#pragma mark - Disconenct Device
- (void)disconnectDevice:(CBPeripheral*)device
{
    if (device == nil) {
        return;
    }else{
        [self disconnectPeripheral:device];
    }
}

-(void)connectPeripheral:(CBPeripheral*)peripheral
{
    NSError *error;
    if (peripheral)
    {
        if (peripheral.state != CBPeripheralStateConnected)
        {
            [centralManager connectPeripheral:peripheral options:nil];
        }
        else
        {
            if(delegate)
            {
                [delegate didFailToConnectDevice:peripheral error:error];
            }
        }
    }
    else
    {
        if(delegate)
        {
            [delegate didFailToConnectDevice:peripheral error:error];
        }
    }
}

-(void) disconnectPeripheral:(CBPeripheral*)peripheral
{
    [self.delegate didDisconnectDevice:peripheral];
    if (peripheral)
    {
        if (peripheral.state == CBPeripheralStateConnected)
        {
            NSLog(@"-(void) disconnectPeripheral:(CBPeripheral*)peripheral");
            [centralManager cancelPeripheralConnection:peripheral];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceDidDisConnectNotification" object:peripheral];
        }
    }
}
-(void) updateBluetoothState
{
    [self centralManagerDidUpdateState:centralManager];
}
-(void)updateBleImageWithStatus:(BOOL)isConnected andPeripheral:(CBPeripheral*)peripheral
{
}
#pragma mark -  Search Timer Auto Connect
-(void)searchConnectedBluetooth:(NSTimer*)timer
{
    //    NSLog(@"its scanning");
    [self rescan];
}
#pragma mark Scan Sync Timer
-(void)scanDeviceSync:(NSTimer*)timer
{
}
#pragma mark - Finding Device with in Range
-(void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    //  NSLog(@"peripherals==%@",peripherals);
}
#pragma mark - > Resttore state of devices
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict
{
    NSArray *peripherals =dict[CBCentralManagerRestoredStatePeripheralsKey];
    
    if (peripherals.count>0)
    {
        for (CBPeripheral *p in peripherals)
        {
            if (p.state != CBPeripheralStateConnected)
            {
                //[self connectPeripheral:p];
            }
        }
    }
}

#pragma mark - Fail to connect device
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    /*---This method will call if failed to connect device-----*/
    if(delegate)[delegate didFailToConnectDevice:peripheral error:error];
}

- (void)discoverIncludedServices:(nullable NSArray<CBUUID *> *)includedServiceUUIDs forService:(CBService *)service;
{
    
}
- (void)discoverCharacteristics:(nullable NSArray<CBUUID *> *)characteristicUUIDs forService:(CBService *)service;
{
    
}
- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic;
{
    
}
#pragma mark - CBCentralManagerDelegate
- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self startScan];
    /*----Here we can come to know bluethooth state----*/
    [blutoothSearchTimer invalidate];
    blutoothSearchTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(searchConnectedBluetooth:) userInfo:nil repeats:YES];
    
    switch (central.state)
    {
        case CBPeripheralManagerStateUnknown:
            //The current state of the peripheral manager is unknown; an update is imminent.
            if(delegate)[delegate bluetoothPowerState:@"The current state of the peripheral manager is unknown; an update is imminent."];
            
            break;
        case CBPeripheralManagerStateUnauthorized:
            //The app is not authorized to use the Bluetooth low energy peripheral/server role.
            if(delegate)[delegate bluetoothPowerState:@"The app is not authorized to use the Bluetooth low energy peripheral/server role."];
            
            break;
        case CBPeripheralManagerStateResetting:
            //The connection with the system service was momentarily lost; an update is imminent.
            if(delegate)[delegate bluetoothPowerState:@"The connection with the system service was momentarily lost; an update is imminent."];
            
            break;
        case CBPeripheralManagerStatePoweredOff:
            //Bluetooth is currently powered off"
            if(delegate)[delegate bluetoothPowerState:@"Bluetooth is currently powered off."];
            
            break;
        case CBPeripheralManagerStateUnsupported:
            //The platform doesn't support the Bluetooth low energy peripheral/server role.
            if(delegate)[delegate bluetoothPowerState:@"The platform doesn't support the Bluetooth low energy peripheral/server role."];
            
            break;
        case CBPeripheralManagerStatePoweredOn:
            //Bluetooth is currently powered on and is available to use.
            if(delegate)[delegate bluetoothPowerState:@"Bluetooth is currently powered on and is available to use."];
            break;
    }
}
#pragma mark - Discover all devices here
/*-----------if device is in range we can find in this method--------*/
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString * checkNameStr = [NSString stringWithFormat:@"%@",peripheral.name];
    NSString * advertiseName = [NSString stringWithFormat:@"%@",[advertisementData valueForKey:@"kCBAdvDataLocalName"]];
//    NSLog(@"Scanned BLE Device----> %@",checkNameStr) ;
    if ([checkNameStr rangeOfString:@"HQINC"].location != NSNotFound || [advertiseName rangeOfString:@"hqinc"].location != NSNotFound)
    {
        NSString * strConnect = [NSString stringWithFormat:@"%@",[advertisementData valueForKey:@"kCBAdvDataIsConnectable"]];
        if ([strConnect isEqualToString:@"1"])
        {
            checkNameStr = [NSString stringWithFormat:@"%@",[advertisementData valueForKey:@"kCBAdvDataLocalName"]];
            NSData* advData = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
            NSString * strAdvData = [NSString stringWithFormat:@"%@",advData.debugDescription]; //this works
            strAdvData = [strAdvData stringByReplacingOccurrencesOfString:@" " withString:@""];
            strAdvData = [strAdvData stringByReplacingOccurrencesOfString:@">" withString:@""];
            strAdvData = [strAdvData stringByReplacingOccurrencesOfString:@"<" withString:@""];
            NSLog(@"AdvertiseData=%@",strAdvData);

            if (![[self checkforValidString:strAdvData] isEqualToString:@"NA"])
            {
                if([strAdvData length]>=20)
                {
                    NSString * strAddress = [strAdvData substringWithRange:NSMakeRange(4, 12)];
                    
                    if ([[foundDevices valueForKey:@"peripheral"] containsObject:peripheral])
                    {
                        for (int i=0; i<[foundDevices count]; i++)
                        {
                            CBPeripheral * Cbpd = [[foundDevices objectAtIndex:i]valueForKey:@"peripheral"];
                            if (Cbpd == peripheral)
                            {
                                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                                [dict setObject:peripheral forKey:@"peripheral"];
                                  [dict setObject:strAddress forKey:@"bleAddress"];
                                [dict setObject:checkNameStr forKey:@"name"];
                                [foundDevices replaceObjectAtIndex:i withObject:dict];
                                break;
                            }
                        }
                    }
                    else
                    {
                        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                        [dict setObject:peripheral forKey:@"peripheral"];
                        [dict setObject:strAddress forKey:@"bleAddress"];
                        [dict setObject:checkNameStr forKey:@"name"];
                        [foundDevices addObject:dict];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifiyDiscoveredDevices" object:nil];
                }
            }
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    /*-------This method will call after succesfully device Ble device connect-----*/
    peripheral.delegate = self;
    if (peripheral.services)
    {
        NSLog(@"Peripheral disciver all services------>");
        [self peripheral:peripheral didDiscoverServices:nil];
    }
    else
    {
        NSLog(@"Peripheral disciver one services------>");
        [peripheral discoverServices:@[[CBUUID UUIDWithString:@"0000ab00-2687-4433-2208-abf9b34fb000"]]];
//        0000ab01-2687-4400-0008-e5f9b34fb000
    }
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceDidDisConnectNotification" object:peripheral];
    NSLog(@"Disconnected from peripheral");
    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication *app=[UIApplication sharedApplication];
        if (app.applicationState == UIApplicationStateBackground)
        {
            NSLog(@"We are in the background Disconnect");
            UIUserNotificationSettings *notifySettings=[[UIApplication sharedApplication] currentUserNotificationSettings];
            if ((notifySettings.types & UIUserNotificationTypeAlert)!=0)
            {
                UILocalNotification *notification=[UILocalNotification new];
                notification.alertBody= @"Device has been disconnected.";
                [app presentLocalNotificationNow:notification];
            }
        }
    });
        if ([[arrGlobalDevices valueForKey:@"peripheral"] containsObject:peripheral])
        {
            NSLog(@"Retrying");
            [self.centralManager connectPeripheral:peripheral options:nil];
        }
}
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    BOOL gotService = NO;
    for(CBService* svc in peripheral.services)
    {
        gotService = YES;
        if(svc.characteristics)
        {
            NSLog(@"Already discoverd----->CHA");
            [self peripheral:peripheral didDiscoverCharacteristicsForService:svc error:nil]; //already discovered characteristic before, DO NOT do it again
        }
        else
        {
            NSLog(@"First time  discoverd----->CHA");
            [peripheral discoverCharacteristics:nil forService:svc]; //need to discover characteristics
        }
    }
    if (gotService == NO)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideHud" object:nil];
    }
}
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for(CBCharacteristic* c in service.characteristics)
    {
        NSLog(@"Discovered characteristic %@(%@)",c.description,c.UUID.UUIDString);
    }
    
    [[BLEService sharedInstance] sendNotifications:peripheral withType:NO withUUID:@"0000ab01-2687-4400-0008-e5f9b34fb000"];
    [[BLEService sharedInstance] EnableNotificationsForCommand:peripheral withType:YES];
    [[BLEService sharedInstance] EnableNotificationsForDATA:peripheral withType:YES];
    [[BLEService sharedInstance] SendCommandWithPeripheral:peripheral withValue:@"1"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceDidConnectNotification" object:peripheral];
}

-(void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
   /* NSString *manf=[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.manfLabel.text=manf;
    });*/
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
-(void)SendCallBackforAddingGroups:(CBPeripheral *)peripheral withData:(NSDictionary *)advertisementData
{
    NSData *nameData = [advertisementData valueForKey:@"kCBAdvDataManufacturerData"];
    NSString *nameString = [NSString stringWithFormat:@"%@",nameData]; //this works
    NSRange rangeFirst = NSMakeRange(1, 4);
    NSString * strOpCodeCheck = [nameString substringWithRange:rangeFirst];
    if ([strOpCodeCheck isEqualToString:@"0a00"])
    {
        rangeFirst = NSMakeRange(5, [nameString length]-5);
        NSString * kpstr = [nameString substringWithRange:rangeFirst];
        kpstr = [kpstr stringByReplacingOccurrencesOfString:@" " withString:@""];
        kpstr = [kpstr stringByReplacingOccurrencesOfString:@">" withString:@""];
        kpstr = [kpstr stringByReplacingOccurrencesOfString:@"<" withString:@""];
        
    NSString * strKeys = [APP_DELEGATE getStringConvertedinUnsigned:[[NSUserDefaults standardUserDefaults]valueForKey:@"passKey"]];
        
    NSString * strFinalData = [APP_DELEGATE getStringConvertedinUnsigned:kpstr];
//    NSData * updatedMFData = [APP_DELEGATE GetDecrypedDataKeyforData:strFinalData withKey:strKeys withLength:[kpstr length]/2];
        
//        NSLog(@"%@",updatedMFData);
    }
}
@end
