//
//  SubjDetailsVC.m
//  HQ-INC App
//
//  Created by Ashwin on 3/25/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//
#import "AppDelegate.h"
#import "SubjDetailsVC.h"
#import "CollectionCustomCell.h"
#import "SubjSetupVC.h"
#import "PlayerSubjVC.h"
#import "PlayerSubjCELL.h"
#import "SessionAddVC.h"
#import "SessionReadVC.h"
#import "BLEService.h"
#import <MessageUI/MessageUI.h>

@import Charts;

@interface SubjDetailsVC ()<UITableViewDelegate,UITableViewDataSource,ChartViewDelegate, MFMailComposeViewControllerDelegate>
{
    NSMutableArray * arrSubjects,*arrRecords;
    BOOL isSessionStarted, blinkStatus;
    UILabel* lblCoreTmp;
    UILabel* lblSkinTmp;
    NSMutableArray * arrSkinsTemp, * arrCoreTemp;
    NSMutableArray *yVals1, * yVals2;
    NSInteger xCount;
    NSMutableArray * arrTempValues;
    NSTimer * blinkTimerl;
    NSInteger blinkCount;
    NSMutableArray * arrSessionGraphData;
    UIScrollView *scrlView;
    UITableView * tblDevices;
}
@end
@implementation SubjDetailsVC
@synthesize dataDict, sessionDict, isfromSessionList;
- (void)viewDidLoad
{
    arrSkinsTemp = [[NSMutableArray alloc] init];
    arrCoreTemp = [[NSMutableArray alloc] init];
    yVals1 = [[NSMutableArray alloc] init];
    yVals2 = [[NSMutableArray alloc] init];
    arrTempValues = [[NSMutableArray alloc] init];
    
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = UIColor.clearColor;
    
    int yy = 64;
    if (IS_IPHONE_X)
    {
        yy = 84;
    }
    long scrlHeight = 750;
    if(IS_IPHONE_5 )
    {
        scrlHeight = 1150;
    }
    else if (IS_IPHONE_6)
    {
        scrlHeight = 860;
    }
    else if(IS_IPHONE_4)
    {
        scrlHeight = 1250;
    }
    
    UIColor * lbltxtClr = [UIColor colorWithRed:180.0/255 green:245.0/255 blue:254.0/255 alpha:1];
    UILabel* lblSubjectDetails = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, DEVICE_WIDTH, 50)];
    [self setLabelProperties:lblSubjectDetails withText:@"SUBJECT DETAILS" backColor:UIColor.clearColor textColor:lbltxtClr textSize:25];
    lblSubjectDetails.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lblSubjectDetails];
   
    UIColor *btnBGColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    UIButton * btnSubSetup = [[UIButton alloc]initWithFrame:CGRectMake(100, DEVICE_HEIGHT-60, 200, 50)];
    [self setButtonProperties:btnSubSetup withTitle:@"Subject setup" backColor:btnBGColor textColor:UIColor.whiteColor txtSize:25];
//    [btnSubSetup addTarget:self action:@selector(btnSubSetupClick) forControlEvents:UIControlEventTouchUpInside];
    btnSubSetup.layer.cornerRadius = 5;
    [self.view addSubview:btnSubSetup];

    UIButton * btnDone = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-250, DEVICE_HEIGHT-60, 150, 50)];
    [self setButtonProperties:btnDone withTitle:@"Done" backColor:btnBGColor textColor:UIColor.whiteColor txtSize:25];
    [btnDone addTarget:self action:@selector(btnDoneClick) forControlEvents:UIControlEventTouchUpInside];
    btnDone.layer.cornerRadius = 5;
    [self.view addSubview:btnDone];

    // for cheking
    arrSubjects = [[NSMutableArray alloc] init];
    NSString * sqlquery = [NSString stringWithFormat:@"select * from Subject_Table"];
    [[DataBaseManager dataBaseManager] execute:sqlquery resultsArray:arrSubjects];
    
    arrRecords = [[NSMutableArray alloc] init];
    NSString * sqlquery1 = [NSString stringWithFormat:@"select * from Record_Table"];
    [[DataBaseManager dataBaseManager] execute:sqlquery1 resultsArray:arrRecords];

    
    [self SetupForProfileview];
    [self setupSecondView];
    
    [self SetupGraphView];
