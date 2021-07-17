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
#import "BLEService.h"
#import <MessageUI/MessageUI.h>

@import Charts;

@interface SubjDetailsVC ()<UITableViewDelegate,UITableViewDataSource,ChartViewDelegate, MFMailComposeViewControllerDelegate, SubjectSetupDelegate>
{
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
    liveSessionDetail = [[NSMutableDictionary alloc] init];
    arrAvailSensorsofMonitor = [[NSMutableDictionary alloc] init];
    
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = UIColor.blackColor;
    
    UIColor * lbltxtClr = [UIColor colorWithRed:180.0/255 green:245.0/255 blue:254.0/255 alpha:1];
    UILabel* lblSubjectDetails = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    [self setLabelProperties:lblSubjectDetails withText:@"SUBJECT DETAILS" backColor:UIColor.clearColor textColor:lbltxtClr textSize:25];
    lblSubjectDetails.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lblSubjectDetails];
   
    UIColor *btnBGColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    
    UIButton * btnSubSetup = [[UIButton alloc]initWithFrame:CGRectMake(100, self.view.frame.size.height-60, 200, 50)];
    [self setButtonProperties:btnSubSetup withTitle:@"Subject setup" backColor:btnBGColor textColor:UIColor.whiteColor txtSize:25];
    [btnSubSetup addTarget:self action:@selector(btnSubSetupClick) forControlEvents:UIControlEventTouchUpInside];
    btnSubSetup.layer.cornerRadius = 5;
    [self.view addSubview:btnSubSetup];

    UIButton * btnDone = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-250, self.view.frame.size.height-60, 150, 50)];
    [self setButtonProperties:btnDone withTitle:@"Done" backColor:btnBGColor textColor:UIColor.whiteColor txtSize:25];
    [btnDone addTarget:self action:@selector(btnDoneClick) forControlEvents:UIControlEventTouchUpInside];
    btnDone.layer.cornerRadius = 5;
    [self.view addSubview:btnDone];
            
    [self SetupForProfileview];
    
    [self SetupGraphView];

    [self SetupBottomSensorView];
    
//    [self gettingImg];

    
    if ( IS_IPHONE_4 || IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_6plus)
    {
        
        lblSubjectDetails.frame = CGRectMake(0, 20, self.view.frame.size.width, 44);
        lblSubjectDetails.font = [UIFont fontWithName:CGRegular size:textSize-6];
        
        btnSubSetup.frame = CGRectMake(10, self.view.frame.size.height-40, 100, 35);
        btnSubSetup.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize-6];

        btnDone.frame = CGRectMake(self.view.frame.size.width-80, self.view.frame.size.height-40, 60, 35);
        btnDone.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize-6];

    }
    
    [super viewDidLoad];
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
  return UIInterfaceOrientationLandscapeLeft; // or Right of course
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskLandscape;
}
-(void)viewWillAppear:(BOOL)animated
{
    [_chartView reloadInputViews];
    
    if (dataDict)
    {
        lblName.text = [dataDict objectForKey:@"name"];
        lblNumber.text = [dataDict objectForKey:@"number"];
        [self gettingImg];
    }
}

