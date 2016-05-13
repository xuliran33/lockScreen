//
//  SetGestureLockViewController.h
//  
//
//  Created by gdj003 on 16/5/6.
//
//

#import <UIKit/UIKit.h>

typedef void (^NoticeSwitchOffBlock)(BOOL isCancel);

@interface SetGestureLockViewController : UIViewController

@property(nonatomic, copy) NoticeSwitchOffBlock noticeBlock;

@end
