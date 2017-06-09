//
//  ChartListViewController.m
//  TestWaitingView
//
//  Created by Thamil Selvan V on 16/02/16.
//  Copyright © 2016. All rights reserved.
//

#import "ChartListViewController.h"
#import "HorizonBarView.h"
#import "ViewController.h"

#define CellIdentifier @"Cell"

@interface ChartListViewController ()
{
    NSMutableArray *chartInfoList;
    NSMutableArray *chartTitleList;
}
@end

@implementation ChartListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Bar Charts";
    self.navigationController.navigationBar.translucent = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    chartInfoList = [NSMutableArray array];
    NSMutableArray *values = @[@[@(16368)],@[@(15568)],@[@(12200)],@[@(7340)],@[@(4420)],@[@(4230)],@[@(3980)],@[@(3378)],@[@(2944)],@[@(1678)]].mutableCopy;
    NSMutableArray *titles = @[@"Catherine Thomas",@"Susanne Peters",@"Jennifer Adcock",@"Stephenson Adam",@"Jualianna Baldwin",@"Baker McBurne",@"Christopher Bailey",@"Alexandar Bolton",@"Benjamin Bold",@"Cameron Carter"].mutableCopy;
    NSMutableDictionary *chartDict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:values,CHART_VALUES,titles,CHART_TITLES,@(16368),CHART_MAX_VALUE,@(1678),CHART_MIN_VALUE, nil];
    
    values = @[@[@(297571)],@[@(267017)],@[@(175200)],@[@(154580)],@[@(116000)],@[@(97800)],@[@(20682)],@[@(20350)]].mutableCopy;
    titles = @[@"Venezuela",@"Saudi",@"Canada",@"Iran",@"Russia",@"UAE",@"US",@"China"].mutableCopy;
    NSMutableDictionary *chartDict2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:values,CHART_VALUES,titles,CHART_TITLES,@(297571.f),CHART_MAX_VALUE,@(20350.f),CHART_MIN_VALUE, nil];
    
    values = @[@[@(57),@(21),@(105),@(36),@(56)],@[@(39),@(75),@(9),@(60),@(36)],@[@(63),@(99),@(15),@(84),@(42)],@[@(30),@(66),@(18),@(51),@(22)],@[@(12),@(24),@(60),@(9),@(7)]].mutableCopy;
    titles = @[@"Sehwag",@"Kallis",@"Ponting",@"Sachin",@"Yousuf"].mutableCopy;
    NSMutableDictionary *chartDict3 = [NSMutableDictionary dictionaryWithObjectsAndKeys:values,CHART_VALUES,titles,CHART_TITLES,@(150),CHART_MAX_VALUE,@(0),CHART_MIN_VALUE, nil];

    [chartInfoList addObject:chartDict1];
    [chartInfoList addObject:chartDict2];
    [chartInfoList addObject:chartDict3];
    
    chartTitleList = [NSMutableArray arrayWithObjects:@"Top 10 Sales People(2016) In USD",@"Petrol Exports In Barrells",@"Cricketer Scores In diff bowlers", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return chartInfoList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [chartTitleList objectAtIndex:indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *chartInfo = [chartInfoList objectAtIndex:indexPath.row];
    ViewController *controller = [[ViewController alloc] init];
    controller.chartInfo = chartInfo;
    controller.chartTitle = [chartTitleList objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
