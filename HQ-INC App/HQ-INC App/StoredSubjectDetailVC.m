//
//  StoredSubjectDetailVC.m
//  HQ-INC App
//
//  Created by Vithamas Technologies on 15/03/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import "StoredSubjectDetailVC.h"
#import "SubjDetailsVC.h"
#import "CollectionCustomCell.h"
#import "SubjSetupVC.h"
#import "PlayerSubjVC.h"
#import "PlayerSubjCELL.h"
#import "SessionReadVC.h"
#import "BLEService.h"
#import <MessageUI/MessageUI.h>
#import "UIFloatLabelTextField.h"

@import Charts;

@interface StoredSubjectDetailVC ()<UITableViewDelegate,UITableViewDataSource,ChartViewDelegate,MFMailComposeViewControllerDelegate,UITextFieldDelegate>
{
    UITableView * tblPreviousCoreTmp,* tblPreviousSkinTmp;
    UILabel* lblName,*lblNumber,* lblCoreTmp,* lblSkinTmp;
    UIButton *btnRead,*btnSpotCheck,*btnViewSnr;
    UIImageView * imgView,*ProfileView;
    
    NSMutableArray * arrSessionGraphData;
    NSMutableArray * arrSkinsTemp, * arrCoreTemp;
    NSInteger xCount,blinkCount;

    NSTimer *blinkTimerl;
    NSMutableArray *yVals1, * yVals2,* arrTempValues;
    bool blinkStatus;
    UIFloatLabelTextField *txtPlayerName,*txtSensorTime,*txtSensorType,*txtSensorNumber;

}
@end

@implementation StoredSubjectDetailVC
@synthesize dataDict, sessionDict,isfromSessionList;
- (void)viewDidLoad
{
    NSLog(@"Before===%@",self.view);

    CGFloat radians = atan2f(self.view.transform.b, self.view.transform.a);
    CGFloat degrees = radians * (180 / M_PI);
    CGAffineTransform transform = CGAffineTransformMakeRotation((90 + degrees) * M_PI/180);
    self.view.transform = transform;

    NSLog(@"After===%@",self.view);

    arrSkinsTemp = [[NSMutableArray alloc] init];
    arrCoreTemp = [[NSMutableArray alloc] init];
    yVals1 = [[NSMutableArray alloc] init];
    yVals2 = [[NSMutableArray alloc] init];
    arrTempValues = [[NSMutableArray alloc] init];

    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = UIColor.blackColor;
    
    UIColor * lbltxtClr = [UIColor colorWithRed:180.0/255 green:245.0/255 blue:254.0/255 alpha:1];
    UILabel* lblSubjectDetails = [[UILabel alloc]initWithFrame:CGRectMake(0, 00, self.view.frame.size.width, 50)];
    [self setLabelProperties:lblSubjectDetails withText:@"SUBJECT DETAILS" backColor:UIColor.clearColor textColor:lbltxtClr textSize:25];
    lblSubjectDetails.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:lblSubjectDetails];
   
    UIColor *btnBGColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    UIButton * btnExportData = [[UIButton alloc]initWithFrame:CGRectMake(100, self.view.frame.size.height-60, 200, 50)];
    [self setButtonProperties:btnExportData withTitle:@"Export Data" backColor:btnBGColor textColor:UIColor.whiteColor txtSize:25];
    [btnExportData addTarget:self action:@selector(btnExportClick) forControlEvents:UIControlEventTouchUpInside];
    btnExportData.layer.cornerRadius = 5;
    [self.view addSubview:btnExportData]; 

    UIButton * btnDone = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-250, self.view.frame.size.height-60, 150, 50)];
    [self setButtonProperties:btnDone withTitle:@"Done" backColor:btnBGColor textColor:UIColor.whiteColor txtSize:25];
    [btnDone addTarget:self action:@selector(btnDoneClick) forControlEvents:UIControlEventTouchUpInside];
    btnDone.layer.cornerRadius = 5;
    [self.view addSubview:btnDone];
    
    UIView* viewFortxtFld = [[UIView alloc] initWithFrame:CGRectMake(40, 15, DEVICE_HEIGHT-80, 60)];
    viewFortxtFld.backgroundColor = UIColor.clearColor;
    [self.view addSubview:viewFortxtFld];
    
    int aa = viewFortxtFld.frame.size.width/4;
    
    txtPlayerName = [[UIFloatLabelTextField alloc]init];
    txtPlayerName.frame = CGRectMake(0, 0, aa, 60);
    [self setTextfieldProperties:txtPlayerName withPlaceHolderText:@"Player Name" withTextSize:textSize+2];
    [APP_DELEGATE getPlaceholderText:txtPlayerName andColor:UIColor.lightGrayColor];
    txtPlayerName.text = @"Jithi";
    [viewFortxtFld addSubview:txtPlayerName];
    
    txtSensorTime = [[UIFloatLabelTextField alloc]init];
    txtSensorTime.frame = CGRectMake(aa+10, 0, aa-10, 60);
    [self setTextfieldProperties:txtSensorTime withPlaceHolderText:@"Session Time" withTextSize:textSize];
    [APP_DELEGATE getPlaceholderText:txtSensorTime andColor:UIColor.lightGrayColor];
    txtSensorTime.text = @"04/02/2021 04:44 PM";
    [viewFortxtFld addSubview:txtSensorTime];
    
    txtSensorType = [[UIFloatLabelTextField alloc]init];
    txtSensorType.frame = CGRectMake(aa*2+10, 0, aa-10, 60);
    [self setTextfieldProperties:txtSensorType withPlaceHolderText:@"Sensor Type" withTextSize:textSize+2];
    [APP_DELEGATE getPlaceholderText:txtSensorType andColor:UIColor.lightGrayColor];
    txtSensorType.text = @"Skin";
    [viewFortxtFld addSubview:txtSensorType];
    
    txtSensorNumber = [[UIFloatLabelTextField alloc]init];
    txtSensorNumber.frame = CGRectMake(aa*3+10, 0, aa-10, 60);
    [self setTextfieldProperties:txtSensorNumber withPlaceHolderText:@"Number of Sensors " withTextSize:textSize];
    [APP_DELEGATE getPlaceholderText:txtSensorNumber andColor:UIColor.lightGrayColor];
    txtSensorNumber.text = @"1";
    [viewFortxtFld addSubview:txtSensorNumber];
    
