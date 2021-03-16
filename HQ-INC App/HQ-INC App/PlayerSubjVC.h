//
//  PlayerSubjVC.h
//  HQ-INC App
//
//  Created by Ashwin on 3/26/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayerSubjVC : UIViewController
{
    UIView * navigViewTop, * viewForPiker,*viewForNotes,*viewforShowNotes;
    UILabel * lblPLayerSubject, *lblFilter, *lblOrder , *lblOutSideTmp,*lblPlceholdNote,*lblOutSidTem,*lblOutSidHumid;
    UITableView * tblPlayerList;
    UIButton * btnExportData, *btnGlobalRead, *btnNotes, *btnSelect, *btnOrder, *btnLinking,* btnlistView ;
    NSMutableArray * arrayPlayers, *arrayPiker,*arrayPickerOrderBy;
    UITextView *txtViewNotes;
}


@end

NS_ASSUME_NONNULL_END
