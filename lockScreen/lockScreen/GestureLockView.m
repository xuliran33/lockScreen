//
//  GestureLockView.m
//  
//
//  Created by gdj003 on 16/5/6.
//
//

#import "GestureLockView.h"

#define BUttonW 64
#define SmallViewButtonW 12

@interface GestureLockView ()
@property(nonatomic, retain) NSMutableArray *selectedButtons;
@property(nonatomic, assign) CGPoint currtenMovePoint;

@end

@implementation GestureLockView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor whiteColor];
        [self SetupSubviews];
    }
    return  self;
}

// 添加密码图案
- (void)SetupSubviews{
    for (int inIndex = 0; inIndex < 9; inIndex++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = inIndex;
        btn.userInteractionEnabled = NO;
        [btn setBackgroundImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateSelected];
        [self addSubview:btn];
    }
}
// 给密码图案设置尺寸
- (void)layoutSubviews{
    [super layoutSubviews];
    for (int index = 0; index < self.subviews.count; index++) {
        // 去除按钮
        UIButton *btn = self.subviews[index];
        // 设置frame
        // 总行/列数
        int totalColumns = 3;
        // 位置
        int col = index % totalColumns;
        int row = index / totalColumns;
        // 间距
        CGFloat marginX = (self.frame.size.width - totalColumns * BUttonW) / (totalColumns + 1);
        CGFloat btnX = marginX + col * (BUttonW + marginX);
        CGFloat btnY = marginX + row * (BUttonW + marginX);
        btn.frame = CGRectMake(btnX, btnY, BUttonW, BUttonW);
    }
}

// 根据touches集合获得对应的触摸点
- (CGPoint)pointWithTouches:(NSSet *)touches{
    UITouch *touch = [touches anyObject];
    return [touch locationInView:touch.view];
}

// 根据触摸点位置获得对应的按钮
- (UIButton *)buttonWithPoint:(CGPoint)point{
    for (UIButton *button in self.subviews) {
        // 判断点是否被frame包含
        if (CGRectContainsPoint(button.frame, point)){
            return button;
        }
    }
    return nil;
}

#pragma mark -------- 触摸方法
// 开始点击
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([self.delegate respondsToSelector:@selector(lockView:BeganTouch:)]){
        [self.delegate lockView:self BeganTouch:touches];
    }
    
    // 清空当前触摸点
    self.currtenMovePoint = CGPointMake(-10, -10);
    // 获得触摸点
    CGPoint pos = [self pointWithTouches:touches];
    // 获得触摸的按钮
    UIButton *btn = [self buttonWithPoint:pos];
    // 设置状态
    if (btn && btn.selected == NO){
        btn.selected = YES;
        [self.selectedButtons addObject:btn];
    }
    // 刷新,调用drawRect方法
    [self setNeedsDisplay];
}

// 触摸中移动
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    // 1. 获得触摸点
    CGPoint pos = [self pointWithTouches:touches];
    // 2. 或得触摸的按钮
    UIButton *btn = [self buttonWithPoint:pos];
    // 设置状态
    if (btn && btn.selected == NO){
        // 触摸到了按钮
        btn.selected = YES;
        [self.selectedButtons addObject: btn];
    }else{
        // 没有触摸到按钮
        self.currtenMovePoint = pos;
    }
    
    // 4. 刷新
    [self setNeedsDisplay];

}

// 绘制结束
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([self.delegate respondsToSelector:@selector(lockView:didFinishPath:shortImage:)]){
        NSMutableString *path = [NSMutableString string];
        for (UIButton *btn in self.selectedButtons) {
            [path appendFormat:@"%ld", (long)btn.tag];
        }
        NSLog(@"--->>>path: %@", path);
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.frame.size.width, self.frame.size.height), YES, 0);
        [[self layer] renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *shotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self.delegate lockView:self didFinishPath:path shortImage:shotImage];
        
        // 取消所选中的按钮
        
//        for (UIButton *button in self.selectedButtons){
//            [button setSelected:NO];
//        }
        
        [self.selectedButtons makeObjectsPerformSelector:@selector(setSelected:) withObject:@(NO)];
        [self.selectedButtons removeAllObjects];
        
        [self setNeedsDisplay];

    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - 绘图
- (void)drawRect:(CGRect)rect{
    if (self.selectedButtons.count == 0) return;
    
    // 画bezier曲线
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // 遍历所有的按钮
    for (int index = 0; index < self.selectedButtons.count; index++){
        UIButton *btn = self.selectedButtons[index];
        if (index == 0){
            [path moveToPoint:btn.center];
        }else{
            [path addLineToPoint:btn.center];
        }
    }
    
    // 连接
    if (CGPointEqualToPoint(self.currtenMovePoint, CGPointMake(-10, -10)) == NO){
        if (CGRectContainsPoint(self.frame, self.currtenMovePoint) == NO){
            [path addLineToPoint:self.currtenMovePoint];
        }
    }
    // 绘图
    path.lineWidth = 5;
    
    path.lineJoinStyle = kCGLineJoinBevel;
    [[UIColor blackColor] set];
    [path stroke];
}

#pragma mark -------- 懒加载
- (NSMutableArray *)selectedButtons{
    if (_selectedButtons == nil) {
        _selectedButtons = [NSMutableArray array];
    }
    return _selectedButtons;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
