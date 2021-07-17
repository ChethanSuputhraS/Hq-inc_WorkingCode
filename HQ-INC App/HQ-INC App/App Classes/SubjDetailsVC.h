//
//  SubjDetailsVC.h
//  HQ-INC App
//
//  Created by Ashwin on 3/25/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Charts;  
NS_ASSUME_NONNULL_BEGIN


@interface SubjDetailsVC : UIViewController
{
    UITableView *tblListOfSensor;
    UILabel* lblName,*lblNumber;
    UIButton *btnRead,*btnSpotCheck,*btnViewSnr;
    UIImageView * imgView;
    
    NSMutableArray * arrSubjects,*arrRecords;
    BOOL isSessionStarted, blinkStatus, blinkStatusCore, blinkStatusSkin;;
    UILabel* lblCoreTmp;
    UILabel* lblSkinTmp;
    NSMutableArray * arrSkinsTemp, * arrCoreTemp;
    NSMutableArray *yVals1, * yVals2;
    NSInteger xCount;
    NSMutableArray * arrTempValues;
    NSTimer * blinkTimerCore, * blinkTimerSkin;
    NSInteger coreBlinkCount, skinBlinkCount;

    NSMutableArray * arrSessionGraphData, * arrSavedSensors;
    UITableView * tblDevices;
    NSMutableDictionary * liveSessionDetail;
    UIView *ProfileView ,*graphBgView,*viewAllSensor,*viewForListOfSensor;
    
    UILabel * lblSensor3,* lblSensor4,* lblSensor5,* lblSensor6,* lblSensor7,* lblSensor8,* lblSensor9,* lblSensor10;
    UILabel * lblTemp3,* lblTemp4,* lblTemp5,* lblTemp6,* lblTemp7,* lblTemp8,* lblTemp9,* lblTemp10;
    
    NSMutableArray * arrAvailSensorsofMonitor;
    int totalAvailableSensorofMonitor;
    BOOL isCommandforSession;
}

-(void)StartSessionConfirmation:(BOOL)isSessionStartSuccess;
-(void)SendTemperatureReadingtoDetailVC:(NSString *)strSensorID withTemperature:(NSString *)strTemp withSensorType:(NSString *)strSensorType;
-(void)ShowErrorMessagewithOpcode:(NSString *)strOpcode;
-(void)ShowErrorMessagewithStopSession:(NSString *)strStopRead;
-(void)WritePlayerNametoMonitorttoStartSession;

-(void)ReceiveSensorDetails:(NSMutableArray *)arrSensors;
-(void)LiveSessionReadingStarted:(NSMutableDictionary *)LiveSessionData;
-(void)UpdatePlayerDatafromSetup:(NSMutableDictionary *)updatedDataDict;
-(void)GetInstantReadingsData:(NSString *)strSensorID withTemperature:(NSString *)strTemp withSensorType:(NSString *)strSensorType withPacket:(NSString *)strPacket;
-(void)ReceiveAvailableSensorsfromMonitorBeforeStartSession:(NSString *)strPacket withPacketLength:(NSString *)strPacketLength;

@property (nonatomic, strong) LineChartView* chartView;
@property(nonatomic, strong) NSMutableDictionary * dataDict;
@property(nonatomic, strong) NSMutableDictionary * sessionDict;
@property BOOL isfromSessionList;

@end

NS_ASSUME_NONNULL_END
