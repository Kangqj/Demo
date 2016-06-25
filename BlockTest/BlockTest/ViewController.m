//
//  ViewController.m
//  BlockTest
//
//  Created by 康起军 on 16/5/1.
//  Copyright © 2016年 康起军. All rights reserved.
//

#import "ViewController.h"
#import "TestEntity.h"
#import "MRCBlockViewController.h"
#import "ARCBlockViewController.h"

#define TLog(prefix,Obj) {NSLog(@"变量内存地址：%p, 变量值：%p, 指向对象值：%@, --> %@",&Obj,Obj,Obj,prefix);}

//1.全局block
typedef NSString * (^ Block1)(NSString *a);

@interface ViewController ()
{
    Block1 block1;
    
    NSString *string1;
}

@property (copy, nonatomic) Block1 block1;
@property (strong, nonatomic) NSString *string1;

@end

@implementation ViewController

@synthesize block1,string1;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //显示三种类型的block
//    [self showDifferentBlock];
    
    //数组中加入__NSStackBlock__
//    [self blockTest1];
    
    //数组中加入__NSGlobalBlock__
//    [self blockTest2];
    
    //block作为函数返回值
//    Block1 block = [self blockTest3];
//    block(@"a");
    
    //block的循环引用
//    [self recycleTest];
}

#pragma mark - UITableViewDelegate methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

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
            cell.textLabel.text = @"MRC下的Block";
            break;
            
        case 1:
            cell.textLabel.text = @"ARC下的Block";
            break;
            
        default:
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        MRCBlockViewController *viewController = [[MRCBlockViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else
    {
        ARCBlockViewController *viewController = [[ARCBlockViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark 三种类型的block

- (void)showDifferentBlock
{
    //2.局部block
    NSString * (^block2)(NSString *) = ^(NSString *a)
    {
        return [a stringByAppendingString:@"000"];
    };
    
    NSLog(@"block2-> %@", block2);
    
    //block中使用局部变量
    __block NSString *str = @"4";
    NSString * (^block4)(NSString *) = ^(NSString *a)
    {
        str = [str stringByAppendingString:@"000"];
        NSLog(@"%@", str);
        
        return str;
    };
    
    NSLog(@"block4-> %@", block4);
    
    //block中使用全局变量
    self.string1 = @"3";
    NSString * (^block3)(NSString *) = ^(NSString *a)
    {
        self.string1 = [self.string1 stringByAppendingString:@"000"];
        NSLog(@"%@", self.string1);
        
        return self.string1;
    };
    
    NSLog(@"block3-> %@", block3);
    
    [self testBlock:block3];
}

//3.作为参数传递的block
- (void)testBlock:(NSString *(^)(NSString *a))block
{
    self.block1 = block;
    NSLog(@"block1-> %@", block1);
}

#pragma mark 数组中加入__NSStackBlock__

- (void)blockTest1
{
    NSMutableArray *arr = [NSMutableArray array];
    /*
    void (^testBlock)() = ^{
        NSLog(@"%@",self.string1);
    };
    
    NSLog(@"testBlock-> %@",testBlock);
    [self addBlock:testBlock ToArr:arr];
    */
    [self addBlockToArr:arr];
    void (^block)() = [arr objectAtIndex:0];
    block();
}

- (void)addBlock:(void (^)())block ToArr:(NSMutableArray *)arr
{
    [arr addObject:block];
}

- (void)addBlockToArr:(NSMutableArray *)arr
{
    void (^testBlock1)() = ^{
        NSLog(@"%@",self.string1);
    };
    
    NSLog(@"testBlock1-> %@",testBlock1);

    [arr addObject:testBlock1];
}

#pragma mark 数组中加入__NSGlobalBlock__

- (void)blockTest2
{
    NSMutableArray *arr = [NSMutableArray array];
    [self addGlobalBlockToArr:arr];
    void (^block)() = [arr objectAtIndex:0];
    block();
}

- (void)addGlobalBlockToArr:(NSMutableArray *)arr
{
    void (^testBlock2)() = ^{
        NSLog(@"aaa");
    };
    
    NSLog(@"testBlock2-> %@",testBlock2);
    
    [arr addObject:testBlock2];
}

#pragma mark block作为函数返回值

- (Block1 )blockTest3
{
    NSString *str = @"000";
    NSString * (^block5)(NSString *) = ^(NSString *a)
    {
        NSLog(@"%@", a);
        return [a stringByAppendingString:str];
    };
    
    NSLog(@"block5-> %@",block5);

    return block5;
}

#pragma mark block的循环引用

- (void)recycleTest
{
#if __has_feature(objc_arc)
    NSLog(@"---ARC环境---");
    
    TestEntity *entity = [[TestEntity alloc] init];
    entity.name = @"aaa";
    
    TLog(@"entity", entity);

    __weak TestEntity *weak = entity;
    
    TLog(@"weak", weak);

    void (^block)() = ^(){
        TLog(@"weak in block", weak);
    };
    
    entity = nil;
    
    block();
    
    //--------------------------
    
    TestEntity *entityb = [[TestEntity alloc] init];
    entityb.name = @"aaa";
    
    __block TestEntity *weakentity = entityb;
    
    TLog(@"blockentity", weakentity);
    
    void (^blockb)() = ^(){
        TLog(@"blockentity in block", weakentity);
    };
    
    entityb = nil;
    
    blockb();
#else
    NSLog(@"---MRC环境---");
    
    TestEntity *entity = [[TestEntity alloc] init];
    entity.name = @"aaa";
    
    TestEntity *weak = entity;
    
    TLog(@"weak", weak);
    
    void (^block)() = ^(){
        TLog(@"weak in block", weak);
    };
    
    entity = nil;
    
    block();
    
    //--------------------------
    
    TestEntity *entityb = [[TestEntity alloc] init];
    entityb.name = @"aaa";
    
    __block TestEntity *weakentity = entityb;
    
    TLog(@"blockentity", weakentity);
    
    void (^blockb)() = ^(){
        TLog(@"blockentity in block", weakentity);
    };
    
    entityb = nil;
    
    blockb();
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