-(void)SetupForProfileview
{
    ProfileView = [[UIView alloc]init];
    ProfileView.frame = CGRectMake(40, 64, self.view.frame.size.width-80, self.view.frame.size.height/3-115);
    ProfileView.backgroundColor = UIColor.blackColor;
    [self.view addSubview:ProfileView];

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
    [self setLabelProperties:lblBattery withText:@"NA %" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:25];
    lblBattery.textAlignment = NSTextAlignmentCenter;
    [ProfileView addSubview:lblBattery];
    
    zz = zz+100;
    UIColor *btnBGColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    btnRead = [[UIButton alloc]initWithFrame:CGRectMake(zz, ProfileView.frame.size.height-50, 150, 50)];
    [self setButtonProperties:btnRead withTitle:@"Start Readings" backColor:btnBGColor textColor:UIColor.whiteColor txtSize:20];
    [btnRead addTarget:self action:@selector(btnStartReadingClick) forControlEvents:UIControlEventTouchUpInside];
    btnRead.layer.cornerRadius = 6;
    btnRead.titleLabel.numberOfLines = 0;
    [ProfileView addSubview:btnRead];
             
    zz = zz+170;
    btnSpotCheck = [[UIButton alloc]initWithFrame:CGRectMake(zz, ProfileView.frame.size.height-50, 150, 50)];
    [self setButtonProperties:btnSpotCheck withTitle:@"Instant \n Reading" backColor:btnBGColor textColor:UIColor.whiteColor txtSize:20];
    btnSpotCheck.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    [btnSpotCheck addTarget:self action:@selector(btnInstanReadingClick) forControlEvents:UIControlEventTouchUpInside];
    btnSpotCheck.layer.cornerRadius = 6;
    btnSpotCheck.titleLabel.numberOfLines = 0;
    [ProfileView addSubview:btnSpotCheck];
    
    
    if (isfromSessionList)
    {
        lblBattery.hidden = YES;
    }
    
    if ( IS_IPHONE_4 || IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_6plus)
    {
        ProfileView.frame = CGRectMake(0, 64, DEVICE_WIDTH, self.view.frame.size.height/3-80);
//        ProfileView.backgroundColor = UIColor.redColor;
        imgView.frame = CGRectMake(0, 0, 110, ProfileView.frame.size.height-30);

        lblName.frame  = CGRectMake(0, imgView.frame.size.height, imgView.frame.size.width-30, 30);
        lblName.font  = [UIFont fontWithName:CGRegular size:textSize-6];
        
        lblNumber.frame = CGRectMake(imgView.frame.size.width-30, imgView.frame.size.height, 30, 30);
        lblName.font  = [UIFont fontWithName:CGRegular size:textSize-6];
        
        lblLatestReading.frame = CGRectMake(imgView.frame.size.width+5, 0, self.view.frame.size.width-imgView.frame.size.width, 30);
        lblLatestReading.font  = [UIFont fontWithName:CGRegular size:textSize-6];

        int zz = imgView.frame.size.width+5;
        lblCoreTmp.frame = CGRectMake(zz, 30,(ProfileView.frame.size.width-zz)/2, 30);
        lblCoreTmp.font  = [UIFont fontWithName:CGRegular size:textSize-6];

        lblSkinTmp.frame = CGRectMake((ProfileView.frame.size.width+zz)/2+5, 30, (ProfileView.frame.size.width-zz)/2-5, 30);
        lblSkinTmp.font  = [UIFont fontWithName:CGRegular size:textSize-6];

        lblMoreSubjDetails.frame = CGRectMake(zz, 65, ProfileView.frame.size.width-zz, 30);
        lblMoreSubjDetails.font  = [UIFont fontWithName:CGRegular size:textSize-6];

        imgBattery.frame = CGRectMake(zz, ProfileView.frame.size.height-30, 30, 15);
        zz = zz + 30;
        lblBattery.frame = CGRectMake(zz, ProfileView.frame.size.height-40, 50, 35);
        lblBattery.font  = [UIFont fontWithName:CGRegular size:textSize-6];

        zz = zz+60;
        btnRead.frame = CGRectMake(zz, ProfileView.frame.size.height-40, 70, 35);
        btnRead.titleLabel.font  = [UIFont fontWithName:CGRegular size:textSize-6];

        zz = zz+80;
        btnSpotCheck.frame = CGRectMake(zz, ProfileView.frame.size.height-40, 70, 35);
        btnSpotCheck.titleLabel.font  = [UIFont fontWithName:CGRegular size:textSize-6];

    }
}
#pragma mark-Graph view
-(void)SetupGraphView
{
    graphBgView = [[UIView alloc]init];
    graphBgView.frame = CGRectMake(40, DEVICE_HEIGHT/3-60, DEVICE_WIDTH-80, DEVICE_HEIGHT/3+50);
    graphBgView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:graphBgView];
       
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
    
    if ( IS_IPHONE_4 || IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_6plus)
    {
        graphBgView.frame = CGRectMake(0, DEVICE_HEIGHT/3-10, DEVICE_WIDTH, DEVICE_HEIGHT/3+20);
        lblTrendGraph.frame = CGRectMake(5, 0, graphBgView.frame.size.width-10, 30);
        lblTrendGraph.font = [UIFont fontWithName:CGBold size:textSize-4];
        _chartView.frame = CGRectMake(0, 30, graphBgView.frame.size.width, graphBgView.frame.size.height-35);
    }
}
-(void)SetupBottomSensorView
{
    UILabel* lblotherSnr = [[UILabel alloc]initWithFrame:CGRectMake(40, DEVICE_HEIGHT/2+120, self.view.frame.size.width-80, 50)];
    [self setLabelProperties:lblotherSnr withText:@"Other sensor" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:25];
    lblotherSnr.font = [UIFont boldSystemFontOfSize:25];
    lblotherSnr.layer.borderColor = UIColor.clearColor.CGColor;
    [self.view addSubview:lblotherSnr];
    
    int xx = 40;
    int yy = DEVICE_HEIGHT-DEVICE_HEIGHT/3;
    
    UIColor *btnBGColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];

    UIView * viewlblTmp = [[UIView alloc] initWithFrame: CGRectMake(xx, yy, DEVICE_WIDTH-xx-40, DEVICE_HEIGHT-yy-80)];
    viewlblTmp.backgroundColor = [UIColor clearColor];
    [self.view addSubview:viewlblTmp];
    
    int width = viewlblTmp.frame.size.width;
    int ya = 50;
    // header
    UILabel * lblIDtypeLeft = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width/2-10, 45)];
    [self setLabelProperties:lblIDtypeLeft withText:[NSString stringWithFormat:@" Sensor ID /%@",@"Type"] backColor:btnBGColor textColor:UIColor.whiteColor textSize:textSize];
    [viewlblTmp addSubview:lblIDtypeLeft];
    
    UILabel * lblIDtypeRight = [[UILabel alloc] initWithFrame:CGRectMake(width/2+5, 0, width/2-5, 45)];
    [self setLabelProperties:lblIDtypeRight withText:[NSString stringWithFormat:@" Sensor ID /%@",@"Type"] backColor:btnBGColor textColor:UIColor.whiteColor textSize:textSize];
    [viewlblTmp addSubview:lblIDtypeRight];
    
    UILabel * lblTempLeft = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width/2-15, 45)];
    [self setLabelProperties:lblTempLeft withText:[NSString stringWithFormat:@"Temp %@",@" "] backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize];
    lblTempLeft.textAlignment = NSTextAlignmentRight;
    [viewlblTmp addSubview:lblTempLeft];
    
    UILabel * lblTempRight = [[UILabel alloc] initWithFrame:CGRectMake(width/2+5, 0, width/2-15, 45)];
    [self setLabelProperties:lblTempRight withText:[NSString stringWithFormat:@"Temp %@",@" "] backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize];
    lblTempRight.textAlignment = NSTextAlignmentRight;
    [viewlblTmp addSubview:lblTempRight];
    
    // sensors lalbles
    ya = ya;
    lblSensor3 = [[UILabel alloc] initWithFrame:CGRectMake(5, ya, width/2-10, 45)];
    [self setLabelProperties:lblSensor3 withText:@"Sensor/Type" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize];
    [viewlblTmp addSubview:lblSensor3];
    
    lblTemp3 = [[UILabel alloc] initWithFrame:CGRectMake(5, ya, width/2-20, 45)];
    [self setLabelProperties:lblTemp3 withText:@"Temperature" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize];
    lblTemp3.textAlignment = NSTextAlignmentRight;
    [viewlblTmp addSubview:lblTemp3];
    
    lblSensor7 = [[UILabel alloc] initWithFrame:CGRectMake(width/2+10, ya, width/2-10, 45)];
    [self setLabelProperties:lblSensor7 withText:@"Sensor/Type" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize];
    [viewlblTmp addSubview:lblSensor7];
    
    lblTemp7 = [[UILabel alloc] initWithFrame:CGRectMake(width/2+10, ya, width/2-20, 45)];
    [self setLabelProperties:lblTemp7 withText:@"Temperature" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize];
    lblTemp7.textAlignment = NSTextAlignmentRight;
    [viewlblTmp addSubview:lblTemp7];
    
    UILabel * lblLineLeft = [[UILabel alloc] initWithFrame:CGRectMake(0, ya+40, lblIDtypeRight.frame.size.width, 0.5)];
    lblLineLeft.backgroundColor = UIColor.lightGrayColor;
    [viewlblTmp addSubview:lblLineLeft];
    
    UILabel * lblLineRight = [[UILabel alloc] initWithFrame:CGRectMake(width/2+5, ya+40, lblIDtypeRight.frame.size.width, 0.5)];
    lblLineRight.backgroundColor = UIColor.lightGrayColor;
    [viewlblTmp addSubview:lblLineRight];
    
    ya = ya+50;
    lblSensor4 = [[UILabel alloc] initWithFrame:CGRectMake(5, ya, width/2-10, 45)];
    [self setLabelProperties:lblSensor4 withText:@"Sensor/Type" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize];
    [viewlblTmp addSubview:lblSensor4];
    
    lblTemp4 = [[UILabel alloc] initWithFrame:CGRectMake(5, ya, width/2-20, 45)];
    [self setLabelProperties:lblTemp4 withText:@"Temperature" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize];
    lblTemp4.textAlignment = NSTextAlignmentRight;
    [viewlblTmp addSubview:lblTemp4];
    
    lblSensor8 = [[UILabel alloc] initWithFrame:CGRectMake(width/2+10, ya, width/2-20, 45)];
    [self setLabelProperties:lblSensor8 withText:@"Sensor/Type" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize];
    [viewlblTmp addSubview:lblSensor8];
    
    lblTemp8 = [[UILabel alloc] initWithFrame:CGRectMake(width/2+10, ya, width/2-20, 45)];
    [self setLabelProperties:lblTemp8 withText:@"Temperature" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize];
    lblTemp8.textAlignment = NSTextAlignmentRight;
    [viewlblTmp addSubview:lblTemp8];
    
    UILabel * lblLineLeft1 = [[UILabel alloc] initWithFrame:CGRectMake(0, ya+40, lblIDtypeRight.frame.size.width, 0.5)];
    lblLineLeft1.backgroundColor = UIColor.lightGrayColor;
    [viewlblTmp addSubview:lblLineLeft1];
    
    UILabel * lblLineRight1 = [[UILabel alloc] initWithFrame:CGRectMake(width/2+5, ya+40, lblIDtypeRight.frame.size.width, 0.5)];
    lblLineRight1.backgroundColor = UIColor.lightGrayColor;
    [viewlblTmp addSubview:lblLineRight1];
              
    ya = ya+50;
     lblSensor5 = [[UILabel alloc] initWithFrame:CGRectMake(5, ya, width/2-10, 45)];
    [self setLabelProperties:lblSensor5 withText:@"Sensor/Type" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize];
    [viewlblTmp addSubview:lblSensor5];
    
    lblTemp5 = [[UILabel alloc] initWithFrame:CGRectMake(5, ya, width/2-20, 45)];
    [self setLabelProperties:lblTemp5 withText:@"Temperature" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize];
    lblTemp5.textAlignment = NSTextAlignmentRight;
    [viewlblTmp addSubview:lblTemp5];
    
    lblSensor9 = [[UILabel alloc] initWithFrame:CGRectMake(width/2+10, ya, width/2-20, 45)];
    [self setLabelProperties:lblSensor9 withText:@"Sensor/Type" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize];
    [viewlblTmp addSubview:lblSensor9];
    
    lblTemp9 = [[UILabel alloc] initWithFrame:CGRectMake(width/2+10, ya, width/2-20, 45)];
    [self setLabelProperties:lblTemp9 withText:@"Temperature" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize];
    lblTemp9.textAlignment = NSTextAlignmentRight;
    [viewlblTmp addSubview:lblTemp9];
    
    UILabel * lblLineLeft2 = [[UILabel alloc] initWithFrame:CGRectMake(0, ya+40, lblIDtypeRight.frame.size.width, 0.5)];
    lblLineLeft2.backgroundColor = UIColor.lightGrayColor;
    [viewlblTmp addSubview:lblLineLeft2];
    
    UILabel * lblLineRight2 = [[UILabel alloc] initWithFrame:CGRectMake(width/2+5, ya+40, lblIDtypeRight.frame.size.width, 0.5)];
    lblLineRight2.backgroundColor = UIColor.lightGrayColor;
    [viewlblTmp addSubview:lblLineRight2];
    
    ya = ya+50;
    lblSensor6 = [[UILabel alloc] initWithFrame:CGRectMake(5, ya, width/2-20, 45)];
    [self setLabelProperties:lblSensor6 withText:@"Sensor/Type" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize];
    [viewlblTmp addSubview:lblSensor6];
    
    lblTemp6 = [[UILabel alloc] initWithFrame:CGRectMake(5, ya, width/2-20, 45)];
    [self setLabelProperties:lblTemp6 withText:@"Temperature" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize];
    lblTemp6.textAlignment = NSTextAlignmentRight;
    [viewlblTmp addSubview:lblTemp6];
    
    lblSensor10 = [[UILabel alloc] initWithFrame:CGRectMake(width/2+10, ya, width/2-20, 45)];
    [self setLabelProperties:lblSensor10 withText:@"Sensor/Type" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize];
    [viewlblTmp addSubview:lblSensor10];
    
    lblTemp10 = [[UILabel alloc] initWithFrame:CGRectMake(width/2+10, ya, width/2-20, 45)];
    [self setLabelProperties:lblTemp10 withText:@"Temperature" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:textSize];
    lblTemp10.textAlignment = NSTextAlignmentRight;
    [viewlblTmp addSubview:lblTemp10];
    
    UILabel * lblLineleft3 = [[UILabel alloc] initWithFrame:CGRectMake(0, ya+40, lblIDtypeRight.frame.size.width, 0.5)];
    lblLineleft3.backgroundColor = UIColor.lightGrayColor;
    [viewlblTmp addSubview:lblLineleft3];
    
    UILabel * lblLineRight3 = [[UILabel alloc] initWithFrame:CGRectMake(width/2+5, ya+40, lblIDtypeRight.frame.size.width, 0.5)];
    lblLineRight3.backgroundColor = UIColor.lightGrayColor;
    [viewlblTmp addSubview:lblLineRight3];
    
    if ( IS_IPHONE_4 || IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_6plus)
    {
        int yy  = ProfileView.frame.size.height +  graphBgView.frame.size.height + 70;
        lblotherSnr.frame = CGRectMake(5, yy, self.view.frame.size.width, 30);
        lblotherSnr.font = [UIFont fontWithName:CGRegular size:textSize-6];
        int xx = 5;
        
        viewlblTmp.frame = CGRectMake(xx, yy+30, DEVICE_WIDTH-10, DEVICE_HEIGHT-yy-80);
        int width = viewlblTmp.frame.size.width;

        // header
        lblIDtypeLeft.frame = CGRectMake(0, 0, width/2-10, 25);
        lblIDtypeLeft.font = [UIFont fontWithName:CGRegular size:textSize-6];

        lblIDtypeRight.frame = CGRectMake(width/2+5, 0, width/2-5, 25);
        lblIDtypeRight.font = [UIFont fontWithName:CGRegular size:textSize-6];

        lblTempLeft.frame = CGRectMake(0, 0, width/2-15, 25);
        lblTempLeft.font = [UIFont fontWithName:CGRegular size:textSize-6];

        lblTempRight.frame = CGRectMake(width/2+5, 0, width/2-15, 25);
        lblTempRight.font = [UIFont fontWithName:CGRegular size:textSize-6];
        
        // sensors lalbles
        int ya = 25;
        
        lblSensor3.frame = CGRectMake(5, ya, width/2-10, 25);
        lblSensor3.font = [UIFont fontWithName:CGRegular size:textSize-8];

        lblTemp3.frame = CGRectMake(5, ya, width/2-10, 25);
        lblTemp3.font = [UIFont fontWithName:CGRegular size:textSize-8];
        
        lblSensor7.frame = CGRectMake(width/2+10, ya, width/2-10, 25);
        lblSensor7.font = [UIFont fontWithName:CGRegular size:textSize-8];

        lblTemp7.frame = CGRectMake(width/2+10, ya, width/2-10, 25);
        lblTemp7.font = [UIFont fontWithName:CGRegular size:textSize-8];
        
        lblLineLeft.frame = CGRectMake(0, ya+25, lblIDtypeRight.frame.size.width, 0.5);
        lblLineRight.frame = CGRectMake(width/2+5, ya+25, lblIDtypeRight.frame.size.width, 0.5);

        ya = ya+25;
        
        lblSensor4.frame = CGRectMake(5, ya, width/2-10, 25);
        lblSensor4.font = [UIFont fontWithName:CGRegular size:textSize-8];

        lblTemp4.frame = CGRectMake(5, ya, width/2-10, 25);
        lblTemp4.font = [UIFont fontWithName:CGRegular size:textSize-8];

        lblSensor4.frame = CGRectMake(5, ya, width/2-10, 25);
        lblSensor4.font = [UIFont fontWithName:CGRegular size:textSize-8];

        lblSensor8.frame = CGRectMake(width/2+10, ya, width/2-10, 25);
        lblSensor8.font = [UIFont fontWithName:CGRegular size:textSize-8];

        lblTemp8.frame = CGRectMake(width/2+10, ya, width/2-10, 25);
        lblTemp8.font = [UIFont fontWithName:CGRegular size:textSize-8];

        lblLineLeft1.frame = CGRectMake(0, ya+25, lblIDtypeRight.frame.size.width, 0.5);
        lblLineRight1.frame = CGRectMake(width/2+5, ya+25, lblIDtypeRight.frame.size.width, 0.5);

        ya = ya+25;
         lblSensor5.frame = CGRectMake(5, ya, width/2-10, 25);
         lblSensor5.font = [UIFont fontWithName:CGRegular size:textSize-8];

        lblTemp5.frame = CGRectMake(5, ya, width/2-10, 25);
        lblTemp5.font = [UIFont fontWithName:CGRegular size:textSize-8];

        lblSensor9.frame = CGRectMake(width/2+10, ya, width/2-10, 25);
        lblSensor9.font = [UIFont fontWithName:CGRegular size:textSize-8];

        lblTemp9.frame = CGRectMake(width/2+10, ya, width/2-10, 25);
        lblTemp9.font = [UIFont fontWithName:CGRegular size:textSize-8];

        lblLineLeft2.frame = CGRectMake(0, ya+25, lblIDtypeRight.frame.size.width, 0.5);
        lblLineRight2.frame = CGRectMake(width/2+5, ya+25, lblIDtypeRight.frame.size.width, 0.5);

        ya = ya+25;
        lblSensor6.frame = CGRectMake(5, ya, width/2-10, 25);
        lblSensor6.font = [UIFont fontWithName:CGRegular size:textSize-8];
        
        lblTemp6.frame = CGRectMake(5, ya, width/2-10, 25);
        lblTemp6.font = [UIFont fontWithName:CGRegular size:textSize-8];
        
        lblSensor10.frame = CGRectMake(width/2+10, ya, width/2-10, 25);
        lblSensor10.font = [UIFont fontWithName:CGRegular size:textSize-8];

        lblTemp10.frame = CGRectMake(width/2+10, ya, width/2-10, 25);
        lblTemp10.font = [UIFont fontWithName:CGRegular size:textSize-8];
        
        lblLineleft3.frame = CGRectMake(0, ya+25, lblIDtypeRight.frame.size.width, 0.5);
        lblLineRight3.frame = CGRectMake(width/2+5, ya+25, lblIDtypeRight.frame.size.width, 0.5);



    }
    
}
-(NSString *)GetSensorIDandTypeForLableWithIndex:(NSInteger)i
{
    if (arrSavedSensors.count > 0)
    {
        NSString * strSensorId = [APP_DELEGATE checkforValidString:[[arrSavedSensors objectAtIndex:i] valueForKey:@"sensor_id"]];
        NSString * strSensorType = [APP_DELEGATE checkforValidString:[[arrSavedSensors objectAtIndex:i] valueForKey:@"sensor_type"]];
        NSString * strType = @"Skin";
        if ([strSensorType isEqualToString:@"3"])
        {
            strType = @"Core";
        }
        return [NSString stringWithFormat:@"%@ / %@", strSensorId, strType];
    }
    else
    {
        return @" ";
    }
  
}
#pragma mark- Table View Method
 -(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView*viewHeader = [[UIView alloc]init];
    viewHeader.frame = CGRectMake(0, 0, tblListOfSensor.frame.size.width, 50);
    viewHeader.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
        
    UILabel *lblTitle= [[UILabel alloc] init];
    lblTitle.frame = CGRectMake(5, 0, tblListOfSensor.frame.size.width - 10, 50);
    lblTitle.text = @"List of available Sensors";
    lblTitle.font = [UIFont fontWithName:CGBold size:textSize + 3];
    lblTitle.textColor = UIColor.whiteColor;
    lblTitle.textAlignment = NSTextAlignmentLeft;
    [viewHeader addSubview:lblTitle];
    
    if ( IS_IPHONE_4 || IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_6plus)
    {
        viewHeader.frame = CGRectMake(0, 0, tblListOfSensor.frame.size.width, 35);
        lblTitle.frame = CGRectMake(5, 0, tblListOfSensor.frame.size.width, 35);
        lblTitle.font = [UIFont fontWithName:CGRegular size:17];
    }
    return viewHeader;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrAvailSensorsofMonitor.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellP = @"CellProfile";
    PlayerSubjCELL *cell = [tableView dequeueReusableCellWithIdentifier:cellP];
    cell = [[PlayerSubjCELL alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellP];
    cell.lblTemp.frame = CGRectMake(tblListOfSensor.frame.size.width/2-10, 0, tblListOfSensor.frame.size.width/2, 40);
    cell.lblTemp.hidden = false;
    cell.lblDate.hidden = false;
    cell.lblName.frame = CGRectMake(5, 0, DEVICE_WIDTH/2, 70);
    cell.lblName.textAlignment = NSTextAlignmentLeft;
    cell.lblTemp.frame = CGRectMake(DEVICE_WIDTH/2, 0, DEVICE_WIDTH/2, 70);

    cell.lblName.text = [[arrAvailSensorsofMonitor objectAtIndex:indexPath.row] valueForKey:@"sensor_id"];
    cell.lblTemp.text = [[arrAvailSensorsofMonitor objectAtIndex:indexPath.row] valueForKey:@"sensor_type"];
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
     globalSbuSetupVC.SubjectDelegate = self;
     [self.navigationController pushViewController:globalSbuSetupVC animated:true];
 }
 -(void)btnDoneClick
 {
     if (isSessionStarted == YES)
     {
         [self AlertViewFCTypeCaution:@"Session is going on. Are you sure want to move back and Stop session. You can minimize the app and let session going on."];
         
         FCAlertView *alert = [[FCAlertView alloc] init];
         alert.colorScheme = [UIColor blackColor];
         [alert makeAlertTypeWarning];
         [alert addButton:@"Move Back" withActionBlock:
          ^{
             
             [self.navigationController popViewControllerAnimated:TRUE];
             //Delete one by one all the Added Sensors
         }];
         [alert showAlertInView:self
                      withTitle:@"HQ-Inc App"
                   withSubtitle:@"Session is going on. Are you sure want to move back and Stop session. You can minimize the app and let session going on."
                withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
            withDoneButtonTitle:@"Cancel" andButtons:nil];
     }
     else
     {
         [self.navigationController popViewControllerAnimated:true];
     }
 }
-(void)btnStartReadingClick
{
    btnRead.titleLabel.numberOfLines = 0;

    if (isSessionStarted == NO)
    {
        if (globalPeripheral.state == CBPeripheralStateConnected)
        {
            [self SetTempIntervalwithPlayerID];
            isCommandforSession = YES;
//            [self CommandtoFetchAllSensorsfromMonitor];
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
        
        [self setButtonProperties:btnRead withTitle:@"Start Readings" backColor:[UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1] textColor:UIColor.whiteColor txtSize:20];
    }
}
-(void)btnInstanReadingClick
{
//    [self setupForViewAllSensors];

    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        if (isSessionStarted == YES)
        {
            
        }
        else
        {
            isCommandforSession = NO;
            [self StartInstantReadingCommand];
//            [self CommandtoFetchAllSensorsfromMonitor];
        }
    }
    else
    {
        [self AlertViewFCTypeCaution:@"Please make sure Monitor is connected with App and then try again to Start Session."];

    }
}

#pragma mark- FETCH ALL AVAILABLE SENSORS FROM MONITOR BEFORE START SESSION
-(void)CommandtoFetchAllSensorsfromMonitor
{
    NSMutableData * packetData = [[NSMutableData alloc] init];
    [[BLEService sharedInstance] WriteValuestoDevice:packetData withOcpde:@"24" withLength:@"0" with:globalPeripheral];
}
-(void)ReceiveAvailableSensorsfromMonitorBeforeStartSession:(NSString *)strPacket withPacketLength:(NSString *)strPacketLength;
{
    if ([strPacket length] >= 2)
    {
        NSString * strTotalSensors = [strPacket substringWithRange:NSMakeRange(0, 2)];

        if ([strTotalSensors isEqualToString:@"ff"] && [strPacketLength isEqualToString:@"00"])
        {
            //No Single Sensor Available...
            dispatch_async(dispatch_get_main_queue(), ^{
                [self AlertViewFCTypeCaution:@"There is no Sensors available with Monitor. Please add Sensors and then try again."];
            });
        }
        else
        {
            if (![strTotalSensors isEqualToString:@"ff"])
            {
                NSString * strNoOfSensors = [self stringFroHex:strTotalSensors];
                totalAvailableSensorofMonitor = [strNoOfSensors intValue];
            }
            int packetLength = [[self stringFroHex:strPacketLength] intValue] - 1;// -1 for No.of.Sensors
            if (packetLength > 0 )
            {
                for (int i=0; i < packetLength/3; i++)
                {
                    NSString * strSensorId = [self stringFroHex:[strPacket substringWithRange:NSMakeRange(2 + (i*6), 4)]];
                    NSString * strSensorType = [strPacket substringWithRange:NSMakeRange(2 + (i*6) + 4, 2)];
                    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:strSensorId,@"sensor_id",strSensorType,@"sensor_type", nil];
                    if (![[arrAvailSensorsofMonitor valueForKey:@"sensor_id"] containsObject:strSensorId])
                    {
                        [arrAvailSensorsofMonitor addObject:dict];
                    }
                }
            }
            if ([arrAvailSensorsofMonitor count] == totalAvailableSensorofMonitor)
            {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self setupForViewAllSensors];
                });
            }
        }
    }
}
#pragma mark- TO START INSTANT READING & RECEIVE DATA
-(void)StartInstantReadingCommand
{
    NSMutableData * packetData = [[NSMutableData alloc] init];
    [[BLEService sharedInstance] WriteValuestoDevice:packetData withOcpde:@"23" withLength:@"0" with:globalPeripheral];
}

