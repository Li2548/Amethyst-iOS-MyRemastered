#import <UIKit/UIKit.h>

@interface UIUtils : NSObject

+ (void)applyRoundedCorners:(UIView *)view;
+ (void)applyRoundedCorners:(UIView *)view cornerRadius:(CGFloat)radius;
+ (void)applyNonLinearAnimation:(UIView *)view;
+ (void)applyNonLinearAnimation:(UIView *)view duration:(CGFloat)duration;
+ (CGFloat)getAnimationSpeed;
+ (void)setAnimationSpeed:(CGFloat)speed;

@end