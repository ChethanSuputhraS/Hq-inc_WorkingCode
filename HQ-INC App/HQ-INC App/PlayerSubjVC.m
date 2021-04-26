//
//  PlayerSubjVC.m
//  HQ-INC App
//
//  Created by Ashwin on 3/26/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "PlayerSubjVC.h"
#import "PlayerSubjCELL.h"
#import "SubjDetailsVC.h"
#import "LinkingVC.h"
#import "SubjSetupVC.h"
#import "GlobalSettingVC.h"
#import "CollectionCustomCell.h"
#import "URLManager.h"
#import <MessageUI/MessageUI.h>


@interface PlayerSubjVC ()<UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate,UITextViewDelegate,URLManagerDelegate,MFMailComposeViewControllerDelegate,FCAlertViewDelegate>
{
    UILabel *lblName,*lblplayer,*lblcore,*lblType1;
    UITextField *txtName,*txtHash;
    UIView *listView,*gridView,*viewForOrderPiker;
    UIView *showPickerView,*showPickerforOrder;
    NSString *selectedFromPicker, *StrikePIker;
    UIButton * btnMenu,* btnGridView;
    BOOL isListClicked, isOneDataAvail, isGridSelected;
    UICollectionView *_collectionView;;
    UIImageView *imgViewListButton;
    UIPickerView *pikerViewTmpSelect,*pikerViewOderSelect;
    NSMutableArray * arrSubjects;
    NSMutableArray * arrayNotes;
    NSMutableDictionary * DictData;
    long selectedIndex,autoSelectedIndex;
    NSString *orderSelected;
    NSNumber *intTemp;
        float highIngstF, highIngstC,lowIngestF, lowIngestC, highDermalC,highDermalF,lowDermalF, lowDermalC;
    
}

@end

@implementation PlayerSubjVC

- (void)viewDidLoad
{
    [self setNeedsStatusBarAppearanceUpdate];
    isGridSelected = YES;
    
    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = UIColor.blackColor;
    
    navigViewTop = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 130)];
    navigViewTop.backgroundColor = UIColor.clearColor;
    [self.view addSubview:navigViewTop];
            
    UIColor * lbltxtclr = [UIColor colorWithRed:180.0/255 green:245.0/255 blue:254.0/255 alpha:1];
    lblPLayerSubject = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, DEVICE_WIDTH, 48)];
    [self setLabelProperties:lblPLayerSubject withText: @"Player / Subject" backColor:UIColor.clearColor textColor:lbltxtclr textSize:25];
    lblPLayerSubject.textAlignment = NSTextAlignmentCenter;
    [navigViewTop addSubview:lblPLayerSubject];
            
    UIColor *allBtnClor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    btnExportData = [[UIButton alloc]initWithFrame:CGRectMake(10, 28, 150, 44)];
    [self setButtonProperties:btnExportData withTitle:@"Export Data" backColor:allBtnClor textColor:UIColor.whiteColor txtSize:17];
    [btnExportData addTarget:self action:@selector(btnExportDataClick) forControlEvents:UIControlEventTouchUpInside];
    [navigViewTop addSubview:btnExportData];
            
    int yyBottom = 76;
    btnGlobalRead = [[UIButton alloc]initWithFrame:CGRectMake(10, yyBottom, 150, 44)];
    [self setButtonProperties:btnGlobalRead withTitle:@"Global Read"  backColor:allBtnClor textColor:UIColor.whiteColor txtSize:17];
    [btnGlobalRead addTarget:self action:@selector(btnGlobalReadClick) forControlEvents:UIControlEventTouchUpInside];
    [navigViewTop addSubview:btnGlobalRead];
             
    btnNotes = [[UIButton alloc]initWithFrame:CGRectMake(170, yyBottom, 70, 44)];
    [self setButtonProperties:btnNotes withTitle:@"Notes" backColor:allBtnClor textColor:UIColor.whiteColor txtSize:17];
    [btnNotes addTarget:self action:@selector(btnNotesClick) forControlEvents:UIControlEventTouchUpInside];
