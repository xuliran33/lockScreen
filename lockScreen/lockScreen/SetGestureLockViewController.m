//
//  SetGestureLockViewController.m
//  
//
//  Created by gdj003 on 16/5/6.
//
//

#import "SetGestureLockViewController.h"
#import "GestureLockView.h"

#define tipLabelFontSize 20
#define MarginY 10
#define TextColor [UIColor blueColor]

@interface SetGestureLockViewController ()<GestureLockViewDeldgate>
// 手势密码截图
@property(nonatomic, weak) UIImageView *lockViewShotView;
// 提示信息
@property(nonatomic, weak) UILabel *tipLabel;
// 重置
@property(nonatomic, weak) UIButton *reseButton;
// 第一次手势密码
@property(nonatomic, copy) NSString *firstLockPath;
// 确认密码
@property(nonatomic, copy) NSString *secondLockPath;
// 绘制手势密码的view
@property(nonatomic, weak) GestureLockView *gestureLockView;

@end

@implementation SetGestureLockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupSubViews];
    // Do any additional setup after loading the view.;
}

- (void)setupSubViews{
    CGFloat mainViewW = self.view.frame.size.width;
    CGFloat mainViewH = self.view.frame.size.height;
    
    CGFloat smallLockViewW = 100.0;
    CGFloat smallLockViewH = 100.0;
    CGFloat smallLockViewX = (mainViewW -smallLockViewW) / 2.0;
    CGFloat smallLockViewY = 40.f;
    UIImageView *lockViewShotView = [[UIImageView alloc] init];
    lockViewShotView.frame = CGRectMake(smallLockViewX, smallLockViewY, smallLockViewW, smallLockViewH);
    [self.view addSubview: lockViewShotView];
    self.lockViewShotView = lockViewShotView;
    
    CGFloat tiplabelH = 32.0;
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.lockViewShotView.frame) + MarginY, mainViewW, tiplabelH)];
    tipLabel.text = @"请输入您的手势密码";
    tipLabel.textColor = TextColor;
    tipLabel.font = [UIFont systemFontOfSize:tipLabelFontSize];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
    self.tipLabel = tipLabel;
    
    CGFloat lockViewW = self.view.frame.size.width;
    GestureLockView *lockView = [[GestureLockView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tipLabel.frame) + MarginY, lockViewW, lockViewW)];
    
//    lockView.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:lockView];
    lockView.delegate =self;
    self.gestureLockView = lockView;
    [self GetLockViewShot];
    
    CGFloat buttonH = 30;
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:TextColor forState:UIControlStateNormal];
    cancelButton.frame = CGRectMake(20, mainViewH - buttonH - 20, 80, buttonH);
    [cancelButton addTarget:self action:@selector(ClickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resetButton.hidden = YES;
    [resetButton setTitle:@"重设" forState:UIControlStateNormal];
    [resetButton setTitleColor:TextColor forState:UIControlStateNormal];
    resetButton.frame = CGRectMake(mainViewW - 80 - 20, cancelButton.frame.origin.y, 80, buttonH);
    [resetButton addTarget:self action:@selector(ClickResetButon:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetButton];
    self.reseButton = resetButton;

}

// 截图
-(void)GetLockViewShot{
    // 设置截屏的大小
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.gestureLockView.frame.size.width, self.gestureLockView.frame.size.height), YES, 0);
    // 开始截图
    [[self.gestureLockView layer] renderInContext:UIGraphicsGetCurrentContext()];
    // 获取屏幕截图
    UIImage *shotImage = UIGraphicsGetImageFromCurrentImageContext();
    // 结束截图
    UIGraphicsEndImageContext();
    
    self.lockViewShotView.image = shotImage;
}

// 取消
- (void)ClickCancelButton:(UIButton *)button{
    [self dismissViewControllerAnimated:YES completion:nil];


}

// 重设
- (void)ClickResetButon:(UIButton *)button{
    self.firstLockPath = @"";
    self.tipLabel.textColor = TextColor;
    self.tipLabel.text = @"请设置您的手势密码";
    [self GetLockViewShot];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ---- GestureLockView delegate
- (void)lockView:(GestureLockView *)lockView BeganTouch:(NSSet *)touches{
    self.tipLabel.textColor = TextColor;
    self.tipLabel.text = @"请输入您的手势密码";
}

- (void)lockView:(GestureLockView *)lockView didFinishPath:(NSString *)path shortImage:(UIImage *)shortImage{
    if (path.length < 4){
        self.tipLabel.textColor = [UIColor redColor];
        self.tipLabel.text = @"请连接至少4个点";
        return ;
    }
    if (self.firstLockPath.length){
        if ([path isEqualToString:self.firstLockPath]){
            self.tipLabel.textColor = TextColor;
            self.tipLabel.text = @"手势密码设置成功";
            [self SaveLockPath:path];
            [NSThread sleepForTimeInterval:1.2];
            [self dismissViewControllerAnimated:YES completion:nil];
            if (_noticeBlock){
                _noticeBlock(NO);
            }
        }else{
                self.tipLabel.textColor = [UIColor redColor];
                self.tipLabel.text = @"两次密码输入不一致";
                self.reseButton.hidden = NO;
        }

    }else{
        self.firstLockPath = [path copy];
        self.lockViewShotView.image = shortImage;
    }
}

- (void)SaveLockPath:(NSString *)path{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setObject:path forKey:@"LockPath"];
    // 线程锁
    // 不管哪一个线程, 在运行到该方法时, 都要检查是不是有其他方法在使用这个线程, 如果有其他方法在使用该线程, 则在其他方法执行完成之后该方法再执行此线程, 否则此线程直接执行该方法
    [userDef synchronize];
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
