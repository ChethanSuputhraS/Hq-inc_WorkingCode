//
//  CollectionCustomCell.m
//  HQ-INC App
//
//  Created by Kalpesh Panchasara on 15/05/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "CollectionCustomCell.h"

@implementation CollectionCustomCell
@synthesize lblName,lblTransView,lblCoreTmp,lblSkinTmp, lblBack , lblNo, lblBorder;
@synthesize imgViewpProfile;
@synthesize viewpProfileRed;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        imgViewpProfile = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
        imgViewpProfile.image = [UIImage imageNamed:@"User.png"];
//        imgViewpProfile.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:imgViewpProfile];
        
        lblBack = [[UILabel alloc ]initWithFrame:CGRectMake(0, self.contentView.frame.size.height - 50, self.contentView.frame.size.width, 50)];
        lblBack.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:lblBack];

        lblName = [[UILabel alloc ]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width-50, 50)];
        lblName.font = [UIFont fontWithName:CGRegular size:25];
        lblName.textColor = UIColor.whiteColor;
        lblName.backgroundColor = [UIColor blackColor];
        lblName.textAlignment = NSTextAlignmentCenter;
        [lblBack addSubview:lblName];
        
        lblNo = [[UILabel alloc ]initWithFrame:CGRectMake(self.contentView.frame.size.width-50, 0, 50, 50)];
        lblNo.font = [UIFont fontWithName:CGRegular size:25];
        lblNo.textColor = UIColor.whiteColor;
        lblNo.textAlignment = NSTextAlignmentCenter;
        lblNo.backgroundColor = [UIColor lightGrayColor];
        [lblBack addSubview:lblNo];

        lblTransView = [[UILabel alloc ]initWithFrame:CGRectMake(self.contentView.frame.size.width - 100, 0, 100, self.contentView.frame.size.height - 50)];
        lblTransView.backgroundColor = [UIColor colorWithRed:204.0/255.0f green:204.0/255.0f blue:204.0/255.0f alpha:0.7];
        [self.contentView addSubview:lblTransView];

        lblCoreTmp = [[UILabel alloc ]initWithFrame:CGRectMake(self.contentView.frame.size.width - 100, 20, 100, 80)];
        lblCoreTmp.font = [UIFont fontWithName:CGRegular size:20];
        lblCoreTmp.textColor = UIColor.blackColor;
        lblCoreTmp.numberOfLines = 0;
        lblCoreTmp.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:lblCoreTmp];

        lblSkinTmp = [[UILabel alloc ]initWithFrame:CGRectMake(self.contentView.frame.size.width - 100, 100, 100, 80)];
        lblSkinTmp.font = [UIFont fontWithName:CGRegular size:20];
        lblSkinTmp.textColor = UIColor.blackColor;
        lblSkinTmp.numberOfLines = 0;
        lblSkinTmp.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:lblSkinTmp];

        lblBorder = [[UILabel alloc ]initWithFrame:CGRectMake(0, self.contentView.frame.size.height - 1, self.contentView.frame.size.width,1)];
        lblBorder.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:lblBorder];

  
        
//        viewpProfileRed = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
//        [self.contentView addSubview:viewpProfileRed];

        
        
        lblName.text = @"Name";
        lblNo.text = @"#";
        lblCoreTmp.text = @"-NA-\nCore Temp";
        lblSkinTmp.text = @"-NA-\nSkin Temp";
        imgViewpProfile.image = [UIImage imageNamed:@"add.png"];
        
        lblCoreTmp.hidden = true;
        lblSkinTmp.hidden = true;
        
        if ( IS_IPHONE_4 || IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_6plus)
        {
            imgViewpProfile.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
            lblName.frame = CGRectMake(40, 0, (DEVICE_WIDTH-40)/4, 40);
            lblName.font = [UIFont fontWithName:CGRegular size:textSize-6];

            lblBack.frame = CGRectMake(0, self.contentView.frame.size.height - 30, self.contentView.frame.size.width, 30);
            
            lblName.frame = CGRectMake(0, 0, self.contentView.frame.size.width-40, 30);
            lblName.font = [UIFont fontWithName:CGRegular size:textSize-6];
            
            lblNo.frame = CGRectMake(self.contentView.frame.size.width-40, 0, 40, 30);
            lblNo.font = [UIFont fontWithName:CGRegular size:textSize-6];

            lblTransView.frame = CGRectMake(self.contentView.frame.size.width - 40, 0, 40, self.contentView.frame.size.height - 30);

            lblCoreTmp.frame = CGRectMake(self.contentView.frame.size.width - 40, 5, 40, 30);
            lblCoreTmp.font = [UIFont fontWithName:CGRegular size:textSize-6];
            
            lblSkinTmp.frame = CGRectMake(self.contentView.frame.size.width - 40, lblTransView.frame.size.height-50, 40, 30);
            lblSkinTmp.font = [UIFont fontWithName:CGRegular size:textSize-6];

            lblBorder.frame = CGRectMake(0, self.contentView.frame.size.height - 1, self.contentView.frame.size.width,1);

        }
        
    }
    return self;
}
-(void)UpdateCellforValue:(int)tempValue;
{
    if (tempValue<=99 && tempValue>96)
    {
         lblTransView.backgroundColor = [UIColor colorWithRed:23.0/255.0f green:90.0/255.0f blue:255.0/255.0f alpha:0.8];
         lblCoreTmp.textColor = UIColor.whiteColor;
         lblSkinTmp.textColor = UIColor.whiteColor;
         lblName.backgroundColor = [UIColor colorWithRed:23.0/255.0f green:90.0/255.0f blue:255.0/255.0f alpha:1];
         lblNo.backgroundColor =  [UIColor colorWithRed:23.0/255.0f green:90.0/255.0f blue:255.0/255.0f alpha:1];
         lblNo.layer.borderWidth = 1;
         lblName.layer.borderWidth = 1;
         lblCoreTmp.hidden = false;
         lblSkinTmp.hidden = false;
    }
    else if (tempValue >= 100)
    {
         lblTransView.backgroundColor = [UIColor colorWithRed:242.0/255.0f green:12.0/255.0f blue:27.0/255.0f alpha:0.8];
         lblCoreTmp.textColor = UIColor.whiteColor;
         lblSkinTmp.textColor = UIColor.whiteColor;
         lblName.backgroundColor = [UIColor colorWithRed:242.0/255.0f green:12.0/255.0f blue:27.0/255.0f alpha:1];
         lblNo.backgroundColor = [UIColor colorWithRed:242.0/255.0f green:12.0/255.0f blue:27.0/255.0f alpha:1];
         lblNo.layer.borderWidth = 1;
         lblName.layer.borderWidth = 1;
         lblCoreTmp.hidden = false;
         lblSkinTmp.hidden = false;
    }
    else
    {
         lblCoreTmp.hidden = false;
         lblSkinTmp.hidden = false;
    }

}
@end
