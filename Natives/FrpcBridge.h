#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FrpcBridgeDelegate <NSObject>

- (void)frpcDidStartWithMessage:(NSString *)message;
- (void)frpcDidStopWithMessage:(NSString *)message;
- (void)frpcDidFailWithError:(NSString *)error;

@end

@interface FrpcBridge : NSObject

@property (nonatomic, weak) id<FrpcBridgeDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isRunning;

+ (instancetype)sharedInstance;

- (void)startFrpcWithConfig:(NSString *)configPath;
- (void)stopFrpc;
- (void)updateConfig:(NSString *)configContent toPath:(NSString *)configPath;

@end

NS_ASSUME_NONNULL_END