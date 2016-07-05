//
//  MRCBlockViewController.m
//  BlockTest
//
//  Created by 康起军 on 16/5/29.
//  Copyright © 2016年 康起军. All rights reserved.
//

#import "MRCBlockViewController.h"
#import "MRCThreeBlockSViewController.h"
#import "MRCCaptureVarViewController.h"

@interface MRCBlockViewController ()

@end

@implementation MRCBlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
#if __has_feature(objc_arc)
    NSLog(@"---ARC环境---");
    self.title = @"ARC环境下的Block";
#else
    NSLog(@"---MRC环境---");
    self.title = @"MRC环境下的Block";
#endif
    
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - UITableViewDelegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = @"三种Block";
            break;
            
        case 1:
            cell.textLabel.text = @"Block引用外部变量";
            break;
            
        case 2:
            cell.textLabel.text = @"Block的循环引用";
            break;
            
        default:
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            MRCThreeBlockSViewController *viewController = [[MRCThreeBlockSViewController alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
            [viewController release];
            
            break;
        }
            
        case 1:
        {
            MRCCaptureVarViewController *viewController = [[MRCCaptureVarViewController alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
            [viewController release];
            
            break;
        }
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
