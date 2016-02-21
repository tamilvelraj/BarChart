#import "HorizonBarView.h"
#import <math.h>
#import <CoreText/CoreText.h>

#define HORIZONTAL_TITLE_HEIGHT 100.f
#define VERTICAL_TITLE_WIDTH 100.f
#define MeterAxisDataFont [UIFont fontWithName:@"Helvetica" size:11.f]
#define COLOR(x,y,z) [UIColor colorWithRed:x/255.f green:y/255.f blue:z/255.f alpha:1.f];

typedef enum {
    HorizontalBarChart = 0,
    VerticalBarChart = 1
} ChartType;

typedef enum {
    MeterAxis = 0,
    DisplayAxis = 1
} AxisType;

@interface AxisData : NSObject
@property(nonatomic, assign) AxisType type;
@property(nonatomic, assign, readwrite) CGSize chartSize;
@property(nonatomic, strong) NSArray *titles;
@property(nonatomic, assign) CGFloat width;

-(instancetype)initWithChartSize:(CGSize)chartsize;
@end

@implementation AxisData {
}

-(instancetype)initWithChartSize:(CGSize)chartsize
{
    self = [super init];
    if (self) {
        _chartSize = chartsize;
    }
    return self;
}
@end

#define DisplayAxisPadding 10.f
#define DisplayHalfAxisPadding 5.f

@interface DisplayAxisData : AxisData
@end

@implementation DisplayAxisData
-(instancetype)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

-(void)setTitles:(NSArray*)titles
{
    CGFloat lwidth = 50.f;
    for (int i=0; i<titles.count; i++)
    {
        NSString *title = [titles objectAtIndex:i];
        CGSize size = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30.f) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: MeterAxisDataFont} context:nil].size;
        if (size.width > lwidth)
        {
            lwidth = size.width;
        }
    }
    
    self.width = lwidth + DisplayAxisPadding;
    [super setTitles:titles];
}


@end

#define MeterAxisPadding 4.f
#define MeterAxisHalfPadding (MeterAxisPadding/2)
#define MinimalMeterAxisUnits 5
#define MaximumMeterAxisUnits 10
#define DefaultGridChartSize CGSizeMake(self.chartSize, 300.f)
#define FixedBarWidth 40.f

@interface MeterAxisData : AxisData
@property(nonatomic, assign) BOOL floatType;
@property(nonatomic, assign,readonly) NSInteger startMeterValue;
@property(nonatomic, assign,readonly) NSInteger endMeterValue;
@property(nonatomic, assign,readonly) NSInteger oneUnitValue;
@property(nonatomic, assign,readonly) NSInteger noOfMeterUnits;
@property(nonatomic, strong) DisplayAxisData *displayAxisData;

-(void)setMeterTitlesFromValue1:(NSInteger)startValue value2:(NSInteger)endValue;
@end

@implementation MeterAxisData {
    NSMutableArray *meterTitles;
}

-(instancetype)initWithChartSize:(CGSize)chartsize
{
    self = [super initWithChartSize:chartsize];
    if (self)
    {
    }
    return self;
}

-(NSMutableArray*)titles
{
    return meterTitles;
}

-(void)setMeterTitlesFromValue1:(NSInteger)startValue value2:(NSInteger)endValue
{
    _startMeterValue = startValue;
    _endMeterValue = endValue;
    
    CGFloat width = 50.f;
    _noOfMeterUnits = (self.chartSize.width > self.chartSize.height)? MinimalMeterAxisUnits: MaximumMeterAxisUnits;
    
    NSInteger fromValueLength = [[NSString stringWithFormat:@"%li",startValue] length];
    NSInteger roundingFromValue = powf(10,(fromValueLength - 1)) / 2;
    if (startValue && roundingFromValue) {
         startValue = (startValue - (startValue % roundingFromValue));
         startValue = (startValue - (startValue % _noOfMeterUnits));
    }
    
    NSInteger toValueLength = [[NSString stringWithFormat:@"%li",endValue] length];
    NSInteger roundingToValue = powf(10,(toValueLength - 1))/2;
    endValue = (endValue - (endValue % roundingToValue))+roundingToValue;
    endValue = (endValue - (endValue % _noOfMeterUnits))+_noOfMeterUnits;

    _oneUnitValue = roundf((endValue - startValue) / _noOfMeterUnits);

    meterTitles = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%li",startValue]];
    
    for (int i=1; i<=_noOfMeterUnits; i++) {
        NSString *title = [NSString stringWithFormat:@"%li",(startValue + i*_oneUnitValue)];
        [meterTitles addObject:title];
    }
    
    for (int i=0; i<meterTitles.count; i++)
    {
        NSString *title = [NSString stringWithFormat:@"%@",[meterTitles objectAtIndex:i]];
        CGSize size = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30.f) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: MeterAxisDataFont} context:nil].size;
        NSLog(@"size %@",NSStringFromCGSize(size));
        if (size.width > width)
        {
            width = size.width;
        }
    }

    self.width = width + MeterAxisPadding;
}