//    btnNotes.frame = CGRectMake(170, yyBottom, 18, 4.85);
//    btnNotes.layer.cornerRadius = 2;
//    btnNotes.layer.masksToBounds = YES;
    [navigViewTop addSubview:btnNotes];
                
    lblFilter = [[UILabel alloc]initWithFrame:CGRectMake(260, yyBottom, 90, 44)];
    [self setLabelProperties:lblFilter withText:@"Filter:" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:17];
    [navigViewTop addSubview:lblFilter];
    
    btnSelect = [[UIButton alloc]initWithFrame:CGRectMake(305, yyBottom, 150, 44)];
    [self setButtonProperties:btnSelect withTitle:@"Select" backColor:allBtnClor textColor:UIColor.whiteColor txtSize:17];
    [btnSelect addTarget:self action:@selector(btnSelectClick) forControlEvents:UIControlEventTouchUpInside];
    [navigViewTop addSubview:btnSelect];

    lblOrder = [[UILabel alloc]initWithFrame:CGRectMake(475, yyBottom, 90, 44)];
    [self setLabelProperties:lblOrder withText:@"Order" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:17];
    [navigViewTop addSubview:lblOrder];
    
    btnOrder = [[UIButton alloc]initWithFrame:CGRectMake(525, yyBottom, 50, 40)];
    [self setButtonProperties:btnOrder withTitle:@"" backColor:allBtnClor textColor:UIColor.clearColor txtSize:17];
    UIImage *btnOrimg = [UIImage imageNamed:@"DownArrow.png.png"];
    [btnOrder setImage:btnOrimg forState:normal];
    [btnOrder addTarget:self action:@selector(btnOrderClick) forControlEvents: UIControlEventTouchUpInside];
    [navigViewTop addSubview:btnOrder];

    lblOutSideTmp = [[UILabel alloc]initWithFrame:CGRectMake(navigViewTop.frame.size.width-300, 45, 200, 30)];
    [self setLabelProperties:lblOutSideTmp withText:@"Outside Temp / Humidity :" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:15];
    lblOutSideTmp.textAlignment = NSTextAlignmentRight;
    [navigViewTop addSubview:lblOutSideTmp];
    
    lblOutSidTem = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-105, 45, 60, 30)];
    [self setLabelProperties:lblOutSidTem withText:@"22ºC /" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:15];
    lblOutSidTem.textAlignment = NSTextAlignmentRight;
    [navigViewTop addSubview:lblOutSidTem];
    
    lblOutSidHumid = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-62, 45, 60, 30)];
    [self setLabelProperties:lblOutSidHumid withText:@"76%" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:15];
    lblOutSidHumid.textAlignment = NSTextAlignmentRight;
    [navigViewTop addSubview:lblOutSidHumid];
           
    int aa = navigViewTop.frame.size.width-btnSelect.frame.size.width-btnOrder.frame.size.width+20;
    UIButton * btnLink = [[UIButton alloc]initWithFrame:CGRectMake(aa, yyBottom, 50, 50)];
    [self setButtonProperties:btnLink withTitle:@"" backColor:UIColor.clearColor textColor:UIColor.clearColor txtSize:20];
    [btnLink addTarget:self action:@selector(btnLinkClick) forControlEvents:UIControlEventTouchUpInside];
    UIImage *btnimg = [UIImage imageNamed:@"linked.png"];
    [btnLink setImage:btnimg forState:normal];
    [navigViewTop addSubview:btnLink];
    
    btnlistView = [[UIButton alloc]initWithFrame:CGRectMake(aa+103, yyBottom, 35, 50)];
    btnlistView.backgroundColor = UIColor.clearColor;
    [btnlistView addTarget:self action:@selector(btnlistViewClick) forControlEvents:UIControlEventTouchUpInside];
    [btnlistView setImage:[UIImage imageNamed:@"List.png"] forState:normal];
    [navigViewTop addSubview:btnlistView];
        
    btnGridView = [[UIButton alloc]initWithFrame:CGRectMake(aa+140, yyBottom, 35, 50)];
    btnGridView.backgroundColor = UIColor.clearColor;
    [btnGridView addTarget:self action:@selector(btnGridClick) forControlEvents:UIControlEventTouchUpInside];
    [btnGridView setImage:[UIImage imageNamed:@"GridSelected.png"] forState:normal];
    [navigViewTop addSubview:btnGridView];
    
    gridView = [[UIView alloc]init];
    gridView.frame =CGRectMake(0, 130, DEVICE_WIDTH, DEVICE_HEIGHT-130);
    gridView.backgroundColor = UIColor.blackColor;
    gridView.hidden = false;
    [self.view addSubview:gridView];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
       _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-130) collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];

    [_collectionView registerClass:[CollectionCustomCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
     _collectionView.hidden = false;
    [gridView addSubview:_collectionView];
    
    listView = [[UIView alloc]init];
    listView.frame =CGRectMake(0, 130, DEVICE_WIDTH-0, DEVICE_HEIGHT-130);
    listView.backgroundColor = UIColor.blackColor;
    listView.hidden = true;
    [self.view addSubview:listView];

    tblPlayerList = [[UITableView alloc]init];
    tblPlayerList.frame = CGRectMake(0, 0, listView.frame.size.width, listView.frame.size.height);
    tblPlayerList.backgroundColor = UIColor.clearColor;
    tblPlayerList.delegate = self;
    tblPlayerList.dataSource = self;
    tblPlayerList.separatorStyle = UITableViewCellSeparatorStyleNone;
    [listView addSubview:tblPlayerList];
    
    arrayPlayers = [[NSMutableArray alloc] init];
    arrayPiker = [[NSMutableArray alloc]initWithObjects:@"Core Temp",@"Skin Temp",@"Last Name",@"Subject#", nil];
    arrayPickerOrderBy =[[NSMutableArray alloc]initWithObjects:@"Name",@"Number",@"Tempareture", nil];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
    initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.2; //seconds
    lpgr.delegate = self;
    [tblPlayerList addGestureRecognizer:lpgr];
    
    UILongPressGestureRecognizer *longPCollection = [[UILongPressGestureRecognizer alloc]
    initWithTarget:self action:@selector(handleLongPress1:)];
    longPCollection.minimumPressDuration = 1.2; //seconds
    longPCollection.delegate = self;
    [_collectionView addGestureRecognizer:longPCollection];


    
    [_collectionView reloadData];
    [tblPlayerList reloadData];
    [super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self SetupForViewWillApeear];
    [_collectionView reloadData];
    [tblPlayerList reloadData];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(void)SetupForViewWillApeear
{
    arrSubjects = [[NSMutableArray alloc] init];
    NSString * sqlquery = [NSString stringWithFormat:@"select * from Subject_Table"];
    [[DataBaseManager dataBaseManager] execute:sqlquery resultsArray:arrSubjects]; // from database data
    NSLog(@"=======Subject Array======%@",arrSubjects);

    for (int i=0; i<arrSubjects.count; i++)
    {
        if (![[[arrSubjects objectAtIndex:i] valueForKey:@"photo_URLThumbNail"] isEqual:@"nil"])
        {
            
        NSString * filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"PlayerPhoto/%@",[[arrSubjects objectAtIndex:i] valueForKey:@"photo_URL"]]];
        NSData *pngData = [NSData dataWithContentsOfFile:filePath];
        UIImage * mainImage = [UIImage imageWithData:pngData];
        UIImage * imgCollect = [self scaleMyImage:mainImage withNewWidth:800 newHeight:800];
        UIImage * imgTable = [self scaleMyImage:mainImage withNewWidth:300 newHeight:300];
        
    
            [[arrSubjects objectAtIndex:i] setObject:imgCollect forKey:@"profileImageCollection"];
            [[arrSubjects objectAtIndex:i] setObject:imgTable forKey:@"profileImageTable"];
        }
    
        NSNumber * intnum = [NSNumber numberWithInt:[[[arrSubjects objectAtIndex:i] valueForKey:@"number"] intValue]];
        [[arrSubjects objectAtIndex:i] setObject:intnum forKey:@"IntNumber"];
        
        intTemp = [NSNumber numberWithFloat:[[[arrSubjects objectAtIndex:i] valueForKey:@"ing_highF"] floatValue]];
        [[arrSubjects objectAtIndex:i] setObject:intTemp forKey:@"IntTemptur"];

    }
    
    [self DataFromnDatabase];
//    [self getOutSideTempAndHumidity];
}
#pragma mark - Collection Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
        return arrSubjects.count+1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionCustomCell *cell=[collectionView  dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    cell.backgroundColor=[UIColor whiteColor];
    
    
      CGFloat vWidth = (DEVICE_WIDTH/3)-10;
      CGFloat vHeight = vWidth + 20;
    
    if (arrSubjects.count > indexPath.row)
    {
        cell.imgViewpProfile.frame = CGRectMake(0, 0,vWidth-0, vHeight  - 50);
        cell.imgViewpProfile.contentMode = UIViewContentModeScaleAspectFill;
        cell.imgViewpProfile.layer.masksToBounds = YES;
        cell.lblTransView.hidden = NO;
        cell.lblName.text = [[arrSubjects objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.lblNo.text = [[arrSubjects objectAtIndex:indexPath.row] objectForKey:@"number"];
        NSString * strHigtmp = [[arrSubjects objectAtIndex:indexPath.row] objectForKey:@"drml_highF"];
        int intConv = [[NSString stringWithFormat:@"%@0.2f",strHigtmp] intValue];
        
        NSString * strHigCore = [[arrSubjects objectAtIndex:indexPath.row] objectForKey:@"ing_highF"];
               int intConvCore = [[NSString stringWithFormat:@"%@",strHigCore] intValue];
        
        cell.lblCoreTmp.text = [NSString stringWithFormat:@"%dºF\nSkin",intConv];
        cell.lblType1Tmp.text = [NSString stringWithFormat:@"%dºF\nCore",intConvCore];//ºF\nSkin Temp

        UIImage * imgProf = [[arrSubjects objectAtIndex:indexPath.row] objectForKey:@"profileImageCollection"];
        
        if (imgProf != nil)
        {
            cell.imgViewpProfile.image = imgProf;
        }
        else
        {
            cell.imgViewpProfile.image = imgProf;//Here Default Profile Photo will disply
        }
        
        int ii ;
        ii = cell.lblCoreTmp.text.intValue;
           
        if (ii<=99 && ii>96)
        {
            cell.lblTransView.backgroundColor = [UIColor colorWithRed:23.0/255.0f green:90.0/255.0f blue:255.0/255.0f alpha:0.8];
            cell.lblCoreTmp.textColor = UIColor.whiteColor;
            cell.lblType1Tmp.textColor = UIColor.whiteColor;
            cell.lblName.backgroundColor = [UIColor colorWithRed:23.0/255.0f green:90.0/255.0f blue:255.0/255.0f alpha:1];
            cell.lblNo.backgroundColor =  [UIColor colorWithRed:23.0/255.0f green:90.0/255.0f blue:255.0/255.0f alpha:1];
            cell.lblNo.layer.borderWidth = 1;
            cell.lblName.layer.borderWidth = 1;
            cell.lblCoreTmp.hidden = false;
            cell.lblType1Tmp.hidden = false;
        }
        else if (ii >= 100)
        {
            cell.lblTransView.backgroundColor = [UIColor colorWithRed:242.0/255.0f green:12.0/255.0f blue:27.0/255.0f alpha:0.8];
            cell.lblCoreTmp.textColor = UIColor.whiteColor;
            cell.lblType1Tmp.textColor = UIColor.whiteColor;
            cell.lblName.backgroundColor = [UIColor colorWithRed:242.0/255.0f green:12.0/255.0f blue:27.0/255.0f alpha:1];
            cell.lblNo.backgroundColor = [UIColor colorWithRed:242.0/255.0f green:12.0/255.0f blue:27.0/255.0f alpha:1];
            cell.lblNo.layer.borderWidth = 1;
            cell.lblName.layer.borderWidth = 1;
            cell.lblCoreTmp.hidden = false;
            cell.lblType1Tmp.hidden = false;
        }
        else
        {
            cell.lblCoreTmp.hidden = false;
            cell.lblType1Tmp.hidden = false;
        }
    }
    else
    {
        cell.imgViewpProfile.frame = CGRectMake((vWidth - 72)/2, ((vHeight-50)-118)/2, 72, 118);
        cell.imgViewpProfile.image = [UIImage imageNamed:@"add.png"];
        cell.lblTransView.hidden = YES;
        cell.lblName.text = @"Name";
        cell.lblNo.text = @"#";
        cell.lblName.backgroundColor = UIColor.blackColor;
        cell.lblNo.backgroundColor = UIColor.darkGrayColor;
        cell.lblTransView.hidden = true;
        cell.lblCoreTmp.hidden = true;
        cell.lblType1Tmp.hidden = true;
    }
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat vWidth = (DEVICE_WIDTH/3)-10;
    return CGSizeMake(vWidth, vWidth + 20);
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    //        [self InsertRecordTbleData];
    if (arrSubjects.count > indexPath.row)
    {
        globalSubjectDetailVC = [[SubjDetailsVC alloc]init];
        globalSubjectDetailVC.dataDict = [arrSubjects objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:globalSubjectDetailVC animated:true];
    }
    else
    {
        globalSbuSetupVC = [[SubjSetupVC alloc]init];
        globalSbuSetupVC.isFromEdit = NO;
        [self.navigationController pushViewController:globalSbuSetupVC animated:true];
    }
    
    NSLog(@"selected index=%ld %ld", (long)indexPath.item, (long)indexPath.row);
}
#pragma mark - Tableview Methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrSubjects.count+1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellP = @"CellProfile";
    PlayerSubjCELL *cell = [tableView dequeueReusableCellWithIdentifier:cellP];
    cell = [[PlayerSubjCELL alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellP];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.lblName.text = @"---";
    cell.lblPlayer.text = @"---";
    cell.lblCoreTmp.text = @"---";
    cell.lblType1Tmp.text = @"---";
    
    if (arrSubjects.count > indexPath.row)
    {
        cell.lblName.text = [[arrSubjects objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.lblPlayer.text = [[arrSubjects objectAtIndex:indexPath.row] objectForKey:@"number"];
        NSString * strHigtmp = [[arrSubjects objectAtIndex:indexPath.row] objectForKey:@"drml_highF"];
        int intConv = [[NSString stringWithFormat:@"%@0.2f",strHigtmp] intValue];
        
        NSString * strHigCore = [[arrSubjects objectAtIndex:indexPath.row] objectForKey:@"ing_highF"];
               int intConvCore = [[NSString stringWithFormat:@"%@",strHigCore] intValue];
        
        cell.lblCoreTmp.text = [NSString stringWithFormat:@"%dºF\nSkin",intConv];
        cell.lblType1Tmp.text = [NSString stringWithFormat:@"%dºF\nCore",intConvCore];//ºF\nSkin Temp
        
        cell.imgViewpProfile.frame = CGRectMake(40, 5, 70, 70);
        cell.imgViewpProfile.contentMode = UIViewContentModeScaleAspectFill;
        cell.imgViewpProfile.layer.masksToBounds = YES;

        UIImage * imgProf = [[arrSubjects objectAtIndex:indexPath.row] objectForKey:@"profileImageTable"];
        if (imgProf != nil)
        {
            cell.imgViewpProfile.image = imgProf;
        }
        else
        {
            cell.imgViewpProfile.image = imgProf;//Here Default Profile Photo will disply
        }
    }
    else
    {
        cell.imgViewpProfile.image = [UIImage imageNamed:@"add.png"];
        cell.imgViewpProfile.frame = CGRectMake(49, 5, 45, 70);
    }
    
    if (indexPath.row % 2)
       {
           cell.backgroundColor = [UIColor colorWithRed:230.0/255.0f green:230.0/255.0f blue:230.0/255.0f alpha:1];
       }
       else
       {
           cell.backgroundColor = UIColor.whiteColor;
       }
    // above code css commeted
    cell.lblLine.frame = CGRectMake(0, 79, self.view.frame.size.width, 1);
    int i ;
    i =  cell.lblCoreTmp.text.intValue;
    
     if (i<=99 && i>96)
    {
        cell.backgroundColor = [UIColor blueColor];
        cell.lblName.textColor = UIColor.whiteColor;
        cell.lblPlayer.textColor = UIColor.whiteColor;
        cell.lblCoreTmp.textColor = UIColor.whiteColor;
        cell.lblType1Tmp.textColor = UIColor.whiteColor;
        cell.lblLine.hidden = false;
    }
    else if (i >= 100)
    {
        cell.backgroundColor = [UIColor redColor];
        cell.lblName.textColor = UIColor.whiteColor;
        cell.lblPlayer.textColor = UIColor.whiteColor;
        cell.lblCoreTmp.textColor = UIColor.whiteColor;
        cell.lblType1Tmp.textColor = UIColor.whiteColor;
        cell.lblLine.hidden = false;
    }
    else
    {
        cell.backgroundColor = UIColor.whiteColor;
        cell.lblName.textColor = UIColor.blackColor;
        cell.lblPlayer.textColor = UIColor.blackColor;
        cell.lblCoreTmp.textColor = UIColor.blackColor;
        cell.lblType1Tmp.textColor = UIColor.blackColor;
        cell.lblLine.hidden = false;
    }
    
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (arrSubjects.count > indexPath.row)
       {
           globalSubjectDetailVC = [[SubjDetailsVC alloc]init];
           globalSubjectDetailVC.dataDict = [arrSubjects objectAtIndex:indexPath.row];
           [self.navigationController pushViewController:globalSubjectDetailVC animated:true];
       }
       else
       {
           globalSbuSetupVC = [[SubjSetupVC alloc]init];
           globalSbuSetupVC.isFromEdit = NO;
           [self.navigationController pushViewController:globalSbuSetupVC animated:true];
       }
}
 -(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView*viewHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tblPlayerList.frame.size.width, 50)];
    viewHeader.backgroundColor = [UIColor colorWithRed:77.0/255 green:(CGFloat)77.0/255 blue:77.0/255 alpha:1];
    
    UILabel *lblName= [[UILabel alloc] initWithFrame:CGRectMake(100, 0, (DEVICE_WIDTH-70)/4, 50)];
    [self setLabelProperties:lblName withText: @"Name" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:25];
    lblName.textAlignment = NSTextAlignmentCenter;
    [viewHeader addSubview:lblName];
    
    UILabel *lblPlayerH = [[UILabel alloc]initWithFrame:CGRectMake((DEVICE_WIDTH-70)/4*2-80, 0, (DEVICE_WIDTH-70)/4, 50)];
    [self setLabelProperties:lblPlayerH withText:@"Player #" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:25];
    lblPlayerH.textAlignment = NSTextAlignmentCenter;
    [viewHeader addSubview:lblPlayerH];
       
    UILabel *lblCoreTmp = [[UILabel alloc]initWithFrame:CGRectMake((DEVICE_WIDTH-70)/4*3-80, 0, (DEVICE_WIDTH-70)/4, 50)];
    [self setLabelProperties:lblCoreTmp withText:@"Core Temp" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:25];
    lblCoreTmp.textAlignment = NSTextAlignmentCenter;
    [viewHeader addSubview:lblCoreTmp];
    
    UILabel *lblType1Tmp = [[UILabel alloc]initWithFrame:CGRectMake((DEVICE_WIDTH-70)/4*4-110, 0,(DEVICE_WIDTH-70)/4, 50)];
    [self setLabelProperties:lblType1Tmp withText:@"Skin Temp" backColor:UIColor.clearColor textColor:UIColor.whiteColor textSize:25];
    lblType1Tmp.textAlignment = NSTextAlignmentCenter;
    [viewHeader addSubview:lblType1Tmp];

    return viewHeader;
    }
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}
#pragma mark- Img Scalling
-(UIImage *)scaleMyImage:(UIImage *)newImg withNewWidth:(double)newWidth newHeight:(double)newHeight
{
    double originalW = newImg.size.width;
    double originalH = newImg.size.height;
    double updateH = (newHeight * originalH)/ originalW;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth,updateH));
    [newImg drawInRect: CGRectMake(0, 0, newWidth, updateH)];
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

