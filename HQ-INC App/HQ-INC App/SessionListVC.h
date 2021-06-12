//
//  SessionListVC.h
//  HQ-INC App
//
//  Created by Kalpesh Panchasara on 05/02/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SessionListVC : UIViewController
{
    UILabel *lblLinking;
    UITableView * tblLinkMonitor;
    UIButton * btnAdd,*btnCancel, *btnDone;
}
@property (nonatomic, strong) NSMutableDictionary * dictSession;
@end

NS_ASSUME_NONNULL_END