-(void)GetInstantReadingsData:(NSString *)strSensorID withTemperature:(NSString *)strTemp withSensorType:(NSString *)strSensorType withPacket:(NSString *)strPacket
{
    NSString * strTimeStamp = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];

    NSString * strUserId = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    if ([[APP_DELEGATE checkforValidString:[dataDict valueForKey:@"user_id"]] isEqualToString:@"NA"])
    {
        strUserId = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
        NSString * strUpdate = [NSString stringWithFormat:@"update Subject_Table set user_id = '%@' where id = '%@'",strUserId ,[dataDict valueForKey:@"id"] ];
        [[DataBaseManager dataBaseManager] execute:strUpdate];
        [dataDict setValue:strUserId forKey:@"user_id"];
    }
    else
    {
        strUserId = [dataDict valueForKey:@"user_id"];
    }
    
    NSString * strDataQuery = [NSString stringWithFormat:@"insert into 'instant_read_data' ('user_id', 'temp', 'timestamp', 'sensor_type', 'sensor_id', 'packet') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",strUserId,strTemp,strTimeStamp,strSensorType,strSensorID,strPacket];
    [[DataBaseManager dataBaseManager] execute:strDataQuery];
    
    float tempC = strTemp.floatValue;
    float tempF = (tempC * 1.8) + 32;
    NSString * strTempF = [NSString stringWithFormat:@"%.2f", tempF];

    if ([strSensorType isEqualToString:@"Core"])
    {
        NSString * strUpdateLatestTemp = [NSString stringWithFormat:@"update Subject_Table set latestCoretempC = \"%@\", latestCoretempF = \"%@\" where user_id = '%@'",strTemp,strTempF ,strUserId];
        [[DataBaseManager dataBaseManager] execute:strUpdateLatestTemp];
    }
    else
    {
        NSString * strUpdateLatestTemp = [NSString stringWithFormat:@"update Subject_Table set latestSkintempC = \"%@\",latestSkintempF = \"%@\" where user_id = '%@'",strTemp,strTempF,strUserId];
        [[DataBaseManager dataBaseManager] execute:strUpdateLatestTemp];

    }



}
#pragma mark- Start Reading Flow
#pragma mark 1. SET TIME INTERVAL
-(void)SetTempIntervalwithPlayerID
{
    NSString * strUserId = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    if ([[APP_DELEGATE checkforValidString:[dataDict valueForKey:@"user_id"]] isEqualToString:@"NA"])
    {
        strUserId = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
        NSString * strUpdate = [NSString stringWithFormat:@"update Subject_Table set user_id = '%@' where id = '%@'",strUserId ,[dataDict valueForKey:@"id"] ];
        [[DataBaseManager dataBaseManager] execute:strUpdate];
        [dataDict setValue:strUserId forKey:@"user_id"];
    }
    else
    {
        strUserId = [dataDict valueForKey:@"user_id"];
    }

    NSInteger interval = [@"10" integerValue];
    if (![[APP_DELEGATE checkforValidString:[dataDict valueForKey:@"timeInterval"]] isEqualToString:@"NA"])
    {
        if ([[dataDict valueForKey:@"timeInterval"] isEqualToString:@"1 Minute"])
        {
            interval = [@"60" integerValue];
        }
        else if ([[dataDict valueForKey:@"timeInterval"] isEqualToString:@"1 Hour"])
        {
            interval = [@"3600" integerValue];
        }
        else if ([[dataDict valueForKey:@"timeInterval"] isEqualToString:@"1 Hour"])
        {
            interval = [@"86400" integerValue];
        }
    }
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
#pragma mark 2. WRITE PLAYER NAME TO DEVICE
-(void)WritePlayerNametoMonitorttoStartSession
{
    NSString * str = [self hexFromStr:[dataDict objectForKey:@"name"]];
    NSData * msgData = [self dataFromHexString:str];
    
    NSInteger intLength = [[dataDict objectForKey:@"name"] length];

    [[BLEService sharedInstance] WriteValuestoDevice:msgData withOcpde:@"12" withLength:[NSString stringWithFormat:@"%ld",(long)intLength] with:globalPeripheral];
}
#pragma mark 3. START SESSION CONFIRMATION / ALSO TO STOP SESSION
-(void)StartSessionConfirmation:(BOOL)isSessionStartSuccess;
{
    if (isSessionStartSuccess == NO)
    {
        [self AlertViewFCTypeCaution:@"Something went wrong with Start Session. Please try again."];
        isSessionStarted = NO;
    }
    else
    {
        isSessionStarted = YES;
        [self setButtonProperties:btnRead withTitle:@"Stop Readings" backColor:[UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1] textColor:UIColor.whiteColor txtSize:20];
    }
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

#pragma mark 4. RECIEVING TEMP FROM DEVICE
-(void)SendTemperatureReadingtoDetailVC:(NSString *)strSensorID withTemperature:(NSString *)strTemp withSensorType:(NSString *)strSensorType
{
    if ([strTemp intValue] > 0)
    {
        if ([strTemp length] > 3)
        {
            NSString * strdotBefore = [strTemp substringWithRange:NSMakeRange(0, 2)];
            strTemp = [NSString stringWithFormat:@"%@%@",strdotBefore,[strTemp substringWithRange:NSMakeRange(2, [strTemp length] - 2)]];
        }
        NSString * strDataType = strSensorType; //if Sensor type dermal then its Core, if its Ingestible then its Skin
            
        if ([[arrSavedSensors valueForKey:@"sensor_id"] containsObject:strSensorID])
        {
            //3 - Ingestible (Core),  4 - Dermal (Skin)
            NSInteger foundIndex = [[arrSavedSensors valueForKey:@"sensor_id"] indexOfObject:strSensorID];
            if (foundIndex != NSNotFound)
                {
                    if ([arrSavedSensors count] > foundIndex)
                    {
                        if ([[[arrSavedSensors objectAtIndex:foundIndex] valueForKey:@"sensor_type"] isEqualToString:@"3"])
                        {
                            strDataType = @"Core";

                        }
                        
                        NSString * strValueTemp = [APP_DELEGATE checkforValidString:strTemp];
                        NSLog(@"====================================================kkkk%@ ==%@",arrSavedSensors,strValueTemp);
                        NSMutableDictionary * dictData = [[arrSavedSensors objectAtIndex:foundIndex] mutableCopy];
                        [dictData setValue:strValueTemp forKey:@"temp"];
                        [arrSavedSensors replaceObjectAtIndex:foundIndex withObject:dictData];
                    }
                }
            }
            [self UpdateTemperatureforLabels];

            xCount = xCount + 1;
            
            NSLog(@"========Sensord_ID=%@  ======= Sensor_Type =%@ ======= Temp=%@=======",strSensorID, strDataType, strTemp);

            if ([strDataType isEqualToString:@"Core"])
            {
                if ([arrCoreTemp count] <= 0)
                {
                    [arrCoreTemp addObject:strSensorID];
                    [APP_DELEGATE endHudProcess];
                }
                if ([arrCoreTemp containsObject:strSensorID])
                {
                    lblCoreTmp.text = [NSString stringWithFormat:@"Core Tmp %@˚C",strTemp];
                    lblCoreTmp.backgroundColor = [UIColor blueColor];
                    
                    [blinkTimerCore invalidate];
                    blinkTimerCore = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)(0.1) target:self selector:@selector(animateCoreTempLabel) userInfo:nil repeats:TRUE];

                    if ([yVals1 count] >= 10)
                    {
                        [yVals1 removeObjectAtIndex:0];
                    }
                    [yVals1 addObject:[[ChartDataEntry alloc] initWithX:xCount y:[strTemp doubleValue]]];
                }
//                NSLog(@"<=========Core========>%@",strTemp);
            }
            else
            {
                if ([arrSkinsTemp count] <= 0)
                {
                    [arrSkinsTemp addObject:strSensorID];
                    [APP_DELEGATE endHudProcess];
                }
                if ([arrSkinsTemp containsObject:strSensorID])
                {
                    [blinkTimerSkin invalidate];
                    blinkTimerSkin = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)(0.1) target:self selector:@selector(animateSkinTempLabel) userInfo:nil repeats:TRUE];
                    lblSkinTmp.text = [NSString stringWithFormat:@"Skin Tmp %@˚C",strTemp];

                    if ([yVals2 count] >= 10)
                    {
                        [yVals2 removeObjectAtIndex:0];
                    }

                    [yVals2 addObject:[[ChartDataEntry alloc] initWithX:xCount y:[strTemp doubleValue]]];
                }
//                NSLog(@"<=========Skin========>%@",strTemp);
            }
            if ([arrTempValues count] >= 20)
            {
//                [arrTempValues removeObjectAtIndex:0];
            }
            [arrTempValues addObject:[NSNumber numberWithDouble:[strTemp doubleValue]]];
        }
    double max1 = [[arrTempValues valueForKeyPath: @"@max.self"] doubleValue];
    double min1 = [[arrTempValues valueForKeyPath: @"@min.self"] doubleValue];

    _chartView.leftAxis.axisMaximum = max1 + 0.1;
    _chartView.leftAxis.axisMinimum = min1 - 0.1;
        
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
#pragma mark 5. STOP SESSION COMMAND
-(void)StopSessionCommandtoDevice
{
    NSInteger intMsg = [@"0" integerValue];
    NSData * dataMsg = [[NSData alloc] initWithBytes:&intMsg length:1];

    NSLog(@"Wrote Command for Start Session---==%@",dataMsg);
    [[BLEService sharedInstance] WriteValuestoDevice:dataMsg withOcpde:@"13" withLength:@"0" with:globalPeripheral];
}

