//
//  SessionReadVC.m
//  HQ-INC App
//
//  Created by Ashwin on 10/28/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "SessionReadVC.h"
#import "SessionCell.h"
#import "ViewSessionVC.h"
@interface SessionReadVC ()<UITableViewDelegate,UITableViewDataSource>
{
    UILabel * lblHeader;
}
@end

@implementation SessionReadVC

- (void)viewDidLoad
{
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = UIColor.blackColor;
    
    
    UIColor *lblTxtClr = [UIColor colorWithRed:180.0/255 green:245.0/255 blue:254.0/255 alpha:1];
     
     lblHeader = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, DEVICE_WIDTH, 50)];
     [self setLabelProperties:lblHeader withText:@"SESSIONS" backColor:UIColor.clearColor textColor:lblTxtClr textSize:25];
     lblHeader.textAlignment = NSTextAlignmentCenter;
     [self.view addSubview:lblHeader];
     
     UIButton * btnBck = [UIButton buttonWithType:UIButtonTypeCustom];
     [btnBck setFrame:CGRectMake(10, globalStatusHeight-5, 50, 50)];
     btnBck.backgroundColor = UIColor.clearColor;
//     [btnBck setImage:[UIImage imageNamed:@"backArr.png"] forState:UIControlStateNormal];
     [btnBck addTarget:self action:@selector(btnBckClick) forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:btnBck];
     
     UIImageView * imgBack = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
     imgBack.image = [UIImage imageNamed:@"backArr.png"];
     [btnBck addSubview:imgBack];
     
     UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, globalStatusHeight + 60 - 1, DEVICE_WIDTH, 0.5)];
     line.backgroundColor = [UIColor lightGrayColor];
     [self.view addSubview:line];
    
    int yy = globalStatusHeight + 65;
    
    tblReadSession = [[UITableView alloc]initWithFrame: CGRectMake(5, yy, DEVICE_WIDTH-10, DEVICE_HEIGHT-yy) style:UITableViewStylePlain];
      tblReadSession.frame = CGRectMake(5, yy, DEVICE_WIDTH-10, DEVICE_HEIGHT-yy);
      tblReadSession.backgroundColor = UIColor.whiteColor;
      tblReadSession.delegate = self;
      tblReadSession.dataSource = self;
      tblReadSession.allowsMultipleSelection = true;
      tblReadSession.backgroundColor = UIColor.clearColor;
      tblReadSession.separatorStyle = UITableViewScrollPositionNone;
      [self.view addSubview:tblReadSession];
    
    if ( IS_IPHONE_4 || IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_6plus)
    {
        lblHeader.frame = CGRectMake(0, 20, DEVICE_WIDTH, 50);
        lblHeader.font = [UIFont fontWithName:CGRegular size:textSize-6];
        
        [btnBck setFrame:CGRectMake(10, globalStatusHeight-5, 30, 30)];

        imgBack.frame = CGRectMake(5, 5, 30, 30);

        line.frame = CGRectMake(0, globalStatusHeight + 40 - 1, DEVICE_WIDTH, 0.5);
        tblReadSession.frame = CGRectMake(5, yy, DEVICE_WIDTH-10, DEVICE_HEIGHT-yy);

    }
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)btnBckClick
{
    [self.navigationController popViewControllerAnimated:true];
}
#pragma mark-tableview method
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( IS_IPHONE_4 || IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_6plus)
    {
        return 40;
    }
    return 60;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    SessionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[SessionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }

     cell.lblname.text = @"29-10-2020  01:20 PM";
     cell.imgArrow.hidden = false;
    
    
    if (indexPath.row % 2 == 0)
    {
        cell.backgroundColor = [UIColor colorWithRed:230.0/255.0f green:230.0/255.0f blue:230.0/255.0f alpha:1];
    }
    else
    {
        cell.backgroundColor = [UIColor lightGrayColor];
    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.backgroundColor = UIColor.clearColor;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    ViewSessionVC * vVC  = [[ViewSessionVC alloc] init];
    [self.navigationController pushViewController:vVC animated:true];
}
-(void)setLabelProperties:(UILabel *)lbl withText:(NSString *)strText backColor:(UIColor *)backColor textColor:(UIColor *)txtColor textSize:(int)txtSize
{
    lbl.text = strText;
    lbl.textColor = txtColor;
    lbl.backgroundColor = backColor;
    lbl.clipsToBounds = true;
    lbl.textAlignment = NSTextAlignmentLeft;
    lbl.layer.cornerRadius = 5;
    lbl.font = [UIFont fontWithName:CGRegular size:txtSize];
}
@end
