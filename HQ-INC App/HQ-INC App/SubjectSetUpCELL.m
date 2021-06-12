//
//  SubjectSetUpCELL.m
//  HQ-INC App
//
//  Created by Ashwin on 5/25/20.
//  Copyright © 2020 Kalpesh Panchasara. All rights reserved.
//

#import "SubjectSetUpCELL.h"
#import "SubjSetupVC.h"

@implementation SubjectSetUpCELL
@synthesize viewSelect,lblSensor,lblNameSnr;

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
        
    lblSensor = [[UILabel alloc]init];
    lblSensor.textColor = UIColor.blackColor;
    lblSensor.backgroundColor = UIColor.clearColor;
    lblSensor.font = [UIFont fontWithName:CGRegular size:textSize-6];
    [self.contentView addSubview:lblSensor];
        
    lblNameSnr = [[UILabel alloc]init];
    lblNameSnr.textColor = UIColor.blackColor;
    lblNameSnr.font = [UIFont fontWithName:CGRegular size:textSize-6];
    lblNameSnr.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:lblNameSnr];

    viewSelect = [[UIImageView alloc]init];
    viewSelect.image = [UIImage imageNamed:@"radioUnselected.png"];
        viewSelect.hidden = true;
    [self.contentView addSubview:viewSelect];
    }
    return self;
    }
@end