#pragma mark - Buttons NavigView
-(void)btnGridClick
{
     if (isGridSelected == true)
    {
        isGridSelected = true;
        btnGridView.enabled = true;
        [btnlistView setImage:[UIImage imageNamed:@"List.png"] forState:UIControlStateNormal];
        [btnGridView setImage:[UIImage imageNamed:@"GridSelected.png"] forState:UIControlStateNormal];
        gridView.hidden = false;
        listView.hidden = true;
    }
    else if (isGridSelected == true)
    {
        isGridSelected = false;
        btnGridView.enabled = false;
        [btnlistView setImage:[UIImage imageNamed:@"ListSelected.png"] forState:UIControlStateNormal];
        [btnGridView setImage:[UIImage imageNamed:@"Grid.png"] forState:UIControlStateNormal];
        gridView.hidden = true;
        listView.hidden = false;
    }
}
-(void)btnlistViewClick
{
    btnGridView.enabled = true;
    [btnGridView setImage:[UIImage imageNamed:@"Grid.png"] forState:UIControlStateNormal];
    [btnlistView setImage:[UIImage imageNamed:@"ListSelected.png"] forState:UIControlStateNormal];
    gridView.hidden = true;
    listView.hidden = false;
}
-(void)btnLinkClick
{
    UIViewController *SubjPlyLinkVc = [[LinkingVC alloc]init];
    [self.navigationController pushViewController:SubjPlyLinkVc animated:true];
}
-(void)btnNotesClick
{
    [self setUpForNotesButton];
}
-(void)btnSelectClick
{
//    [viewForPiker removeFromSuperview];
    viewForPiker = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    viewForPiker.backgroundColor = [UIColor colorWithRed:0 green:(CGFloat)0 blue:0 alpha:0.9];
    [self.view addSubview:viewForPiker];

    showPickerView  = [[UIView alloc]initWithFrame:CGRectMake(150, DEVICE_HEIGHT, DEVICE_WIDTH-300, 400)];
    showPickerView.backgroundColor = UIColor.whiteColor;
    showPickerView.layer.cornerRadius = 6;
    showPickerView.clipsToBounds = true;
    [viewForPiker addSubview:showPickerView];
    
    UIView * bgView = [[UIView alloc]init];
    bgView.frame  = CGRectMake(0, 0, showPickerView.frame.size.width, 70);
    bgView.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    [showPickerView addSubview:bgView];
        
    UILabel * lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, showPickerView.frame.size.width , 70)];
    lblHeader.text = @"Fliter by";
    lblHeader.textColor = UIColor.whiteColor;
    lblHeader.textAlignment = NSTextAlignmentCenter;
    lblHeader.font = [UIFont fontWithName:CGRegular size:30];
    [bgView addSubview:lblHeader];
    
    UIButton *btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 70)];
    [self setButtonProperties:btnCancel withTitle:@"Cancel" backColor:UIColor.clearColor textColor:UIColor.whiteColor txtSize:25];
    [btnCancel addTarget:self action:@selector(btnCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:btnCancel];
        
    UIButton *btnDone = [[UIButton alloc]initWithFrame:CGRectMake(showPickerView.frame.size.width-100, 0, 100, 70)];
    [self setButtonProperties:btnDone withTitle:@"Done" backColor:UIColor.clearColor textColor:UIColor.whiteColor txtSize:25];
    [btnDone addTarget:self action:@selector(btnDoneClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:btnDone];
        
    pikerViewTmpSelect = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 75, showPickerView.frame.size.width, 300)];
    pikerViewTmpSelect.delegate = self;
    pikerViewTmpSelect.dataSource = self;
    pikerViewTmpSelect.backgroundColor = UIColor.whiteColor;
    NSInteger indexSelctTemp = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectIndexTempr"];
    [pikerViewTmpSelect selectRow:indexSelctTemp inComponent:0 animated:YES];
    [showPickerView addSubview:pikerViewTmpSelect];

      [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
         {
         self-> showPickerView.frame = CGRectMake(150, (DEVICE_HEIGHT-400)/2, DEVICE_WIDTH-300, 400);
         }
         completion:(^(BOOL finished)
         {
        })];
}
-(void)btnGlobalReadClick
{
    globalSettingClassVC = [[GlobalSettingVC alloc]init];
    [self.navigationController pushViewController:globalSettingClassVC animated:true];
}
-(void)btnOrderClick
{
    [self setupforPickerOrder];
}
-(void)btnExportDataClick
{
    if (arrSubjects.count == 0)
    {
        [self AlertViewFCTypeCaution:@"No data available."];
    }
    else if (arrSubjects > 0 )
    {
        [self exportCSV];
    }
}
-(void)exportCSV
{
    NSArray *Name = [arrSubjects valueForKey:@"name"];
    NSArray *Number = [arrSubjects valueForKey:@"number"];
    NSArray *high_Ingest = [arrSubjects valueForKey:@"ing_highF"];
    NSArray *low_Ingest = [arrSubjects valueForKey:@"ing_lowF"];
    NSArray *high_drml = [arrSubjects valueForKey:@"drml_highF"];
    NSArray *low_drml = [arrSubjects valueForKey:@"drml_lowF"];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *root = [documentsDir stringByAppendingPathComponent:@"PlayerData.csv"];
    
    NSMutableString *csv = [[NSMutableString alloc] initWithCapacity:0];
    for (int i=0; i<[arrSubjects count]; i++)
    {
     if (i == 0)
     {
         [csv appendFormat:@"Name , Number , High_ingest , Low_Ingest , high_dermal , Low_dermal \n"];
     }
    [csv appendFormat:@"%@,%@,%@,%@,%@,%@\n", Name[i], Number[i], high_Ingest[i], low_Ingest[i],high_drml[i],low_drml[i]];
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
            NSData *noteData = [NSData dataWithContentsOfFile:root];
            [mc addAttachmentData:noteData mimeType:@"csv" fileName:@"PlayerData.csv"];
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
//MARK: piker view
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == pikerViewTmpSelect)
    {
        return arrayPiker.count;
    }
    else if (pickerView == pikerViewOderSelect)
    {
        return arrayPickerOrderBy.count;
    }
    return true;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == pikerViewTmpSelect)
       {
    return [arrayPiker objectAtIndex:row];
       }
    else if (pickerView == pikerViewOderSelect)
       {
    return [arrayPickerOrderBy objectAtIndex:row];
       }
    return 0;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == pikerViewTmpSelect)
    {
        selectedFromPicker = [arrayPiker objectAtIndex:row];
    }
    else if (pickerView == pikerViewOderSelect)
    {
        orderSelected = [arrayPickerOrderBy objectAtIndex:row];
    }
}
#pragma mark- button Picker Select
-(void)btnDoneClick
{
    if ([selectedFromPicker isEqual:@""])
    {
        [btnSelect setTitle:@"Select" forState:UIControlStateNormal];
    }
    else if ([selectedFromPicker isEqual:selectedFromPicker])
    {
        [btnSelect setTitle:selectedFromPicker forState:UIControlStateNormal];
    }
    // after slected by
    // [tblPlayerList reloadData];
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         self-> showPickerView.frame = CGRectMake(150, DEVICE_HEIGHT, DEVICE_WIDTH-300, 400);
     }
                    completion:(^(BOOL finished)
    {
        [self-> viewForPiker removeFromSuperview];
    })];
    [self selctedIndexTemparature:selectedFromPicker];
}
-(void)selctedIndexTemparature:(NSString *)strTempSelect
{
    if ([strTempSelect isEqual:@"Core Temp"])
    {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"selectIndexTempr"];
    }
    else if ([strTempSelect isEqual:@"Skin Temp"])
    {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"selectIndexTempr"];
    }
    else if ([strTempSelect isEqual:@"Last Name"])
    {
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"selectIndexTempr"];
    }
    else if ([strTempSelect isEqual:@"Subject#"])
    {
        [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"selectIndexTempr"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_collectionView reloadData];
    [tblPlayerList reloadData];
}
-(void)btnCancelClick
{
       [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         self-> showPickerView.frame = CGRectMake(150, DEVICE_HEIGHT, DEVICE_WIDTH-300, 400);
     }
                    completion:(^(BOOL finished)
    {
        [self-> viewForPiker removeFromSuperview];
    })];
}

