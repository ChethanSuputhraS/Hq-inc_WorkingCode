//
//  AppDelegate.m
//  HQ-INC App
//
//  Created by stuart watts on 24/03/2020.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//
#import <objc/runtime.h>
#import "AppDelegate.h"
#import "LoginVC.h"
#import "Constant.h"
#import "PlayerSubjVC.h"
#import "GlobalSettingVC.h"
#import "SubjSetupVC.h"
#import "LinkingVC.h"
#import "HomeVC.h"
#import "Header.h"
#import "AddMonitorVC.h"
#import "BleTestClass.h"
//#import <<#header#>>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSInteger intMsg = 17;
    NSData * data = [[NSData alloc] initWithBytes:&intMsg length:1];
    const char *byte = [data bytes];
    unsigned int length = [data length];
    NSString * strBits;

    for (int i=0; i<length; i++)
    {
        char n = byte[i];
        char buffer[9];
        buffer[8] = 0; //for null
        int j = 8;
        while(j > 0)
        {
            if(n & 0x01)
            {
                buffer[--j] = '1';
            } else
        {
            buffer[--j] = '0';
        }
        n >>= 1;
        }
        strBits = [NSString stringWithFormat:@"%s",buffer];
        NSLog(@"opopoppopop=%@",strBits);

}
    NSArray * arrDays = [[NSArray alloc] initWithObjects:@"128",@"64",@"32",@"16",@"8",@"4",@"2",@"1", nil];
    for (int i = 0; i < strBits.length; i++)
    {
        NSString * strStatus = [strBits substringWithRange:NSMakeRange((i*1), 1)];
        NSLog(@"KAKPKPKPK=%@",[strBits substringWithRange:NSMakeRange((i*1), 1)]);

        if ([strStatus isEqualToString:@"1"])
        {
            NSLog(@"Value=%@",[arrDays objectAtIndex:i]);
        }
    }
