//
//  SessionCell.m
//  HQ-INC App
//
//  Created by Ashwin on 10/28/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "SessionCell.h"

@implementation SessionCell
@synthesize lblname,lblTemp,imgArrow,viewSelect;
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
    {
        
        lblname = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH/2-20, 60)];
        [lblname setBackgroundColor:UIColor.clearColor];//[UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1]];
        [lblname setFont:[UIFont fontWithName:CGRegular size:25]];
        lblname.font = [UIFont fontWithName:CGRegular size:textSize+3];
        [lblname setTextAlignment:NSTextAlignmentLeft];
        [lblname setTextColor:[UIColor blackColor]];
//        lblSession.layer.cornerRadius = 12;
        [self.contentView addSubview:lblname];
        
        lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH/2-10, 0, DEVICE_WIDTH/2-20, 60)];
        [lblTemp setBackgroundColor:UIColor.clearColor];//[UIColor colorWithRed:24.0/255 green:(CGFloat)157.0/255 blue:191.0/255 alpha:1]];
        [lblTemp setFont:[UIFont fontWithName:CGRegular size:25]];
        lblTemp.font = [UIFont fontWithName:CGRegular size:textSize+3];
        [lblTemp setTextAlignment:NSTextAlignmentRight];
        [lblTemp setTextColor:[UIColor blackColor]];
        //        lblSession.layer.cornerRadius = 12;
        [self.contentView addSubview:lblTemp];
        
          imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-40, 17, 25, 25)];
          [imgArrow setImage:[UIImage imageNamed:@"arrow.png"]];
          [imgArrow setContentMode:UIViewContentModeScaleAspectFit];
          imgArrow.hidden = true;
          [self.contentView addSubview:imgArrow];
        
        viewSelect = [[UIImageView alloc]init];
        viewSelect.image = [UIImage imageNamed:@"radioUnselected.png"];
        viewSelect.hidden = true;
        [self.contentView addSubview:viewSelect];
        
        if ( IS_IPHONE_4 || IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_6plus)
        {
            lblname.frame = CGRectMake(5, 0,  DEVICE_WIDTH/3-10, 40);
            [lblname setFont:[UIFont fontWithName:CGRegular size:textSize-6]];

            
            lblTemp.frame = CGRectMake(DEVICE_WIDTH/3, 0, DEVICE_WIDTH/3, 40);
            [lblTemp setFont:[UIFont fontWithName:CGRegular size:textSize-6]];

            imgArrow.frame = CGRectMake(DEVICE_WIDTH-40, 0, 40, 40);



        }
        
        
    }
    return self;
    }
@end
