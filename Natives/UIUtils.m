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
    // 使用UIView的弹簧动画实现适度的非线性效果
    // 先创建一个轻微的缩放效果，然后弹回原始大小
    CGAffineTransform originalTransform = view.transform;
    CGAffineTransform scaledTransform = CGAffineTransformScale(originalTransform, 0.99, 0.99);
    
    [UIView animateWithDuration:duration * [self getAnimationSpeed] / 2
                          delay:0
         usingSpringWithDamping:0.85  // 更柔和的弹性阻尼
          initialSpringVelocity:0.15  // 更低的初始速度
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
        view.transform = scaledTransform;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration * [self getAnimationSpeed] / 2
                              delay:0
             usingSpringWithDamping:0.8  // 更柔和的弹性阻尼
              initialSpringVelocity:0.1
                            options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
            view.transform = originalTransform;
        } completion:nil];
    }];
}

+ (CGFloat)getAnimationSpeed {
    // 从偏好设置中获取动画速度，默认为1.0（正常速度）
    // 确保返回值至少为0.1，避免动画时间过短或为0
    CGFloat speed = getPrefFloat(@"general.animation_speed");
    return speed > 0 ? speed : 1.0;
}

+ (void)setAnimationSpeed:(CGFloat)speed {
    // 保存动画速度到偏好设置
    setPrefFloat(@"general.animation_speed", speed);
}

@end