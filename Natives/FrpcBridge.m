#import "FrpcBridge.h"
#import "utils.h"
#import "Frpclib.framework/Headers/Frpclib.h"

@interface FrpcBridge ()
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, strong) NSTimer *statusTimer;
@property (nonatomic, strong) NSString *configPath;
@property (nonatomic, assign) BOOL frpcProcessRunning;
@end

@implementation FrpcBridge

+ (instancetype)sharedInstance {
    static FrpcBridge *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)startFrpcWithConfig:(NSString *)configPath {
    if (self.isRunning) {
        if ([self.delegate respondsToSelector:@selector(frpcDidFailWithError:)]) {
            [self.delegate frpcDidFailWithError:@"Frpc is already running"];
        }
        return;
    }
    
    self.configPath = configPath;
    
    // 检查配置文件是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:configPath]) {
        if ([self.delegate respondsToSelector:@selector(frpcDidFailWithError:)]) {
            [self.delegate frpcDidFailWithError:@"配置文件不存在"];
        }
        return;
    }
    
    // 使用Frpclib启动frpc服务
    @try {
        // 在后台线程中启动frpc
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                // 标记frpc进程正在运行
                self.frpcProcessRunning = YES;
                
                // 启动frpc服务
                FrpclibRun(configPath);
                
                // frpc服务已停止
                self.frpcProcessRunning = NO;
                
                // 在主线程中更新UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.isRunning) {
                        self.isRunning = NO;
                        [self stopStatusTimer];
                        
                        if ([self.delegate respondsToSelector:@selector(frpcDidFailWithError:)]) {
                            [self.delegate frpcDidFailWithError:@"Frpc服务已停止"];
                        }
                    }
                });
            }
        });
        
        // 更新状态
        self.isRunning = YES;
        
        // 启动状态检查定时器
        [self startStatusTimer];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(frpcDidStartWithMessage:)]) {
                [self.delegate frpcDidStartWithMessage:@"Frpc started successfully"];
            }
        });
    }
    @catch (NSException *exception) {
        self.isRunning = NO;
        self.frpcProcessRunning = NO;
        [self stopStatusTimer];
        
        if ([self.delegate respondsToSelector:@selector(frpcDidFailWithError:)]) {
            [self.delegate frpcDidFailWithError:[NSString stringWithFormat:@"启动Frpc失败: %@", exception.reason]];
        }
    }
}

- (void)stopFrpc {
    if (!self.isRunning) {
        if ([self.delegate respondsToSelector:@selector(frpcDidFailWithError:)]) {
            [self.delegate frpcDidFailWithError:@"Frpc is not running"];
        }
        return;
    }
    
    // 停止frpc服务
    // 注意：由于FrpclibRun是阻塞调用，我们无法直接停止它
    // 我们只能标记服务为停止状态
    self.isRunning = NO;
    self.frpcProcessRunning = NO;
    
    // 停止状态检查定时器
    [self stopStatusTimer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(frpcDidStopWithMessage:)]) {
            [self.delegate frpcDidStopWithMessage:@"Frpc stopped successfully"];
        }
    });
}

- (void)updateConfig:(NSString *)configContent toPath:(NSString *)configPath {
    NSError *error;
    [configContent writeToFile:configPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"Failed to write config file: %@", error.localizedDescription);
    } else {
        NSLog(@"Config file updated successfully at path: %@", configPath);
    }
}

- (void)startStatusTimer {
    [self stopStatusTimer]; // 先停止现有的定时器
    
    __weak typeof(self) weakSelf = self;
    self.statusTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && strongSelf.isRunning) {
            // 检查frpc进程是否仍在运行
            if (!strongSelf.frpcProcessRunning) {
                strongSelf.isRunning = NO;
                [strongSelf stopStatusTimer];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([strongSelf.delegate respondsToSelector:@selector(frpcDidFailWithError:)]) {
                        [strongSelf.delegate frpcDidFailWithError:@"Frpc进程已停止运行"];
                    }
                });
            }
        }
    }];
}

- (void)stopStatusTimer {
    if (self.statusTimer) {
        [self.statusTimer invalidate];
        self.statusTimer = nil;
    }
}

- (void)dealloc {
    [self stopStatusTimer];
    if (self.isRunning) {
        [self stopFrpc];
    }
}

@end