//
//  PlayerSubjCELL.h
//  HQ-INC App
//
//  Created by Ashwin on 3/26/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayerSubjCELL : UITableViewCell



@property(nonatomic,strong) UILabel * lblName ,* lblPlayer, * lblCoreTmp, * lblType1Tmp,*lblDate,*lblTemp,*lblConncet,*lblLine;
@property(nonatomic,strong)UIImageView *imgViewpProfile;
@property(nonatomic,strong)UIButton *btnDelete;
@end

NS_ASSUME_NONNULL_END
