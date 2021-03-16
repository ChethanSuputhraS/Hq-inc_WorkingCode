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
    UITableView * tblPreviousCoreTmp,* tblPreviousSkinTmp;
    UILabel* lblName,*lblNumber;
    UIButton *btnRead,*btnSpotCheck,*btnViewSnr;
    UIImageView * imgView;
}
-(void)SetupDemoFromAddSensorData:(NSMutableArray *)arryData;
-(void)StartSessionConfirmation:(BOOL)isSessionStartSuccess;
-(void)SendTemperatureReadingtoDetailVC:(NSMutableArray *)arrSensorData;
-(void)ShowErrorMessagewithOpcode:(NSString *)strOpcode;
-(void)ShowErrorMessagewithStopSession:(NSString *)strStopRead;
-(void)WritePlayerNametoMonitorttoStartSession;

@property (nonatomic, strong) LineChartView* chartView;

@property(nonatomic, strong) NSMutableDictionary * dataDict;
@property(nonatomic, strong) NSMutableDictionary * sessionDict;
@property BOOL isfromSessionList;
@end

NS_ASSUME_NONNULL_END