#pragma mark- long Press
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self->tblPlayerList];
    CGPoint pc = [gestureRecognizer locationInView:self->_collectionView];
    
    NSIndexPath *indexPath = [self->tblPlayerList indexPathForRowAtPoint:p];
    NSIndexPath * indexP = [self -> _collectionView indexPathForItemAtPoint:pc];
    
    NSLog(@"lindex path----->%ld", (long)indexPath.row);
    NSLog(@"lindex path CollectionView----->%ld", (long)indexP.row);

    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if (arrSubjects.count > indexPath.row)
        {
            //show popup to delete here ...
            NSString  * strName = [[arrSubjects objectAtIndex:indexPath.row] valueForKey:@"name"];
            NSString * strMsg = [NSString stringWithFormat:@"Are you sure, you want to delete  Player %@ ?",strName];
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeWarning];
            [alert addButton:@"Delete" withActionBlock:
             ^{
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeSuccess];
                [alert showAlertInView:self
                             withTitle:@"HQ-Inc App"
                          withSubtitle:[NSString stringWithFormat:@"%@ Deleted Successfully ",strName]
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
                if (self->arrSubjects.count > 0)
                {
                    NSString * strDelete = [NSString stringWithFormat:@"Delete from Subject_Table where id = '%@'",[[self->arrSubjects objectAtIndex:indexPath.row] valueForKey:@"id"]];
                    [[DataBaseManager dataBaseManager] execute:strDelete];
                    [self->arrSubjects removeObjectAtIndex:indexPath.row];
                    [self->tblPlayerList reloadData];
                    [self -> _collectionView reloadData];
                }
            }];
            [alert showAlertInView:self
                         withTitle:@"HQ-Inc App"
                      withSubtitle:strMsg
                   withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
               withDoneButtonTitle:@"Cancel" andButtons:nil];
        }
    }
}
-(void)handleLongPress1:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint pc = [gestureRecognizer locationInView:self->_collectionView];
    NSIndexPath * indexP = [self -> _collectionView indexPathForItemAtPoint:pc];
    NSLog(@"lindex path CollectionView----->%ld", (long)indexP.row);

    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if (arrSubjects.count > indexP.row)
        {
                    //show popup to delete here ...
            NSString  * strName = [[arrSubjects objectAtIndex:indexP.row] valueForKey:@"name"];
            NSString * strMsg = [NSString stringWithFormat:@"Are you sure, you want to delete  Player %@ ?",strName];
            
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeWarning];
            [alert addButton:@"Delete" withActionBlock:
                     ^{
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeSuccess];
                [alert showAlertInView:self
                             withTitle:@"HQ-Inc App"
                          withSubtitle:[NSString stringWithFormat:@"%@ Deleted Successfully ",strName]
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
                if (self->arrSubjects.count > 0)
                {
                    NSString * strDelete = [NSString stringWithFormat:@"Delete from Subject_Table where id = '%@'",[[self->arrSubjects objectAtIndex:indexP.row] valueForKey:@"id"]];
                    [[DataBaseManager dataBaseManager] execute:strDelete];
                    [self->arrSubjects removeObjectAtIndex:indexP.row];
                    [self->tblPlayerList reloadData];
                    [self -> _collectionView reloadData];
                      }
                }];
            [alert showAlertInView:self
                         withTitle:@"HQ-Inc App"
                      withSubtitle:strMsg
                   withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
               withDoneButtonTitle:@"Cancel" andButtons:nil];
        }
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}
-(void)setupforPickerOrder
{
    [viewForOrderPiker removeFromSuperview];
    viewForOrderPiker = [[UIView alloc]init];
    viewForOrderPiker.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    viewForOrderPiker.backgroundColor = [UIColor colorWithRed:0 green:(CGFloat)0 blue:0 alpha:0.9];
    [self.view addSubview:viewForOrderPiker];
     
    showPickerforOrder  = [[UIView alloc]init];
    showPickerforOrder.frame = CGRectMake(200, DEVICE_HEIGHT, DEVICE_WIDTH-400, 400);
    showPickerforOrder.backgroundColor = UIColor.whiteColor;
    showPickerforOrder.layer.cornerRadius = 6;
    showPickerforOrder.clipsToBounds = true;
    [viewForOrderPiker addSubview:showPickerforOrder];

    UIView * bgViewOrder = [[UIView alloc]init];
    bgViewOrder.frame  = CGRectMake(0, 0, showPickerforOrder.frame.size.width, 70);
    bgViewOrder.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    [showPickerforOrder addSubview:bgViewOrder];
    
    
    UILabel * lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, showPickerforOrder.frame.size.width , 70)];
    lblHeader.text = @"Order by";
    lblHeader.textColor = UIColor.whiteColor;
    lblHeader.textAlignment = NSTextAlignmentCenter;
    lblHeader.font = [UIFont fontWithName:CGRegular size:30];
    [bgViewOrder addSubview:lblHeader];
    
    UIButton *btnOrderCancel = [[UIButton alloc]init];
    btnOrderCancel.frame = CGRectMake(0, 0, 100, 70);
    [btnOrderCancel addTarget:self action:@selector(btnOrderCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [btnOrderCancel setTitle:@"Cancel" forState:normal];
    [btnOrderCancel setTitleColor:UIColor.blackColor forState:normal];
    btnOrderCancel.layer.cornerRadius = 12;
    [btnOrderCancel setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnOrderCancel.backgroundColor = UIColor.clearColor;
    btnOrderCancel.titleLabel.font = [UIFont fontWithName:CGRegular size:25];
    [bgViewOrder addSubview:btnOrderCancel];
           
    UIButton *btnOrderDone = [[UIButton alloc]init];
    btnOrderDone.frame = CGRectMake(showPickerforOrder.frame.size.width-100, 0, 100, 70);
    [btnOrderDone addTarget:self action:@selector(btnOrderDoneClick) forControlEvents:UIControlEventTouchUpInside];
    [btnOrderDone setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnOrderDone.backgroundColor = UIColor.clearColor;
    [btnOrderDone setTitle:@"Done" forState:normal];
    btnOrderDone.titleLabel.font = [UIFont fontWithName:CGRegular size:25];
    [bgViewOrder addSubview:btnOrderDone];
    
    pikerViewOderSelect = [[UIPickerView alloc]init];
    pikerViewOderSelect.frame = CGRectMake(0, 75, showPickerforOrder.frame.size.width, 250);
    pikerViewOderSelect.delegate = self;
    pikerViewOderSelect.dataSource = self;
    pikerViewOderSelect.backgroundColor = UIColor.whiteColor;
    [showPickerforOrder addSubview:pikerViewOderSelect];
    NSInteger indexSelected = [[NSUserDefaults standardUserDefaults] integerForKey:@"sortSelectedIndex"];
    [pikerViewOderSelect selectRow:indexSelected inComponent:0 animated:YES];
    
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
       {
        self->showPickerforOrder.frame = CGRectMake(200, (DEVICE_HEIGHT-300)/2, DEVICE_WIDTH-400, 400);
       }
                    completion:NULL];
}
#pragma mark- Buttons Order
-(void)btnOrderDoneClick
{
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         self-> showPickerforOrder.frame = CGRectMake(200, DEVICE_HEIGHT, DEVICE_WIDTH-400, 400);
     }
                    completion:(^(BOOL finished){
                    [self-> viewForOrderPiker removeFromSuperview];
    })];
    [self sortingData:orderSelected];
}
-(void)btnOrderCancelClick
{
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         self-> showPickerforOrder.frame = CGRectMake(200, DEVICE_HEIGHT, DEVICE_WIDTH-400, 400);
     }
                    completion:(^(BOOL finished){
                    [self-> viewForOrderPiker removeFromSuperview];
    })];
}
-(void)sortingData:(NSString *)strSort
{
    NSSortDescriptor *sortDescriptor;
    if ([strSort isEqual:@"Name"])
    {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortedArray = [arrSubjects sortedArrayUsingDescriptors:@[sortDescriptor]];
        arrSubjects = [[NSMutableArray alloc] init];
        arrSubjects = [sortedArray mutableCopy];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"sortSelectedIndex"];
    }
    else if ([strSort isEqual:@"Number"])
    {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"IntNumber" ascending:YES];
        NSArray *sortedArraynum = [arrSubjects sortedArrayUsingDescriptors:@[sortDescriptor]];
        arrSubjects = [[NSMutableArray alloc] init];
        arrSubjects = [sortedArraynum mutableCopy];
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"sortSelectedIndex"];
    }
    else if ([strSort isEqual:@"Tempareture"])
    {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"IntTemptur" ascending:YES];
        NSArray *sortedArrTemp = [arrSubjects sortedArrayUsingDescriptors:@[sortDescriptor]];
        arrSubjects = [[NSMutableArray alloc] init];
        arrSubjects = [sortedArrTemp mutableCopy];
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"sortSelectedIndex"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_collectionView reloadData];
    [tblPlayerList reloadData];
}
-(void)setUpForNotesButton
{
    [viewForNotes removeFromSuperview];
    viewForNotes = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    viewForNotes.backgroundColor = [UIColor colorWithRed:0 green:(CGFloat)0 blue:0 alpha:0.9];
    [self.view addSubview:viewForNotes];
     
    viewforShowNotes  = [[UIView alloc]initWithFrame:CGRectMake(100, (DEVICE_HEIGHT), DEVICE_WIDTH-200, 500)];
    viewforShowNotes.backgroundColor = UIColor.whiteColor;
    viewforShowNotes.layer.cornerRadius = 6;
    viewforShowNotes.clipsToBounds = true;
    [viewForNotes addSubview:viewforShowNotes];
    
    UILabel * lblNote = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, viewforShowNotes.frame.size.width, 45)];
    [self setLabelProperties:lblNote withText:@"Note" backColor:UIColor.clearColor textColor:UIColor.blackColor textSize:40];
    lblNote.textAlignment = NSTextAlignmentCenter;
    lblNote.font = [UIFont fontWithName:CGRegular size:40];