//    [self setDataCount];

    [self gettingImg];

    [super viewDidLoad];
    
    NSLog(@"--------------------------%@",sessionDict);
    if (isfromSessionList == YES)
    {
        arrSessionGraphData = [[NSMutableArray alloc] init];
        NSString * strSession = [NSString stringWithFormat:@"select * from Session_data where session_id = '%@'",[sessionDict valueForKey:@"session_id"]];
        [[DataBaseManager dataBaseManager] execute:strSession resultsArray:arrSessionGraphData];
        [self SendTemperatureReadingtoDetailVC:arrSessionGraphData];
        
        btnRead.hidden = YES;
        btnSpotCheck.hidden = YES;
        [btnSubSetup setTitle:@"Export Data" forState:UIControlStateNormal];
        [btnSubSetup addTarget:self action:@selector(exportCSV) forControlEvents:UIControlEventTouchUpInside];
        
        imgView.image = [UIImage imageNamed:@"User_Default"];
        lblName.text = [sessionDict valueForKey:@"player_name"];
        
//        imgView.contentMode = UIViewContentModeScaleAspectFit;

        double timeStamp = [[sessionDict valueForKey:@"timeStamp"] doubleValue];
        NSTimeInterval unixTimeStamp = timeStamp ;
        NSDate *exactDate = [NSDate dateWithTimeIntervalSince1970:unixTimeStamp];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd/MM/yyy hh:mm a";
        NSString  *finalate = [dateFormatter stringFromDate:exactDate];
        lblSubjectDetails.text = finalate;
        
//        NSMutableArray * i
        
//        requestStr1 =  [NSString stringWithFormat:@"insert into 'Subject_Table'('name','number','photo_URL','photo_URLThumbNail','ing_highF','ing_lowF','drml_highF','drml_lowF','ing_highC','ing_lowC','drml_highC','drml_lowC','notes', 'user_id') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\", \"%@\")",strName,strNum,strImagePath,strThumbNail,strIngLow,strIngHigh,strDrmlLow,strDrmlHigh,strIngstHighC,strIngstLowC,strDermlHighC,strDermlLowC,strNotes, strUserId];


    }
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [tblPreviousCoreTmp reloadData];
    [tblPreviousSkinTmp reloadData];
    [_chartView reloadInputViews];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
#pragma mark-
-(void)SetupForProfileview
{
    UIView * ProfileView = [[UIView alloc]init];
    ProfileView.frame = CGRectMake(40, 70, DEVICE_WIDTH-80, DEVICE_HEIGHT/3-115);
    ProfileView.backgroundColor = UIColor.clearColor;
    [scrlView addSubview:ProfileView];

    imgView = [[UIImageView alloc]init];
    imgView.frame = CGRectMake(0, 15, ProfileView.frame.size.width-500, ProfileView.frame.size.height-50);
    imgView.backgroundColor = UIColor.whiteColor;
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.layer.masksToBounds = true;
    [ProfileView addSubview:imgView];
    
    UIColor * lblNBGC = [UIColor colorWithRed:26.0/255 green:26.0/255 blue:26.0/255 alpha:1];
    lblName  = [[UILabel alloc]initWithFrame:CGRectMake(0, imgView.frame.size.height, ProfileView.frame.size.width-550, 48)];
    [self setLabelProperties:lblName withText:@"name" backColor:lblNBGC textColor:UIColor.whiteColor textSize:25];
    lblName.text = [dataDict objectForKey:@"name"];
    lblName.layer.cornerRadius = 0;
    lblName.textAlignment = NSTextAlignmentCenter;
    [ProfileView addSubview:lblName];
        
    lblNumber = [[UILabel alloc]initWithFrame:CGRectMake(ProfileView.frame.size.width-550, imgView.frame.size.height, 50, 48)];
    [self setLabelProperties:lblNumber withText:@"#" backColor:UIColor.lightGrayColor textColor:UIColor.whiteColor textSize:25 ];
    lblNumber.text = [dataDict objectForKey:@"number"];
    lblNumber.textAlignment = NSTextAlignmentCenter;
    lblNumber.layer.cornerRadius = 0;
    [ProfileView addSubview:lblNumber];
    
    UILabel* lblLatestReading = [[UILabel alloc]initWithFrame:CGRectMake(imgView.frame.size.width+25, 0, DEVICE_WIDTH, 50)];
    [self setLabelProperties:lblLatestReading withText:@"Latest Readings" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:25];
    lblLatestReading.font = [UIFont boldSystemFontOfSize:25];
    [ProfileView addSubview:lblLatestReading];
    
    int zz = imgView.frame.size.width+20;
    UIColor * LblBGcolor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];
    
     lblCoreTmp = [[UILabel alloc]initWithFrame:CGRectMake(zz, 50,(ProfileView.frame.size.width-zz)/2, 50)];
    [self setLabelProperties:lblCoreTmp withText:@" Core Tmp --NA-- " backColor:LblBGcolor textColor:UIColor.blackColor textSize:25];//98.6˚F
    lblCoreTmp.textAlignment = NSTextAlignmentCenter;
    [ProfileView addSubview:lblCoreTmp];
    
    lblSkinTmp = [[UILabel alloc]initWithFrame:CGRectMake((ProfileView.frame.size.width+zz)/2+5, 50, (ProfileView.frame.size.width-zz)/2-5, 50)];
      [self setLabelProperties:lblSkinTmp withText:@" Skin Tmp --NA-- " backColor:LblBGcolor textColor:UIColor.blackColor textSize:25];//99.2˚F
      lblSkinTmp.textAlignment = NSTextAlignmentCenter;
      [ProfileView addSubview:lblSkinTmp];

    UILabel* lblMoreSubjDetails = [[UILabel alloc]initWithFrame:CGRectMake(zz, 110, ProfileView.frame.size.width-zz, ProfileView.frame.size.height-170)];
    [self setLabelProperties:lblMoreSubjDetails withText:@" More Subject Details" backColor:LblBGcolor textColor:UIColor.blackColor textSize:25];
    lblMoreSubjDetails.textAlignment = NSTextAlignmentCenter;
    [ProfileView addSubview:lblMoreSubjDetails];
     
    UIImageView* imgBattery = [[UIImageView alloc]init]; // zz = imageView height
    imgBattery.frame = CGRectMake(zz, ProfileView.frame.size.height-35, 40, 20);
    imgBattery.image = [UIImage imageNamed:@"battery-1.png"];
    imgBattery.backgroundColor = UIColor.clearColor;
    [ProfileView addSubview:imgBattery];
    
    zz = zz + 40;
    UILabel* lblBattery = [[UILabel alloc]initWithFrame:CGRectMake(zz, ProfileView.frame.size.height-50, 100, 50)];
    [self setLabelProperties:lblBattery withText:@"100 %" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:25];
    lblBattery.textAlignment = NSTextAlignmentCenter;
    [ProfileView addSubview:lblBattery];
    
    zz = zz+100;
    UIColor *btnBGColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    btnRead = [[UIButton alloc]initWithFrame:CGRectMake(zz, ProfileView.frame.size.height-50, 150, 50)];
    [self setButtonProperties:btnRead withTitle:@"Read" backColor:btnBGColor textColor:UIColor.whiteColor txtSize:25];
    [btnRead addTarget:self action:@selector(btnReadClick) forControlEvents:UIControlEventTouchUpInside];
    btnRead.layer.cornerRadius = 6;
    [ProfileView addSubview:btnRead];
             
    zz = zz+170;
    btnSpotCheck = [[UIButton alloc]initWithFrame:CGRectMake(zz, ProfileView.frame.size.height-50, 150, 50)];
    [self setButtonProperties:btnSpotCheck withTitle:@"Spot\n check" backColor:btnBGColor textColor:UIColor.whiteColor txtSize:20];
    btnSpotCheck.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    [btnSpotCheck addTarget:self action:@selector(btnSpotCkClick) forControlEvents:UIControlEventTouchUpInside];
    btnSpotCheck.layer.cornerRadius = 6;
    btnSpotCheck.titleLabel.numberOfLines = 0;
    [ProfileView addSubview:btnSpotCheck];
    
    if (isfromSessionList)
    {
        lblBattery.hidden = YES;
    }
    
