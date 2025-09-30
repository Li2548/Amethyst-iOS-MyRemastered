#import "FrpcBridge.h"
#import "utils.h"

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
    
    // 模拟启动frpc服务
    self.isRunning = YES;
    self.frpcProcessRunning = YES;
    
    // 启动状态检查定时器
    [self startStatusTimer];
    
    // 模拟frpc服务运行5秒后停止
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.isRunning) {
            self.isRunning = NO;
            self.frpcProcessRunning = NO;
            [self stopStatusTimer];
            
            if ([self.delegate respondsToSelector:@selector(frpcDidFailWithError:)]) {
                [self.delegate frpcDidFailWithError:@"Frpc服务已停止 (模拟)"];
            }
        }
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(frpcDidStartWithMessage:)]) {
            [self.delegate frpcDidStartWithMessage:@"Frpc started successfully (模拟运行)"];
        }
    });
}

- (void)stopFrpc {
    if (!self.isRunning) {
        if ([self.delegate respondsToSelector:@selector(frpcDidFailWithError:)]) {
            [self.delegate frpcDidFailWithError:@"Frpc is not running"];
        }
        return;
    }
    
    // 停止frpc服务
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