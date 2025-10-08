#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CustomIconManager : NSObject

+ (instancetype _Nonnull)sharedManager;
- (void)saveCustomIcon:(UIImage * _Nonnull)image withCompletion:(void (^ _Nullable)(BOOL success, NSError * _Nullable error))completion;
- (void)setCustomIconWithCompletion:(void (^ _Nullable)(BOOL success, NSError * _Nullable error))completion;
- (BOOL)hasCustomIcon;
- (void)removeCustomIcon;

@end