//    lblSubjectDetails.text = finalate;
    
//    [self SetupForProfileview];
//    [self setupSecondView];
    
    [self SetupGraphView];
//    [self setDataCount];

    [self gettingImg];
    
//        imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    arrSessionGraphData = [[NSMutableArray alloc] init];
    NSString * strSession = [NSString stringWithFormat:@"select * from Session_data where session_id = '%@'",[sessionDict valueForKey:@"session_id"]];
//    NSString * strSession = [NSString stringWithFormat:@"select * from Session_data"];

    [[DataBaseManager dataBaseManager] execute:strSession resultsArray:arrSessionGraphData];
    [self SendTemperatureReadingtoDetailVC:arrSessionGraphData];
    
    btnRead.hidden = YES;
    btnSpotCheck.hidden = YES;
    
    imgView.image = [UIImage imageNamed:@"User_Default"];
    lblName.text = [sessionDict valueForKey:@"player_name"];
    
    double timeStamp = [[sessionDict valueForKey:@"timeStamp"] doubleValue];
    NSTimeInterval unixTimeStamp = timeStamp ;
    NSDate *exactDate = [NSDate dateWithTimeIntervalSince1970:unixTimeStamp];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd/MM/yyy hh:mm a";
    NSString  *finalate = [dateFormatter stringFromDate:exactDate];

    [super viewDidLoad];
    
    NSLog(@"--------------------------%@",sessionDict);
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
#pragma mark- Setup For profile View
-(void)SetupTopInformationView
{
    UIView * topView = [[UIView alloc]init];
    topView.frame = CGRectMake(10, 0, self.view.frame.size.width-20, 50);
    topView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:topView];
    
    UIColor * lbltxtClr = [UIColor colorWithRed:180.0/255 green:245.0/255 blue:254.0/255 alpha:1];
    UILabel* lblSubjectDetails = [[UILabel alloc]initWithFrame:CGRectMake(0, 00, self.view.frame.size.width, 50)];
    [self setLabelProperties:lblSubjectDetails withText:@"SUBJECT DETAILS" backColor:UIColor.clearColor textColor:lbltxtClr textSize:25];
    lblSubjectDetails.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lblSubjectDetails];


}
-(void)SetupForProfileview
{
    UIView * ProfileView = [[UIView alloc]init];
    ProfileView.frame = CGRectMake(40, 70, self.view.frame.size.width-80, self.view.frame.size.height/3-130);
    ProfileView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:ProfileView];

    imgView = [[UIImageView alloc]init];
    imgView.frame = CGRectMake(0, 10, ProfileView.frame.size.width-500, ProfileView.frame.size.height-50);
    imgView.backgroundColor = UIColor.whiteColor;
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.layer.masksToBounds = true;
    [ProfileView addSubview:imgView];
    
    UIColor * lblNBGC = [UIColor colorWithRed:26.0/255 green:26.0/255 blue:26.0/255 alpha:1];
    lblName  = [[UILabel alloc]initWithFrame:CGRectMake(0, imgView.frame.size.height, ProfileView.frame.size.width-550, 48)];
    [self setLabelProperties:lblName withText:@"name" backColor:lblNBGC textColor:UIColor.whiteColor textSize:25];