-(void)UpdateTemperatureforLabels
{
 if (arrSavedSensors.count > 0)
{
    for (int i = 2; i < [arrSavedSensors count] ; i++) // 2
    {
        NSString * strTemp = @"NA";
        if ([[[arrSavedSensors objectAtIndex:i] allKeys] containsObject:@"temp"])
        {
            strTemp = [APP_DELEGATE checkforValidString:[[arrSavedSensors objectAtIndex:i] valueForKey:@"temp"]];
        }
        if (i == 2)
        {
            lblSensor3.text = [self GetSensorIDandTypeForLableWithIndex:2];
            if ([strTemp isEqualToString:@"NA"])
            {
                lblTemp3.text = @" ";
            }
            else
            {
                lblTemp3.text = [NSString stringWithFormat:@"%@ ºC", strTemp];
            }
        }
        else if (i == 3)
        {
            lblSensor4.text = [self GetSensorIDandTypeForLableWithIndex:3];
            if ([strTemp isEqualToString:@"NA"])
            {
                lblTemp4.text = @" ";
            }
            else
            {
                lblTemp4.text = [NSString stringWithFormat:@"%@ ºC", strTemp];
            }
        }
        else if (i == 4)
        {
            lblSensor5.text = [self GetSensorIDandTypeForLableWithIndex:4];
            if ([strTemp isEqualToString:@"NA"])
            {
                lblTemp5.text = @" ";
            }
            else
            {
                lblTemp5.text = [NSString stringWithFormat:@"%@ ºC", strTemp];
            }
        }
        else if (i == 5)
        {
            lblSensor6.text = [self GetSensorIDandTypeForLableWithIndex:5];
            if ([strTemp isEqualToString:@"NA"])
            {
                lblTemp6.text = @" ";
            }
            else
            {
                lblTemp6.text = [NSString stringWithFormat:@"%@ ºC", strTemp];
            }
        }
        else if (i == 6)
        {
            lblSensor7.text = [self GetSensorIDandTypeForLableWithIndex:6];
            if ([strTemp isEqualToString:@"NA"])
            {
                lblTemp7.text = @" ";
            }
            else
            {
                lblTemp7.text = [NSString stringWithFormat:@"%@ ºC", strTemp];
            }
        }
        else if (i == 7)
        {
            lblSensor8.text = [self GetSensorIDandTypeForLableWithIndex:7];
            if ([strTemp isEqualToString:@"NA"])
            {
                lblTemp8.text = @" ";
            }
            else
            {
                lblTemp8.text = [NSString stringWithFormat:@"%@ ºC", strTemp];
            }
        }
        else if (i == 8)
        {
            lblSensor9.text = [self GetSensorIDandTypeForLableWithIndex:8];
            if ([strTemp isEqualToString:@"NA"])
            {
                lblTemp9.text = @" ";
            }
            else
            {
                lblTemp9.text = [NSString stringWithFormat:@"%@ ºC", strTemp];
            }
        }
        else if (i == 9)
        {
            lblSensor10.text = [self GetSensorIDandTypeForLableWithIndex:9];
            if ([strTemp isEqualToString:@"NA"])
            {
                lblTemp10.text = @" ";
            }
            else
            {
                lblTemp10.text = [NSString stringWithFormat:@"%@ ºC", strTemp];
            }
        }
      }
    }
}