//    zz = zz+120;
//    btnViewSnr = [[UIButton alloc]initWithFrame:CGRectMake(zz, ProfileView.frame.size.height-50, 100, 50)];
//    [self setButtonProperties:btnViewSnr withTitle:@"View \nsession" backColor:btnBGColor textColor:UIColor.whiteColor txtSize:20];
//    btnViewSnr.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
//    [btnViewSnr addTarget:self action:@selector(btnSessionClick) forControlEvents:UIControlEventTouchUpInside];
//    btnViewSnr.layer.cornerRadius = 6;
//    btnViewSnr.titleLabel.numberOfLines = 0;
//    [ProfileView addSubview:btnViewSnr];
}
#pragma mark- Second View
-(void)setupSecondView
{
    UIView * tblBgView = [[UIView alloc]init];
    tblBgView.frame = CGRectMake(40, (DEVICE_HEIGHT/3)-20, DEVICE_WIDTH-80, DEVICE_HEIGHT/3-50);
    tblBgView.backgroundColor = UIColor.clearColor;
    [scrlView addSubview:tblBgView];
    
    UILabel* lblPreviousCoreTmp = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH, 50)];
    [self setLabelProperties:lblPreviousCoreTmp withText:@"Previous Core Temp" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:25];
    lblPreviousCoreTmp.font = [UIFont boldSystemFontOfSize:25];
    [tblBgView addSubview:lblPreviousCoreTmp];
    
    tblPreviousCoreTmp = [[UITableView alloc]initWithFrame:CGRectMake(0, 50, tblBgView.frame.size.width/2-20, tblBgView.frame.size.height-50)];
    tblPreviousCoreTmp.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];
    tblPreviousCoreTmp.delegate = self;
    tblPreviousCoreTmp.dataSource = self;
    tblPreviousCoreTmp.clipsToBounds = true;
    tblPreviousCoreTmp.layer.cornerRadius = 5;
    tblPreviousCoreTmp.backgroundColor = UIColor.blackColor;
    [tblBgView addSubview:tblPreviousCoreTmp];

    UILabel* lblPreviousSkinTmp = [[UILabel alloc]initWithFrame:CGRectMake(tblBgView.frame.size.width/2+20, 0, DEVICE_WIDTH, 50)];
    [self setLabelProperties:lblPreviousSkinTmp withText:@"Previous Skin Temp" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:25];
    lblPreviousSkinTmp.font = [UIFont boldSystemFontOfSize:25];
    [tblBgView addSubview:lblPreviousSkinTmp];

    int zt = tblBgView.frame.size.width/2+20;
    tblPreviousSkinTmp = [[UITableView alloc]initWithFrame:CGRectMake(zt, 50, tblBgView.frame.size.width/2-20, tblBgView.frame.size.height-50)];
    tblPreviousSkinTmp.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];
    tblPreviousSkinTmp.clipsToBounds = true;
    tblPreviousSkinTmp.delegate = self;
    tblPreviousSkinTmp.dataSource = self;
    tblPreviousSkinTmp.layer.cornerRadius = 5;
    tblPreviousSkinTmp.backgroundColor = UIColor.blackColor;
    [tblBgView addSubview:tblPreviousSkinTmp];
    
}
#pragma mark-Graph view
-(void)SetupGraphView
{
    UIView * graphBgView = [[UIView alloc]init];
    graphBgView.frame = CGRectMake(40, (DEVICE_HEIGHT/3)*2-60, DEVICE_WIDTH-80, DEVICE_HEIGHT/3);
    graphBgView.backgroundColor = UIColor.clearColor;
    [scrlView addSubview:graphBgView];
       
    UILabel* lblTrendGraph = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, graphBgView.frame.size.width, 50)];
    [self setLabelProperties:lblTrendGraph withText:@"Trend Graph" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:25];
    lblTrendGraph.font = [UIFont boldSystemFontOfSize:25];
    [graphBgView addSubview:lblTrendGraph];
       
       // CHARTVIEW
    _chartView = [[LineChartView alloc] initWithFrame:CGRectMake(0, 45, graphBgView.frame.size.width, graphBgView.frame.size.height-80)];
    _chartView.backgroundColor = UIColor.whiteColor;
    _chartView.layer.cornerRadius = 5;
    _chartView.delegate = self;
    _chartView.chartDescription.enabled = NO;
    _chartView.dragEnabled = YES;
    _chartView.drawGridBackgroundEnabled = NO;
    _chartView.clipsToBounds = true;
    _chartView.delegate = self;
    _chartView.chartDescription.enabled = NO;
    _chartView.dragEnabled = YES;
    [_chartView setScaleEnabled:YES];
    _chartView.drawGridBackgroundEnabled = NO;
    _chartView.pinchZoomEnabled = YES;
    _chartView.gridBackgroundColor = UIColor.clearColor;
    [graphBgView addSubview:_chartView];
       
    ChartLegend *l = _chartView.legend;
    l.form = ChartLegendFormLine;
    l.font = [UIFont fontWithName:CGRegular size:11.f];
    l.textColor = UIColor.blackColor;
    l.horizontalAlignment = ChartLegendHorizontalAlignmentLeft;
    l.verticalAlignment = ChartLegendVerticalAlignmentBottom;
    l.orientation = ChartLegendOrientationHorizontal;
    l.drawInside = NO;
           
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelFont = [UIFont systemFontOfSize:11.f];
    xAxis.labelTextColor = UIColor.blackColor;
    xAxis.drawGridLinesEnabled = NO;
    xAxis.drawAxisLineEnabled = NO;
    xAxis.gridColor= UIColor.clearColor;
    xAxis.axisLineColor = UIColor.blackColor;
    xAxis.axisLineWidth = 10.0;
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    leftAxis.labelTextColor = UIColor.blackColor;// [UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f];
    leftAxis.axisMaximum = 100.4;
    leftAxis.axisMinimum = 91;
    leftAxis.drawGridLinesEnabled = NO;
    leftAxis.drawZeroLineEnabled = NO;
    leftAxis.granularityEnabled = NO;
    
    [_chartView animateWithXAxisDuration:1.8 yAxisDuration:0.5];
     
    
    ChartYAxis *rightAxis = _chartView.rightAxis;
    rightAxis.labelTextColor = UIColor.clearColor;
    rightAxis.axisLineColor = UIColor.clearColor;
    rightAxis.axisMaximum = 0.0;
    rightAxis.axisMinimum = 0.0;
    rightAxis.drawGridLinesEnabled = NO;
    rightAxis.granularityEnabled = NO;

    
    tblDevices = [[UITableView alloc]initWithFrame:CGRectMake(0, 50, graphBgView.frame.size.height+10, scrlView.frame.size.height-150)];
    tblDevices.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];
    tblDevices.delegate = self;
    tblDevices.dataSource = self;
    tblDevices.clipsToBounds = true;
    tblDevices.layer.cornerRadius = 5;
    tblDevices.backgroundColor = UIColor.redColor;
    [scrlView addSubview:tblDevices];
}
#pragma mark- Table View Method
 -(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
        UIView*viewHeader = [[UIView alloc]init];
        viewHeader.frame = CGRectMake(0, 0, tblPreviousCoreTmp.frame.size.width, 35);
        viewHeader.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
        
        UILabel *lblDateTime= [[UILabel alloc] init];
        lblDateTime.frame = CGRectMake(5, 0, tblPreviousCoreTmp.frame.size.width, 35);
        lblDateTime.text = @"Date / Time";
        lblDateTime.font = [UIFont fontWithName:CGRegular size:17];
        lblDateTime.textColor = UIColor.blackColor;
        lblDateTime.textAlignment = NSTextAlignmentLeft;
        [viewHeader addSubview:lblDateTime];
        
        UILabel *lblTemp= [[UILabel alloc]init];
        lblTemp.frame = CGRectMake(0, 0, tblPreviousCoreTmp.frame.size.width-10, 35);
        lblTemp.text = @"Temp";
        lblTemp.font = [UIFont fontWithName:CGRegular size:17];
        lblTemp.textColor = UIColor.blackColor;
        lblTemp.textAlignment = NSTextAlignmentRight;
        [viewHeader addSubview:lblTemp];
        
        return viewHeader;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblPreviousCoreTmp)
    {
        return [arrCoreTemp count]; //
    }
    else if (tableView == tblPreviousSkinTmp)
    {
        return [arrSkinsTemp count];
    }
    return true;//arrRecords.count; //array  have to pass here
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellP = @"CellProfile";
    PlayerSubjCELL *cell = [tableView dequeueReusableCellWithIdentifier:cellP];
    cell = [[PlayerSubjCELL alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellP];
    cell.lblTemp.frame = CGRectMake(tblPreviousCoreTmp.frame.size.width/2-10, 0, tblPreviousCoreTmp.frame.size.width/2, 40);
    
    NSString *string = lblCoreTmp.text;
    NSString *newStr = [string substringFromIndex:10];
    
    if (tableView == tblPreviousCoreTmp)
    {
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.lblTemp.hidden = false;
    cell.lblDate.hidden = false;
        cell.lblDate.text =[[arrCoreTemp objectAtIndex:indexPath.row]valueForKey:@"time"];;
        cell.lblTemp.text = [NSString stringWithFormat:@"%@ ºC",[[arrCoreTemp objectAtIndex:indexPath.row]valueForKey:@"temp"]]; //ºF temp
    }
    else if (tableView == tblPreviousSkinTmp)
    {
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.lblTemp.hidden = false;
    cell.lblDate.hidden = false;
        cell.lblDate.text = [[arrSkinsTemp objectAtIndex:indexPath.row]valueForKey:@"time"];
        cell.lblTemp.text = [NSString stringWithFormat:@"%@ ºF",[[arrSkinsTemp objectAtIndex:indexPath.row]valueForKey:@"temp"]];

    }
    return cell;
}
#pragma mark - Buttons
-(void)btnBackClik
{
    [self StopSessionCommandtoDevice];
    [self.navigationController popViewControllerAnimated:true];
}
 -(void)btnSubSetupClick
 {
     globalSbuSetupVC = [[SubjSetupVC alloc]init];
     globalSbuSetupVC.dataDict = dataDict;
     globalSbuSetupVC.isFromEdit = YES;
     [self.navigationController pushViewController:globalSbuSetupVC animated:true];
 }
 -(void)btnDoneClick
 {
     // if sensor added successfully you need to check here
//     [self AddSenssorCompleated];
     [self.navigationController popViewControllerAnimated:true];
     
 }
