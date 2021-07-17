//
//  AddSensorCell.m
//  HQ-INC App
//
//  Created by Ashwin on 8/27/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "AddSensorCell.h"

@implementation AddSensorCell
@synthesize lblDeviceName,lblConnect,lblAddress,lblDeviceType;
- (void)awakeFromNib
{
    
    [super awakeFromNib];
    // Initialization code
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(10, 0,  DEVICE_WIDTH/3-20, 70)];
        [lblAddress setBackgroundColor:[UIColor clearColor]];
        [lblAddress setTextColor:[UIColor blackColor]];
        [lblAddress setFont:[UIFont fontWithName:CGRegular size:textSize+5]];
        [lblAddress setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:lblAddress];
        
        lblDeviceType = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH/3, 0, 200, 70)];
        [lblDeviceType setBackgroundColor:[UIColor clearColor]];
        [lblDeviceType setTextColor:[UIColor blackColor]];
        [lblDeviceType setFont:[UIFont fontWithName:CGRegular size:textSize+2]];
        [lblDeviceType setTextAlignment:NSTextAlignmentLeft];
//        [self.contentView addSubview:lblDeviceType];
        
        lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH/2-15, 0, DEVICE_WIDTH/2-70, 70)];
        [lblDeviceName setBackgroundColor:[UIColor clearColor]];
        [lblDeviceName setTextColor:[UIColor blackColor]];
        [lblDeviceName setFont:[UIFont fontWithName:CGRegular size:textSize+5]];
        [lblDeviceName setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:lblDeviceName];
        
        lblConnect = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-120, 10, 100, 50)];
        [lblConnect setBackgroundColor:UIColor.clearColor];//[UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1]];
        [lblConnect setFont:[UIFont fontWithName:CGRegular size:25]];
        lblConnect.font = [UIFont fontWithName:CGRegular size:textSize+3];
        [lblConnect setTextAlignment:NSTextAlignmentCenter];
        [lblConnect setTextColor:[UIColor blackColor]];
        lblConnect.layer.cornerRadius = 12;
        [self.contentView addSubview:lblConnect];
        
        
        if ( IS_IPHONE_4 || IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_6plus)
        {
            lblAddress.frame = CGRectMake(5, 0,  DEVICE_WIDTH/3-10, 40);
            [lblAddress setFont:[UIFont fontWithName:CGRegular size:textSize-6]];

            
            lblDeviceType.frame = CGRectMake(DEVICE_WIDTH/3, 0, DEVICE_WIDTH/3, 40);
            [lblAddress setFont:[UIFont fontWithName:CGRegular size:textSize-6]];

            lblDeviceName.frame = CGRectMake(DEVICE_WIDTH/2, 0, DEVICE_WIDTH/2-10, 40);
            [lblDeviceName setFont:[UIFont fontWithName:CGRegular size:textSize-6]];

            lblConnect.frame = CGRectMake(DEVICE_WIDTH-100, 10, 100, 40);
            [lblConnect setFont:[UIFont fontWithName:CGRegular size:textSize-6]];

        }
   
    }
         return self;
}
@end
