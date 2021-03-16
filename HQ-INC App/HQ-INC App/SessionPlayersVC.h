//
//  SessionPlayersVC.h
//  HQ-INC App
//
//  Created by Kalpesh Panchasara on 05/02/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SessionPlayersVC : UIViewController
{
    UILabel *lblLinking;
    UITableView * tblLinkMonitor;
    UIButton * btnAdd,*btnCancel, *btnDone;
}
@end

NS_ASSUME_NONNULL_END
