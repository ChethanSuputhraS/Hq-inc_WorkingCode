//
//  LinkingVC.h
//  HQ-INC App
//
//  Created by Ashwin on 3/27/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMPullToRefreshManager.h"
#import "BLEManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface LinkingVC : UIViewController
{
    UITableView * tblDeviceList;
     UILabel *lblNoDevice,*lblError ,* lblScanning;
    MNMPullToRefreshManager * topPullToRefreshManager;
    UIView *viewForSensorNameNum, *viewForAddSensor;
    UIButton *btnCancelSnr,*btnSave;
    UITextField *txtNameSnr;
}
@end

NS_ASSUME_NONNULL_END
