//
//  SessionCell.h
//  HQ-INC App
//
//  Created by Ashwin on 10/28/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SessionCell : UITableViewCell

@property(nonatomic,strong)UILabel *lblname,*lblTemp;
@property(nonatomic,strong)UIImageView *imgArrow,*viewSelect;
@end

NS_ASSUME_NONNULL_END
