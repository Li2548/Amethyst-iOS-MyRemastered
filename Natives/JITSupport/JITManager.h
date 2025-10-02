#ifndef JITMANAGER_H
#define JITMANAGER_H

#ifdef __cplusplus
extern "C" {
#endif

// 声明JITManager的C接口
void* JITManager_sharedManager(void);
int JITManager_enableJITForCurrentProcess(void* manager);
int JITManager_isJITSupported(void* manager);

#ifdef __cplusplus
}
#endif

#endif /* JITMANAGER_H */