@end


@interface ChartData : NSObject
@property(nonatomic, assign) ChartType chartType;
@property(nonatomic, assign, readonly) NSInteger noOfSections;
@property(nonatomic, assign, readonly) NSInteger noOfBars;
@property(nonatomic, strong) NSMutableArray *values;
@property(nonatomic, strong) NSMutableArray *titles;
@property(nonatomic, assign) CGFloat minValue;
@property(nonatomic, assign) CGFloat maxValue;
@end

@implementation ChartData
-(instancetype)initWithData:(NSDictionary*)data
{
    self = [super init];
    if (self)
    {
        _values = [data objectForKey:CHART_VALUES];
        _titles = [data objectForKey:CHART_TITLES];
        
        _minValue = [[data objectForKey:CHART_MIN_VALUE] floatValue]; //[[_values valueForKeyPath:@"@min"] floatValue];
        _maxValue = [[data objectForKey:CHART_MAX_VALUE] floatValue]; //[[_values valueForKeyPath:@"@max"] floatValue];
        
        _noOfSections = _values.count;
        if (_noOfSections) {
            _noOfBars = [[_values objectAtIndex:0] count];
        }
    }
    return self;
}
@end

@interface GridData : NSObject
@property(nonatomic, assign) ChartType chartType;
@property(nonatomic, assign, readonly) CGSize gridSize;
@property(nonatomic, strong, readonly) NSMutableArray *meterAxisUnitPoints;
@property(nonatomic, strong, readonly) NSMutableArray *displayAxisUnitPoints;
@property(nonatomic, strong, readonly) MeterAxisData *meterAxisData;
@property(nonatomic, strong, readonly) DisplayAxisData *displayAxisData;

-(instancetype)initWithChartSize:(CGSize)chartsize;
-(void)setUpChartData:(ChartData*)chartData;
@end

@interface GridData()
@property(nonatomic, strong, readwrite) MeterAxisData *meterAxisData;
@property(nonatomic, strong, readwrite) DisplayAxisData *displayAxisData;
@property(nonatomic, assign, readonly) CGFloat oneMeterUnitBoundValue;
@property(nonatomic, assign, readonly) CGFloat oneDisplayUnitBoundValue;
@property(nonatomic, strong, readwrite) NSMutableArray *meterAxisUnitPoints;
@property(nonatomic, strong, readwrite) NSMutableArray *displayAxisUnitPoints;
@property(nonatomic, assign, readwrite) CGSize gridSize;
@end

@implementation GridData {
    CGSize chartSize;
}

-(instancetype)initWithChartSize:(CGSize)chartsize
{
    self = [super init];
    if (self) {
        chartSize = chartsize;
    }
    return self;
}

