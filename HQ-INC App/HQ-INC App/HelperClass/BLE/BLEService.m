//  BLEService.m
//
//
//  Created by Kalpesh Panchasara on 7/11/14.
//  Copyright (c) 2014 Kalpesh Panchasara, Ind. All rights reserved.
//
#import "BLEService.h"
#import "BLEManager.h"
#import "AppDelegate.h"
#import "Constant.h"

//0x00, 0xb0, 0x4f, 0xb3, 0xf9, 0xE5, 0x08, 0x00, 0x00, 0x44, 0x87, 0x26, 0x00, 0xab, 0x00, 0x00
#define TI_KEYFOB_LEVEL_SERVICE_UUID                        0x2A19
#define TI_KEYFOB_BATT_SERVICE_UUID                         0x180F
#define CPTD_SERVICE_UUID_STRING                              @"0000ab00-2687-4433-2208-abf9b34fb000"
#define CPTD_CHARACTERISTIC_COMM_CHAR                         @"0000ab01-2687-4433-2208-abf9b34fb000"
static BLEService    *sharedInstance    = nil;

@interface BLEService ()<CBPeripheralDelegate,AVAudioPlayerDelegate>
{
    int collectionCount;
    NSMutableArray * arrAccelorometer_01;
    NSMutableArray * arrForce_01, * arrForce_02, * arrForce_03, * arrForce_04;
    
}
@property (nonatomic, strong) CBPeripheral *servicePeripheral;
@property (nonatomic,strong) NSMutableArray *servicesArray;
@end

@implementation BLEService
@synthesize servicePeripheral, bleConnectdelegate;

#pragma mark- Self Class Methods
-(id)init
{
    self = [super init];
    if (self) {
        //do additional work
    }
    return self;
}

+ (instancetype)sharedInstance
{
    if (!sharedInstance)
        sharedInstance = [[BLEService alloc] init];
    
    return sharedInstance;
}

-(id)initWithDevice:(CBPeripheral*)device andDelegate:(id /**<>*/)delegate{
    self = [super init];
    if (self)
    {
        _delegate = delegate;
        [device setDelegate:self];
        //        [servicePeripheral setDelegate:self];
        servicePeripheral = device;
    }
    return self;
}