-(void)btnReadClick
{
//    [[BLEService sharedInstance] getFloatValueofDecimal:@"8fc2c742"];
    btnRead.titleLabel.numberOfLines = 0;

    if (isSessionStarted == NO)
    {
        if (globalPeripheral.state == CBPeripheralStateConnected)
        {
            [self SetTempIntervalwithPlayerID];
           // [self StartSessionConfirmation:YES];
        }
        else
        {
            [self AlertViewFCTypeCaution:@"Please make sure Monitor is connected with App and then try again to Start Session."];
        }
    }
    else
    {
        isSessionStarted = NO;
        if (globalPeripheral.state == CBPeripheralStateConnected)
        {
            [self StopSessionCommandtoDevice];
        }
        
        [self setButtonProperties:btnRead withTitle:@"Read" backColor:[UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1] textColor:UIColor.whiteColor txtSize:25];
    }
}
-(void)btnSpotCkClick
{
    [self StopSessionCommandtoDevice];

}
-(void)btnSessionClick
{
    SessionReadVC * sRVC = [[SessionReadVC alloc] init];
    [self.navigationController pushViewController:sRVC animated:true];
}
-(void)setupEdintgData
{

}
#pragma mark- Img Scalling
-(void)gettingImg
{
    NSString * filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"PlayerPhoto/%@", [dataDict valueForKey:@"photo_URL"]]];
    NSData *pngData = [NSData dataWithContentsOfFile:filePath];
    UIImage * mainImage = [UIImage imageWithData:pngData];
    UIImage * image = [self scaleMyImage:mainImage];
    imgView.image = image;
}
-(UIImage *)scaleMyImage:(UIImage *)newImg
{
    UIGraphicsBeginImageContext(CGSizeMake(newImg.size.width/2,newImg.size.height/2));
    [newImg drawInRect: CGRectMake(0, 0, newImg.size.width/2, newImg.size.height/2)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return smallImage;
}
- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
}
#pragma mark- Properties of Button and Lable
-(void)setButtonProperties:(UIButton *)btn withTitle:(NSString *)strText backColor:(UIColor *)backColor textColor:(UIColor *)txtColor txtSize:(int)txtSize
{
    [btn setTitle:strText forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn setTitleColor:txtColor forState:UIControlStateNormal];
    btn.backgroundColor = backColor;
    btn.layer.cornerRadius = 5;
    btn.clipsToBounds = true;
}
-(void)setLabelProperties:(UILabel *)lbl withText:(NSString *)strText backColor:(UIColor *)backColor textColor:(UIColor *)txtColor textSize:(int)txtSize
{
    lbl.text = strText;
    lbl.textColor = txtColor;
    lbl.backgroundColor = backColor;
    lbl.clipsToBounds = true;
    lbl.layer.cornerRadius = 5;
    lbl.font = [UIFont fontWithName:CGRegular size:txtSize];
}
-(int)getRandomNumberBetween:(int)from and:(int)to;
{
    return (int)from + arc4random() % (to-from+1);
}
#pragma mark- Chart DataSet
- (void)setDataCount
{
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals2 = [[NSMutableArray alloc] init];
    
     for ( int i = 0; i<50; i++)
     {
         double strCoreTemp = [self getRandomNumberBetween:92 and:100.4];
         [yVals1 addObject:[[ChartDataEntry alloc] initWithX:i y:strCoreTemp]];
     }
    
    for ( int i = 0; i<50; i++)
    {
        double strCoreTemp = [self getRandomNumberBetween:92 and:100.4];
        [yVals2 addObject:[[ChartDataEntry alloc] initWithX:i y:strCoreTemp]];
    }
        
    LineChartDataSet *set1 = nil, *set2 = nil;
    
    if (_chartView.data.dataSetCount > 0)
    {
        set1 = (LineChartDataSet *)_chartView.data.dataSets[0];
        set2 = (LineChartDataSet *)_chartView.data.dataSets[1];
        [set1 replaceEntries:yVals1];
        [set2 replaceEntries:yVals2];
        [_chartView.data notifyDataChanged];
        [_chartView notifyDataSetChanged];
    }
    else
    {
        set1 = [[LineChartDataSet alloc] initWithEntries:yVals1 label:@"Core Temp"];
        set1.axisDependency = AxisDependencyLeft;
        [set1 setColor:[UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f]];
        [set1 setCircleColor:UIColor.whiteColor];
        set1.lineWidth = 1.8;
        set1.circleRadius = 0.0;
        set1.fillColor = UIColor.blueColor; //[UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f];
        set1.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
        set1.drawCircleHoleEnabled = NO;
        set1.drawHorizontalHighlightIndicatorEnabled = NO;
        
        set2 = [[LineChartDataSet alloc] initWithEntries:yVals2 label:@"Skin Temp"];
        set2.axisDependency = AxisDependencyLeft;
        [set2 setColor:UIColor.greenColor];
        [set2 setCircleColor:UIColor.whiteColor];
        set2.lineWidth = 1.5;
        set2.circleRadius = 0.0;
        set2.fillColor = UIColor.greenColor;
        set2.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
        set2.drawCircleHoleEnabled = NO;
        
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        [dataSets addObject:set2];
        
        LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
        [data setValueTextColor:UIColor.blackColor];
        [data setValueFont:[UIFont systemFontOfSize:9.f]];
        
        _chartView.data = data;
    }
}
#pragma mark-BLE  Methoda
-(void)SetTempIntervalwithPlayerID
{
    NSString * strUserId = @"NA";
    if ([[APP_DELEGATE checkforValidString:[dataDict valueForKey:@"user_id"]] isEqualToString:@"NA"])
    {
        strUserId = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
        NSString * strUpdate = [NSString stringWithFormat:@"update Subject_Table set user_id = '%@' where id = '%@'",strUserId ,[dataDict valueForKey:@"id"] ];
        [[DataBaseManager dataBaseManager] execute:strUpdate];
    }
    else
    {
        strUserId = [dataDict valueForKey:@"user_id"];
    }

    NSInteger interval = [@"5" integerValue];
    NSData * dataInterval = [[NSData alloc] initWithBytes:&interval length:2];

    NSInteger intUserID = [strUserId integerValue];
    NSData * dataUserID = [[NSData alloc] initWithBytes:&intUserID length:4];
    
    long long mills = (long long)([[NSDate date]timeIntervalSince1970]);
    NSData *dates = [NSData dataWithBytes:&mills length:4];

    NSMutableData * packetData = [[NSMutableData alloc] initWithData:dataInterval];
    [packetData appendData:dataUserID];
    [packetData appendData:dates];

    NSLog(@"Setting Time Interval Command---==%@",packetData);
    [[BLEService sharedInstance] WriteValuestoDevice:packetData withOcpde:@"11" withLength:@"6" with:globalPeripheral];
}
-(void)StopSessionCommandtoDevice
{
    NSInteger intMsg = [@"0" integerValue];
    NSData * dataMsg = [[NSData alloc] initWithBytes:&intMsg length:1];

    NSLog(@"Wrote Command for Start Session---==%@",dataMsg);
    [[BLEService sharedInstance] WriteValuestoDevice:dataMsg withOcpde:@"13" withLength:@"0" with:globalPeripheral];
}
-(void)AddSenssorCompleated
{
    NSInteger intMsg = [@"1" integerValue];
    NSData * dataMsg = [[NSData alloc] initWithBytes:&intMsg length:1];

    NSLog(@"AddSensor  DONEClick---==%@",dataMsg);
    [[BLEService sharedInstance] WriteValuestoDevice:dataMsg withOcpde:@"09" withLength:@"0" with:globalPeripheral];
}
//-(void)SendTemperatureReadingtoDetailVC:(NSString *)strSensorID withTemp:(NSString *)strTemp;
-(void)SendTemperatureReadingtoDetailVC:(NSMutableArray *)arrSensorData;
{
    for (int i = 0; i < [arrSensorData count]; i++)
    {
        NSString * strSensorID = [[arrSensorData objectAtIndex:i] valueForKey:@"sensor_id"];
        NSString * strTemp = [[arrSensorData objectAtIndex:i] valueForKey:@"temp"];
                
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd/MM/yyy hh:mm:ss";
        NSString  *dateString ;
        
        if (isfromSessionList == YES)
        {
            double timeStamp = [[[arrSensorData objectAtIndex:i] valueForKey:@"timestamp"] doubleValue];
            NSTimeInterval unixTimeStamp = timeStamp ;
            NSDate *exactDate = [NSDate dateWithTimeIntervalSince1970:unixTimeStamp];
            dateString = [dateFormatter stringFromDate:exactDate];
        }
        else
        {
            NSDate *exactDate = [NSDate date];
            dateString = [dateFormatter stringFromDate:exactDate];

        }
        
        if ([strTemp intValue] > 0)
        {
            if ([strTemp length] > 3)
            {
                NSString * strdotBefore = [strTemp substringWithRange:NSMakeRange(0, 2)];
                strTemp = [NSString stringWithFormat:@"%@%@",strdotBefore,[strTemp substringWithRange:NSMakeRange(2, [strTemp length] - 2)]];
            }
            NSString * strDataType = @"Skin"; //if Sensor type dermal then its Core, if its Ingestible then its Skin
            if ([[arrGlobalDevices valueForKey:@"sensor_id"] containsObject:strSensorID])
            {
                NSInteger foundIndex = [[arrGlobalDevices valueForKey:@"sensor_id"] indexOfObject:strSensorID];
                if (foundIndex != NSNotFound)
                {
                    if ([arrGlobalDevices count] > foundIndex)
                    {
                        if ([[[arrGlobalDevices objectAtIndex:foundIndex] valueForKey:@"sensor_type"] isEqualToString:@"Ingestible"])
                        {
                            strDataType = @"Core";
                        }
                    }
                }
            }
            xCount = xCount + 1;

            if ([strDataType isEqualToString:@"Core"])
            {
                lblCoreTmp.text = [NSString stringWithFormat:@"Core Tmp %@˚C",strTemp];
                lblCoreTmp.backgroundColor = [UIColor blueColor];
                
                [blinkTimerl invalidate];
                blinkTimerl = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)(0.1) target:self selector:@selector(animateBlinking) userInfo:nil repeats:TRUE];

//                [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(animateBlinking) userInfo:nil repeats:YES];
//                [self performSelector:@selector(stopBlinking) withObject:nil afterDelay:0.2];
                if ([arrCoreTemp count] == 0)
                {
                    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:strSensorID,@"sensor_id",strDataType,@"sensor_type",strTemp,@"temp",dateString,@"time", nil];
                    [arrCoreTemp addObject:dict];
                }
                else
                {
                    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:strSensorID,@"sensor_id",strDataType,@"sensor_type",strTemp,@"temp", dateString,@"time", nil];
                    [arrCoreTemp insertObject:dict atIndex:0];
                }
                [tblPreviousCoreTmp reloadData];
                
                [yVals1 addObject:[[ChartDataEntry alloc] initWithX:xCount y:[strTemp doubleValue]]];
                [APP_DELEGATE endHudProcess];
                NSLog(@"<=========Core========>%@",strTemp);
            }
            else
            {
                lblSkinTmp.text = [NSString stringWithFormat:@"Skin Tmp %@˚C",strTemp];
                if ([arrSkinsTemp count] == 0)
                {
                    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:strSensorID,@"sensor_id",strDataType,@"sensor_type",strTemp,@"temp", dateString,@"time", nil];
                    [arrSkinsTemp addObject:dict];
                }
                else
                {
                    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:strSensorID,@"sensor_id",strDataType,@"sensor_type",strTemp,@"temp", dateString,@"time", nil];
                    [arrSkinsTemp insertObject:dict atIndex:0];
                }
                [tblPreviousSkinTmp reloadData];
                [yVals2 addObject:[[ChartDataEntry alloc] initWithX:xCount y:[strTemp doubleValue]]];
                NSLog(@"<=========Skin========>%@",strTemp);

            }
            [arrTempValues addObject:[NSNumber numberWithDouble:[strTemp doubleValue]]];

        }
        
    }
    
    double max1 = [[arrTempValues valueForKeyPath: @"@max.self"] doubleValue];
    double min1 = [[arrTempValues valueForKeyPath: @"@min.self"] doubleValue];

    _chartView.leftAxis.axisMaximum = max1 + 0.1;
    _chartView.leftAxis.axisMinimum = min1 - 0.1;

     /*for ( int i = 0; i<50; i++)
     {
         double strCoreTemp = [self getRandomNumberBetween:92 and:100.4];
         [yVals1 addObject:[[ChartDataEntry alloc] initWithX:i y:strCoreTemp]];
     }
    
    for ( int i = 0; i<50; i++)
    {
        double strCoreTemp = [self getRandomNumberBetween:92 and:100.4];
        [yVals2 addObject:[[ChartDataEntry alloc] initWithX:i y:strCoreTemp]];
    }*/
        
    LineChartDataSet *set1 = nil, *set2 = nil;
    
    if (_chartView.data.dataSetCount > 0)
    {
        set1 = (LineChartDataSet *)_chartView.data.dataSets[0];
        set2 = (LineChartDataSet *)_chartView.data.dataSets[1];
        [set1 replaceEntries:yVals1];
        [set2 replaceEntries:yVals2];
        [_chartView.data notifyDataChanged];
        [_chartView notifyDataSetChanged];
    }
    else
    {
        set1 = [[LineChartDataSet alloc] initWithEntries:yVals1 label:@"Core Temp"];
        set1.axisDependency = AxisDependencyLeft;
        [set1 setColor:[UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f]];
        [set1 setCircleColor:UIColor.whiteColor];
        set1.lineWidth = 1.8;
        set1.circleRadius = 0.0;
        set1.fillColor = UIColor.blueColor; //[UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f];
        set1.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
        set1.drawCircleHoleEnabled = NO;
        set1.valueTextColor = UIColor.whiteColor;
        set1.drawHorizontalHighlightIndicatorEnabled = NO;
        
        set2 = [[LineChartDataSet alloc] initWithEntries:yVals2 label:@"Skin Temp"];
        set2.axisDependency = AxisDependencyLeft;
        [set2 setColor:[UIColor redColor]];
        [set2 setCircleColor:UIColor.whiteColor];
        set2.lineWidth = 1.5;
        set2.circleRadius = 0.0;
        set2.fillColor = UIColor.greenColor;
        set2.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
        set2.drawCircleHoleEnabled = NO;
        
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        [dataSets addObject:set2];
        
        LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
        [data setValueTextColor:UIColor.clearColor];
        [data setValueFont:[UIFont systemFontOfSize:9.f]];
        
        _chartView.data = data;
    }

}
-(void)stopBlinking
{
    
}
-(void)animateBlinking
{
    if (blinkCount >= 6)
    {
        blinkCount = 0;
        [blinkTimerl invalidate];
        blinkTimerl = nil;
    }
    else
    {
        if(blinkStatus == NO){
           lblCoreTmp.backgroundColor = [UIColor blueColor];
          blinkStatus = YES;
        }else {
           lblCoreTmp.backgroundColor = [UIColor whiteColor];
           blinkStatus = NO;
        }
        blinkCount = blinkCount + 1;
    }

}
-(void)StartSessionConfirmation:(BOOL)isSessionStartSuccess;
{
    if (isSessionStartSuccess == NO)
    {
        [self AlertViewFCTypeCaution:@"Something went wrong with Start Session. Please try again."];
        isSessionStarted = NO;
    }
    else
    {
//        [APP_DELEGATE startHudProcess:@"Loading..."];
        isSessionStarted = YES;
        [self setButtonProperties:btnRead withTitle:@"Stop\nSession" backColor:[UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1] textColor:UIColor.whiteColor txtSize:20];
    }
}
-(void)WritePlayerNametoMonitorttoStartSession
{
    NSString * str = [self hexFromStr:[dataDict objectForKey:@"name"]];
    NSData * msgData = [self dataFromHexString:str];
    
    NSInteger intLength = [[dataDict objectForKey:@"name"] length];

    [[BLEService sharedInstance] WriteValuestoDevice:msgData withOcpde:@"12" withLength:[NSString stringWithFormat:@"%ld",(long)intLength] with:globalPeripheral];
}
-(void)ShowErrorMessagewithOpcode:(NSString *)strOpcode;
{
    [APP_DELEGATE endHudProcess];
    if ([strOpcode isEqualToString:@"00"])
    {
        [self AlertViewFCTypeCaution:@"Something went wrong with Start Session. Please try again."];
    }
    else
    {
        [self AlertViewFCTypeSuccess:@"Session has started successfully."];
    }
}
-(void)ShowErrorMessagewithStopSession:(NSString *)strStopRead
{
    [APP_DELEGATE endHudProcess];
    if ([strStopRead isEqualToString:@"00"])
    {
        [self AlertViewFCTypeCaution:@"Something went wrong with Start Session. Please try again."];
    }
    else
    {
        [self AlertViewFCTypeSuccess:@"Session has been stop."];
    }
}
-(void)AlertViewFCTypeCaution:(NSString *)strPopup
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeCaution];
    [alert showAlertInView:self
                 withTitle:@"HQ-Inc"
              withSubtitle:strPopup
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}
-(void)AlertViewFCTypeSuccess:(NSString *)strPopup
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeSuccess];
    [alert showAlertInView:self
                 withTitle:@"HQ-Inc"
              withSubtitle:strPopup
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
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


-(void)exportCSV
{
    NSArray * arrSensorId = [arrSessionGraphData valueForKey:@"sensor_id"];
    NSArray * arrSensor_type = [arrSessionGraphData valueForKey:@"sensor_type"];
    NSArray * arrSession_id = [arrSessionGraphData valueForKey:@"session_id"];
    NSArray * arrTemp = [arrSessionGraphData valueForKey:@"temp"];
    NSArray * arrTimeStamp = [arrSessionGraphData valueForKey:@"timestamp"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *root = [documentsDir stringByAppendingPathComponent:@"PlayerData.csv"];
    
    NSMutableString *csv = [[NSMutableString alloc] initWithCapacity:0];
    for (int i=0; i<[arrSessionGraphData count]; i++)
    {
     if (i == 0)
     {
         [csv appendFormat:@"Sensor ID , Sensor Type , Session ID , Temperature , Timestamp  \n"];
     }
    [csv appendFormat:@"%@,%@,%@,%@,%@\n", arrSensorId[i], arrSensor_type[i], arrSession_id[i], arrTemp[i],arrTimeStamp[i]];
    }
    [csv writeToFile:root atomically:YES encoding:NSUTF8StringEncoding error:NULL];

    NSLog(@"%@",csv);
    NSString * strMsg =  @"file attached";
    // To address
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:strMsg];
    [mc setMessageBody:strMsg isHTML:NO];
    [mc setToRecipients:nil];
    
    if (mc == nil)
    {}
        else
        {
            double timeStamp = [[sessionDict valueForKey:@"timeStamp"] doubleValue];
            NSTimeInterval unixTimeStamp = timeStamp ;
            NSDate *exactDate = [NSDate dateWithTimeIntervalSince1970:unixTimeStamp];
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"ddMMyyyhh:mm a";
            NSString  *finalate = [dateFormatter stringFromDate:exactDate];
            NSString * strFileName = [NSString stringWithFormat:@"%@_%@.csv",[sessionDict valueForKey:@"player_name"], finalate];
            NSData *noteData = [NSData dataWithContentsOfFile:root];
            [mc addAttachmentData:noteData mimeType:@"csv" fileName:strFileName];
            [self.navigationController presentViewController:mc animated:YES completion:nil];
        }
}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
//    "player_id" = 1613640340;

