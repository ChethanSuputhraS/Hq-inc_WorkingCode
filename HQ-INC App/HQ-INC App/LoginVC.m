//
//  LoginVC.m
//  HQ-INC App
//
//  Created by Ashwin on 3/24/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "LoginVC.h"
#import "Constant.h"
#import "AppDelegate.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "PlayerSubjVC.h"
#import "MBProgressHUD.h"
NSString * globalDeviceToken;

@interface LoginVC ()<UITextFieldDelegate, UIScrollViewDelegate>
{
    UIImageView * myImageView;
    UIScrollView * myScrollView;
}
@end

@implementation LoginVC

//- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
//    NSLog(@"viewForZoomingInScrollView");
//    [self setTransform:scrollView.transform];
//    return self->myImageView;
//}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView.subviews objectAtIndex:1];
}
- (void)setTransform:(CGAffineTransform)transform
{
//    [super setTransform:transform];

    CGAffineTransform invertedTransform = CGAffineTransformInvert(transform);
    for (UIView *view in [myScrollView subviews])
    {
        [view setTransform:invertedTransform];
    }
}
- (void)viewDidLoad
{
    [self setNeedsStatusBarAppearanceUpdate];
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"isLoggedIn"])
    {
        isUserLoggedAndDontEndHudProcess = false;
        isUserfromLogin = NO;
        
        return;
    }
    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = UIColor.blackColor;
    
    UIImage *imageToLoad = [UIImage imageNamed:@"Splash"];

       myImageView = [[UIImageView alloc]initWithImage:imageToLoad];
       myScrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
       [myScrollView addSubview:myImageView];
       myScrollView.contentSize = myImageView.bounds.size;
       myScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
       myScrollView.minimumZoomScale = 0.3f;
       myScrollView.maximumZoomScale = 3.0f;
       myScrollView.delegate = self;
       [self.view addSubview:myScrollView];
    
    UILabel *lblLogin;
    lblLogin = [[UILabel alloc]initWithFrame:CGRectMake(0, 200, 200, 100)];
    lblLogin.text = @"Login";
    lblLogin.textColor = UIColor.whiteColor;
    lblLogin.backgroundColor = [UIColor yellowColor];
    lblLogin.textAlignment = NSTextAlignmentCenter;
    lblLogin.font = [UIFont fontWithName:CGBold size:35];
    [myScrollView addSubview:lblLogin];

    
  /*  loginView = [[UIView alloc]initWithFrame:CGRectMake(150, (DEVICE_HEIGHT-430)/2, DEVICE_WIDTH-300, 430)];
    loginView.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    loginView.layer.borderWidth = 1;
    loginView.layer.cornerRadius = 10;
    [self.view addSubview:loginView];
    
    UILabel *lblLogin;
    lblLogin = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, (loginView.frame.size.width), 40)];
    lblLogin.text = @"Login";
    lblLogin.textColor = UIColor.whiteColor;
    lblLogin.textAlignment = NSTextAlignmentCenter;
    lblLogin.font = [UIFont fontWithName:CGBold size:35];
    [loginView addSubview:lblLogin];
    
    txtUserName = [[UITextField alloc]initWithFrame:CGRectMake(80, 90, loginView.frame.size.width-160, 60)];
    txtUserName.textAlignment = NSTextAlignmentCenter;
    txtUserName.backgroundColor = UIColor.whiteColor;
    txtUserName.autocorrectionType = UITextAutocorrectionTypeNo;
    txtUserName.placeholder = @"User Name";
    txtUserName.font = [UIFont fontWithName:CGRegular size:27];
    txtUserName.delegate = self;
    txtUserName.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtUserName.keyboardType = UIKeyboardTypeEmailAddress;
    txtUserName.returnKeyType = UIReturnKeyNext;
    txtUserName.textColor = [UIColor darkGrayColor];
    txtUserName.layer.cornerRadius = 5;
     UIColor *color = [UIColor lightGrayColor];
     txtUserName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"User Name" attributes:@{NSForegroundColorAttributeName: color,NSFontAttributeName: [UIFont fontWithName:CGRegular size:27.0]}];
     [loginView addSubview:txtUserName];

    
    
    txtPasswordLogin = [[UITextField alloc]initWithFrame:CGRectMake(80, 165, loginView.frame.size.width-160, 60)];
    txtPasswordLogin.textAlignment = NSTextAlignmentCenter;
    txtPasswordLogin.backgroundColor = UIColor.whiteColor;
    txtPasswordLogin.autocorrectionType = UITextAutocorrectionTypeNo;
    txtPasswordLogin.placeholder = @"Password";
    txtPasswordLogin.textColor = [UIColor darkGrayColor];
    txtPasswordLogin.delegate = self;
    txtPasswordLogin.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtPasswordLogin.secureTextEntry = true;
    txtPasswordLogin.layer.cornerRadius = 5;
    txtPasswordLogin.font = [UIFont fontWithName:CGRegular size:27];
    txtPasswordLogin.returnKeyType = UIReturnKeyDone;
    UIColor *colorP = [UIColor lightGrayColor];
         txtPasswordLogin.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: colorP,NSFontAttributeName: [UIFont fontWithName:CGRegular size:27.0]}];
    [loginView addSubview:txtPasswordLogin];


    UIButton *btnLoginTouchId = [[UIButton alloc]initWithFrame:CGRectMake((loginView.frame.size.width - 100)/2, 260, 100, 150)];
    [btnLoginTouchId addTarget:self action:@selector(btnLoginClick) forControlEvents:UIControlEventTouchUpInside];
    btnLoginTouchId.backgroundColor = UIColor.clearColor;
    [loginView addSubview:btnLoginTouchId];
    
    imgViewFingerPrint = [[UIImageView alloc]initWithFrame:CGRectMake((loginView.frame.size.width - 100)/2, 260, 100, 150)];
    imgViewFingerPrint.image = [UIImage imageNamed:@"fingerprint.png"];
    [loginView addSubview:imgViewFingerPrint];
    
//    arrUser = [[NSMutableArray alloc] init];
//    NSString * sqlquery = [NSString stringWithFormat:@"select * from User_Table"];
//    [[DataBaseManager dataBaseManager] execute:sqlquery resultsArray:arrUser];
*/
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
#pragma mark - Buttons
-(void)btnLoginClick
{
    if ([txtUserName.text  isEqual: @""])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"HqIncApp"
        message:@"Pleaase User name." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];

    }
    else if ([txtPasswordLogin.text isEqual: @"" ])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"HqIncApp"
        message:@"Pleaase Password." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        NSMutableDictionary *dictObtained;
                
        NSString * strName = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"name"]];
        NSString * strEmail = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"user_email"]];
        NSString * strPw = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"user_password"]];
        NSString * strActive = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"is_active"]];
        NSString * strUserName = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"user_name"]];
        NSString * strDeviceToken = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"device_token"]];
        NSString * strDeviceType = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"device_type"]];
        NSString * requestStr =    [NSString stringWithFormat:@"insert into 'User_Table'('name','user_email','user_pw','is_active','user_name','device_token','device_type') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",strEmail,strName,strPw,strActive,strUserName,strDeviceToken,strDeviceType];
        //                  [[DataBaseManager dataBaseManager] executeSw:requestStr];
                NSLog(@"%@", requestStr);
        
        NSMutableDictionary *DictData = [[NSMutableDictionary alloc]init];
        [DictData setValue:@"2" forKey:@"device_type"];
        NSString *strCommand;
        [DictData setValue:txtUserName.text forKey:@"name"];
        [DictData setValue:txtPasswordLogin.text forKey:@"password"];
        [DictData setValue:@"0" forKey:@"is_social_login"];
        [DictData setValue:@"NA" forKey:@"social_type"];
        [DictData setValue:@"NA" forKey:@"social_id"];
        strCommand = @"login";
        NSLog(@"%@", dictObtained);
        NSLog(@"%@", DictData);
        
        NSString *deviceToken = globalDeviceToken;
        if (deviceToken == nil || deviceToken == NULL)
        {
            [DictData setValue:@"1234" forKey:@"device_token"];
        }
        else
        {
            [DictData setValue:deviceToken  forKey:@"device_token"];
        }
        UIViewController *plySubVC = [[PlayerSubjVC alloc]init];
        [self.navigationController pushViewController:plySubVC animated:true];
        
