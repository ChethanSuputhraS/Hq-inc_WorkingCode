//
//  BLEService.h
//
//
//  Created by Kalpesh Panchasara on 7/11/14.
//  Copyright (c) 2014 Kalpesh Panchasara, Ind. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreBluetooth/CoreBluetooth.h>

/*!
 *  @protocol SGFServiceDelegate
 *
 *  @discussion Delegate for SGFService.
 *
 */
@protocol BLEServiceDelegate <NSObject>

@optional
/*!
 *  @method activeDevice:
 *
 *  @param device	The device providing this update of communication status.
 *
 *  @discussion			This method is invoked when the @link name @/link of <i>device</i> changes.
 */
-(void)activeDevice:(CBPeripheral*)device;

/*!
 *  @method updateSignalImage:forDevice:
 *
 *  @param device	The device providing this update.
 *
 *  @discussion			This method returns the result of a @link readDeviceRSSI: @/link call.
 */
-(void)updateSignalImage:(int )RSSI forDevice:(CBPeripheral*)device;

@required
/*!
 *  @method batterySignalValueUpdated:withBattLevel:
 *
 *  @param device	The device providing this update.
 *
 *  @discussion			This method returns the result of a @link readDeviceBattery: @/link call.
 */
-(void)batterySignalValueUpdated:(CBPeripheral*)device withBattLevel:(NSString*)batLevel;
-(void)ReceiveListofSessionsID:(NSDictionary *)dictData;
-(void)RecieveSessionInformation:(NSMutableDictionary *)dictDetail;
-(void)RecievePlayerNameofSession:(NSString *)strPlayerName;
-(void)RecieveSensofrInformationofSession:(NSMutableArray *)arrSensors;
-(void)RecieveSessionDataString:(NSString *)strData withPacketLength:(int)packetLength;
-(void)RecieveSessionEndPacket;

@end

@interface BLEService : NSObject

/*!
 *  @property delegate
 *
 *  @discussion The delegate object that will receive service events.
 *
 */
@property (nonatomic, weak) id<BLEServiceDelegate>delegate;

-(id)init;

+ (instancetype)sharedInstance;


/*!
 *  @method initWithDevice:andDelegate:
 *  @discussion If the developer sets the SGFServiceDelegate while creating object for SGFManager then no need to use
 *      this method. If the developer does not set SGFServiceDelegate while creating object for SGFManager then
 *      developer has to call this method manually when device connected.
 *
 */
-(id)initWithDevice:(CBPeripheral*)device andDelegate:(id /*<BLEServiceDelegate>*/)delegate;


/*!
 *  @method startDeviceService
 *
 *  @discussion			This method activates the services of connected devices.
 */
-(void)startDeviceService;


/*!
 *  @method readDeviceBattery:
 *
 *  @param device	The device providing this update.
 *
 *  @discussion			This method starts to reading battery values of device.
 *
 *  @see                batterySignalValueUpdated:withBattLevel:
 */
-(void)readDeviceBattery:(CBPeripheral*)device;

/*!
 *  @method readDeviceRSSI:
 *
 *  @param device	The device providing this update.
 *
 *  @discussion			This method starts to reading RSSI values of device.
 *
 *  @see                updateSignalImage:forDevice:
 */

-(void)readDeviceRSSI:(CBPeripheral*)device;
-(void)sendNotifications:(CBPeripheral*)kp withType:(BOOL)isMulti withUUID:(NSString *)strUUID;
-(void)EnableNotificationsForCommand:(CBPeripheral*)kp withType:(BOOL)isMulti;
-(void)EnableNotificationsForDATA:(CBPeripheral*)kp withType:(BOOL)isMulti;
-(void)sendNotificationsForOff:(CBPeripheral*)kp withType:(BOOL)isMulti;
-(void)SendCommandWithPeripheral:(CBPeripheral *)kp withValue:(NSString *)strValue;
-(void)WriteValuestoDevice:(NSData *)datas withOcpde:(NSString *)strOpcode withLength:(NSString *)strLength with:(CBPeripheral *)peripheral;

-(NSString *)getStringConvertedinUnsigned:(NSString *)strNormal;
-(NSString *)GetDecrypedDataKeyforData:(NSString *)strData withKey:(NSString *)strKey withLength:(long)dataLength;
-(void)SetUTCTimetoDevice:(CBPeripheral *)peripheral;
-(void)getFloatValueofDecimal:(NSString *)strDecimal;

@end
