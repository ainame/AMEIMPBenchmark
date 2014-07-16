//
//  AMEBenchmarkViewController.m
//  AMEIMPBenchmark
//
//  Created by satoshi.namai on 2014/07/16.
//  Copyright (c) 2014年 ainame. All rights reserved.
//

#import "AMEBenchmarkViewController.h"
#import <objc/runtime.h>

@interface AMEBenchmarkViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation AMEBenchmarkViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.label.text = @"ベンチマーク開始";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // NOTE: 2分探索は比較回数が平均log_2(N)で探索できる
    // log_2(10000000)でも23回程度の比較で挿入できるので20回配列要素を取得する操作を実行した結果を求める
    NSLog(@"times,  length,      imp,      sel");
    [self compareWithTimes:20 length:10];
    [self compareWithTimes:20 length:100];
    [self compareWithTimes:20 length:1000];
    [self compareWithTimes:20 length:10000];
    [self compareWithTimes:20 length:100000];
    [self compareWithTimes:20 length:1000000];
    [self compareWithTimes:20 length:10000000];
    self.label.text = @"ベンチマーク終了";
}

- (void)compareWithTimes:(NSUInteger)times length:(NSUInteger)length
{
    NSTimeInterval resultIMP = [self doIterateByIMPWithTimes:times length:length];
    NSTimeInterval resultNormalSendMessage = [self doIterateByNormalSendMessageWithTimes:times length:length];
    NSLog(@"%4d, %8d, %f, %f", (int)times, (int)length, resultIMP, resultNormalSendMessage);
}

- (NSArray *)createArrayWithLength:(NSUInteger)length
{
    NSMutableArray *array = [@[] mutableCopy];
    for (int i = 0; i < length; i++) {
        NSNumber *number = @(rand() % 10000);
        [array addObject:number];
    }
    return [array copy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSTimeInterval)doIterateByIMPWithTimes:(NSUInteger)times length:(NSUInteger)length
{
    NSArray *array = [self createArrayWithLength:length];
    IMP objectAtIndexImp = [array methodForSelector:@selector(objectAtIndex:)];
    NSTimeInterval sum = 0;
    for (int time = 0; time < times; time++) {
        for (int iterate = 0; iterate < 100; iterate++) {
            NSDate *start = [NSDate date];
            int i = random() % length;
            objectAtIndexImp(array, @selector(objectAtIndex:), i);
            NSDate *finish = [NSDate date];
            sum += [finish timeIntervalSinceDate:start];
        }
    }
    NSTimeInterval ave = (NSTimeInterval)sum / 100;
    return ave;
}

- (NSTimeInterval)doIterateByNormalSendMessageWithTimes:(NSUInteger)times length:(NSUInteger)length
{
    NSArray *array = [self createArrayWithLength:length];
    NSTimeInterval sum = 0;
    for (int time = 0; time < times; time++) {
        for (int iterate = 0; iterate < 100; iterate++) {
            NSDate *start = [NSDate date];
            int i = random() % length;
            [array objectAtIndex:i];
            NSDate *finish = [NSDate date];
            sum += [finish timeIntervalSinceDate:start];
        }
    }
    NSTimeInterval ave = (NSTimeInterval)sum / 100;
    return ave;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