//    lblName.text = [dataDict objectForKey:@"name"];
    lblName.layer.cornerRadius = 0;
    lblName.textAlignment = NSTextAlignmentCenter;
    [ProfileView addSubview:lblName];
        
    lblNumber = [[UILabel alloc]initWithFrame:CGRectMake(ProfileView.frame.size.width-550, imgView.frame.size.height, 50, 48)];
    [self setLabelProperties:lblNumber withText:@"#" backColor:UIColor.lightGrayColor textColor:UIColor.whiteColor textSize:25 ];
//    lblNumber.text = [dataDict objectForKey:@"number"];
    lblNumber.textAlignment = NSTextAlignmentCenter;
    lblNumber.layer.cornerRadius = 0;
    [ProfileView addSubview:lblNumber];
    
    UILabel* lblLatestReading = [[UILabel alloc]initWithFrame:CGRectMake(imgView.frame.size.width+25, 0, self.view.frame.size.width, 50)];
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
    [self setLabelProperties:lblMoreSubjDetails withText:@"More Subject Details" backColor:LblBGcolor textColor:UIColor.blackColor textSize:25];
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
    

}
#pragma mark- Second View
-(void)setupSecondView
{
    UIView * tblBgView = [[UIView alloc]init];
    tblBgView.frame = CGRectMake(40, (self.view.frame.size.height/3)-55, self.view.frame.size.width-80, self.view.frame.size.height/3-50);
    tblBgView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:tblBgView];
    
    UILabel* lblPreviousCoreTmp = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width, 30)];
    [self setLabelProperties:lblPreviousCoreTmp withText:@"Previous Core Temp" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:20];
    lblPreviousCoreTmp.font = [UIFont boldSystemFontOfSize:20]; //25
    [tblBgView addSubview:lblPreviousCoreTmp];
    
    tblPreviousCoreTmp = [[UITableView alloc]initWithFrame:CGRectMake(0, 30, tblBgView.frame.size.width/2-20, tblBgView.frame.size.height-30)];
    tblPreviousCoreTmp.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];
    tblPreviousCoreTmp.delegate = self;
    tblPreviousCoreTmp.dataSource = self;
    tblPreviousCoreTmp.clipsToBounds = true;
    tblPreviousCoreTmp.layer.cornerRadius = 5;
    tblPreviousCoreTmp.backgroundColor = UIColor.blackColor;
    [tblBgView addSubview:tblPreviousCoreTmp];

    UILabel* lblPreviousSkinTmp = [[UILabel alloc]initWithFrame:CGRectMake(tblBgView.frame.size.width/2+20, 0, self.view.frame.size.width, 30)];
    [self setLabelProperties:lblPreviousSkinTmp withText:@"Previous Skin Temp" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:20];
    lblPreviousSkinTmp.font = [UIFont boldSystemFontOfSize:20]; //25
    [tblBgView addSubview:lblPreviousSkinTmp];

    int zt = tblBgView.frame.size.width/2+20;
    tblPreviousSkinTmp = [[UITableView alloc]initWithFrame:CGRectMake(zt, 30, tblBgView.frame.size.width/2-20, tblBgView.frame.size.height-30)];
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
    graphBgView.frame = CGRectMake(40, 100, self.view.frame.size.width-80, self.view.frame.size.height - 170);
    graphBgView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:graphBgView];
       
    int wh = graphBgView.frame.size.width/5;
    
    UILabel* lblTrendGraph = [[UILabel alloc]initWithFrame:CGRectMake(10, 0,wh, 50)];
    [self setLabelProperties:lblTrendGraph withText:@"Trend Graph" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize+2];
    lblTrendGraph.font = [UIFont boldSystemFontOfSize:textSize+2];
    [graphBgView addSubview:lblTrendGraph];
       
    UIColor *btnBGColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    UIColor * LblBGcolor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];


    UIButton * btnPrevious = [[UIButton alloc]initWithFrame:CGRectMake(wh+5, 0, 50, 50)];
    [self setButtonProperties:btnPrevious withTitle:@"" backColor:btnBGColor textColor:UIColor.whiteColor txtSize:20];
    btnPrevious.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    [btnPrevious addTarget:self action:@selector(btnPreviousClick) forControlEvents:UIControlEventTouchUpInside];
    btnPrevious.layer.cornerRadius = 6;
    btnPrevious.titleLabel.numberOfLines = 0;
    [btnPrevious setImage:[UIImage imageNamed:@"arrowLeft@1x.png"] forState:UIScrollViewDecelerationRateNormal];
    [graphBgView addSubview:btnPrevious];
    
    UILabel* lblPreDate = [[UILabel alloc]initWithFrame:CGRectMake(wh*2-80, 0, wh+75, 50)];
    [self setLabelProperties:lblPreDate withText:@"04/02/2021 04:44 PM" backColor:LblBGcolor textColor:UIColor.blackColor textSize:textSize];
    lblPreDate.textAlignment = NSTextAlignmentCenter;
    [graphBgView addSubview:lblPreDate];
    
    UILabel* lblNextDate = [[UILabel alloc]initWithFrame:CGRectMake(wh*3+10, 0, wh+75, 50)];
    [self setLabelProperties:lblNextDate withText:@"04/02/2021 04:54 PM" backColor:LblBGcolor textColor:UIColor.blackColor textSize:textSize];
    lblNextDate.textAlignment = NSTextAlignmentCenter;
    [graphBgView addSubview:lblNextDate];
    
    UIButton * btnNext = [[UIButton alloc]initWithFrame:CGRectMake(wh*4+(wh-50), 0, 50, 50)];
    [self setButtonProperties:btnNext withTitle:@"" backColor:btnBGColor textColor:UIColor.whiteColor txtSize:20];
    btnNext.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    [btnNext addTarget:self action:@selector(btnNextClick) forControlEvents:UIControlEventTouchUpInside];
    btnNext.layer.cornerRadius = 6;
    btnNext.titleLabel.numberOfLines = 0;
    [btnNext setImage:[UIImage imageNamed:@"rightArrow@1x.png"] forState:UIScrollViewDecelerationRateNormal];
    [graphBgView addSubview:btnNext];
    
       // CHARTVIEW
    _chartView = [[LineChartView alloc] initWithFrame:CGRectMake(0, 60, graphBgView.frame.size.width, graphBgView.frame.size.height-60)];
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

    // css commented