-(void)setUpChartData:(ChartData*)chartData
{
    NSArray *titles = [chartData titles];
    _meterAxisData = [[MeterAxisData alloc] initWithChartSize:chartSize];
        
    CGFloat startValue = chartData.minValue;
    CGFloat endValue = chartData.maxValue;
    
    [_meterAxisData setMeterTitlesFromValue1:startValue value2:endValue];
    
    _displayAxisData = [[DisplayAxisData alloc] initWithChartSize:chartSize];
    [_displayAxisData setTitles:titles];
    
    CGFloat meterAxisWidth = _meterAxisData.width;
    CGFloat displayAxisWidth = _displayAxisData.width;
    
    NSInteger noOfMeterAxisUnitCount = [_meterAxisData.titles count];
    NSInteger noOfDisplayAxisUnitCount = [_displayAxisData.titles count];
    
    _meterAxisUnitPoints = [NSMutableArray array];
    _displayAxisUnitPoints = [NSMutableArray array];
    
    if (_chartType == VerticalBarChart)
    {
        _gridSize = CGSizeMake(chartSize.width - meterAxisWidth, chartSize.height - displayAxisWidth);
        _oneMeterUnitBoundValue = _gridSize.height / (noOfMeterAxisUnitCount-1);
        _oneDisplayUnitBoundValue = (chartData.noOfBars * FixedBarWidth)+FixedBarWidth;
        
        for (int i=0; i < noOfMeterAxisUnitCount; i++)
        {
            CGFloat pointY = _gridSize.height - (i*_oneMeterUnitBoundValue);
            NSValue *meterAxisPoint = [NSValue valueWithCGPoint:CGPointMake(meterAxisWidth, pointY)];
            [_meterAxisUnitPoints addObject:meterAxisPoint];
        }
        
        for (int i=0; i < noOfDisplayAxisUnitCount; i++)
        {
            NSValue *meterAxisPoint = [NSValue valueWithCGPoint:CGPointMake(_oneDisplayUnitBoundValue/2, (chartSize.height - (displayAxisWidth/2)))];
            [_displayAxisUnitPoints addObject:meterAxisPoint];
        }
    }
    else if(_chartType == HorizontalBarChart)
    {
        _gridSize = CGSizeMake(chartSize.width - displayAxisWidth, chartSize.height - meterAxisWidth);
        _oneMeterUnitBoundValue = (chartData.noOfBars * FixedBarWidth)+FixedBarWidth;
        _oneDisplayUnitBoundValue = _gridSize.height / noOfDisplayAxisUnitCount;
        
        for (int i=0; i < noOfDisplayAxisUnitCount; i++)
        {
            NSValue *displayAxisPoint = [NSValue valueWithCGPoint:CGPointMake(displayAxisWidth, (i*_oneDisplayUnitBoundValue)+meterAxisWidth)];
            [_displayAxisUnitPoints addObject:displayAxisPoint];
        }
        
        for (int i=0; i < noOfMeterAxisUnitCount; i++)
        {
            NSValue *meterAxisPoint = [NSValue valueWithCGPoint:CGPointMake(_oneMeterUnitBoundValue/2, chartSize.height - (meterAxisWidth/2))];
            [_meterAxisUnitPoints addObject:meterAxisPoint];
        }
    }
}

@end

@interface BarLayer : CAShapeLayer
@property(nonatomic,assign) CGFloat value;
@property(nonatomic,assign) CGSize size;
@property(nonatomic, assign) NSInteger index;
+(CABasicAnimation *)animationForKey:(NSString*)key fromValue:(NSValue*)fValue toValue:(NSValue*)tValue;
@end

@implementation BarLayer
+(CABasicAnimation *)animationForKey:(NSString*)key fromValue:(NSValue*)fValue toValue:(NSValue*)tValue
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:key];
    animation.fromValue = fValue;
    animation.toValue = tValue;
    animation.duration = 1.f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    return animation;
}

@end

@interface BarSectionLayer : CAShapeLayer
@property(nonatomic, assign) NSInteger index;
@property(nonatomic, assign) NSInteger noofBars;
@property(nonatomic, strong) NSArray *values;
@property(nonatomic, strong) NSArray *boundValues;
@property(nonatomic, assign) CGSize size;
@property(nonatomic, assign) CGPoint bPosition;
@property(nonatomic, strong) NSMutableArray *subLayers;
@end

@implementation BarSectionLayer {
    CGFloat barPadding;
    //CGSize barSize;
}

-(void)layoutSublayersOfLayer:(CALayer *)layer
{
    NSLog(@"layoutSublayersOfLayer");
}

//-(CGFloat)getBound