//         [self LoginData];

//        if ([APP_DELEGATE isNetworkreachable])
//        {
//            [self LoginData];
//        }
//        else
//        {
//            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"HqIncApp"
//                                                                           message:@"There is no internet connection. Please connect to internet first then try again."
//                                                                    preferredStyle:UIAlertControllerStyleAlert];
//
//            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
//                                                                  handler:^(UIAlertAction * action) {}];
//
//            [alert addAction:defaultAction];
//            [self presentViewController:alert animated:YES completion:nil];
//
//        }
    }
} 
#pragma mark - Should return

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtUserName)
    {
        [txtUserName resignFirstResponder];
        [txtPasswordLogin becomeFirstResponder];
    }
    else  if (textField == txtPasswordLogin)
    {
        [txtPasswordLogin resignFirstResponder];
    }
    return true;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
     if (textField == txtUserName || txtPasswordLogin)
    {
        self.view.frame = CGRectMake(0, -50, DEVICE_WIDTH, DEVICE_HEIGHT);
    }

}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
}

#pragma mark- Login DATA
-(void)LoginData
{
    NSMutableDictionary *DictData = [[NSMutableDictionary alloc]init];
    [DictData setValue:@"2" forKey:@"device_type"];
    NSString *strCommand;
    [DictData setValue:txtUserName.text forKey:@"email"];
    [DictData setValue:txtPasswordLogin.text forKey:@"password"];
    [DictData setValue:@"0" forKey:@"is_social_login"];
    [DictData setValue:@"NA" forKey:@"social_type"];
    [DictData setValue:@"NA" forKey:@"social_id"];
    strCommand = @"login";
    
    NSString *deviceToken = globalDeviceToken;
    if (deviceToken == nil || deviceToken == NULL)
    {
        [DictData setValue:@"1234" forKey:@"device_token"];
    }
    else
    {
        [DictData setValue:deviceToken  forKey:@"device_token"];
    }
//    URLManager *mangerl = [[URLManager alloc]init];
//    mangerl.commandName = @"login";
//    mangerl.delegate = self;
//    NSString *strServerUrl = @"http://succorfish.com/mobile/login"; // pass URL here
//    [mangerl urlCall:strServerUrl withParameters:DictData];
//    NSLog(@"passed info is %@",DictData);
}


