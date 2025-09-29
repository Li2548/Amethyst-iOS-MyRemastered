#import "FrpcBridge.h"
#import "utils.h"

@interface FrpcBridge ()
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, strong) NSTimer *statusTimer;
@property (nonatomic, strong) NSString *configPath;
@property (nonatomic, assign) pid_t frpcProcessId;
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
    
    // 启动frpc进程
    NSString *frpcPath = [[NSBundle mainBundle] pathForResource:@"frpc" ofType:@""];
    if (!frpcPath || ![[NSFileManager defaultManager] fileExistsAtPath:frpcPath]) {
        // 尝试在不同位置查找frpc
        NSArray *searchPaths = @[
            [[NSBundle mainBundle] pathForResource:@"frpc" ofType:@"" inDirectory:@"resources"],
            [[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"frpc",
            @"/usr/local/bin/frpc",
            @"/usr/bin/frpc"
        ];
        
        for (NSString *path in searchPaths) {
            if (path && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
                frpcPath = path;
                break;
            }
        }
        
        if (!frpcPath || ![[NSFileManager defaultManager] fileExistsAtPath:frpcPath]) {
            if ([self.delegate respondsToSelector:@selector(frpcDidFailWithError:)]) {
                [self.delegate frpcDidFailWithError:@"Frpc可执行文件不存在。请将frpc可执行文件添加到项目中，或将frpc安装到系统路径中。"];
            }
            return;
        }
    }
    
    // 创建进程
    pid_t pid = fork();
    if (pid == 0) {
        // 子进程
        const char *frpcPathC = [frpcPath UTF8String];
        const char *configPathC = [configPath UTF8String];
        execl(frpcPathC, "frpc", "-c", configPathC, NULL);
        exit(1);
    } else if (pid > 0) {
        // 父进程
        self.frpcProcessId = pid;
        self.isRunning = YES;
        
        // 启动状态检查定时器
        [self startStatusTimer];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(frpcDidStartWithMessage:)]) {
                [self.delegate frpcDidStartWithMessage:@"Frpc started successfully"];
            }
        });
    } else {
        // 错误
        if ([self.delegate respondsToSelector:@selector(frpcDidFailWithError:)]) {
            [self.delegate frpcDidFailWithError:@"无法启动Frpc进程"];
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
    
    // 停止frpc进程
    if (self.frpcProcessId > 0) {
        kill(self.frpcProcessId, SIGTERM);
        self.frpcProcessId = 0;
    }
    
    self.isRunning = NO;
    
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
            if (strongSelf.frpcProcessId > 0) {
                int status;
                pid_t result = waitpid(strongSelf.frpcProcessId, &status, WNOHANG);
                
                // 如果进程已退出
                if (result == strongSelf.frpcProcessId || result == -1) {
                    strongSelf.isRunning = NO;
                    strongSelf.frpcProcessId = 0;
                    [strongSelf stopStatusTimer];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([strongSelf.delegate respondsToSelector:@selector(frpcDidFailWithError:)]) {
                            NSString *errorMessage = WIFEXITED(status) ? 
                                [NSString stringWithFormat:@"Frpc进程已退出，退出码: %d", WEXITSTATUS(status)] : 
                                @"Frpc进程异常终止";
                            [strongSelf.delegate frpcDidFailWithError:errorMessage];
                        }
                    });
                }
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