//
//  HomeCell.m
//  HoldItWrite
//
//  Created by Kalpesh Panchasara on 12/07/20.
//  Copyright © 2019 Kalpesh Panchasara. All rights reserved.
//

#import "HomeCell.h"

@implementation HomeCell
@synthesize lblDeviceName,lblConnect,lblAddress,lblBack;
- (void)awakeFromNib {
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
    {    // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        
        lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,DEVICE_WIDTH-0,70)];
        lblBack.backgroundColor = [UIColor whiteColor];
        lblBack.layer.cornerRadius = 10;
        lblBack.layer.masksToBounds = YES;
        lblBack.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.contentView addSubview:lblBack];
        
        lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, DEVICE_WIDTH-36, 35)];
        lblDeviceName.numberOfLines = 0;
        [lblDeviceName setBackgroundColor:[UIColor clearColor]];
        lblDeviceName.textColor = UIColor.blackColor;
        [lblDeviceName setFont:[UIFont fontWithName:CGRegular size:textSize+3]];
        [lblDeviceName setTextAlignment:NSTextAlignmentLeft];
        lblDeviceName.text = @"Device name";
        
        
        lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(18, 35,  DEVICE_WIDTH-36, 35)];
        [lblAddress setBackgroundColor:[UIColor clearColor]];
        [lblAddress setTextColor:[UIColor blackColor]];
        [lblAddress setFont:[UIFont fontWithName:CGRegular size:textSize]];
        [lblAddress setTextAlignment:NSTextAlignmentLeft];
        lblAddress.text = @"Ble Address";
        
        lblConnect = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-150, 0, 100, 70)];
        [lblConnect setBackgroundColor:[UIColor clearColor]];
        [lblConnect setTextColor:[UIColor blackColor]];
        [lblConnect setFont:[UIFont fontWithName:CGRegular size:textSize]];
        [lblConnect setTextAlignment:NSTextAlignmentLeft];
        lblConnect.text = @"ADD";
        

        [self.contentView addSubview:lblDeviceName];
        [self.contentView addSubview:lblAddress];
        [self.contentView addSubview:lblConnect];
        
        
        if ( IS_IPHONE_4 || IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_6plus)
        {
            lblBack.frame = CGRectMake(0, 0,DEVICE_WIDTH-0,60);
            lblDeviceName.frame = CGRectMake(5, 0, DEVICE_WIDTH-10, 30);
            lblAddress.frame = CGRectMake(5, 30,  DEVICE_WIDTH-10, 30);
            lblConnect.frame = CGRectMake(DEVICE_WIDTH-100, 0, 80, 60);
            lblConnect.font = [UIFont fontWithName:CGRegular size:textSize-6];
            
        }
    }
    return self;
}

@end
