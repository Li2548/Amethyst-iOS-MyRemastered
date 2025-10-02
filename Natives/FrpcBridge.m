#import "FrpcBridge.h"
#import "utils.h"

@interface FrpcBridge ()
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, strong) NSTimer *statusTimer;
@property (nonatomic, strong) NSString *configPath;
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
    self.isRunning = YES;
    
    // 在实际实现中，这里会启动frpc进程
    // 由于这是一个示例实现，我们只是模拟启动过程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 模拟启动过程
        sleep(1);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(frpcDidStartWithMessage:)]) {
                [self.delegate frpcDidStartWithMessage:@"Frpc started successfully"];
            }
            
            // 启动状态检查定时器
            [self startStatusTimer];
        });
    });
}

- (void)stopFrpc {
    if (!self.isRunning) {
        if ([self.delegate respondsToSelector:@selector(frpcDidFailWithError:)]) {
            [self.delegate frpcDidFailWithError:@"Frpc is not running"];
        }
        return;
    }
    
    self.isRunning = NO;
    
    // 停止状态检查定时器
    [self stopStatusTimer];
    
    // 在实际实现中，这里会停止frpc进程
    // 由于这是一个示例实现，我们只是模拟停止过程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 模拟停止过程
        sleep(1);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(frpcDidStopWithMessage:)]) {
                [self.delegate frpcDidStopWithMessage:@"Frpc stopped successfully"];
            }
        });
    });
}

- (void)updateConfig:(NSString *)configContent toPath:(NSString *)configPath {
    // 在实际实现中，这里会将配置内容写入指定路径的文件
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
            // 在实际实现中，这里会检查frpc进程的状态
            // 由于这是一个示例实现，我们只是记录日志
            NSLog(@"Frpc is running...");
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
}

@end