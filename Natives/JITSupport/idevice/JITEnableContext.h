//
//  JITEnableContext.h
//  StikJIT
//
//  Created by s s on 2025/3/28.
//

#ifndef JITEnableContext_h
#define JITEnableContext_h

#import <Foundation/Foundation.h>

@class JITEnableContext;

// 定义类型但不实现，因为我们需要链接到libidevice_ffi.a
typedef void *DebugProxyHandle;
typedef void *IdeviceProviderHandle;
typedef void *IdevicePairingFile;

typedef void (^HeartbeatCompletionHandler)(int result, NSString *message);
typedef void (^LogFunc)(NSString *message);
typedef void (^DebugAppCallback)(int pid, DebugProxyHandle* debug_proxy, dispatch_semaphore_t semaphore);
typedef void (^SyslogLineHandler)(NSString *line);
typedef void (^SyslogErrorHandler)(NSError *error);

@interface JITEnableContext : NSObject

+ (instancetype)shared;

- (void)startHeartbeatWithCompletionHandler:(HeartbeatCompletionHandler)completionHandler
                                   logger:(LogFunc)logger;
- (void)ensureHeartbeat;
- (BOOL)debugAppWithBundleID:(NSString*)bundleID logger:(LogFunc)logger jsCallback:(DebugAppCallback)jsCallback;
- (BOOL)debugAppWithPID:(int)pid logger:(LogFunc)logger jsCallback:(DebugAppCallback)jsCallback;
- (void)startSyslogRelayWithHandler:(SyslogLineHandler)lineHandler
                            onError:(SyslogErrorHandler)errorHandler;
- (void)stopSyslogRelay;

@end

#endif /* JITEnableContext_h */