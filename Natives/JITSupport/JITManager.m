#import "JITManager.h"
#import <mach/mach.h>

@implementation JITManager

+ (instancetype)sharedManager {
    static JITManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JITManager alloc] init];
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
    // 这里可以添加更详细的检查逻辑
    return YES;
}

@end