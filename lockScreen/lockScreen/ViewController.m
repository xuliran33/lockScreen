//
//  ViewController.m
//  lockScreen
//
//  Created by gdj003 on 16/5/6.
//  Copyright (c) 2016年 xuliran. All rights reserved.
//

#import "ViewController.h"
#import "SetGestureLockViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setGestureLock:(UIButton *)sender {
    SetGestureLockViewController *setLock = [[SetGestureLockViewController alloc] init];
    
    [self presentViewController:setLock animated:YES completion:nil];
    
}
@end
