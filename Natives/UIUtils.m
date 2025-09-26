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
    // 使用UIView的弹簧动画实现更明显的非线性效果
    // 先创建一个更明显的缩放效果，然后弹回原始大小
    CGAffineTransform originalTransform = view.transform;
    CGAffineTransform scaledTransform = CGAffineTransformScale(originalTransform, 0.90, 0.90);
    
    // 添加轻微的旋转效果增强视觉反馈
    CGAffineTransform rotatedTransform = CGAffineTransformRotate(scaledTransform, 0.05);
    
    [UIView animateWithDuration:duration * [self getAnimationSpeed] / 3
                          delay:0
         usingSpringWithDamping:0.6  // 更有弹性的阻尼
          initialSpringVelocity:0.5  // 增加初始速度
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
        view.transform = rotatedTransform;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration * [self getAnimationSpeed] / 1.5
                              delay:0
             usingSpringWithDamping:0.5  // 更有弹性的阻尼
              initialSpringVelocity:0.3
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