-(void)ReceiveSensorDetails:(NSMutableArray *)arrSensors;
{
    arrSavedSensors = [[NSMutableArray alloc] init];
    arrSavedSensors = arrSensors;
}
-(void)LiveSessionReadingStarted:(NSMutableDictionary *)LiveSessionData;
{
    liveSessionDetail = LiveSessionData;
    isSessionStarted = YES;
    [self setButtonProperties:btnRead withTitle:@"Stop Readings" backColor:[UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1] textColor:UIColor.whiteColor txtSize:20];
}

-(void)UpdatePlayerDatafromSetup:(NSMutableDictionary *)updatedDataDict;
{
    dataDict = [updatedDataDict mutableCopy];
    lblName.text = [dataDict objectForKey:@"name"];
    lblNumber.text = [dataDict objectForKey:@"number"];

    [self gettingImg];
}
-(void)stopBlinking
{
    
}
-(void)animateCoreTempLabel
{
    if (coreBlinkCount >= 6)
    {
        coreBlinkCount = 0;
        [blinkTimerCore invalidate];
        blinkTimerCore = nil;
    }
    else
    {
        if(blinkStatusCore == NO){
           lblCoreTmp.backgroundColor = [UIColor blueColor];
          blinkStatusCore = YES;
        }else {
           lblCoreTmp.backgroundColor = [UIColor whiteColor];
           blinkStatusCore = NO;
        }
        coreBlinkCount = coreBlinkCount + 1;
    }
}
-(void)animateSkinTempLabel
{
    if (skinBlinkCount >= 6)
    {
        skinBlinkCount = 0;
        [blinkTimerSkin invalidate];
        blinkTimerSkin = nil;
    }
    else
    {
        if(blinkStatusSkin == NO)
        {
           lblSkinTmp.backgroundColor = [UIColor blueColor];
          blinkStatusSkin = YES;
        }
        else
        {
           lblSkinTmp.backgroundColor = [UIColor whiteColor];
           blinkStatusSkin = NO;
        }
        
        skinBlinkCount = skinBlinkCount + 1;
    }
}
#pragma mark- Img Scalling
-(void)gettingImg
{
    if ([[APP_DELEGATE checkforValidString:[dataDict valueForKey:@"photo_URL"]] isEqualToString:@"NA"])
    {
        imgView.image = [UIImage imageNamed:@"User_Default.png"];
    }
    else
    {
        NSString * filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"PlayerPhoto/%@", [dataDict valueForKey:@"photo_URL"]]];
        NSData *pngData = [NSData dataWithContentsOfFile:filePath];
        UIImage * mainImage = [UIImage imageWithData:pngData];
        UIImage * image = [self scaleMyImage:mainImage];
        imgView.image = image;
    }
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
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
#pragma mark- Sensor list Methoda
-(void)setupForViewAllSensors
{
    viewAllSensor = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    viewAllSensor.backgroundColor = [UIColor colorWithRed:0 green:(CGFloat)0 blue:0 alpha:0.8];
    [self.view addSubview:viewAllSensor];

    viewForListOfSensor = [[UIView alloc]initWithFrame:CGRectMake(150, (DEVICE_HEIGHT), DEVICE_WIDTH-300, 510)];
    viewForListOfSensor.backgroundColor = UIColor.whiteColor;
    viewForListOfSensor.layer.cornerRadius = 6;
    viewForListOfSensor.clipsToBounds = true;
    [viewAllSensor addSubview:viewForListOfSensor];
    
    UIColor *btnBGColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];

    tblListOfSensor = [[UITableView alloc]initWithFrame: CGRectMake(0, 0, viewForListOfSensor.frame.size.width-0, viewForListOfSensor.frame.size.height-110) style:UITableViewStylePlain];;
    tblListOfSensor.backgroundColor = UIColor.whiteColor;
    tblListOfSensor.delegate= self;
    tblListOfSensor.dataSource = self;
    [viewForListOfSensor addSubview:tblListOfSensor];
    
    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, viewForListOfSensor.frame.size.height-110, viewForListOfSensor.frame.size.width, 110)];
    lblBack.backgroundColor = btnBGColor;
    [viewForListOfSensor addSubview:lblBack];
    
    UILabel * lblHint = [[UILabel alloc] initWithFrame:CGRectMake(0, viewForListOfSensor.frame.size.height-110, viewForListOfSensor.frame.size.width, 44)];
    lblHint.font = [UIFont fontWithName:CGRegular size:textSize];
    lblHint.textAlignment = NSTextAlignmentCenter;
    lblHint.numberOfLines = 0;
    lblHint.text = @"Do you want to continue with above Sensors?";
    lblHint.textColor = UIColor.whiteColor;
    [viewForListOfSensor addSubview:lblHint];

    
    UIButton *btnNoStopSession = [[UIButton alloc]initWithFrame:CGRectMake(10, viewForListOfSensor.frame.size.height-60, (viewForListOfSensor.frame.size.width-30)/2, 50)];
    [self setButtonProperties:btnNoStopSession withTitle:@"No, I want to add more" backColor:UIColor.whiteColor textColor:btnBGColor txtSize:textSize-1];
    [btnNoStopSession addTarget:self action:@selector(btnStopClick) forControlEvents:UIControlEventTouchUpInside];