-(void)layoutSublayers
{
//    self.bounds = CGRectMake(0, 0, _size.width, _size.height);
//    self.position = _bPosition;
    
    CGFloat gridSectionHeight = CGRectGetHeight(self.bounds);
    barPadding = FixedBarWidth/2;
    
    [_subLayers enumerateObjectsUsingBlock:^(CAShapeLayer *layer, NSUInteger idx, BOOL * _Nonnull stop) {
        [layer removeFromSuperlayer];
    }];
    _subLayers = [NSMutableArray array];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    UIColor *green = COLOR(26,158,118);
    UIColor *red = COLOR(214,103,44);
    UIColor *blue = COLOR(9,117,181);
    UIColor *yellow = COLOR(231,161,40);
    UIColor *pink = COLOR(203,121,169);
    
    NSArray *colors = @[blue,green,pink,red,yellow];
    
    for (int i=0; i<_noofBars; i++)
    {
        CGFloat barheight = [[_boundValues objectAtIndex:i] floatValue];
        CGSize barSize = CGSizeMake((_size.width-barPadding)/_noofBars, barheight);

        NSInteger barindex = i+1;
        BarLayer *barlayer = [BarLayer layer];
        barlayer.strokeColor = [[colors objectAtIndex:i%colors.count] CGColor];
        barlayer.lineWidth = barSize.width;
        
        barlayer.bounds = CGRectMake(0, 0, barSize.width, barSize.height);
        
        CGPoint barPosition = CGPointMake(barPadding+(barSize.width*barindex)-(barSize.width/2), gridSectionHeight-(barSize.height/2));
        barlayer.position = barPosition;
        barlayer.index = barindex;
        [self addSublayer:barlayer];
        [_subLayers addObject:barlayer];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(barPadding, barSize.height)];
        [path addLineToPoint:CGPointMake(barPadding, 0)];
        barlayer.path = path.CGPath;
        
        CABasicAnimation *animation = [BarLayer animationForKey:@"strokeEnd" fromValue:@(0) toValue:@(1)];
        [barlayer addAnimation:animation forKey:@"BoundsHeight"];
    }
    
    [CATransaction setDisableActions:NO];
    [CATransaction commit];
}

@end

#define DEGREE_TO_RADIANS(degree) (degree/180)*M_PI

@interface AxisTextLayer : CATextLayer
+(CATextLayer*)meterTextLayerWithSize:(CGSize)size string:(NSString *)text;
+(CATextLayer*)displayTextLayerWithSize:(CGSize)size string:(NSString *)text;
@end

@implementation AxisTextLayer

+(CATextLayer*)meterTextLayerWithSize:(CGSize)size string:(NSString *)text
{
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.bounds = CGRectMake(0, 0, size.width, size.height);
    textLayer.alignmentMode = kCAAlignmentRight;
    textLayer.string = text;
    textLayer.backgroundColor = [UIColor clearColor].CGColor;
    textLayer.wrapped = YES;
    //textLayer.transform = CATransform3DMakeRotation(0, 0, 0, .5f);
    //self.textLayer.contentsScale = [[UIScreen mainScreen] scale];
    
    CTFontRef ctBoldFont = CTFontCreateWithName((__bridge CFStringRef)MeterAxisDataFont.fontName, MeterAxisDataFont.pointSize, NULL);
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (__bridge id)ctBoldFont,
                                (id)kCTFontAttributeName,
                                [UIColor blackColor].CGColor, (id)kCTForegroundColorAttributeName, nil];
    CFRelease(ctBoldFont);
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    [string addAttributes:attributes range:NSMakeRange(0, string.length)];
    textLayer.string = string;
    return textLayer;
}

+(CATextLayer*)displayTextLayerWithSize:(CGSize)size string:(NSString *)text
{
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.bounds = CGRectMake(0, 0, size.width, size.height);
    textLayer.alignmentMode = kCAAlignmentRight;
    textLayer.string = text;
    textLayer.backgroundColor = [UIColor clearColor].CGColor;
    textLayer.wrapped = YES;
    textLayer.transform = CATransform3DMakeRotation(DEGREE_TO_RADIANS(30), 0, 0, .5f);
    //self.textLayer.contentsScale = [[UIScreen mainScreen] scale];
    
    CTFontRef ctBoldFont = CTFontCreateWithName((__bridge CFStringRef)MeterAxisDataFont.fontName, MeterAxisDataFont.pointSize, NULL);
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (__bridge id)ctBoldFont,
                                (id)kCTFontAttributeName,
                                [UIColor blackColor].CGColor, (id)kCTForegroundColorAttributeName, nil];
    CFRelease(ctBoldFont);
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    [string addAttributes:attributes range:NSMakeRange(0, string.length)];
    textLayer.string = string;
    return textLayer;
}

