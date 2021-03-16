//
//  SessionPlayersVC.m
//  HQ-INC App
//
//  Created by Kalpesh Panchasara on 05/02/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import "SessionPlayersVC.h"
#import "PlayerSubjVC.h"
#import "PlayerSubjCELL.h"
#import "SessionListVC.h"


@interface SessionPlayersVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray * arrPlayers;
}


@end

@implementation SessionPlayersVC

- (void)viewDidLoad
{
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = UIColor.blackColor;
    
    lblLinking = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, DEVICE_WIDTH, 50)];
    lblLinking.text = @"Players";
    lblLinking.textColor = [UIColor whiteColor];
    lblLinking.textAlignment = NSTextAlignmentCenter;
    lblLinking.font = [UIFont boldSystemFontOfSize:25];
    [self.view addSubview:lblLinking];

    tblLinkMonitor = [[UITableView alloc]initWithFrame: CGRectMake(40, 64, DEVICE_WIDTH-80, DEVICE_HEIGHT-170) style:UITableViewStylePlain];
    tblLinkMonitor.frame = CGRectMake(0, 100, DEVICE_WIDTH, DEVICE_HEIGHT-170);
    tblLinkMonitor.backgroundColor = UIColor.whiteColor;
    tblLinkMonitor.delegate = self;
    tblLinkMonitor.dataSource = self;
    tblLinkMonitor.allowsMultipleSelection = true;
    tblLinkMonitor.backgroundColor = UIColor.blackColor;
    tblLinkMonitor.separatorStyle = UITableViewScrollPositionNone;

    [self.view addSubview:tblLinkMonitor];
    
    btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(100, DEVICE_HEIGHT-60, 150, 50)];
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    //    [btnCancel setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    btnCancel.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    [btnCancel addTarget:self action:@selector(btnCancelClick) forControlEvents:UIControlEventTouchUpInside];
    btnCancel.layer.borderWidth = 1;
    btnCancel.layer.cornerRadius = 5;
    btnCancel.titleLabel.font = [UIFont fontWithName:CGRegular size:30];
    [self.view addSubview:btnCancel];
        
    btnDone = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-250, DEVICE_HEIGHT-60, 150, 50)];
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    btnDone.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    [btnDone addTarget:self action:@selector(btnDoneClick) forControlEvents:UIControlEventTouchUpInside];
    btnDone.layer.borderWidth = 1;
    btnDone.layer.cornerRadius = 5;
    btnDone.titleLabel.font = [UIFont fontWithName:CGRegular size:30];
    [self.view addSubview:btnDone];
    
    arrPlayers = [[NSMutableArray alloc] init];
    NSString * sqlquery = [NSString stringWithFormat:@"select * from Session_Table group by player_id"];
    [[DataBaseManager dataBaseManager] execute:sqlquery resultsArray:arrPlayers];

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
    
#pragma mark - Buttons
-(void)btnAddClick
{
    PlayerSubjVC * Pvc = [ [PlayerSubjVC alloc] init];
    [self.navigationController pushViewController:Pvc animated:(true)];
}
-(void)btnCancelClick
{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)btnDoneClick
{
    
}
#pragma mark - UITabke view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrPlayers.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // for cheking  taking Player Cell only
    
    static NSString *cellP = @"CellProfile";
    PlayerSubjCELL *cell = [tableView dequeueReusableCellWithIdentifier:cellP];
    cell = [[PlayerSubjCELL alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellP];
    
    cell.lblPlayer.frame = CGRectMake(15, 0, DEVICE_WIDTH/2, 80);
    cell.lblPlayer.font = [UIFont fontWithName:CGRegular size:25];
    
    cell.selectionStyle= UITableViewCellSelectionStyleNone;
    cell.lblLine.hidden = false;
    cell.lblPlayer.textAlignment = NSTextAlignmentLeft;
    cell.lblPlayer.text = [[arrPlayers objectAtIndex:indexPath.row] valueForKey:@"player_name"];
    cell.lblConncet.hidden = true;
    cell.imgViewpProfile.hidden = false;

    cell.imgViewpProfile.frame = CGRectMake(DEVICE_WIDTH-40, 27.5, 25, 25);
    [cell.imgViewpProfile setImage:[UIImage imageNamed:@"arrow.png"]];
    [cell.imgViewpProfile setContentMode:UIViewContentModeScaleAspectFit];
    
    cell.lblLine.frame = CGRectMake(0, 79, DEVICE_WIDTH, 1);

    
return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary * dict = [arrPlayers objectAtIndex:indexPath.row];
    SessionListVC * session = [[SessionListVC alloc] init];
    session.dictSession = dict;
    [self.navigationController pushViewController:session animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
