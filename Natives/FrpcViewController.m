#import "FrpcViewController.h"
#import "FrpcBridge.h"
#import <UIKit/UIKit.h>

@interface FrpcViewController () <FrpcBridgeDelegate, UITextViewDelegate, UIDocumentPickerDelegate>

// UI Elements
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *startStopButton;
@property (nonatomic, strong) UIButton *importButton;
@property (nonatomic, strong) UITextView *configTextView;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIActivityIndicatorView *statusIndicator;

@end

@implementation FrpcViewController

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count > 0) {
        NSURL *url = urls.firstObject;
        
        // 读取文件内容
        NSError *error;
        NSString *content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        
        if (content && !error) {
            self.configTextView.text = content;
            
            // 保存导入的配置
            NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
            NSString *configPath = [documentsPath stringByAppendingPathComponent:@"frpc.ini"];
            [content writeToFile:configPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        } else {
            [self showAlertWithTitle:@"导入失败" message:@"无法读取配置文件内容。"];
        }
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    // 用户取消了文档选择器
}

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
    
    // Load saved config
    [self loadSavedConfig];
    
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
    
    // Import Button
    self.importButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.importButton setTitle:@"导入配置" forState:UIControlStateNormal];
    [self.importButton addTarget:self action:@selector(importConfigTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.importButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.importButton];

    // Config TextView
    self.configTextView = [[UITextView alloc] init];
    self.configTextView.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    self.configTextView.layer.borderColor = [UIColor systemGrayColor].CGColor;
    self.configTextView.layer.borderWidth = 1.0;
    self.configTextView.layer.cornerRadius = 5.0;
    self.configTextView.delegate = self;
    self.configTextView.text = @"# 示例 Frpc 配置 (.ini格式)
[common]
server_addr = example.com
server_port = 7000

[minecraft]
type = tcp
local_ip = 127.0.0.1
local_port = 25565
remote_port = 0";
    self.configTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.configTextView];
    
    // Info Label
    self.infoLabel = [UILabel new];
    self.infoLabel.text = @"请在上方输入Frpc配置（支持.ini格式），然后点击启动按钮。配置文件将保存到Documents目录。";
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
        
        [self.importButton.topAnchor constraintEqualToAnchor:self.startStopButton.bottomAnchor constant:8],
        [self.importButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.importButton.widthAnchor constraintEqualToConstant:120],

        [self.configTextView.topAnchor constraintEqualToAnchor:self.importButton.bottomAnchor constant:12],
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
        // 验证配置
        if (![self validateConfig:self.configTextView.text]) {
            [self showAlertWithTitle:@"配置错误" message:@"配置格式不正确，请检查后重试。"];
            return;
        }
        
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

- (void)importConfigTapped:(UIButton *)sender {
    // 创建文档选择器
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.plain-text"] inMode:UIDocumentPickerModeImport];
    documentPicker.delegate = self;
    [self presentViewController:documentPicker animated:YES completion:nil];
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
    // 保存当前编辑的配置
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *configPath = [documentsPath stringByAppendingPathComponent:@"frpc.ini"];
    [textView.text writeToFile:configPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

#pragma mark - Helpers

- (void)loadSavedConfig {
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *configPath = [documentsPath stringByAppendingPathComponent:@"frpc.ini"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:configPath]) {
        NSError *error;
        NSString *configContent = [NSString stringWithContentsOfFile:configPath encoding:NSUTF8StringEncoding error:&error];
        
        if (configContent && !error) {
            self.configTextView.text = configContent;
        }
    }
}

- (BOOL)validateConfig:(NSString *)config {
    // 简单验证配置是否包含基本的frpc配置节
    if (config.length == 0) {
        return NO;
    }
    
    // 检查是否包含[common]节
    if ([config rangeOfString:@"[common]"].location == NSNotFound) {
        return NO;
    }
    
    return YES;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Helpers

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end