@end

@interface GridLayer : CAShapeLayer
@property(nonatomic,strong) GridData *data;
@property(nonatomic,strong) CAShapeLayer *vAxisLayer;
@property(nonatomic,strong) CAShapeLayer *barLayer;
@property(nonatomic,strong) CAShapeLayer *hAxisLayer;
@end

@implementation GridLayer

/*-(UIBezierPath*)vmarkerPathAtPoint:(CGPoint)point
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point];
    [path addLineToPoint:CGPointMake(point.x - 10.f, point.y)];
    return path;
} */

-(void)layoutSublayers
{
    CGSize gridSize = _data.gridSize;
    
    _barLayer = [CAShapeLayer layer];
    _barLayer.lineDashPattern = @[@(3),@(3)];
    _barLayer.masksToBounds = YES;
    _barLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    _barLayer.lineWidth = 1.f;

    _hAxisLayer = [CAShapeLayer layer];
    _hAxisLayer.strokeColor = [UIColor darkGrayColor].CGColor;
    //_hAxisLayer.masksToBounds = YES;
    _hAxisLayer.lineWidth = 1.f;

    _vAxisLayer = [CAShapeLayer layer];
    _vAxisLayer.strokeColor = [UIColor darkGrayColor].CGColor;
    _vAxisLayer.masksToBounds = YES;
    
    [self addSublayer:_barLayer];
    [self addSublayer:_vAxisLayer];
    [self addSublayer:_hAxisLayer];
    
    _barLayer.bounds = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), gridSize.width, CGRectGetHeight(self.bounds));
    _barLayer.position = CGPointMake(_data.meterAxisData.width+(gridSize.width/2), CGRectGetHeight(self.bounds)/2);
    
    _vAxisLayer.bounds = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), _data.meterAxisData.width, gridSize.height);
    _vAxisLayer.position = CGPointMake(_data.meterAxisData.width/2, gridSize.height/2);
    
    _hAxisLayer.bounds = CGRectMake(_data.meterAxisData.width, gridSize.height, gridSize.width, _data.displayAxisData.width);
    _hAxisLayer.position = CGPointMake(_data.meterAxisData.width+(gridSize.width/2), gridSize.height+(_data.displayAxisData.width/2));
    
    NSInteger noofMeterUnits = _data.meterAxisUnitPoints.count;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    UIBezierPath *displayUnitPath = [UIBezierPath bezierPath];  //will be drawn horizontally.
    displayUnitPath.lineCapStyle = kCGLineCapRound;
    
    [displayUnitPath moveToPoint:CGPointMake(_data.meterAxisData.width, gridSize.height)];
    [displayUnitPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds), gridSize.height)];
    _hAxisLayer.path = displayUnitPath.CGPath;
    
    UIBezierPath *meterMarkPath = [UIBezierPath bezierPath];  //will drawn vertically.
    meterMarkPath.lineCapStyle = kCGLineCapRound;
    meterMarkPath.lineWidth = 1.f;
    
    [meterMarkPath moveToPoint:CGPointMake(_data.meterAxisData.width, CGRectGetHeight(_vAxisLayer.bounds))];
    [meterMarkPath addLineToPoint:CGPointMake(_data.meterAxisData.width, CGRectGetMinX(_vAxisLayer.bounds))];
    _vAxisLayer.path = meterMarkPath.CGPath;
    
    for (int i=0; i<noofMeterUnits; i++)
    {
        NSArray *titles = _data.meterAxisData.titles;
        CGPoint meterPoint = [[_data.meterAxisUnitPoints objectAtIndex:i] CGPointValue];
        
        CGSize textsize = CGSizeMake(_data.meterAxisData.width-MeterAxisPadding, 20);
        CATextLayer *textLayer = [AxisTextLayer meterTextLayerWithSize:textsize string:[titles objectAtIndex:i]];
        textLayer.bounds = CGRectMake(0, 0, textsize.width, textsize.height);
        textLayer.position = CGPointMake((textsize.width/2)-MeterAxisPadding, meterPoint.y-MeterAxisHalfPadding);
        [_vAxisLayer addSublayer:textLayer];
    }
    
    UIBezierPath *meterUnitPath = [UIBezierPath bezierPath];  //will drawn vertically.
    for (int i=1; i<noofMeterUnits; i++)
    {
        UIBezierPath *path = [UIBezierPath bezierPath];
        CGPoint meterPoint = [[_data.meterAxisUnitPoints objectAtIndex:i] CGPointValue];
        CGPoint frompoint = CGPointMake(0, meterPoint.y);
        CGPoint topoint = CGPointMake(gridSize.width, meterPoint.y);
        [path moveToPoint:frompoint];
        [path addLineToPoint:topoint];
        path.lineCapStyle = kCGLineCapButt;
        [meterUnitPath appendPath:path];
    }
    
    [CATransaction setDisableActions:NO];
    
    _barLayer.path = meterUnitPath.CGPath;
    [CATransaction commit];
    
}
@end

