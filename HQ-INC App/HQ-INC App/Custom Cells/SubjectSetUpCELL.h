//
//  SubjectSetUpCELL.h
//  HQ-INC App
//
//  Created by Ashwin on 5/25/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SubjectSetUpCELL : UITableViewCell
{
   
}
@property(nonatomic,strong)UIImageView*viewSelect;
@property(nonatomic,strong)UILabel*lblSensor,*lblNameSnr;
@property(nonatomic, readwrite) CGSize contentSizeForView;

@end

NS_ASSUME_NONNULL_END