//        [strDecrypted substringWithRange:NSMakeRange(2, 2)]
        
    globalArr = [[NSMutableArray alloc] init];
    globalStatusHeight = 20;
    textSize = 20;
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        textSize = 14;
    }
    if (IS_IPHONE_X)
    {
        globalStatusHeight = 44;
    }
    [self generateSecretkey];
    
    arrGlobalSensorsAdded = [[NSMutableArray alloc] init];
    
    PlayerSubjVC * view1 = [[PlayerSubjVC alloc]init];
    UINavigationController *navig = [[UINavigationController alloc]initWithRootViewController:view1];
    self.window = [[UIWindow alloc]init];
    self.window.frame = self.window.bounds;
    self.window.rootViewController = navig;
    [self.window makeKeyAndVisible];

    [self createDatabase];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * path = [paths objectAtIndex:0];
    NSLog(@"data base path:%@",[path stringByAppendingPathComponent:@"HqIncApp.sqlite"]);
    
    if ([[self checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:@"isCelsicusSelect"]] isEqualToString:@"NA"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"No" forKey:@"isCelsicusSelect"];
        [[NSUserDefaults standardUserDefaults] synchronize];
           
        NSString * strHigIngF =@"100.40ºF";
        NSString * strLowIngF =@"96.00ºF";
        NSString * strHigDrmlF = @"100.40ºF";
        NSString * strLowDermlF =@"96.00ºF";
        NSString * strHigIngC = @"38.00ºC";
        NSString * strLowIngC = @"35.56ºC";
        NSString * strHighDermlC = @"38.00ºC";
        NSString * strLowDermlC = @"35.56ºC";
        NSString * strBattry = @"20";
        NSString * strQuantity = @"20";
           
        NSString * requestStr =  [NSString stringWithFormat:@"insert into 'Alarm_Table' ('high_ingest_F', 'low_ingest_F', 'high_dermal_F', 'low_dermal_F', 'high_ingest_C', 'low_ingest_C', 'high_dermal_C',  'low_dermal_C', 'battery_alarm', 'quantity') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",strHigIngF,strLowIngF,strHigDrmlF,strLowDermlF,strHigIngC,strLowIngC,strHighDermlC,strLowDermlC,strBattry,strQuantity];
           
        [[DataBaseManager dataBaseManager] executeSw:requestStr];
    }
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma mark - data Database
-(void)createDatabase
{
    [[DataBaseManager dataBaseManager] Create_User_Table];
    [[DataBaseManager dataBaseManager] Create_Sensor_Table];
    [[DataBaseManager dataBaseManager] Create_Monitor_Table];
    [[DataBaseManager dataBaseManager] Create_Record_Table];
    [[DataBaseManager dataBaseManager] Create_Subject_Table];
    [[DataBaseManager dataBaseManager] Create_Notes_Table];
    [[DataBaseManager dataBaseManager] Create_Alarm_Table];
    [[DataBaseManager dataBaseManager] Create_Session_Table];
    [[DataBaseManager dataBaseManager] Create_SessionData_Table];
}
#pragma mark Hud Method
-(void)startHudProcess:(NSString *)text
{
    [HUD removeFromSuperview];
    HUD = [[MBProgressHUD alloc] initWithView:self.window];
    HUD.labelText = text;
    HUD.labelColor = UIColor.whiteColor;
    
    [self.window addSubview:HUD];
    [HUD show:YES];
}
-(void)endHudProcess
{
    [HUD hide:YES];
}
-(int)getSignedValue:(NSString *)strVal
{
    NSString *tempNumber = @"FB";
    NSScanner *scanner = [NSScanner scannerWithString:tempNumber];
    unsigned int temp;
    [scanner scanHexInt:&temp];
    int actualInt = (char)temp; //why char because you have 8 bit integer
    NSLog(@"%@:%d:%d",tempNumber, temp, actualInt);
    return actualInt;
}
#pragma mark Generate Pass Key Methods
-(void)generateSecretkey
{
//    {0x34, 0x55, 0x17, 0x12, 0x13, 0x88, 0x98, 0x47, 0x90, 0x08, 0x49, 0x21, 0x12, 0xd4, 0x11, 0x2e};
    [[NSUserDefaults standardUserDefaults] setValue:@"34551712138898479008492112d4112e" forKey:@"EncryptionKey"];                                                   //3499ab12138898473308492112d4112e
    [[NSUserDefaults standardUserDefaults] synchronize];
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
-(NSString *)checkforValidString:(NSString *)strRequest
{
    NSString * strValid;
    if (![strRequest isEqual:[NSNull null]])
    {
        if (strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""] && ![strRequest isEqualToString:@"(null)"])
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
-(void)clearDb
{
    NSString * strDelete = [NSString stringWithFormat:@"delete from User_Table"];
    [[DataBaseManager dataBaseManager] execute:strDelete];
}
-(NSData *)GetEncryptedKeyforData:(NSString *)strData withKey:(NSString *)strKey withLength:(long)dataLength
{
    //RAW Data of 20 bytes
    NSScanner *scanner = [NSScanner scannerWithString: strData];
    unsigned char strrRawData[20];
    unsigned index = 0;
    while (![scanner isAtEnd])
    {
        unsigned value = 0;
        if (![scanner scanHexInt: &value])
        {
            // invalid value
            break;
        }
        strrRawData[index++] = value;
    }
    
    //Password encrypted Key 16 bytes
    NSScanner *scannerKey = [NSScanner scannerWithString: strKey];
    unsigned char strrDataKey[16];
    unsigned indexKey = 0;
    while (![scannerKey isAtEnd])
    {
        unsigned value = 0;
        if (![scannerKey scanHexInt: &value])
        {
            // invalid value
            break;
        }
        strrDataKey[indexKey++] = value;
    }
    
    unsigned char  tempResultOp[16];
    Header_h AES_ECB(strrRawData, strrDataKey, tempResultOp, 1);
    
    NSUInteger size = dataLength;
    NSData* data = [NSData dataWithBytes:(const void *)tempResultOp length:sizeof(unsigned char)*size];
  return data;
}
#pragma mark - For Decrypting Data
-(NSString *)GetDecrypedDataKeyforData:(NSString *)strData withKey:(NSString *)strKey withLength:(long)dataLength
{
    //RAW Data of 20 bytes
    NSScanner *scanner = [NSScanner scannerWithString: strData];
    unsigned char strrRawData[16];
    unsigned index = 0;
    while (![scanner isAtEnd])
    {
        unsigned value = 0;
        if (![scanner scanHexInt: &value])
        {
            // invalid value
            break;
        }
        strrRawData[index++] = value;
    }

    //Password encrypted Key 16 bytes
    NSScanner *scannerKey = [NSScanner scannerWithString: strKey];
    unsigned char strrDataKey[16];
    unsigned indexKey = 0;
    while (![scannerKey isAtEnd])
    {
        unsigned value = 0;
        if (![scannerKey scanHexInt: &value])
        {
            // invalid value
            break;
        }
        strrDataKey[indexKey++] = value;
    }

    unsigned char  strSentData[] = {0x00, 0x00,0x00, 0x00, 0x00, 0x00, 0x00, 0x00,0x00, 0x00,0x00, 0x00, 0x00, 0x00, 0x00, 0x00};

    strSentData[1] = strSentData[1] ^ strrRawData[1];
    strSentData[2] = strSentData[2] ^ strrRawData[2];
    strSentData[3] = strSentData[3] ^ strrRawData[3];
    strSentData[4] = strSentData[4] ^ strrRawData[4];

    unsigned char  tempResultOp[16];
    Header_h AES_ECB(strrRawData, strrDataKey, tempResultOp, 0);

    NSString * strRawResult = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",tempResultOp[0],tempResultOp[1],tempResultOp[2],tempResultOp[3],tempResultOp[4],tempResultOp[5],tempResultOp[6],tempResultOp[7],tempResultOp[8],tempResultOp[9],tempResultOp[10],tempResultOp[11],tempResultOp[12],tempResultOp[13],tempResultOp[14],tempResultOp[15]];
//    NSLog(@"Rawwww Result=%@",strRawResult);
    return strRawResult;
}
-(NSString *)SyncUserTextinfowithDevice:(NSString *)strName
{
    NSString * str = [self hexFromStr:strName];
//    NSLog(@"Data====>>>>%@",str);
    return str;
}
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
-(void)getPlaceholderText:(UITextField *)txtField  andColor:(UIColor*)color
{
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
          UILabel *placeholderLabel = object_getIvar(txtField, ivar);
          placeholderLabel.textColor = color;
}
@end