#pragma mark- BLE send Notifications Here
- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
//    NSLog(@"<<<<<Kalpesh>>>>Recieved_from_Device>>%@",characteristic);
    NSString * strUUID = [NSString stringWithFormat:@"%@",characteristic.UUID];
    if ([[strUUID lowercaseString] isEqualToString:CPTD_CHARACTERISTIC_COMM_CHAR])//For Authentication 0000AB01-0143-0800-0008-E5F9B34FB000
    {
        NSData * valData = characteristic.value;
        NSString * valueStr = [NSString stringWithFormat:@"%@",valData.debugDescription];
        valueStr = [valueStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        valueStr = [valueStr stringByReplacingOccurrencesOfString:@">" withString:@""];
        valueStr = [valueStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
        
        if (![[self checkforValidString:valueStr] isEqualToString:@"NA"])
        {
            if ([valueStr length]>=6)
            {
                NSString * strOpcode = [valueStr substringWithRange:NSMakeRange(0, 2)];
                if ([strOpcode isEqualToString:@"01"]) //For Authentication
                {
                    NSString * strRandomValue = [valueStr substringWithRange:NSMakeRange(4, 2)];
                    NSString * strDecimal = [self stringFroHex:strRandomValue];
                    NSInteger  strResultValue = [self convertAlgo:[strDecimal integerValue]];
                    NSData * authData = [[NSData alloc] initWithBytes:&strResultValue length:4];
                    NSInteger opInt = 2;
                    NSData * opCodeData = [[NSData alloc] initWithBytes:&opInt length:1];
                    NSInteger lengths = 4;
                    NSData * lengthData = [[NSData alloc] initWithBytes:&lengths length:1];
                    NSMutableData * finalData = [opCodeData mutableCopy];
                    [finalData appendData:lengthData];
                    [finalData appendData:authData];
                    
                    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
                    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
                    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:finalData];

                    NSLog(@"Wrote data for Authentication=%@",finalData);
                }
                else if ([strOpcode isEqualToString:@"02"]) //For Authentication Status
                {
                    if ([[valueStr substringWithRange:NSMakeRange(0, 6)] isEqualToString:@"020101"])
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"AuthenticationCompleted" object:nil];
                        
//                        //To Check whether device is running live session or not...
//                        NSInteger interval = [@"0" integerValue];
//                        NSData * dataInterval = [[NSData alloc] initWithBytes:&interval length:2];
//
//                        NSMutableData * packetData = [[NSMutableData alloc] initWithData:dataInterval];
//                        [[BLEService sharedInstance] WriteValuestoDevice:packetData withOcpde:@"32" withLength:@"0" with:peripheral];
                    }
                }
                if ([valueStr length]>=36)
                {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        NSString * strKey = [[NSUserDefaults standardUserDefaults] valueForKey:@"EncryptionKey"];
                        NSString * strKeyUnsigned = [self getStringConvertedinUnsigned:strKey];
                        NSString * strPacket = [self getStringConvertedinUnsigned:[valueStr substringWithRange:NSMakeRange(4, 32)]];

                        NSString * strDecrypted = [APP_DELEGATE GetDecrypedDataKeyforData:strPacket withKey:strKeyUnsigned withLength:strKey.length / 2];
                        NSString * strOpcode = [valueStr substringWithRange:NSMakeRange(0, 2)];
                        NSLog(@"Opcode= %@       Length= %@        Decrypted Data=%@",strOpcode,[valueStr substringWithRange:NSMakeRange(2, 2)],strDecrypted);

                        if ([strOpcode isEqualToString:@"08"]) //For Added Sensor Response
                        {
                            if (([strDecrypted length] > 8))
                            {
                                if ([[strDecrypted substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"00"]) //Failed
                                {
                                    NSString * strSessionID = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(2, 4)]];
                                    NSString * strErrorCode = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(6, 2)]];
                                    [globalAddSensor FailedtoAddSensor:strErrorCode withSensorID:strSessionID];
                                }
                                else if ([[strDecrypted substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"01"]) //Success
                                {
                                    if (([strDecrypted length] > 14))
                                    {
                                        NSString * strSensorId = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(2, 4)]];
                                        NSString * strSensorType = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(6, 2)]];
                                        NSString * strBatteryLevel = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(8, 2)]];
                                        NSString * strChannelNo = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(10, 2)]];
                                        NSString * strNodePosition = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(12, 2)]];
                                        NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:strSensorId,@"sensor_id",strSensorType,@"sensor_type",strBatteryLevel,@"Battery",strChannelNo,@"Channel",strNodePosition,@"NodePosition", nil];
                                        [globalAddSensor SuccesfullyAddedSensor:dict withSensorID:strSensorId];
                                    }
                                }
                            }
                        }
                        else if ([strOpcode isEqualToString:@"09"]) //For Add Sensor Complete Confirmation
                        {
                            if (([strDecrypted length] > 4))
                            {
                            }
                        }
                        else if ([strOpcode isEqualToString:@"0b"]) //Confirmation of Read Interval
                        {
                            if (([strDecrypted length] > 4))
                            {
                                if ([[strDecrypted substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"00"]) //Failed
                                {
                                    [globalSubjectDetailVC ShowErrorMessagewithOpcode:strOpcode];
                                }
                                else if([[strDecrypted substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"01"])
                                {
                                    [globalSubjectDetailVC WritePlayerNametoMonitorttoStartSession];
                        //                                    NSLog(@"Start Read Temperature++++>>>1200%@",dataMsg);
                                }
                            }
                        }
                        else if ([strOpcode isEqualToString:@"0c"]) //Confirmation of Read Interval
                        {
                            if (([strDecrypted length] > 4))
                            {
                                if ([[strDecrypted substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"00"]) //Failed
                                {
                                    [globalSubjectDetailVC ShowErrorMessagewithOpcode:strOpcode];
                                }
                                else if([[strDecrypted substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"01"])
                                {
                                    [globalSubjectDetailVC StartSessionConfirmation:YES];
                                }
                            }
                        }
                        else if ([strOpcode isEqualToString:@"0d"]) //Confirmation of Read Interval
                        {
                            if (([strDecrypted length] > 4))
                            {
                                if ([[strDecrypted substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"00"]) //Failed
                                {
                                    [globalSubjectDetailVC ShowErrorMessagewithStopSession:strOpcode];
                                }
                                else if([[strDecrypted substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"01"])
                                {
                                    [globalSubjectDetailVC ShowErrorMessagewithStopSession:strDecrypted];
                                }
                            }
                        }
                        else if ([strOpcode isEqualToString:@"0e"]) //Live readings of Device
                        {
                            NSMutableArray * arrSensorData = [[NSMutableArray alloc] init];
                            long totalPacketCount = strDecrypted.length / 8;
                            for (int i = 0; i < totalPacketCount; i++)
                            {
                                if (strDecrypted.length >= (i*8) + 8)
                                {
                                    NSString * strSensorId = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(i * 8, 4)]];
                                    NSString * strSensorTemp = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange((i * 8) + 4, 4)]];
                                    int divValue =  [strSensorTemp doubleValue];
                                    double fPointData = divValue / 100.0;
                                    NSString *StrFloating = [NSString stringWithFormat:@"%.2f", fPointData];
                                                            
                                    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:strSensorId,@"sensor_id",StrFloating,@"temp", nil];
                                    [arrSensorData addObject:dict];
                                }
                            }
                            if ([arrSensorData count]>0)
                            {
                                [globalSubjectDetailVC SendTemperatureReadingtoDetailVC:arrSensorData];
                            }
                        }
                        else if ([strOpcode isEqualToString:@"0f"]) //Receive Stored Session
                        {
                            if ([strDecrypted length] >= 16)
                            {
                                NSString * strSquenceNo = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(0, 4)]];
                                NSString * strPacketNo = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(4, 2)]];
                                NSString * strSessionID = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(6, 2)]];
                                NSString * strPlayerID = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(8, 8)]];
                                NSString * strTimestamp = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(16, 8)]];
                                NSDictionary * dictData = [NSDictionary dictionaryWithObjectsAndKeys:strSquenceNo,@"sequenceNo",strPacketNo,@"packetno",strSessionID, @"session_id",strPlayerID,@"player_id",strTimestamp,@"timestamp", nil];
                        //                                [globalSettingClassVC ReceiveListofSessionsID:dictData];
                                NSInteger intMsg = [strSquenceNo integerValue];
                                NSData * dataMsg = [[NSData alloc] initWithBytes:&intMsg length:2];
                                [[BLEService sharedInstance] WriteValuestoDevice:dataMsg withOcpde:@"15" withLength:@"2" with:peripheral];
                                [self->_delegate ReceiveListofSessionsID:dictData];
                            }
                        }
                        else if ([strOpcode isEqualToString:@"15"]) //For Scanned Sensors
                        {
                            if ([strDecrypted length] > 6)
                            {

                                NSString * strSensorId = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(0, 4)]];
                                NSString * strSensorType = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(4, 2)]];//3-Ingestible, 4-Dermal
                                NSString * strFinalType = @"Ingestible";
                                
                                NSLog(@"For Ocpde 15 ====>%@",strSensorType);

                                if ([strSensorType isEqualToString:@"4"])
                                {
                                    strFinalType = @"Dermal";
                                }
                                [globalAddSensor AddSensortoList:strSensorId withType:strFinalType];
                            }
                        }
                        else if ([strOpcode isEqualToString:@"12"]) //For Start Session Confirmation
                        {
                            if (([strDecrypted length] > 4))
                            {
                                if ([[strDecrypted substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"00"]) //Failed
                                {
                                    [globalSubjectDetailVC StartSessionConfirmation:NO];
                                }
                                else if([[strDecrypted substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"01"])
                                {
                                    [globalSubjectDetailVC StartSessionConfirmation:YES];
                                }
                            }
                        }
                        else if ([strOpcode isEqualToString:@"13"]) //For Stop Session Confirmation
                        {
                            if (([strDecrypted length] > 4))
                            {
                                
                            }
                        }
                        else if ([strOpcode isEqualToString:@"20"]) //To Check Live Session is Going on or not...
                        {
                            if (([strDecrypted length] > 2))
                            {
                                if ([[strDecrypted substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"01"])
                                {
                                    NSInteger interval = [@"250" integerValue];
                                    NSData * dataInterval = [[NSData alloc] initWithBytes:&interval length:2];

                                    NSMutableData * packetData = [[NSMutableData alloc] initWithData:dataInterval];
                                    [[BLEService sharedInstance] WriteValuestoDevice:packetData withOcpde:@"33" withLength:@"1" with:peripheral];

                                    [self->bleConnectdelegate MonitorConnnectedIsSessionActive:YES];
                                }
                                else
                                {
                                    [self->bleConnectdelegate MonitorConnnectedIsSessionActive:NO];
                                }
                            }
                        }
                        else if ([strOpcode isEqualToString:@"21"]) //IF Live session going on then get number of sensors for it...
                        {
                            NSString * strPacket = [[strDecrypted substringWithRange:NSMakeRange(0, 2)] lowercaseString];
                            if ([strPacket isEqualToString:@"ff"]) //Session Start
                            {
                                if ([strDecrypted length] >= 26)
                                {
                                    NSString * strSessionID = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(2, 2)]] ;
                                    NSString * strPlayerID = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(4, 8)]];
                                    NSString * strTimestamp = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(12, 8)]];
                                    NSString * strReadInterval = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(20, 4)]];
                                    NSString * strNoSensors = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(24, 2)]];

                                    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:strSessionID,@"session_id",strPlayerID,@"player_id",strTimestamp,@"timeStamp",strReadInterval,@"read_interval",strNoSensors,@"no_of_sensor", nil];
                                    [self->bleConnectdelegate RecieveLiveSessionInformation:dict];
                                    
                                    NSInteger intMsg = [@"255" integerValue];
                                    NSData * dataMsg = [[NSData alloc] initWithBytes:&intMsg length:1];
                                    [[BLEService sharedInstance] WriteValuestoDevice:dataMsg withOcpde:@"33" withLength:@"1" with:peripheral];
                                }
                            }
                            else if ([strPacket isEqualToString:@"fe"]) //Player Name
                            {
                               int packetLength = [[self stringFroHex:[valueStr substringWithRange:NSMakeRange(2, 2)]] intValue] - 1;// -1 for fe
                                if ([strDecrypted length] > packetLength)
                                {
                                    NSString * strHexaData = [strDecrypted substringWithRange:NSMakeRange(2, (packetLength * 2) - 2)];
                                    NSMutableString * strPlayerName = [[NSMutableString alloc] init];
                                    int i = 0;
                                    while (i < [strHexaData length])
                                    {
                                        NSString * hexChar = [strHexaData substringWithRange: NSMakeRange(i, 2)];
                                        int value = 0;
                                        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
                                        [strPlayerName appendFormat:@"%c", (char)value];
                                        i+=2;
                                    }
                                    [self->bleConnectdelegate RecieveLiveSessionPlayerName:[NSString stringWithFormat:@"%@",strPlayerName]];

                                    NSInteger intMsg = [@"254" integerValue];
                                    NSData * dataMsg = [[NSData alloc] initWithBytes:&intMsg length:1];
                                    [[BLEService sharedInstance] WriteValuestoDevice:dataMsg withOcpde:@"33" withLength:@"1" with:peripheral];
                                }
                            }
                            else if ([strPacket isEqualToString:@"fd"]) //Sensor Information
                            {
                                NSMutableArray * arrSensorInfo = [[NSMutableArray alloc] init];
                                int packetLength = [[self stringFroHex:[valueStr substringWithRange:NSMakeRange(2, 2)]] intValue] - 1;// -1 for fd
                                if (packetLength > 0 )
                                {
                                    for (int i=0; i < packetLength/3; i++)
                                    {
                                        NSString * strSensorId = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(2 + (i*6), 4)]];
                                        NSString * strSensorType = [strDecrypted substringWithRange:NSMakeRange(2 + (i*6) + 4, 2)];
                                        NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:strSensorId,@"sensor_id",strSensorType,@"sensor_type", nil];
                                        [arrSensorInfo addObject:dict];
                                    }
                                    [self->bleConnectdelegate RecieveLiveSensorInformationofSession:arrSensorInfo];
                                }
                            }
                        }
                        else if ([strOpcode isEqualToString:@"10"]) //Session Data
                        {
                            if ([strDecrypted length] >= 4)
                            {
                                NSString * strPacket = [[strDecrypted substringWithRange:NSMakeRange(0, 2)] lowercaseString];
                                if ([strPacket isEqualToString:@"ff"]) //Session Start
                                {
                                    if ([strDecrypted length] >= 26)
                                    {
                                        NSString * strSessionID = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(2, 2)]] ;
                                        NSString * strPlayerID = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(4, 8)]];
                                        NSString * strTimestamp = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(12, 8)]];
                                        NSString * strReadInterval = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(20, 4)]];
                                        NSString * strNoSensors = [self stringFroHex:[strDecrypted substringWithRange:NSMakeRange(24, 2)]];

                                        NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:strSessionID,@"session_id",strPlayerID,@"player_id",strTimestamp,@"timeStamp",strReadInterval,@"read_interval",strNoSensors,@"no_of_sensor", nil];
                                        [self->_delegate RecieveSessionInformation:dict];
                                        
                                        NSInteger intMsg = [@"255" integerValue];
                                        NSData * dataMsg = [[NSData alloc] initWithBytes:&intMsg length:1];
                                        [[BLEService sharedInstance] WriteValuestoDevice:dataMsg withOcpde:@"16" withLength:@"1" with:peripheral];
                                    }
                                }
                                else if ([strPacket isEqualToString:@"fe"]) //Player Name
                                {
                                   int packetLength = [[self stringFroHex:[valueStr substringWithRange:NSMakeRange(2, 2)]] intValue] - 1;// -1 for fe
                                    if ([strDecrypted length] > packetLength)
                                    {
                                        NSString * strHexaData = [strDecrypted substringWithRange:NSMakeRange(2, (packetLength * 2) - 2)];
                                        NSMutableString * strPlayerName = [[NSMutableString alloc] init];
                                        int i = 0;
                                        while (i < [strHexaData length])
                                        {
                                            NSString * hexChar = [strHexaData substringWithRange: NSMakeRange(i, 2)];
                                            int value = 0;
                                            sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
                                            [strPlayerName appendFormat:@"%c", (char)value];
                                            i+=2;
                                        }
                                        [self->_delegate RecievePlayerNameofSession:[NSString stringWithFormat:@"%@",strPlayerName]];

                                        NSInteger intMsg = [@"254" integerValue];
                                        NSData * dataMsg = [[NSData alloc] initWithBytes:&intMsg length:1];
                                        [[BLEService sharedInstance] WriteValuestoDevice:dataMsg withOcpde:@"16" withLength:@"1" with:peripheral];
                                    }
                                }
                                else if ([strPacket isEqualToString:@"fd"]) //Sensor Information
                                {
                                    NSMutableArray * arrSensorInfo = [[NSMutableArray alloc] init];
                                    int packetLength = [[self stringFroHex:[valueStr substringWithRange:NSMakeRange(2, 2)]] intValue] - 1;// -1 for fd
                                    if (packetLength > 0 )
                                    {
                                        for (int i=0; i < packetLength/3; i++)
                                        {
                                            NSString * strSensorId = [strDecrypted substringWithRange:NSMakeRange(2 + (i*6), 4)];
                                            NSString * strSensorType = [strDecrypted substringWithRange:NSMakeRange(2 + (i*6) + 4, 2)];
                                            NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:strSensorId,@"sensor_id",strSensorType,@"sensor_type", nil];
                                            [arrSensorInfo addObject:dict];
                                        }
                                        [self->_delegate RecieveSensorInformationofSession:arrSensorInfo];
                                    }
                                    NSInteger intMsg = [@"253" integerValue];
                                    NSData * dataMsg = [[NSData alloc] initWithBytes:&intMsg length:1];
                                    [[BLEService sharedInstance] WriteValuestoDevice:dataMsg withOcpde:@"16" withLength:@"1" with:peripheral];

                                }
                                else if ([strPacket isEqualToString:@"fc"]) //Session Data
                                {
                                    int packetLength = [[self stringFroHex:[valueStr substringWithRange:NSMakeRange(2, 2)]] intValue] - 3;// -1 for fc & -2 for sequence No.
                                    [self->_delegate RecieveSessionDataString:strDecrypted withPacketLength:packetLength];
                                }
                                else if ([strPacket isEqualToString:@"fb"]) //End of Session Data
                                {
                                    [self->_delegate RecieveSessionEndPacket];
                                }
                            }
                        }
                    });
                }
                else
                {

                }
            }
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error;
{
//    NSLog(@"<=======didWriteValueForCharacteristic========>%@ ===Error==%@",characteristic.value,error.description);
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error;
{
//    NSLog(@"<=======didWriteValueForDescriptor========>%@ ===Error==%@",descriptor.value, error.description);
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
}
#pragma mark - Add/Delete Device Info
-(void)AddDeviceInformation:(CBPeripheral *)peripheral
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        NSString * strKey = [[NSUserDefaults standardUserDefaults] valueForKey:@"EncryptionKey"];
        NSString * strKeyUnsigned = [self getStringConvertedinUnsigned:strKey];
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        NSNumber *timeStampObj = [NSNumber numberWithInteger: timeStamp];
        NSString * strUserData = [NSString stringWithFormat:@"HQINCA%@",timeStampObj];//1597731984

        if (![[self checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:@"UserUniqueData"]] isEqualToString:@"NA"])
        {
            NSString * strUserName = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserUniqueData"];
            if ([strUserName length] < 16)
            {
                strUserName = [NSString stringWithFormat:@"%@%@",strUserName,[strUserData substringWithRange:NSMakeRange(0, (16 - [strUserName length]))]];
            }
            else if([strUserName length] > 16)
            {
                strUserName = [strUserName substringWithRange:NSMakeRange(0, 16)];
            }
            strUserData = strUserName;
        }
        strUserData = @"kalpeshpanchasar";
        NSLog(@"Send Data==%@",strUserData);
        
        NSString * strPacket = [self getStringConvertedinUnsigned:[APP_DELEGATE SyncUserTextinfowithDevice:strUserData]];
        NSData * strDecrypted = [APP_DELEGATE GetEncryptedKeyforData:strPacket withKey:strKeyUnsigned withLength:strKey.length / 2];
        [self writeDeviceInfotoPeripheral:strDecrypted with:peripheral withOpcode:3];
    });
}
-(void)DeleteDeviceInformation:(CBPeripheral *)peripheral
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        NSString * strKey = [[NSUserDefaults standardUserDefaults] valueForKey:@"EncryptionKey"];
        NSString * strKeyUnsigned = [self getStringConvertedinUnsigned:strKey];
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        NSNumber *timeStampObj = [NSNumber numberWithInteger: timeStamp];
        NSString * strUserData = [NSString stringWithFormat:@"HOLDIT%@",timeStampObj];//HolditWrite1597731984

        if (![[self checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:@"UserUniqueData"]] isEqualToString:@"NA"])
        {
            NSString * strUserName = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserUniqueData"];
            if ([strUserName length] < 16)
            {
                strUserName = [NSString stringWithFormat:@"%@%@",strUserName,[strUserData substringWithRange:NSMakeRange(0, (16 - [strUserName length]))]];
            }
            else if([strUserName length] > 16)
            {
                strUserName = [strUserName substringWithRange:NSMakeRange(0, 16)];
            }
            strUserData = strUserName;
        }
        NSString * strPacket = [self getStringConvertedinUnsigned:[APP_DELEGATE SyncUserTextinfowithDevice:strUserData]];
        NSData * strDecrypted = [APP_DELEGATE GetEncryptedKeyforData:strPacket withKey:strKeyUnsigned withLength:strKey.length / 2];
        [self writeDeviceInfotoPeripheral:strDecrypted with:peripheral withOpcode:4];
    });
}
#pragma mark - To Write Request to Device
-(void)writeDeviceInfotoPeripheral:(NSData *)message with:(CBPeripheral *)peripheral withOpcode:(NSInteger)opcode
{
    //Opcode : 3 (Add device) ||  4 : (Delete Device) ||  5 : (Verify Device)
    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
    
    NSInteger opInt = opcode;
    NSData * opCodeData = [[NSData alloc] initWithBytes:&opInt length:1];
    NSInteger lengths = 16;
    NSData * lengthData = [[NSData alloc] initWithBytes:&lengths length:1];

    NSMutableData * finalData = [opCodeData mutableCopy];
    [finalData appendData:lengthData];
    [finalData appendData:message];
    NSLog(@"SENDING   ....  Data=%@",finalData);
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:finalData];
}

