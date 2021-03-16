//
//  PlayerSubjCELL.m
//  HQ-INC App
//
//  Created by Ashwin on 3/26/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "PlayerSubjCELL.h"

@implementation PlayerSubjCELL
@synthesize lblName,lblPlayer,lblCoreTmp,lblType1Tmp,lblDate,lblTemp,lblConncet,lblLine;
@synthesize imageView, imgViewpProfile;
@synthesize btnDelete;

- (void)awakeFromNib
{
    

    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
     
        imgViewpProfile = [[UIImageView alloc]initWithFrame:CGRectMake(50, 0, 60, 60)];
        imgViewpProfile.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:imgViewpProfile];
        
        lblName = [[UILabel alloc ]initWithFrame:CGRectMake(120, 0, (DEVICE_WIDTH-80)/4, 80)];
        lblName.font = [UIFont fontWithName:CGRegular size:20];
        lblName.textColor = UIColor.blackColor;
        lblName.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:lblName];
        
        lblPlayer = [[UILabel alloc ]initWithFrame:CGRectMake((DEVICE_WIDTH-70)/4*2-80, 0, (DEVICE_WIDTH-70)/4, 80)];
        lblPlayer.textColor = UIColor.blackColor;
        lblPlayer.textAlignment = NSTextAlignmentCenter;
        lblPlayer.font = [UIFont fontWithName:CGRegular size:20];
        [self.contentView addSubview:lblPlayer];
                
        lblCoreTmp = [[UILabel alloc ]initWithFrame:CGRectMake((DEVICE_WIDTH-70)/4*3-80, 0, (DEVICE_WIDTH-70)/4, 80)];
        lblCoreTmp.textColor = UIColor.blackColor;
        lblCoreTmp.textAlignment = NSTextAlignmentCenter;
        lblCoreTmp.font = [UIFont fontWithName:CGRegular size:20];
        [self.contentView addSubview:lblCoreTmp];
        
        lblType1Tmp = [[UILabel alloc ]initWithFrame:CGRectMake((DEVICE_WIDTH-70)/4*4-100, 0,(DEVICE_WIDTH-70)/4, 80)];
        lblType1Tmp.textColor = UIColor.blackColor;
        lblType1Tmp.textAlignment = NSTextAlignmentCenter;
        lblType1Tmp.font = [UIFont fontWithName:CGRegular size:20];
        [self.contentView addSubview:lblType1Tmp];
        
        lblDate = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, DEVICE_WIDTH, 40)];
        lblDate.backgroundColor = UIColor.clearColor;
        lblDate.textColor = UIColor.blackColor;
        lblDate.textAlignment = NSTextAlignmentLeft;

        lblDate.hidden = true;
        [self.contentView addSubview:lblDate];
        
        lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH/2, 0, DEVICE_WIDTH/2, 40)];
        lblTemp.backgroundColor = UIColor.clearColor;
        lblTemp.textColor = UIColor.blackColor;
        lblTemp.hidden = true;
        lblTemp.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:lblTemp];
        
        lblConncet = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-110, 5, 100, 40)];
        lblConncet.hidden = true;
        lblConncet.text = @"Connect";
        lblConncet.textColor = UIColor.whiteColor;
        lblConncet.layer.cornerRadius = 20;
        lblConncet.layer.masksToBounds = true;
        lblConncet.backgroundColor = [UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1];
        lblConncet.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:lblConncet];

        lblLine = [[UILabel alloc ]initWithFrame:CGRectMake(0, 49, DEVICE_WIDTH, 1)];
        lblLine.backgroundColor = UIColor.lightGrayColor;
        lblLine.hidden = true;
        [self.contentView addSubview:lblLine];
    }
    return self;
    }
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
