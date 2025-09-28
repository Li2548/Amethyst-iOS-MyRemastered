#import "FrpcViewController.h"
#import "FrpcBridge.h"

@interface FrpcViewController () <FrpcBridgeDelegate, UITextViewDelegate>

// UI Elements
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *startStopButton;
@property (nonatomic, strong) UITextView *configTextView;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIActivityIndicatorView *statusIndicator;

@end

@implementation FrpcViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"联机 (Frpc)";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    [self setupUI];
    
    // Set up FrpcBridge
    [FrpcBridge sharedInstance].delegate = self;
    
    // Update UI for initial state
    [self updateUIForConnectionState];
}

- (void)setupUI {
    // Status Label
    self.statusLabel = [UILabel new];
    self.statusLabel.text = @"Frpc 状态: 未运行";
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.font = [UIFont systemFontOfSize:12];
    self.statusLabel.textColor = [UIColor secondaryLabelColor];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.statusLabel];

    // Status Indicator
    self.statusIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.statusIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.statusIndicator];

    // Start/Stop Button
    self.startStopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.startStopButton setTitle:@"启动 Frpc" forState:UIControlStateNormal];
    [self.startStopButton addTarget:self action:@selector(startStopTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.startStopButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.startStopButton];

    // Config TextView
    self.configTextView = [[UITextView alloc] init];
    self.configTextView.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    self.configTextView.layer.borderColor = [UIColor systemGrayColor].CGColor;
    self.configTextView.layer.borderWidth = 1.0;
    self.configTextView.layer.cornerRadius = 5.0;
    self.configTextView.delegate = self;
    self.configTextView.text = @"# 示例 Frpc 配置\n[common]\nserver_addr = example.com\nserver_port = 7000\n\n[minecraft]\ntype = tcp\nlocal_ip = 127.0.0.1\nlocal_port = 25565\nremote_port = 0";
    self.configTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.configTextView];
    
    // Info Label
    self.infoLabel = [UILabel new];
    self.infoLabel.text = @"请在上方输入Frpc配置，然后点击启动按钮。配置文件将保存到Documents目录。";
    self.infoLabel.numberOfLines = 0;
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    self.infoLabel.font = [UIFont systemFontOfSize:12];
    self.infoLabel.textColor = [UIColor secondaryLabelColor];
    self.infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.infoLabel];

    // Layout
    [NSLayoutConstraint activateConstraints:@[
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:8],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],

        [self.statusIndicator.topAnchor constraintEqualToAnchor:self.statusLabel.bottomAnchor constant:4],
        [self.statusIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.statusIndicator.widthAnchor constraintEqualToConstant:20],
        [self.statusIndicator.heightAnchor constraintEqualToConstant:20],
        
        [self.startStopButton.topAnchor constraintEqualToAnchor:self.statusIndicator.bottomAnchor constant:12],
        [self.startStopButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.startStopButton.widthAnchor constraintEqualToConstant:120],

        [self.configTextView.topAnchor constraintEqualToAnchor:self.startStopButton.bottomAnchor constant:20],
        [self.configTextView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.configTextView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.configTextView.heightAnchor constraintEqualToConstant:200],
        
        [self.infoLabel.topAnchor constraintEqualToAnchor:self.configTextView.bottomAnchor constant:20],
        [self.infoLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.infoLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.infoLabel.bottomAnchor constraintLessThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20]
    ]];
}

- (void)updateUIForConnectionState {
    if ([FrpcBridge sharedInstance].isRunning) {
        self.statusLabel.text = @"Frpc 状态: 运行中";
        [self.statusIndicator stopAnimating];
        [self.startStopButton setTitle:@"停止 Frpc" forState:UIControlStateNormal];
    } else {
        self.statusLabel.text = @"Frpc 状态: 未运行";
        [self.statusIndicator stopAnimating];
        [self.startStopButton setTitle:@"启动 Frpc" forState:UIControlStateNormal];
    }
}

- (NSString *)imageName {
    return @"MenuOnline";
}

#pragma mark - Actions

- (void)startStopTapped:(UIButton *)sender {
    FrpcBridge *bridge = [FrpcBridge sharedInstance];
    
    if (bridge.isRunning) {
        // 停止Frpc
        [self.statusIndicator startAnimating];
        self.statusLabel.text = @"正在停止 Frpc...";
        self.startStopButton.enabled = NO;
        [bridge stopFrpc];
    } else {
        // 保存配置并启动Frpc
        NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *configPath = [documentsPath stringByAppendingPathComponent:@"frpc.ini"];
        
        // 保存配置文件
        [bridge updateConfig:self.configTextView.text toPath:configPath];
        
        // 启动Frpc
        [self.statusIndicator startAnimating];
        self.statusLabel.text = @"正在启动 Frpc...";
        self.startStopButton.enabled = NO;
        [bridge startFrpcWithConfig:configPath];
    }
}

#pragma mark - FrpcBridgeDelegate

- (void)frpcDidStartWithMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text = [NSString stringWithFormat:@"Frpc 状态: 运行中 (%@)", message];
        [self.statusIndicator stopAnimating];
        self.startStopButton.enabled = YES;
        [self updateUIForConnectionState];
        
        [self showAlertWithTitle:@"成功" message:message];
    });
}

- (void)frpcDidStopWithMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text = [NSString stringWithFormat:@"Frpc 状态: 未运行 (%@)", message];
        [self.statusIndicator stopAnimating];
        self.startStopButton.enabled = YES;
        [self updateUIForConnectionState];
        
        [self showAlertWithTitle:@"成功" message:message];
    });
}

- (void)frpcDidFailWithError:(NSString *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text = [NSString stringWithFormat:@"Frpc 状态: 错误"];
        [self.statusIndicator stopAnimating];
        self.startStopButton.enabled = YES;
        [self updateUIForConnectionState];
        
        [self showAlertWithTitle:@"错误" message:error];
    });
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    // 可以在这里添加自动保存功能或其他逻辑
}

#pragma mark - Helpers

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end