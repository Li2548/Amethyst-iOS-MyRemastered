//
//  JITEnableContext.m
//  StikJIT
//
//  Created by s s on 2025/3/28.
//

#import "JITEnableContext.h"

@implementation JITEnableContext

+ (instancetype)shared {
    // 返回nil，因为我们没有完整的实现
    return nil;
}

- (void)startHeartbeatWithCompletionHandler:(HeartbeatCompletionHandler)completionHandler
                                   logger:(LogFunc)logger {
    // 空实现
    if (completionHandler) {
        completionHandler(0, @"Not implemented");
    }
}

- (void)ensureHeartbeat {
    // 空实现
}

- (BOOL)debugAppWithBundleID:(NSString*)bundleID logger:(LogFunc)logger jsCallback:(DebugAppCallback)jsCallback {
    // 空实现
    return NO;
}

- (BOOL)debugAppWithPID:(int)pid logger:(LogFunc)logger jsCallback:(DebugAppCallback)jsCallback {
    // 空实现
    return NO;
}

- (void)startSyslogRelayWithHandler:(SyslogLineHandler)lineHandler
                            onError:(SyslogErrorHandler)errorHandler {
    // 空实现
}

- (void)stopSyslogRelay {
    // 空实现
}

@end