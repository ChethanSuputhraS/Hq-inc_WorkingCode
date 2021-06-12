//
//  LoginVC.h
//  HQ-INC App
//
//  Created by Ashwin on 3/24/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginVC.h"





NS_ASSUME_NONNULL_BEGIN

@interface LoginVC : UIViewController
{
    UITextField *txtUserName,*txtPasswordLogin;
    UIView * loginView;
    UIImageView *imgViewFingerPrint;
    NSMutableArray * arrUser;
}
@end

NS_ASSUME_NONNULL_END
