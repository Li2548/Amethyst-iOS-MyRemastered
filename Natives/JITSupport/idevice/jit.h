//
//  jit.h
//  StikJIT
//
//  Created by Stephen on 3/27/25.
//

// jit.h
#ifndef JIT_H
#define JIT_H

typedef void (^LogFuncC)(const char* message, ...);
typedef void (^DebugAppCallback)(int pid, struct DebugProxyHandle* debug_proxy, dispatch_semaphore_t semaphore);

// 声明函数但不实现，因为我们需要链接到libidevice_ffi.a
extern int debug_app(void* tcp_provider, const char *bundle_id, LogFuncC logger, DebugAppCallback callback);
extern int debug_app_pid(void* tcp_provider, int pid, LogFuncC logger, DebugAppCallback callback);
extern int launch_app_via_proxy(void* tcp_provider, const char *bundle_id, LogFuncC logger);

#endif /* JIT_H */