@interface GridBGView : UIScrollView
@property(nonatomic, strong) ChartData *chartData;
@property(nonatomic, strong) GridData *gridData;
@property(nonatomic, strong) NSMutableArray *subLayers;
@end

@implementation GridBGView

-(NSArray*)barsProgressHeightForValues:(NSArray*)values
{
    NSMutableArray *boundValues = [NSMutableArray array];
    for (int i=0; i<values.count; i++)
    {
        CGFloat value = [[values objectAtIndex:i] floatValue];
        CGFloat barHeight = (value / _gridData.meterAxisData.oneUnitValue)*_gridData.oneMeterUnitBoundValue;
        [boundValues addObject:[NSNumber numberWithFloat:barHeight]];
    }
    return boundValues;
}

-(void)reloadView
{
    _subLayers = [NSMutableArray array];
    NSInteger noofBarsInSection = _chartData.noOfBars;
    NSInteger noofSections = _chartData.noOfSections;
    CGFloat sectionWidth = FixedBarWidth * _chartData.noOfBars + FixedBarWidth;
    CGFloat sectionHeight = _gridData.gridSize.height;
    
    self.contentSize = CGSizeMake(sectionWidth*noofSections, CGRectGetHeight(self.bounds));
    
    for (int i=0; i<noofSections; i++)
    {
        NSArray *barValues = [_chartData.values objectAtIndex:i];
        NSInteger sectionindex = i;
        BarSectionLayer *sectionLayer = [BarSectionLayer layer];
        sectionLayer.backgroundColor = [[UIColor clearColor] CGColor];
        sectionLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        sectionLayer.index = sectionindex;
        sectionLayer.opacity = 0.8f;
        sectionLayer.noofBars = noofBarsInSection;
        sectionLayer.values = barValues; //barValues.count should equal to noOfBars
        sectionLayer.boundValues = [self barsProgressHeightForValues:barValues];
        sectionLayer.anchorPoint = CGPointMake(.5f, .5f);
        sectionLayer.bounds = CGRectMake(0, 0, sectionWidth, sectionHeight);
        sectionLayer.size = CGSizeMake(sectionWidth, sectionHeight);
        sectionLayer.bPosition = CGPointMake((sectionindex+0.5f)*sectionWidth, sectionHeight*0.5f);
        sectionLayer.position = CGPointMake((sectionindex+0.5f)*sectionWidth, sectionHeight*0.5f);
        
        [self.layer addSublayer:sectionLayer];
        [_subLayers addObject:sectionLayer];
    }
    
    NSInteger noOfDisplayUnits = _gridData.displayAxisData.titles.count;
    for (int i=0; i<noOfDisplayUnits; i++)
    {
        NSArray *titles = _gridData.displayAxisData.titles;
        CGPoint displayPoint = [[_gridData.displayAxisUnitPoints objectAtIndex:i] CGPointValue];
        
        CGSize textsize = CGSizeMake(_gridData.displayAxisData.width-DisplayAxisPadding, 20);
        CATextLayer *textLayer = [AxisTextLayer displayTextLayerWithSize:textsize string:[titles objectAtIndex:i]];
        textLayer.bounds = CGRectMake(0, 0, textsize.width, textsize.height);
        textLayer.affineTransform = CGAffineTransformMakeRotation(-M_PI_4);
        textLayer.alignmentMode = kCAAlignmentRight;
        
        BarSectionLayer *sectionLayer = [_subLayers objectAtIndex:i];
        [sectionLayer addSublayer:textLayer];
        
        textLayer.position = CGPointMake(displayPoint.x, displayPoint.y);
    }

}

