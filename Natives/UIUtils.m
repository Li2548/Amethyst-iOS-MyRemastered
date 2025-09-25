#import "UIUtils.h"
#import "LauncherPreferences.h"

@implementation UIUtils

+ (void)applyRoundedCorners:(UIView *)view {
    [self applyRoundedCorners:view cornerRadius:12.0];
}

+ (void)applyRoundedCorners:(UIView *)view cornerRadius:(CGFloat)radius {
    view.layer.cornerRadius = radius;
    view.layer.masksToBounds = YES;
}

+ (void)applyNonLinearAnimation:(UIView *)view {
    [self applyNonLinearAnimation:view duration:0.5];
}

+ (void)applyNonLinearAnimation:(UIView *)view duration:(CGFloat)duration {
    // 使用UIView的弹簧动画实现非线性效果
    [UIView animateWithDuration:duration * [self getAnimationSpeed] 
                          delay:0 
         usingSpringWithDamping:0.8 
          initialSpringVelocity:0 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
        // 触发视图的重新布局或其他视觉变化
        view.alpha = 1.0;
    } completion:nil];
}

+ (CGFloat)getAnimationSpeed {
    // 从偏好设置中获取动画速度，默认为1.0（正常速度）
    return getPrefFloat(@"general.animation_speed") > 0 ? getPrefFloat(@"general.animation_speed") : 1.0;
}

+ (void)setAnimationSpeed:(CGFloat)speed {
    // 保存动画速度到偏好设置
    setPrefFloat(@"general.animation_speed", speed);
}

@end