//    [viewforShowNotes addSubview:lblNote];
    
    UIView * viewBgNote = [[UIView alloc]initWithFrame:CGRectMake(0, 0, viewforShowNotes.frame.size.width, 70)];
    viewBgNote.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
    [viewforShowNotes addSubview:viewBgNote];
    
    UIButton *btnNoteCancel = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 70)];
    [self setButtonProperties:btnNoteCancel withTitle:@"Cancel" backColor:UIColor.clearColor textColor:UIColor.whiteColor txtSize:25];
    [btnNoteCancel addTarget:self action:@selector(btnNoteCancelClick) forControlEvents:UIControlEventTouchUpInside];
    btnNoteCancel.layer.cornerRadius = 5;
    [viewBgNote addSubview:btnNoteCancel];
        
    UIButton *btnNoteDone = [[UIButton alloc]initWithFrame:CGRectMake(viewforShowNotes.frame.size.width-100, 0, 100, 70)];
    [self setButtonProperties:btnNoteDone withTitle:@"Done" backColor:UIColor.clearColor textColor:UIColor.whiteColor txtSize:25];
    [btnNoteDone addTarget:self action:@selector(btnNoteDoneClick) forControlEvents:UIControlEventTouchUpInside];
    [viewBgNote addSubview:btnNoteDone];
       
    txtViewNotes = [[UITextView alloc] initWithFrame:CGRectMake(0, 70, viewforShowNotes.frame.size.width, viewforShowNotes.frame.size.height-70)];
    txtViewNotes.delegate = self;
    txtViewNotes.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtViewNotes.autocorrectionType = UITextAutocorrectionTypeNo;
    txtViewNotes.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:0.6];
    txtViewNotes.font = [UIFont fontWithName:CGRegular size:30];
    [viewforShowNotes addSubview:txtViewNotes];
    
    lblPlceholdNote = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, txtViewNotes.frame.size.width, 50)];
    [self setLabelProperties:lblPlceholdNote withText:@"Write a Notes here" backColor:UIColor.clearColor textColor:UIColor.lightGrayColor textSize:25];
    lblPlceholdNote.font = [UIFont fontWithName:CGRegular size:26];
    [txtViewNotes addSubview:lblPlceholdNote];

    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
        {
        self->viewforShowNotes.frame = CGRectMake(100, (DEVICE_HEIGHT-500)/2, DEVICE_WIDTH-200, 500);
        }
                    completion:NULL];
    }
