//
//  ViewController.m
//  CrashDemo
//
//  Created by 康起军 on 16/4/27.
//  Copyright © 2016年 康起军. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *dataArr;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *arr1 = [NSArray arrayWithObjects:@"手势密码", @"Touch ID", @"字母密码", nil];
    
    NSArray *arr2 = [NSArray arrayWithObjects:@"更改密码", @"设置伪装密码", nil];
    
    NSArray *arr3 = [NSArray arrayWithObjects:@"摇一摇关闭应用", @"摇一摇锁屏", nil];
    
    NSArray *arr4 = [NSArray arrayWithObjects:@"更改App图标", @"设置伪装", nil];

    NSArray *arr5 = [NSArray arrayWithObjects:@"入侵抓拍",@"抓拍记录",nil];

    NSArray *arr6 = [NSArray arrayWithObjects:@"意见反馈",@"评价",nil];

    NSArray *arr7 = [NSArray arrayWithObjects:@"关于我们",nil];

    NSArray *arr8 = [NSArray arrayWithObjects:@"销毁账户",nil];
    
    dataArr = [[NSMutableArray alloc] initWithObjects:arr1, arr2, arr3, arr4, arr5, arr6, arr7, arr8, nil];
    
    
    UITableView *m_tableview = [[UITableView alloc] initWithFrame:self.view.bounds];
    m_tableview.delegate = self;
    m_tableview.dataSource = self;
    [self.view addSubview:m_tableview];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor lightGrayColor];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = [dataArr objectAtIndex:section];
    return arr.count;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
    NSArray *arr = [dataArr objectAtIndex:indexPath.section];
    cell.textLabel.text = [arr objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
