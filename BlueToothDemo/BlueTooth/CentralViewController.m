//
//  CentralViewController.m
//  BlueTooth
//
//  Created by Kangqj on 15/11/2.
//  Copyright (c) 2015年 Kangqj. All rights reserved.
//

#import "CentralViewController.h"
#import "CentralOperateViewController.h"

@interface CentralViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *myTableView;

@end

@implementation CentralViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"周边信号强度";
    
    [[CentralOperateManager sharedManager] startScanWithFinish:^{}];
    
    UILabel *rssiLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 44)];
    rssiLab.textColor = [UIColor blackColor];
    rssiLab.textAlignment = NSTextAlignmentCenter;
    rssiLab.font = [UIFont systemFontOfSize:10];
    rssiLab.backgroundColor = [UIColor redColor];
    [self.view addSubview:rssiLab];
    
    [[CentralOperateManager sharedManager] getRSSIData:^(NSInteger rssi) {
        
        rssiLab.text = [NSString stringWithFormat:@"信号强度:%d",rssi];
        
    }];
    
//    [self initTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[CentralOperateManager sharedManager] startScanWithFinish:^{
        
        [self.myTableView reloadData];
        
    }];
}


- (void)initTableView
{
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height-60)];
    [self.view addSubview:self.myTableView];
    self.myTableView.dataSource = self;
    self.myTableView.delegate = self;
    
    UIButton *relfash = [UIButton buttonWithType:UIButtonTypeCustom];
    relfash.frame = CGRectMake(0, 0, 40, 40);
    [relfash setTitle:@"刷新" forState:UIControlStateNormal];
    [relfash setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    relfash.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [relfash addTarget:self action:@selector(reflashPeripherals) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:relfash];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setTitle:@"返回" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    leftBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [leftBtn addTarget:self action:@selector(backToMainView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
    [[CentralOperateManager sharedManager] stopScan];
}

- (void)reflashPeripherals
{
    [[CentralOperateManager sharedManager] reflashScan];
}


#pragma mark -Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [CentralOperateManager sharedManager].dataDicArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"characteristicDetailsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    if ([CentralOperateManager sharedManager].dataDicArr.count >indexPath.row)
    {
        NSDictionary *dic = [[CentralOperateManager sharedManager].dataDicArr objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [dic objectForKey:@"name"];
        
        NSArray *arr = [dic objectForKey:@"UUIDs"];
        NSNumber *rssi = [dic objectForKey:@"RSSI"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"services:%zd个 RSSI:%d",arr.count,[rssi intValue]];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //service:0为读数据，
    [[CentralOperateManager sharedManager] connectPeripheral:indexPath.row service:0];
    
    CentralOperateViewController *operateVC = [[CentralOperateViewController alloc] init];
    [self.navigationController pushViewController:operateVC animated:YES];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