#pragma mark-button Notes
-(void)btnNoteDoneClick
{
    [self.view endEditing:YES];
    if ([txtViewNotes.text isEqual:@""])
    {
        [self AlertViewFCTypeCaution:@"Please enter notes to save."];
    }
    else
    {
        NSMutableArray * ArrayNoteIn;
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [ArrayNoteIn addObject:dict];
        
        [dict setObject:txtViewNotes.text forKey:@"notes"];
//        NSLog(@"%@", dict);
        
        NSString * strName = [APP_DELEGATE checkforValidString:[dict valueForKey:@"name"]];
        NSString * strNote = [APP_DELEGATE checkforValidString:[dict valueForKey:@"notes"]];
        NSString * strDate = [APP_DELEGATE checkforValidString:[dict valueForKey:@"NA"]];
        NSString * strTime = [APP_DELEGATE checkforValidString:[dict valueForKey:@"NA"]];
          
        NSString * requestStr1 =    [NSString stringWithFormat:@"insert into 'Notes_Table'('name','notes','date','time') values(\"%@\",\"%@\",\"%@\",\"%@\")",strName,strNote,strDate,strTime];
        [[DataBaseManager dataBaseManager] executeSw:requestStr1];
//        NSLog(@"%@", requestStr1);
        
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeSuccess];
        [alert showAlertInView:self
                     withTitle:@"HQ-Inc"
                  withSubtitle:@"Notes added successfully."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
        [alert doneActionBlock:^{
            [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
            {
                self-> viewforShowNotes.frame = CGRectMake(100, (DEVICE_HEIGHT), DEVICE_WIDTH-200, 500);
            }
                            completion:(^(BOOL finished)
            {
                [self-> viewForNotes removeFromSuperview];
            })];
        }];
    }
}
-(void)btnNoteCancelClick
{
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        self-> viewforShowNotes.frame = CGRectMake(100, (DEVICE_HEIGHT), DEVICE_WIDTH-200, 500);
    }
                    completion:(^(BOOL finished)
    {
        [self-> viewForNotes removeFromSuperview];
    })];
}
#pragma mark- TextView Methods
- (void)textViewDidChange:(UITextView *)textView
{
    if  ([textView.text isEqual:@""])
    {
        lblPlceholdNote.text = @"Write  notes here";
    }
    else if ([textView.text isEqual:textView.text])
    {
        lblPlceholdNote.text = @"";
    }
}
-(void)getOutSideTempAndHumidity
{
    DictData = [[NSMutableDictionary alloc] init];
    URLManager *mangerl = [[URLManager alloc]init];
    mangerl.delegate = self;
    NSString *strServerUrl = @"https://api.openweathermap.org/data/2.5/weather?lat=12.3412978&lon=76.612816&appid=e7b2054dc37b1f464d912c00dd309595&units=Metric"; // pass URL here
    [mangerl getUrlCall:strServerUrl withParameters:DictData];
}
#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
//    NSLog(@"The result is...%@", result);
    NSString * strUrl = [NSString stringWithFormat:@"%@", [[result valueForKey:@"main"] valueForKey:@"temp"]];
    float temp = strUrl.intValue;
    NSString * strTemp_C = [NSString stringWithFormat:@"%.0f",temp];
    strTemp_C = [NSString stringWithFormat:@"%.0f",(temp-273)]; // ºC
    NSString * strUrlhum = [NSString stringWithFormat:@"%@", [[result valueForKey:@"main"] valueForKey:@"humidity"]];
    lblOutSidTem.text =  [NSString stringWithFormat:@"%@ºC/",strTemp_C];
    lblOutSidHumid.text = [NSString stringWithFormat:@"%@%%",strUrlhum];
}
- (void)onError:(NSError *)error
{
    NSLog(@"The error is...%@", error);
    NSInteger ancode = [error code];
    NSMutableDictionary * errorDict = [error.userInfo mutableCopy];
    NSLog(@"errorDict===%@",errorDict);
    if (ancode == -1001 || ancode == -1004 || ancode == -1005 || ancode == -1009)
    {}
    else
    {}
    NSString * strLoginUrl = [NSString stringWithFormat:@"%@%@",WEB_SERVICE_URL,@"token.json"];
       if ([[errorDict valueForKey:@"NSErrorFailingURLStringKey"] isEqualToString:strLoginUrl])
       {
           NSLog(@"NSErrorFailingURLStringKey===%@",[errorDict valueForKey:@"NSErrorFailingURLStringKey"]);
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
-(int)getRandomNumberBetween:(int)from and:(int)to;
{
    return (int)from + arc4random() % (to-from+1);
}
-(void)InsertRecordTbleData
{
    for ( int i = 0; i<50; i++)
    {
        NSString * strid = [NSString stringWithFormat:@"%d",i] ;
        NSString * strCoreTemp = [NSString stringWithFormat:@"%d",[self getRandomNumberBetween:92 and:100.4]]; //ºF[NSString stringWithFormat:@"%d",arc4random_uniform(101.2)] ;
        NSString * strSkinTemp = [NSString stringWithFormat:@"%d",[self getRandomNumberBetween:93 and:100.4]];//ºF
        
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy hh:mm"];
        NSString *dateString = [dateFormat stringFromDate:today];
        NSString * timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];

        
        NSString * strNA = @"NA";
        NSString * requestStr =    [NSString stringWithFormat:@"insert into 'Record_Table'('user_id','skin_temperature','core_temperature','date_time','time_stamp','check_type') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",strid,strSkinTemp,strCoreTemp,dateString,timestamp,strNA];
         [[DataBaseManager dataBaseManager] executeSw:requestStr];
    }
}
-(void)DataFromnDatabase
{
    if (arrSubjects.count > 0)
    {
            NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
            tmpDict = [arrSubjects objectAtIndex:0];
//            NSLog(@"%@",tmpDict);
        
            highIngstF = [[tmpDict valueForKey:@"ing_highF"] floatValue];
            lowIngestF = [[tmpDict valueForKey:@"ing_lowF"] floatValue];
            highDermalF = [[tmpDict valueForKey:@"drml_highF"] floatValue];
            lowDermalF = [[tmpDict valueForKey:@"drml_lowF"] floatValue];
            
            highIngstC = [[tmpDict valueForKey:@"ing_highC"] floatValue];
            lowIngestC = [[tmpDict valueForKey:@"ing_lowC"] floatValue];
            highDermalC = [[tmpDict valueForKey:@"drml_highC"] floatValue];
            lowDermalC = [[tmpDict valueForKey:@"drml_lowC"] floatValue];
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
@end