-(void)WriteValuestoDevice:(NSData *)datas withOcpde:(NSString *)strOpcode withLength:(NSString *)strLength with:(CBPeripheral *)peripheral
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
      {
        if (peripheral != nil)
        {
            if (peripheral.state == CBPeripheralStateConnected)
            {
                CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
                CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
                
                NSString * StrData = [NSString stringWithFormat:@"%@",datas];
                StrData = [StrData stringByReplacingOccurrencesOfString:@" " withString:@""];
                StrData = [StrData stringByReplacingOccurrencesOfString:@"<" withString:@""];
                StrData = [StrData stringByReplacingOccurrencesOfString:@">" withString:@""];
                NSString * strPacket = [self getStringConvertedinUnsigned:StrData];
                NSString * strKey = [[NSUserDefaults standardUserDefaults] valueForKey:@"EncryptionKey"];
                NSString * strKeyUnsigned = [self getStringConvertedinUnsigned:strKey];
                NSData * strEncryptedData = [APP_DELEGATE GetEncryptedKeyforData:strPacket withKey:strKeyUnsigned withLength:strKey.length / 2];
                
                NSInteger intOpcode = [strOpcode integerValue];
                NSData * opcodeData = [[NSData alloc] initWithBytes:&intOpcode length:1];

                NSInteger intLength = [strLength integerValue];
                NSData * lengthData = [[NSData alloc] initWithBytes:&intLength length:1];

                NSMutableData * finalData = [opcodeData mutableCopy];
                [finalData appendData:lengthData];
                [finalData appendData:strEncryptedData];
                NSLog(@"Final Wrote Data---->%@",finalData);
                [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:finalData];
            }
        }
    });
    
    /*if (peripheral != nil)
    {
        if (peripheral.state == CBPeripheralStateConnected)
        {
            CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:message];
        }
    }*/
}

