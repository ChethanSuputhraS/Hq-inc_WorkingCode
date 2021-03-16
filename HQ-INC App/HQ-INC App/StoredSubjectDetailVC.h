//
//  StoredSubjectDetailVC.h
//  HQ-INC App
//
//  Created by Vithamas Technologies on 15/03/21.
//  Copyright © 2021 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StoredSubjectDetailVC : UIViewController
{
    
}


@property (nonatomic, strong) LineChartView* chartView;

@property(nonatomic, strong) NSMutableDictionary * dataDict;
@property(nonatomic, strong) NSMutableDictionary * sessionDict;


@end

NS_ASSUME_NONNULL_END
