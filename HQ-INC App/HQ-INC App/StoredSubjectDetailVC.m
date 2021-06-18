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
    NSMutableArray * arrSessionSensors;
    NSMutableDictionary * dictStoredSessionData;
    NSInteger dataFetchSensorCount;
    NSInteger maxDataCount, startTime, endTime;
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
    dictStoredSessionData = [[NSMutableDictionary alloc] init];
    
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


    arrSessionSensors = [[NSMutableArray alloc] init];
    NSString * strSensorsQuery = [NSString stringWithFormat:@"select * from Sensor_Table where session_id = '%@' group by sensor_id",[sessionDict valueForKey:@"session_id"]];
    [[DataBaseManager dataBaseManager] execute:strSensorsQuery resultsArray:arrSessionSensors];

    NSLog(@"=========Session Sensors=====%@",arrSessionSensors);

    dataFetchSensorCount = 0;
    
    NSInteger readInterval = [[sessionDict valueForKey:@"read_interval"] integerValue];
    NSInteger totalMaxCount = 300 / readInterval;
    if (totalMaxCount > 100)
    {
        totalMaxCount = 100;
    }
    maxDataCount = totalMaxCount;
    
    startTime = [[sessionDict valueForKey:@"timeStamp"] integerValue];
    endTime = startTime + ( readInterval * maxDataCount);
    [self SetDatetoValue:startTime withLabel:lblPreviousDate];
    [self SetDatetoValue:endTime withLabel:lblNextDate];

    [self FetchSensorDataQuery:0 start:startTime end:endTime];

    btnRead.hidden = YES;
    btnSpotCheck.hidden = YES;
    
    imgView.image = [UIImage imageNamed:@"User_Default"];
    lblName.text = [sessionDict valueForKey:@"player_name"];

    if ( IS_IPHONE_4 || IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_6plus)
    {
        lblSubjectDetails.frame = CGRectMake(0, 00, self.view.frame.size.width, 40);
        lblSubjectDetails.font = [UIFont fontWithName:CGRegular size:textSize-6];
        
        btnExportData.frame = CGRectMake(5, self.view.frame.size.height-40, 100, 35);
        btnExportData.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize-6];

        btnDone.frame = CGRectMake(self.view.frame.size.width-80, self.view.frame.size.height-40, 60, 35);
        btnDone.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize-6];

        viewFortxtFld.frame = CGRectMake(10, 15, DEVICE_HEIGHT-20, 40);
        int aa = viewFortxtFld.frame.size.width/4;
        
        txtPlayerName.frame = CGRectMake(0, 0, aa, 40);
        txtPlayerName.font = [UIFont fontWithName:CGRegular size:textSize-6];

        txtSensorTime.frame = CGRectMake(aa+5, 0, aa-5, 40);
        txtSensorTime.font = [UIFont fontWithName:CGRegular size:textSize-6];
        
        txtSensorType.frame = CGRectMake(aa*2+5, 0, aa-5, 40);
        txtSensorType.font = [UIFont fontWithName:CGRegular size:textSize-6];

        txtSensorNumber.frame = CGRectMake(aa*3+5, 0, aa-5, 40);
        txtSensorNumber.font = [UIFont fontWithName:CGRegular size:textSize-6];


    }
    
    [self SetupGraphView];
    [self gettingImg];

    [super viewDidLoad];
    
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
    [btnPrevious setImage:[UIImage imageNamed:@"arrowLeft.png"] forState:UIScrollViewDecelerationRateNormal];
    [graphBgView addSubview:btnPrevious];
    
    lblPreviousDate = [[UILabel alloc]initWithFrame:CGRectMake(wh*2-80, 0, wh+75, 50)];
    [self setLabelProperties:lblPreviousDate withText:@"04/02/2021 04:44 PM" backColor:LblBGcolor textColor:UIColor.blackColor textSize:textSize];
    lblPreviousDate.textAlignment = NSTextAlignmentCenter;
    [graphBgView addSubview:lblPreviousDate];
    
    lblNextDate = [[UILabel alloc]initWithFrame:CGRectMake(wh*3+10, 0, wh+75, 50)];
    [self setLabelProperties:lblNextDate withText:@"04/02/2021 04:54 PM" backColor:LblBGcolor textColor:UIColor.blackColor textSize:textSize];
    lblNextDate.textAlignment = NSTextAlignmentCenter;
    [graphBgView addSubview:lblNextDate];
    
    UIButton * btnNext = [[UIButton alloc]initWithFrame:CGRectMake(wh*4+(wh-50), 0, 50, 50)];
    [self setButtonProperties:btnNext withTitle:@"" backColor:btnBGColor textColor:UIColor.whiteColor txtSize:20];
    btnNext.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    [btnNext addTarget:self action:@selector(btnNextClick) forControlEvents:UIControlEventTouchUpInside];
    btnNext.layer.cornerRadius = 6;
    btnNext.titleLabel.numberOfLines = 0;
    [btnNext setImage:[UIImage imageNamed:@"rightArrow.png"] forState:UIScrollViewDecelerationRateNormal];
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
    
    if ( IS_IPHONE_4 || IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_6plus)
    {
        graphBgView.frame = CGRectMake(10, 60, self.view.frame.size.width-20, self.view.frame.size.height -105);
//        graphBgView.backgroundColor = UIColor.redColor;
        
        
        lblTrendGraph.frame = CGRectMake(5, 0,wh, 40);
        lblTrendGraph.font = [UIFont fontWithName:CGBold size:textSize-6];

        btnPrevious.frame = CGRectMake(wh+55, 0, 35, 35);
        
        lblPreviousDate.frame = CGRectMake(wh*2-20, 0, wh+75, 35);
        lblPreviousDate.font = [UIFont fontWithName:CGBold size:textSize-6];

        lblNextDate.frame = CGRectMake(graphBgView.frame.size.width-lblPreviousDate.frame.size.width-45, 0, wh+75, 35);
        lblNextDate.font = [UIFont fontWithName:CGBold size:textSize-6];
        
        btnNext.frame = CGRectMake(graphBgView.frame.size.width-40, 0, 35, 35);
        
        _chartView.frame = CGRectMake(0, 40, graphBgView.frame.size.width, graphBgView.frame.size.height-40);

        
        
    }
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
        for (int i=0; i<1; i++)
        {
         if (i == 0)
         {
             [csv appendFormat:@"Sensor ID , Sensor Type , Session ID , Temp , Timestamp ,\n"];
         }
            
        [csv appendFormat:@"%@,%@,%@,%@,%@\n", arrSensorId[i], arrSensor_type[i], arrSession_id[i], arrTemp[i],arrTimeStamp[i]];
        }
        [csv writeToFile:root atomically:YES encoding:NSUTF8StringEncoding error:NULL];

        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:root]] applicationActivities:nil];
        
        
        if ([activityController respondsToSelector:@selector(popoverPresentationController)] )
        {
            activityController.popoverPresentationController.sourceRect = CGRectMake(UIScreen.mainScreen.bounds.size.width / 2, UIScreen.mainScreen.bounds.size.height / 2, 00, 0);//
            activityController.popoverPresentationController.sourceView = self.view;
            activityController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
        }
    
        [self.navigationController presentViewController:activityController animated:YES completion:nil];

}
-(void)btnPreviousClick
{
    dataFetchSensorCount = 0;
    
    NSInteger readInterval = [[sessionDict valueForKey:@"read_interval"] integerValue];
    NSInteger tmpStartTime = 0, tmpEndTime = 0;
    NSInteger storedStart = startTime;
    tmpStartTime = startTime - ( readInterval * maxDataCount);
    tmpEndTime = storedStart;

    [self FetchSensorDataQuery:1 start:tmpStartTime end:tmpEndTime];
}
-(void)btnNextClick
{
    dataFetchSensorCount = 0;
    NSInteger readInterval = [[sessionDict valueForKey:@"read_interval"] integerValue];

    NSInteger tmpStartTime = 0, tmpEndTime = 0;
    
    tmpStartTime = endTime;
    tmpEndTime = tmpStartTime + ( readInterval * maxDataCount);

    [self FetchSensorDataQuery:2 start:tmpStartTime end:tmpEndTime];
}
-(void)FetchSensorDataQuery:(NSInteger)isAction start:(NSInteger)tmpStartTime end:(NSInteger)tmpEndTime
{
    BOOL isAllSensorAccessed = NO;
    if (dataFetchSensorCount == [arrSessionSensors count])
    {
        isAllSensorAccessed = YES;
        [self SendTemperatureReadingtoDetailVC:arrSessionGraphData];
    }
    else if([arrSessionSensors count] > dataFetchSensorCount)
    {
        isAllSensorAccessed = NO;
        
        NSString * strSensorid = [[arrSessionSensors objectAtIndex:dataFetchSensorCount]valueForKey:@"sensor_id"];
        NSString * strSensorType = [[arrSessionSensors objectAtIndex:dataFetchSensorCount]valueForKey:@"sensor_type"];

        NSMutableArray * arrData = [[NSMutableArray alloc] init];
        NSString * strQuery = [NSString stringWithFormat:@"select * from Session_data where session_id = '1' and sensor_id = '%@' and timeStamp >= %ld and timeStamp <= %ld limit %ld",strSensorid,(long)tmpStartTime,(long)tmpEndTime, (long)maxDataCount];
        [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:arrData];

        if ([arrData count] > 0)
        {
            [self SetDatetoValue:startTime withLabel:lblPreviousDate];
            [self SetDatetoValue:endTime withLabel:lblNextDate];
            
            startTime = tmpStartTime;
            endTime = tmpEndTime;
            
            NSMutableArray * arrGraph = [[NSMutableArray alloc] init];
            for (int i =0; i < [arrData count]; i++)
            {
                NSString * strTemp = [[arrData objectAtIndex:i] valueForKey:@"temp"];
                [arrGraph addObject:[[ChartDataEntry alloc] initWithX:i y:[strTemp doubleValue] ]];
                [arrTempValues addObject:[NSNumber numberWithDouble:[strTemp doubleValue] ]];

            }
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            [dict setObject:arrGraph forKey:@"data"];
            [dict setObject:strSensorid forKey:@"sensor_id"];
            [dict setObject:strSensorType forKey:@"sensor_type"];

            [dictStoredSessionData setObject:dict forKey:strSensorid];


        }

        dataFetchSensorCount = dataFetchSensorCount + 1;
        [self FetchSensorDataQuery:isAction start:tmpStartTime end:tmpEndTime];


    }
    
}
-(void)fetchSessionDatafromDatabase
{
}
#pragma mark : Set Temperature Data to graph
-(void)SendTemperatureReadingtoDetailVC:(NSMutableArray *)arrSensorData;
{
    double max1 = [[arrTempValues valueForKeyPath: @"@max.self"] doubleValue];
    double min1 = [[arrTempValues valueForKeyPath: @"@min.self"] doubleValue];

    _chartView.leftAxis.axisMaximum = max1 + 2.1;
    _chartView.leftAxis.axisMinimum = min1 - 2.1;
    
        NSArray * allDataKeys = [dictStoredSessionData allKeys];
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];

        for (int i =0; i < [allDataKeys count]; i++)
        {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            dict = [dictStoredSessionData valueForKey:[allDataKeys objectAtIndex:i]];
            
            NSString * strType = @"Ingestible";
            UIColor * colorSet = [UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f];
            UIColor * colorFill = UIColor.blueColor;
            if ([[dict valueForKey:@"sensor_type"] isEqualToString:@"4"])//3-Ingestible (Core), 4-Dermal (Skin)
            {
                strType = @"Dermal";
                colorSet = [UIColor redColor];
                colorFill = UIColor.greenColor;
            }
            
            NSMutableArray * arrData = [dict valueForKey:@"data"];
            
            LineChartDataSet * set12 = [[LineChartDataSet alloc] initWithEntries:arrData label:strType];
            set12.axisDependency = AxisDependencyLeft;
            [set12 setColor:colorSet];
            [set12 setCircleColor:UIColor.whiteColor];
            set12.lineWidth = 1.8;
            set12.circleRadius = 0.0;
            set12.fillColor = colorFill; //[UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f];
            set12.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
            set12.drawCircleHoleEnabled = NO;
            set12.valueTextColor = UIColor.whiteColor;
            set12.drawHorizontalHighlightIndicatorEnabled = NO;
            
            [dataSets addObject:set12];
        }
        LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
        [data setValueTextColor:UIColor.clearColor];
        [data setValueFont:[UIFont systemFontOfSize:9.f]];
        _chartView.data = data;
}
-(void)SetDatetoValue:(NSInteger )strDate withLabel:(UILabel *)lbl
{
    double timeStamp = strDate;
    NSTimeInterval unixTimeStamp = timeStamp ;
    NSDate *exactDate = [NSDate dateWithTimeIntervalSince1970:unixTimeStamp];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd/MM/yyy hh:mm a";
    NSString  *finalate = [dateFormatter stringFromDate:exactDate];
    lbl.text = finalate;

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
    
    if ( IS_IPHONE_4 || IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_6plus)
    {
        txtfld.font = [UIFont fontWithName:CGRegular size:14];
    }

}
-(void)setTemperoryData
{
    arrSessionGraphData = [[NSMutableArray alloc] init];
    NSString * strSession = [NSString stringWithFormat:@"select * from Session_data where session_id = '%@'",[sessionDict valueForKey:@"session_id"]];

    [[DataBaseManager dataBaseManager] execute:strSession resultsArray:arrSessionGraphData];

    NSString * strDelete = [NSString stringWithFormat:@"delete from Session_data"];
    [[DataBaseManager dataBaseManager] execute:strDelete];

    int finalDate = 1612437292;
    for (int i = 0; i < 20; i++)
    {
        for (int j = 0; j < 15; j++)
        {

            float tempValue = [[[arrSessionGraphData objectAtIndex:j] valueForKey:@"temp"] floatValue];
            float x = (arc4random()%10);
            float finalTemp = tempValue + (x/10);
            NSLog(@"Total Finla ==%f",finalTemp);

            finalDate = finalDate + 2;
            NSString * strDataQuery = [NSString stringWithFormat:@"insert into 'Session_data' ('session_id', 'temp', 'timestamp', 'sensor_type', 'sensor_id', 'packet') values(\"%@\",\"%f\",\"%d\",\"%@\",\"%@\",\"%@\")",@"1",finalTemp,finalDate,@"Ingestible",@"1b04",@"fc00010bb40bb20bb20bb00bb00bae00"];
                    [[DataBaseManager dataBaseManager] execute:strDataQuery];

        }
    }

     finalDate = 1612437292;
    for (int i = 0; i < 20; i++)
    {
        for (int j = 0; j < 18; j++)
        {

            float tempValue = [[[arrSessionGraphData objectAtIndex:j] valueForKey:@"temp"] floatValue];
            float x = (arc4random()%10);
            float finalTemp = tempValue + (x/10);
            NSLog(@"Total Finla ==%f",finalTemp);

            finalDate = finalDate + 2;
            NSString * strDataQuery = [NSString stringWithFormat:@"insert into 'Session_data' ('session_id', 'temp', 'timestamp', 'sensor_type', 'sensor_id', 'packet') values(\"%@\",\"%f\",\"%d\",\"%@\",\"%@\",\"%@\")",@"1",finalTemp,finalDate,@"Dermal",@"1b05",@"fc00010bb40bb20bb20bb00bb00bae00"];
                    [[DataBaseManager dataBaseManager] execute:strDataQuery];

        }
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
#pragma mark- Img Scalling
-(void)gettingImg
{
    if ([arrSessionSensors count] > 0)
    {
        if ([[APP_DELEGATE checkforValidString:[[arrSessionSensors objectAtIndex:0] valueForKey:@"photo_URL"]] isEqualToString:@"NA"])
        {
            imgView.image = [UIImage imageNamed:@"User_Default.png"];
        }
        else
        {
            NSString * filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"PlayerPhoto/%@", [[arrSessionSensors objectAtIndex:0] valueForKey:@"photo_URL"]]];
            NSData *pngData = [NSData dataWithContentsOfFile:filePath];
            UIImage * mainImage = [UIImage imageWithData:pngData];
            UIImage * image = [self scaleMyImage:mainImage];
            imgView.image = image;
        }

    }
//        arrSessionSensors
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

@end