-(void)drawRect:(CGRect)rect {
    [self reloadView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touched GridBGView");
    for (UITouch *touch in touches)
    {
        CGPoint touchLocation = [touch locationInView:self];
        for (id sublayer in self.layer.sublayers) {
            BOOL touchInLayer = NO;
            if ([sublayer isKindOfClass:[CAShapeLayer class]]) {
                CAShapeLayer *shapeLayer = sublayer;
                if (CGPathContainsPoint(shapeLayer.path, 0, touchLocation, YES)) {
                    // This touch is in this shape layer
                    shapeLayer.backgroundColor = [UIColor greenColor].CGColor;
                    touchInLayer = YES;
                }
            }
            else {
                CALayer *layer = sublayer;
                if (CGRectContainsPoint(layer.frame, touchLocation)) {
                    // Touch is in this rectangular layer
                    layer.backgroundColor = [UIColor greenColor].CGColor;
                    touchInLayer = YES;
                }
            }
        }
    }
}

@end

@interface HorizonBarView() <UIScrollViewDelegate>
{
    GridBGView *gridDataView;
    NSMutableArray *sectionLayers;
    CGSize sectionSize;
    CGFloat horizontalTitleViewHeight;
    GridData *gridData;
    ChartData *chartData;
    CGRect gridFrame;
    GridLayer *gridview;
}
@end

@implementation HorizonBarView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES;
        
        //BG line grid
        gridview = [GridLayer layer];
        gridview.backgroundColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:gridview];
        
        gridDataView = [[GridBGView alloc] init];
        gridDataView.backgroundColor = [UIColor clearColor];
        gridDataView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        gridDataView.bounces = YES;
        [self addSubview:gridDataView];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

-(void)reloadBarView
{
    chartData = [[ChartData alloc] initWithData:_chartInfo];
    
    gridData = [[GridData alloc] initWithChartSize:self.bounds.size];
    gridData.chartType = VerticalBarChart;
    [gridData setUpChartData:chartData];
    
    //Bar display scrollview
    CGPoint bgGridLayerPosition = CGPointMake((CGRectGetWidth(self.bounds)/2), CGRectGetHeight(self.bounds)/2);
    
    gridview.bounds = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    gridview.position = bgGridLayerPosition;
    gridview.data = gridData;
    
    gridFrame = CGRectMake(gridData.meterAxisData.width, 0, gridData.gridSize.width, CGRectGetHeight(self.bounds));
    gridDataView.frame = gridFrame;
    gridDataView.backgroundColor = [UIColor clearColor];
    gridDataView.chartData = chartData;
    gridDataView.gridData = gridData;
}

- (void)drawRect:(CGRect)rect
{
    [self reloadBarView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    return;
    for (UITouch *touch in touches)
    {
        CGPoint touchLocation = [touch locationInView:self];
        for (id sublayer in self.layer.sublayers) {
            BOOL touchInLayer = NO;
            //if ([sublayer isKindOfClass:[CAShapeLayer class]]) {
            CAShapeLayer *shapeLayer = sublayer;
                            if (CGPathContainsPoint(shapeLayer.path, 0, touchLocation, YES)) {
                                // This touch is in this shape layer
                                shapeLayer.backgroundColor = [UIColor greenColor].CGColor;
                                touchInLayer = YES;
                            }
            //} else {
            //CALayer *layer = sublayer;
            if (CGRectContainsPoint(shapeLayer.frame, touchLocation)) {
                // Touch is in this rectangular layer
                shapeLayer.backgroundColor = [UIColor greenColor].CGColor;
                touchInLayer = YES;
            }
            //}
        }
    }
}


@end



