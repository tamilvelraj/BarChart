//
//  ViewController.h
//  LithuBarChart
//
//  Created by Thamil Selvan V on 17/02/16.
//
//

#import "ViewController.h"
#import "HorizonBarView.h"

@interface ViewController () {
    NSTimer *_animationTimer;
}

@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = _chartTitle;

    CGRect frame = self.view.bounds;
    frame.origin.y = 0;
    frame.size.height = frame.size.height - 64.f;
    HorizonBarView *barview = [[HorizonBarView alloc] initWithFrame:frame];
    barview.chartInfo = _chartInfo;
    [self.view addSubview:barview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