#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
//    [APP_DELEGATE endHudProcess];
    NSLog(@"The result is...%@", result);
    
    NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
    tmpDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];
    if([[result valueForKey:@"commandName"] isEqualToString:@"fetchdevice"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            NSMutableDictionary * dictData = [[NSMutableDictionary alloc]init];
            dictData = [[result valueForKey:@"result"] valueForKey:@"data"];
            if ([[NSString stringWithFormat:@"%@",[dictData valueForKey:@"user_id"]] isEqualToString:CURRENT_USER_ID])
            {
                if ([[NSString stringWithFormat:@"%@",[dictData valueForKey:@"status"]]isEqualToString:@"1"])
                {
                    UIViewController *plySubVC = [[PlayerSubjVC alloc]init];
                    [self.navigationController pushViewController:plySubVC animated:true];
//                       [self insertIntoLocalDB:dictData];
                }
                else
                {

                }
            }
            else
            {
              
            }
        }
        else
        {
            if([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Invalid Token"])
            {
              
               
            }
            else
            {
//                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc]init];
//                [tmpDict setValue:strBleAddress forKey:@"bleAddress"];
            }
            
        }
    }
}
- (void)onError:(NSError *)error
{
    NSLog(@"The error is...%@", error);
    
    
    NSInteger ancode = [error code];
    
    NSMutableDictionary * errorDict = [error.userInfo mutableCopy];
    NSLog(@"errorDict===%@",errorDict);
    
    if (ancode == -1001 || ancode == -1004 || ancode == -1005 || ancode == -1009)
    {
        
    }
    else
    {
        
    }
    NSString * strLoginUrl = [NSString stringWithFormat:@"%@%@",WEB_SERVICE_URL,@"token.json"];
       if ([[errorDict valueForKey:@"NSErrorFailingURLStringKey"] isEqualToString:strLoginUrl])
       {
           NSLog(@"NSErrorFailingURLStringKey===%@",[errorDict valueForKey:@"NSErrorFailingURLStringKey"]);
       }
}
#pragma mark- Insert To dataBase

-(void)insertIntoLocalDB:(NSMutableDictionary *)dictObtained
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    NSString * strName = [APP_DELEGATE checkforValidString:[dict valueForKey:@"name"]];
    NSString * strEmail = [APP_DELEGATE checkforValidString:[dict valueForKey:@"user_email"]];
    NSString * strPw = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"password"]];
    NSString * strActive = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"is_active"]];
    NSString * strUserName = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"user_name"]];
    NSString * strDeviceToken = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"device_token"]];
    NSString * strDeviceType = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"device_type"]];
    [globalArr addObject:dict];
    NSString * requestStr =    [NSString stringWithFormat:@"insert into 'User_Table'('name','user_email','user_pw','is_active','user_name','device_token','device_type') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",strEmail,strName,strPw,strActive,strUserName,strDeviceToken,strDeviceType];
        [[DataBaseManager dataBaseManager] executeSw:requestStr];
}
@end
