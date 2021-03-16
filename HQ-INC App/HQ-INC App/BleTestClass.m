//
//  BleTestClass.m
//  HQ-INC App
//
//  Created by Ashwin on 10/15/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "BleTestClass.h"
#import "PlayerSubjCELL.h"
#import "BLEService.h"

@interface BleTestClass ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UITextField *txtFld ;
    UITableView * tblList;
    NSMutableArray * arrData;
}
@end

@implementation BleTestClass

- (void)viewDidLoad
{
    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self SetupMainClass];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)SetupMainClass
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:viewHeader];
    
    
    UIButton * btnBck = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBck setFrame:CGRectMake(10, globalStatusHeight-5, 90, 50)];
    btnBck.backgroundColor = UIColor.clearColor;
//    [btnBck setImage:[UIImage imageNamed:@"BackArrow.png"] forState:UIControlStateNormal];
    [btnBck addTarget:self action:@selector(btnBckClick) forControlEvents:UIControlEventTouchUpInside];
    [btnBck setTitle:@"Cancel" forState:UIControlStateNormal];
    [btnBck setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [viewHeader addSubview:btnBck];
    
    UIImageView * imgBack = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 25, 25)];
    imgBack.image = [UIImage imageNamed:@"backArr.png"];
//    [btnBck addSubview:imgBack];

    
    txtFld = [[UITextField alloc] initWithFrame:CGRectMake(10, 64, DEVICE_WIDTH - 300, 50)];
    txtFld.backgroundColor = UIColor.whiteColor;
    txtFld.delegate =  self;
    txtFld.placeholder = @" Enter Text here";
    txtFld.layer.cornerRadius = 6;
    txtFld.autocorrectionType = UITextAutocorrectionTypeNo;
    txtFld.layer.borderColor = UIColor.blackColor.CGColor;
    txtFld.layer.borderWidth = 1;
    txtFld.layer.masksToBounds = YES;
    [self.view addSubview:txtFld];
    
    UIButton * btnSend = [[UIButton alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-220, 54, 120, 70)];
    btnSend.backgroundColor = UIColor.clearColor;
    [btnSend setTitle:@"Send" forState:UIControlStateNormal];
    [btnSend setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btnSend addTarget:self action:@selector(btnSendClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSend];
    btnSend.layer.borderWidth = 1;
    btnSend.layer.masksToBounds = YES;
    [btnSend setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    btnSend.layer.borderColor = UIColor.blackColor.CGColor;

    
    tblList = [[UITableView alloc] initWithFrame:CGRectMake(10, 160, DEVICE_WIDTH-20, 55)];
    tblList.backgroundColor = UIColor.whiteColor;
    tblList.delegate = self;
    tblList.dataSource = self;
    tblList.allowsMultipleSelection = true;
    tblList.separatorStyle = UITableViewScrollPositionNone;
    tblList.layer.borderColor = UIColor.blackColor.CGColor;
    tblList.layer.borderWidth = 1;
    tblList.layer.masksToBounds = YES;

    [self.view addSubview:tblList];
}
-(void)btnBckClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark-Tavbleview method
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrData.count;
    // array have to pass
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellP = @"CellProfile";
    PlayerSubjCELL *cell = [tableView dequeueReusableCellWithIdentifier:cellP];
    cell = [[PlayerSubjCELL alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellP];
    
    cell.lblPlayer.frame = CGRectMake(5, 0, DEVICE_WIDTH/2, 50);
    cell.selectionStyle= UITableViewCellSelectionStyleNone;
    cell.lblLine.hidden = false;
    cell.lblPlayer.textAlignment = NSTextAlignmentLeft;
    cell.lblPlayer.text = [NSString stringWithFormat:@"%@",[arrData objectAtIndex:indexPath.row]];
    cell.lblPlayer.textColor = [UIColor blackColor];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
-(void)btnSendClick
{
    //[[BLEService sharedInstance] WriteTestTexttoBLEDevice:txtFld.text withPeripheral:globalPeripheral];
}
-(void)updateReceivedDatafromDevice:(NSString *)strData
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [APP_DELEGATE endHudProcess];

        NSString * strValue = [strData substringWithRange:NSMakeRange(4, [strData length]-4)];
        NSMutableString * newString = [[NSMutableString alloc] init];
        int i = 0;
        while (i < [strValue length])
        {
            NSString * hexChar = [strValue substringWithRange: NSMakeRange(i, 2)];
            int value = 0;
            sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
            [newString appendFormat:@"%c", (char)value];
            i+=2;
        }

        self->arrData = [[NSMutableArray alloc] init];
        [self->arrData addObject:newString];
        [self->tblList reloadData];

    });
}
#pragma mark - Textfield Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
        return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
   
    
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    const char * cc = [string cStringUsingEncoding:NSUTF8StringEncoding];
    CGFloat isbackspace  = strcmp(cc, "\\b");
    
    if (isbackspace == -92)
    {
        return YES;
    }
//    if let char = string.cString(using: String.Encoding.utf8)
//    {
//        let isBackSpace = strcmp(char, "\\b")
//        if (isBackSpace == -92) {
//            print("Backspace was pressed")
//        }
//    }
    NSUInteger newLength = [textField.text length];
    return (newLength > 18) ? NO : YES;

}

@end
