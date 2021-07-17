//
//  PlayerSubjVC.h
//  HQ-INC App
//
//  Created by Ashwin on 3/26/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerSubjCELL.h"
#import "SubjDetailsVC.h"
#import "LinkingVC.h"
#import "SubjSetupVC.h"
#import "GlobalSettingVC.h"
#import "CollectionCustomCell.h"
#import "URLManager.h"
#import <MessageUI/MessageUI.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayerSubjVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate,UITextViewDelegate,URLManagerDelegate,MFMailComposeViewControllerDelegate,FCAlertViewDelegate>
{
    UIView  * viewForPiker,*viewForNotes,*viewforShowNotes;
    UILabel   *lblPlceholdNote,*lblOursidetempHumidity;
    UITableView * tblPlayerList;
    NSMutableArray * arrayPlayers, *arrayPiker,*arrayPickerOrderBy;
    UITextView *txtViewNotes;
    
    UILabel *lblName,*lblplayer,*lblcore,*lblType1;
    UITextField *txtName,*txtHash;
    UIView *listView,*gridView,*viewForOrderPiker;
    UIView *showPickerView,*showPickerforOrder;
    NSString *selectedFromPicker, *StrikePIker;
    UIButton * btnMenu,* btnGrid,*btnLink, * btnFilter , * btnList;
    BOOL isListClicked, isOneDataAvail, isGridSelected;
    UICollectionView *_collectionView;;
    UIImageView *imgViewListButton;
    UIPickerView *pikerViewTmpSelect,*pikerViewOderSelect;
    NSMutableArray * arrSubjects;
    NSMutableArray * arrayNotes;
    NSMutableDictionary * dictData;
    long selectedIndex,autoSelectedIndex;
    NSString *orderSelected;
    NSNumber *intTemp;
        float highIngstF, highIngstC,lowIngestF, lowIngestC, highDermalC,highDermalF,lowDermalF, lowDermalC;
    BOOL isCClicked;

}


@end

NS_ASSUME_NONNULL_END