-(void)SendCommandWithPeripheral:(CBPeripheral *)kp withValue:(NSString *)strValue
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            NSInteger indexInt = [strValue integerValue];
            NSData * indexData = [[NSData alloc] initWithBytes:&indexInt length:1];
            
            NSLog(@"Final data%@",indexData); // For battery
            
            CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:indexData];
        }
    }
}
-(void) CBUUIDwriteValue:(CBUUID *)su characteristicUUID:(CBUUID *)cu p:(CBPeripheral *)p data:(NSData *)data
{
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic)
    {
        return;
    }
    [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}
-(void)SetUTCTimetoDevice:(CBPeripheral *)peripheral;
{
    if (peripheral != nil)
    {
        if (peripheral.state == CBPeripheralStateConnected)
        {
            long long mills = (long long)([[NSDate date]timeIntervalSince1970]);
            NSData *dates = [NSData dataWithBytes:&mills length:4];
            
            NSInteger intOpcode = [@"24" integerValue];
            NSData * dataOpcode = [[NSData alloc] initWithBytes:&intOpcode length:1];
            
            NSInteger intLength = [@"04" integerValue];
            NSData * dataLength = [[NSData alloc] initWithBytes:&intLength length:1];
            
            NSMutableData *completeData = [dataOpcode mutableCopy];
            [completeData appendData:dataLength];
            [completeData appendData:dates];
            
            NSLog(@"UTC Time Data==%@ and RTC==%lld",completeData,mills); // For battery
            
            CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];
        }
    }
}
#pragma mark - SYNC Device Infor WITH BLE DEVICE

