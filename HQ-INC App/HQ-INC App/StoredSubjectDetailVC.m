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
#import "SessionAddVC.h"
#import "SessionReadVC.h"
#import "BLEService.h"
#import <MessageUI/MessageUI.h>
@import Charts;


@interface StoredSubjectDetailVC ()<UITableViewDelegate,UITableViewDataSource,ChartViewDelegate,MFMailComposeViewControllerDelegate>
{
    UITableView * tblPreviousCoreTmp,* tblPreviousSkinTmp;
    UILabel* lblName,*lblNumber,* lblCoreTmp,* lblSkinTmp;
    UIButton *btnRead,*btnSpotCheck,*btnViewSnr;
    UIImageView * imgView,*ProfileView;
    
    NSMutableArray * arrSessionGraphData;
    NSMutableArray * arrSkinsTemp, * arrCoreTemp;


}
@end

@implementation StoredSubjectDetailVC
@synthesize dataDict, sessionDict;
- (void)viewDidLoad
{
    arrSkinsTemp = [[NSMutableArray alloc] init];
    arrCoreTemp = [[NSMutableArray alloc] init];
//    yVals1 = [[NSMutableArray alloc] init];
//    yVals2 = [[NSMutableArray alloc] init];
//    arrTempValues = [[NSMutableArray alloc] init];

    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = UIColor.blackColor;
    
    UIColor * lbltxtClr = [UIColor colorWithRed:180.0/255 green:245.0/255 blue:254.0/255 alpha:1];
    UILabel* lblSubjectDetails = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, DEVICE_WIDTH, 50)];
    [self setLabelProperties:lblSubjectDetails withText:@"SUBJECT DETAILS" backColor:UIColor.clearColor textColor:lbltxtClr textSize:25];
    lblSubjectDetails.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lblSubjectDetails];
   
    UIColor *btnBGColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    UIButton * btnExportData = [[UIButton alloc]initWithFrame:CGRectMake(100, DEVICE_HEIGHT-60, 200, 50)];
    [self setButtonProperties:btnExportData withTitle:@"Export Data" backColor:btnBGColor textColor:UIColor.whiteColor txtSize:25];
    [btnExportData addTarget:self action:@selector(btnExportClick) forControlEvents:UIControlEventTouchUpInside];
    btnExportData.layer.cornerRadius = 5;
    [self.view addSubview:btnExportData]; 

    UIButton * btnDone = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-250, DEVICE_HEIGHT-60, 150, 50)];
    [self setButtonProperties:btnDone withTitle:@"Done" backColor:btnBGColor textColor:UIColor.whiteColor txtSize:25];
    [btnDone addTarget:self action:@selector(btnDoneClick) forControlEvents:UIControlEventTouchUpInside];
    btnDone.layer.cornerRadius = 5;
    [self.view addSubview:btnDone];


    double timeStamp = [[sessionDict valueForKey:@"timeStamp"] doubleValue];
    NSTimeInterval unixTimeStamp = timeStamp ;
    NSDate *exactDate = [NSDate dateWithTimeIntervalSince1970:unixTimeStamp];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd/MM/yyy hh:mm a";
    NSString  *finalate = [dateFormatter stringFromDate:exactDate];
    lblSubjectDetails.text = finalate;
    
    
    [self SetupForProfileview];
    [self setupSecondView];
    
    [self SetupGraphView];
//    [self setDataCount];

    [self gettingImg];

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
-(void)SetupForProfileview
{
    UIView * ProfileView = [[UIView alloc]init];
    ProfileView.frame = CGRectMake(40, 70, DEVICE_WIDTH-80, DEVICE_HEIGHT/3-130);
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
    tblBgView.frame = CGRectMake(40, (DEVICE_HEIGHT/3)-55, DEVICE_WIDTH-80, DEVICE_HEIGHT/3-50);
    tblBgView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:tblBgView];
    
    UILabel* lblPreviousCoreTmp = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH, 30)];
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

    UILabel* lblPreviousSkinTmp = [[UILabel alloc]initWithFrame:CGRectMake(tblBgView.frame.size.width/2+20, 0, DEVICE_WIDTH, 30)];
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
    graphBgView.frame = CGRectMake(40, (DEVICE_HEIGHT/3)*2-80, DEVICE_WIDTH-80, DEVICE_HEIGHT/3+15);
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
    [self setLabelProperties:lblPreDate withText:@"15-03-2021 01:49" backColor:LblBGcolor textColor:UIColor.blackColor textSize:textSize];
    lblPreDate.textAlignment = NSTextAlignmentCenter;
    [graphBgView addSubview:lblPreDate];
    
    UILabel* lblNextDate = [[UILabel alloc]initWithFrame:CGRectMake(wh*3+10, 0, wh+75, 50)];
    [self setLabelProperties:lblNextDate withText:@"15-03-2021 12:50" backColor:LblBGcolor textColor:UIColor.blackColor textSize:textSize];
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
@end
