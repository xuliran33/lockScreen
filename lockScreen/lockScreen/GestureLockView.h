//
//  GestureLockView.h
//  
//
//  Created by gdj003 on 16/5/6.
//
//

#import <UIKit/UIKit.h>
@class GestureLockView;
@protocol GestureLockViewDeldgate <NSObject>

@optional
// 开始设置手势
- (void)lockView:(GestureLockView *)lockView BeganTouch:(NSSet *)touches;
// 绘制路径完成
- (void)lockView:(GestureLockView *)lockView didFinishPath:(NSString *)path shortImage:(UIImage *)shortImage;

@end

@interface GestureLockView : UIView

@property(nonatomic, weak) id<GestureLockViewDeldgate> delegate;

// 截图
-(UIImage *)getShotImage;

@end


