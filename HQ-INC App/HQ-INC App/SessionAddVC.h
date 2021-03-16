//
//  SessionAddVC.h
//  HQ-INC App
//
//  Created by Ashwin on 10/28/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SessionAddVC : UIViewController
{
    UILabel *lblHeader;
    UITableView * tbladdSession;
}
-(void)ConnectedMonitorDetail:(NSMutableDictionary *)arryFromAddMonitor;
-(void)SetupDemoFromAddSensorData:(NSMutableArray *)arryData;
-(void)StartSessionConfirmation:(BOOL)isSessionStartSuccess;
@end

NS_ASSUME_NONNULL_END
