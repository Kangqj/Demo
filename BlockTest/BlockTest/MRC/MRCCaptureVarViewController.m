//
//  MRCCaptureVarViewController.m
//  BlockTest
//
//  Created by 康起军 on 16/6/4.
//  Copyright © 2016年 康起军. All rights reserved.
//

#import "MRCCaptureVarViewController.h"
#import "TestEntity.h"

//1.全局block
typedef NSString * (^ Block1)(NSString *a);

@interface MRCCaptureVarViewController ()
{
    Block1 curBlock;
    
    NSString *string1;
}

@property (copy, nonatomic) Block1 curBlock;
@property (strong, nonatomic) NSString *string1;

@end

@implementation MRCCaptureVarViewController

@synthesize curBlock, string1;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self showDifferentBlock];
}

- (void)showDifferentBlock
{
    int *a = 1;
    void (^block1)() = ^(void)
    {
        *a = 2;
    };
    
    NSLog(@"%d",*a);
    
    TestEntity *entity1 = [[TestEntity alloc] init];
    entity1.name = @"1";
    
    NSString * (^block2)(NSString *) = ^(NSString *a)
    {
        entity1.name = @"2";
        
        return entity1.name;
    };
    
    entity1.name = @"3";

    block2(nil);
    
    NSLog(@"block1-> %@ %@", block2, block2(@"0"));
    
    
    
//    NSString *string3 = @"3";
    
    /*
    self.string1 = @"3";
    
    __block typeof(self)weakSelf = self;
    
    NSString * (^block3)(NSString *) = ^(NSString *a)
    {
        weakSelf.string1 = [weakSelf.string1 stringByAppendingString:@"000"];
        NSLog(@"%@", weakSelf.string1);
        
        return weakSelf.string1;
    };
    
    NSLog(@"block3-> %@", block3);
    
    [self testBlock:block3];
     */
}

//3.作为参数传递的block
- (void)testBlock:(NSString *(^)(NSString *a))block
{
    self.curBlock = block;
    NSLog(@"block1-> %@", curBlock);
}

- (void)dealloc
{
    NSLog(@"MRC dealloc");
    
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
