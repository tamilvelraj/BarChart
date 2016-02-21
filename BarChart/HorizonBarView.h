
#import <UIKit/UIKit.h>

#define CHART_VALUES @"ChartValues"
#define CHART_MAX_VALUE @"ChartMaxValue"
#define CHART_MIN_VALUE @"ChartMinValue"
#define CHART_TITLES @"ChartTitles"

@interface HorizonBarView : UIView
@property(nonatomic, strong) NSDictionary *chartInfo;
@end
