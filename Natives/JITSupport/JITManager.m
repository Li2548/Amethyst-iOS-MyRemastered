#import "JITManager.h"
#import <mach/mach.h>
#import <Foundation/Foundation.h>

// 声明内部的Objective-C类和方法
@interface JITManagerInternal : NSObject
+ (instancetype)sharedManager;
- (BOOL)enableJITForCurrentProcess;
- (BOOL)isJITSupported;
@end

@implementation JITManagerInternal

+ (instancetype)sharedManager {
    static JITManagerInternal *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JITManagerInternal alloc] init];
    });
    return sharedInstance;
}

- (BOOL)enableJITForCurrentProcess {
    // 获取当前任务的mach port
    mach_port_t task = mach_task_self();
    
    // 设置任务的异常端口，这是开启JIT的关键步骤
    kern_return_t kr = task_set_exception_ports(task, 
                                                EXC_MASK_ALL, 
                                                MACH_PORT_NULL, 
                                                EXCEPTION_DEFAULT | MACH_EXCEPTION_CODES, 
                                                THREAD_STATE_NONE);
    
    // 如果调用成功，返回YES
    return kr == KERN_SUCCESS;
}

- (BOOL)isJITSupported {
    // 在iOS 26上，JIT支持是可用的
    return YES;
}

@end

// C接口的实现
void* JITManager_sharedManager(void) {
    return (__bridge_retained void*)[JITManagerInternal sharedManager];
}

int JITManager_enableJITForCurrentProcess(void* manager) {
    if (!manager) return 0;
    JITManagerInternal *obj = (__bridge JITManagerInternal*)manager;
    return [obj enableJITForCurrentProcess] ? 1 : 0;
}

int JITManager_isJITSupported(void* manager) {
    if (!manager) return 0;
    JITManagerInternal *obj = (__bridge JITManagerInternal*)manager;
    return [obj isJITSupported] ? 1 : 0;
}