//    btnNoStopSession.layer.cornerRadius = 5;
    btnNoStopSession.titleLabel.numberOfLines = 0;
    btnNoStopSession.titleLabel.font = [UIFont fontWithName:CGBold size:textSize-1];
    [viewForListOfSensor addSubview:btnNoStopSession];

    UIButton *btnYesContinueSession = [[UIButton alloc]initWithFrame:CGRectMake(((viewForListOfSensor.frame.size.width-30)/2)+20, viewForListOfSensor.frame.size.height-60, (viewForListOfSensor.frame.size.width-30)/2, 50)];
    [self setButtonProperties:btnYesContinueSession withTitle:@"OK! Start Session" backColor:UIColor.whiteColor textColor:btnBGColor txtSize:textSize-1];
    btnYesContinueSession.titleLabel.numberOfLines = 0;
    [btnYesContinueSession addTarget:self action:@selector(btnYesClick) forControlEvents:UIControlEventTouchUpInside];
    [viewForListOfSensor addSubview:btnYesContinueSession];
    

    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        self->viewForListOfSensor.frame = CGRectMake(150, (DEVICE_HEIGHT-450)/2, DEVICE_WIDTH-300, 510);
        [self->tblListOfSensor reloadData];
    }
                    completion:NULL];
}
-(void)btnStopClick
{
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        self-> viewForListOfSensor.frame = CGRectMake(150, DEVICE_HEIGHT, DEVICE_WIDTH-300, 490);
    }
    completion:(^(BOOL finished)
    {
        
        [self-> viewAllSensor removeFromSuperview];
    })];
}
-(void)btnYesClick
{
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        self-> viewForListOfSensor.frame = CGRectMake(150, DEVICE_HEIGHT, DEVICE_WIDTH-300, 490);
    }
                    completion:(^(BOOL finished)
    {
        [self-> viewAllSensor removeFromSuperview];
        
        if (isCommandforSession == YES)
        {
            [self SetTempIntervalwithPlayerID];
        }
        else
        {
            [self StartInstantReadingCommand];
        }
    })];
}
-(NSString*)stringFroHex:(NSString *)hexStr
{
    unsigned long long startlong;
    NSScanner* scanner1 = [NSScanner scannerWithString:hexStr];
    [scanner1 scanHexLongLong:&startlong];
    double unixStart = startlong;
    NSNumber * startNumber = [[NSNumber alloc] initWithDouble:unixStart];
    return [startNumber stringValue];
}
@end
//    "player_id" = 1613640340;

/*
 SELECT *
 FROM MyTable
 WHERE record_date < ?
 ORDER BY record_date DESC
 LIMIT 100
 */