-(void)SyncUserTextinfowithDevice:(NSString *)strName with:(CBPeripheral *)peripheral withOpcode:(NSString *)opcode
{
    NSString * str = [self hexFromStr:strName];
    NSData * msgData = [self dataFromHexString:str];
    
    NSInteger intLength = [strName length];
    NSData * lengthData = [[NSData alloc] initWithBytes:&intLength length:1];

    NSInteger intOpcode = [opcode integerValue];
    NSData * dataOpcode = [[NSData alloc] initWithBytes:&intOpcode length:1];

    NSMutableData *completeData = [dataOpcode mutableCopy];
    [completeData appendData:lengthData];
    [completeData appendData:msgData];

    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];
    NSLog(@"Data====>>>>%@",strName);
    
    CBUUID * ssUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
    CBUUID * ccUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
    [self CBUUIDwriteValue:ssUUID characteristicUUID:ccUUID p:peripheral data:completeData];
}
#pragma mark - To Enable Notification on device
-(void)EnableNotificationsForCommand:(CBPeripheral*)kp withType:(BOOL)isMulti
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
    
    kp.delegate = self;
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:kp on:YES];
}
-(void)EnableNotificationsForDATA:(CBPeripheral*)kp withType:(BOOL)isMulti
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
    
    kp.delegate = self;
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:kp on:YES];
}
#pragma mark - To Send Notification
-(void)sendNotifications:(CBPeripheral*)kp withType:(BOOL)isMulti withUUID:(NSString *)strUUID
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
    kp.delegate = self;
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:kp on:YES];
}
-(void)sendNotificationsForOff:(CBPeripheral*)kp withType:(BOOL)isMulti
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
    
    kp.delegate = self;
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:kp on:NO];
}
#pragma mark - Sending notifications
-(void)CBUUIDnotification:(CBUUID*)su characteristicUUID:(CBUUID*)cu p:(CBPeripheral *)p on:(BOOL)on
{
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic)
    {
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
}
-(NSInteger)convertAlgo:(NSInteger)m_auth_key
{
    NSInteger final = ((((m_auth_key * 44) + 1232) * 22) - (121*m_auth_key + 778));//((((m_auth_key * 44) + 1232) * 22) - (121*m_auth_key + 778));;
    return final;
}
#pragma mark - Conversation Methods
-(NSString*)hexFromStr:(NSString*)str
{
    NSData* nsData = [str dataUsingEncoding:NSUTF8StringEncoding];
    const char* data = [nsData bytes];
    NSUInteger len = nsData.length;
    NSMutableString* hex = [NSMutableString string];
    for(int i = 0; i < len; ++i)
        [hex appendFormat:@"%02X", data[i]];
    return hex;
}
-(int)getSignedNegativeValuefromHexaDecimal:(NSString *)strVal
{
    NSString *tempNumber = strVal;
    NSScanner *scanner = [NSScanner scannerWithString:tempNumber];
    unsigned int temp;
    [scanner scanHexInt:&temp];
    int actualInt = (char)temp; //why char because you have 8 bit integer
    NSLog(@"%@:%d:%d",tempNumber, temp, actualInt);
    return actualInt;
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
-(NSString *)getStringConvertedinUnsigned:(NSString *)strNormal
{
    NSString * strKey = strNormal;
    long ketLength = [strKey length]/2;
    NSString * strVal;
    for (int i=0; i<ketLength; i++)
    {
        NSRange range73 = NSMakeRange(i*2, 2);
        NSString * str3 = [strKey substringWithRange:range73];
        if ([strVal length]==0)
        {
            strVal = [NSString stringWithFormat:@" 0x%@",str3];
        }
        else
        {
            strVal = [strVal stringByAppendingString:[NSString stringWithFormat:@" 0x%@",str3]];
        }
    }
    return strVal;
}
- (NSData *)dataFromHexString:(NSString*)hexStr
{
    const char *chars = [hexStr UTF8String];
    int i = 0, len = hexStr.length;
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    
    return data;
}
-(void)getFloatValueofDecimal:(NSString *)strDecimal
{
    float tempCell = [self getSignedIntfromHex:strDecimal]/100;
    NSLog(@"=======>TEMP=%f",tempCell);
    NSString * tempFar = [NSString stringWithFormat:@"%.02f",(tempCell*1.8)+32];
    NSLog(@"=======>TEMP Fenhite=%f",tempCell);

}
-(float)getSignedIntfromHex:(NSString *)hexStr
{
    NSString *tempNumber = hexStr;
    NSScanner *scanner = [NSScanner scannerWithString:tempNumber];
    unsigned int temp;
    [scanner scanHexInt:&temp];
    float actualInt = (int16_t)(temp);
    return actualInt;
}

//Method to get sigend floating point from Hexadecimal
//#pragma mark- Hexadecimal to Floating point
//float ConverttoFloatfromHexadecimal(NSString *  strHex)
//{
//    const char * strCCC = [strHex UTF8String];
//
//    uint32_t num;
//    float f;
//    sscanf(strCCC, "%x", &num);  // assuming you checked input
//    f = *((float*)&num);
//    printf("the hexadecimal 0x%08x becomes %.3f as a float\n", num, f);
//    
//    return f;
//}

#pragma mark- RSSI Update Delegates
-(void) readDeviceBattery:(CBPeripheral *)device
{
    if (device.state != CBPeripheralStateConnected)
    {
        return;
    }
    else
    {
        [self notification:TI_KEYFOB_BATT_SERVICE_UUID characteristicUUID:TI_KEYFOB_LEVEL_SERVICE_UUID p:device on:YES];
    }
}
-(void)readDeviceRSSI:(CBPeripheral *)device
{
    if (device.state == CBPeripheralStateConnected)
    {
        [device readRSSI];
    }
    else
    {
        return;
    }
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (error == nil)
    {
        if(peripheral == nil)
            return;
        if (peripheral != servicePeripheral)
        {
            return ;
        }
        if (peripheral==servicePeripheral)
        {
            if (_delegate)
            {
                [_delegate updateSignalImage:[peripheral.RSSI doubleValue] forDevice:peripheral];
            }
            if (peripheral.state == CBPeripheralStateConnected)
            {
            }
        }
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    if(peripheral == nil)
        return;
    
    if (peripheral != servicePeripheral)
    {
        //NSLog(@"Wrong peripheral\n");
        return ;
    }
    
    if (peripheral==servicePeripheral)
    {
        
    }
}
#pragma mark- Other Helper Methods
-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2
{
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1];
    [UUID2.data getBytes:b2];
    if (memcmp(b1, b2, UUID1.data.length) == 0)return 1;
    else return 0;
}
-(const char *) CBUUIDToString:(CBUUID *) UUID
{
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}
-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p
{
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    return nil; //Service not found on this peripheral
}
-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}
-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++)
    {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil; //Characteristic not found on this service
}
-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service)
    {
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic)
    {
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
}
-(UInt16) CBUUIDToInt:(CBUUID *) UUID
{
    char b1[16];
    [UUID.data getBytes:b1];
    return ((b1[0] << 8) | b1[1]);
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

@end
