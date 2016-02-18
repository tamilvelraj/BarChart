//
//  HorizonBarView.h
//  TestWaitingView
//
//  Created by Thamil Selvan V on 10/02/16.
//  Copyright © 2016 zhtg. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CHART_VALUES @"ChartValues"
#define CHART_MAX_VALUE @"ChartMaxValue"
#define CHART_MIN_VALUE @"ChartMinValue"
#define CHART_TITLES @"ChartTitles"

@interface HorizonBarView : UIView
@property(nonatomic, strong) NSDictionary *chartInfo;
@end
