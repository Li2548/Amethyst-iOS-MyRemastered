#import <Foundation/Foundation.h>

@interface JITManager : NSObject

+ (instancetype)sharedManager;
- (BOOL)enableJITForCurrentProcess;
- (BOOL)isJITSupported;

@end