//    UILabel* lblGraphPreviousSkinTmp = [[UILabel alloc]initWithFrame:CGRectMake(10, _chartView.frame.size.height+40, 200, 40)];
//       [self setLabelProperties:lblGraphPreviousSkinTmp withText:@"Previous Skin Temp" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:20];
//       [graphBgView addSubview:lblGraphPreviousSkinTmp];
//
//       UILabel* lblSkinTmp = [[UILabel alloc]initWithFrame:CGRectMake(210, _chartView.frame.size.height+40, 60, 40)];
//       [self setLabelProperties:lblSkinTmp withText:@" ---" backColor:UIColor.clearColor textColor:UIColor.greenColor textSize:20];
//       [graphBgView addSubview:lblSkinTmp];
//
//       UILabel* lblGraphPreviousCoreTmp = [[UILabel alloc]initWithFrame:CGRectMake(0, _chartView.frame.size.height+40, graphBgView.frame.size.width-80, 40)];
//       [self setLabelProperties:lblGraphPreviousCoreTmp withText:@"Previous Core Temp" backColor:UIColor.clearColor textColor:UIColor.blueColor textSize:20];
//       lblGraphPreviousCoreTmp.textAlignment = NSTextAlignmentRight;
//       [graphBgView addSubview:lblGraphPreviousCoreTmp];
//
//       UILabel* lblCoreTmp1 = [[UILabel alloc]initWithFrame:CGRectMake(lblGraphPreviousCoreTmp.frame.size.width, _chartView.frame.size.height+40, 60, 40)];
//       [self setLabelProperties:lblCoreTmp1 withText:@"---" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:20];
//       lblCoreTmp1.textAlignment = NSTextAlignmentRight;
//       [graphBgView addSubview:lblCoreTmp1];
//

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
#pragma mark-All buttons deligates
-(void)btnDoneClick
{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)btnExportClick
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
-(void)btnPreviousClick
{
    
}
-(void)btnNextClick
{
    
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
        if(blinkStatus == NO)
        {
           lblCoreTmp.backgroundColor = [UIColor blueColor];
          blinkStatus = YES;
        }
        else
        {
           lblCoreTmp.backgroundColor = [UIColor whiteColor];
           blinkStatus = NO;
        }
        blinkCount = blinkCount + 1;
    }
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
-(void)setTextfieldProperties:(UIFloatLabelTextField *)txtfld withPlaceHolderText:(NSString *)strText withTextSize:(int)textSize
{
    txtfld.textAlignment = NSTextAlignmentLeft;
    txtfld.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1];
    txtfld.autocorrectionType = UITextAutocorrectionTypeNo;
    txtfld.floatLabelPassiveColor = UIColor.lightGrayColor;
    txtfld.floatLabelActiveColor = UIColor.lightGrayColor;
    txtfld.delegate = self;
    txtfld.placeholder = strText;
    txtfld.textColor = UIColor.blackColor;
    txtfld.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtfld.layer.cornerRadius = 5;
    txtfld.font = [UIFont fontWithName:CGRegular size:textSize];

}
@end
