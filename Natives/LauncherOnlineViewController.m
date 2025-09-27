#import "LauncherOnlineViewController.h"
#import "ZeroTierBridge.h"

@interface LauncherOnlineViewController () <ZeroTierBridgeDelegate, UITableViewDataSource, UITableViewDelegate>

// UI Elements
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *createRoomButton;
@property (nonatomic, strong) UILabel *tutorialLabel;
@property (nonatomic, strong) UITextField *networkIdTextField;
@property (nonatomic, strong) UIButton *joinRoomButton;
@property (nonatomic, strong) UITableView *networksTableView;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIActivityIndicatorView *statusIndicator;

// Data
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary *> *joinedNetworks;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSString *> *networkStatus;
@property (nonatomic, strong) NSTimer *statusUpdateTimer;

@end

@implementation LauncherOnlineViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"联机 (ZeroTier)";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.joinedNetworks = [NSMutableDictionary new];
    self.networkStatus = [NSMutableDictionary new];

    [self setupUI];
    
    // Start ZeroTier Node
    [ZeroTierBridge sharedInstance].delegate = self;
    NSString *homePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"zerotier-one"];
    [[ZeroTierBridge sharedInstance] startNodeWithHomeDirectory:homePath];
    
    // Update UI for initial state
    [self updateUIForConnectionState];
    
    // Start periodic status updates
    [self startStatusUpdates];
}

- (void)setupUI {
    // Status Label
    self.statusLabel = [UILabel new];
    self.statusLabel.text = @"ZT 节点: 正在初始化...";
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.font = [UIFont systemFontOfSize:12];
    self.statusLabel.textColor = [UIColor secondaryLabelColor];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.statusLabel];

    // Status Indicator
    self.statusIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.statusIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.statusIndicator];
    [self.statusIndicator startAnimating];

    // Create Room Button
    self.createRoomButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.createRoomButton setTitle:@"创建房间" forState:UIControlStateNormal];
    [self.createRoomButton addTarget:self action:@selector(createRoomTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.createRoomButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.createRoomButton];

    // Tutorial Label
    self.tutorialLabel = [UILabel new];
    self.tutorialLabel.text = @"首次使用请先创建房间，然后将房间ID分享给其他玩家";
    self.tutorialLabel.numberOfLines = 0;
    self.tutorialLabel.textAlignment = NSTextAlignmentCenter;
    self.tutorialLabel.font = [UIFont systemFontOfSize:12];
    self.tutorialLabel.textColor = [UIColor secondaryLabelColor];
    self.tutorialLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tutorialLabel];

    // Network ID Text Field
    self.networkIdTextField = [UITextField new];
    self.networkIdTextField.placeholder = @"输入16位网络ID";
    self.networkIdTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.networkIdTextField.textAlignment = NSTextAlignmentCenter;
    self.networkIdTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.networkIdTextField];

    // Join Room Button
    self.joinRoomButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.joinRoomButton setTitle:@"加入房间" forState:UIControlStateNormal];
    [self.joinRoomButton addTarget:self action:@selector(joinRoomTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.joinRoomButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.joinRoomButton];
    
    // Networks Table View
    self.networksTableView = [UITableView new];
    self.networksTableView.dataSource = self;
    self.networksTableView.delegate = self;
    [self.networksTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"NetworkCell"];
    self.networksTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.networksTableView];
    
    // Info Label
    self.infoLabel = [UILabel new];
    self.infoLabel.text = @"加入网络后，房主需在单人游戏中\"对局域网开放\"，其他玩家即可在\"多人游戏\"中看到房间";
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
        
        [self.createRoomButton.topAnchor constraintEqualToAnchor:self.statusIndicator.bottomAnchor constant:12],
        [self.createRoomButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.createRoomButton.widthAnchor constraintEqualToConstant:120],

        [self.tutorialLabel.topAnchor constraintEqualToAnchor:self.createRoomButton.bottomAnchor constant:8],
        [self.tutorialLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.tutorialLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],

        [self.networkIdTextField.topAnchor constraintEqualToAnchor:self.tutorialLabel.bottomAnchor constant:20],
        [self.networkIdTextField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:40],
        [self.networkIdTextField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-40],
        [self.networkIdTextField.heightAnchor constraintEqualToConstant:36],

        [self.joinRoomButton.topAnchor constraintEqualToAnchor:self.networkIdTextField.bottomAnchor constant:12],
        [self.joinRoomButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.joinRoomButton.widthAnchor constraintEqualToConstant:120],
        [self.joinRoomButton.heightAnchor constraintEqualToConstant:36],
        
        [self.networksTableView.topAnchor constraintEqualToAnchor:self.joinRoomButton.bottomAnchor constant:20],
        [self.networksTableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.networksTableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.networksTableView.bottomAnchor constraintEqualToAnchor:self.infoLabel.topAnchor constant:-20],
        
        [self.infoLabel.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
        [self.infoLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.infoLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
}

- (void)updateUIForConnectionState {
    BOOL hasJoinedNetworks = self.joinedNetworks.count > 0;
    
    // Always show these elements
    self.createRoomButton.hidden = NO;
    self.tutorialLabel.hidden = NO;
    self.networkIdTextField.hidden = NO;
    self.joinRoomButton.hidden = NO;
    
    // Update networks table visibility
    self.networksTableView.hidden = !hasJoinedNetworks;
}

- (NSString *)imageName {
    return @"MenuOnline";
}

#pragma mark - Actions

- (void)createRoomTapped:(UIButton *)sender {
    // Show an alert with instructions first
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"创建房间" 
                                                                   message:@"将打开ZeroTier官网，请登录后创建网络。创建完成后，将网络ID分享给其他玩家即可。" 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"前往官网" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:@"https://my.zerotier.com/"];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)joinRoomTapped:(UIButton *)sender {
    NSString *networkIDString = self.networkIdTextField.text;
    if (networkIDString.length == 0) {
        [self showAlertWithTitle:@"错误" message:@"请输入网络ID"];
        return;
    }
    
    // Validate network ID format (should be 16 hex characters)
    if (networkIDString.length != 16) {
        [self showAlertWithTitle:@"错误" message:@"网络ID应该是16位十六进制数字"];
        return;
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:networkIDString];
    uint64_t networkID = 0;
    if (![scanner scanHexLongLong:&networkID]) {
        [self showAlertWithTitle:@"错误" message:@"无效的网络ID格式"];
        return;
    }

    // Update UI to show joining state
    [self.statusIndicator startAnimating];
    self.statusLabel.text = [NSString stringWithFormat:@"正在加入网络: %llx...", networkID];
    self.joinRoomButton.enabled = NO;
    
    // Store the network status
    self.networkStatus[@(networkID)] = @"正在连接...";
    [self.networksTableView reloadData];
    
    [[ZeroTierBridge sharedInstance] joinNetworkWithID:networkID];
}

- (void)leaveRoomTapped:(UIButton *)sender {
    uint64_t networkID = sender.tag;
    [[ZeroTierBridge sharedInstance] leaveNetworkWithID:networkID];
    
    // Update status
    self.networkStatus[@(networkID)] = @"正在离开...";
    [self.networksTableView reloadData];
}

#pragma mark - ZeroTierBridgeDelegate

- (void)zeroTierNodeOnlineWithID:(uint64_t)nodeID {
    self.statusLabel.text = [NSString stringWithFormat:@"ZT 节点: %llx | 状态: 在线", nodeID];
    [self.statusIndicator stopAnimating];
    self.joinRoomButton.enabled = YES;
}

- (void)zeroTierNodeOffline {
    self.statusLabel.text = @"ZT 节点: 离线";
    [self.statusIndicator startAnimating];
    self.joinRoomButton.enabled = NO;
}

- (void)zeroTierDidJoinNetwork:(uint64_t)networkID {
    NSNumber *key = @(networkID);
    self.joinedNetworks[key] = @{@"networkID": [NSString stringWithFormat:@"%llx", networkID]};
    self.networkStatus[key] = @"已连接";
    
    [self.networksTableView reloadData];
    [self updateUIForConnectionState];
    
    // Update status label
    self.statusLabel.text = [NSString stringWithFormat:@"已加入网络: %llx", networkID];
    self.joinRoomButton.enabled = YES;
    [self.statusIndicator stopAnimating];
    
    [self showAlertWithTitle:@"成功" message:[NSString stringWithFormat:@"已加入网络: %llx", networkID]];
}

- (void)zeroTierDidLeaveNetwork:(uint64_t)networkID {
    [self.joinedNetworks removeObjectForKey:@(networkID)];
    [self.networkStatus removeObjectForKey:@(networkID)];
    
    [self.networksTableView reloadData];
    [self updateUIForConnectionState];
    
    // If no more networks, show node status
    if (self.joinedNetworks.count == 0) {
        uint64_t nodeID = [[ZeroTierBridge sharedInstance] nodeID];
        if ([[ZeroTierBridge sharedInstance] isNodeOnline]) {
            self.statusLabel.text = [NSString stringWithFormat:@"ZT 节点: %llx | 状态: 在线", nodeID];
        } else {
            self.statusLabel.text = @"ZT 节点: 离线";
        }
    }
    
    [self showAlertWithTitle:@"成功" message:[NSString stringWithFormat:@"已退出网络: %llx", networkID]];
}

- (void)zeroTierFailedToJoinNetwork:(uint64_t)networkID withError:(NSString *)error {
    // Update status
    self.networkStatus[@(networkID)] = [NSString stringWithFormat:@"错误: %@", error];
    [self.networksTableView reloadData];
    
    // Update main status
    self.statusLabel.text = [NSString stringWithFormat:@"加入 %llx 失败", networkID];
    self.joinRoomButton.enabled = YES;
    [self.statusIndicator stopAnimating];
    
    [self showAlertWithTitle:[NSString stringWithFormat:@"加入 %llx 失败", networkID] message:error];
}

- (void)zeroTierDidReceiveIPAddress:(NSString *)ipAddress forNetworkID:(uint64_t)networkID {
    NSNumber *key = @(networkID);
    NSMutableDictionary *networkInfo = [self.joinedNetworks[key] mutableCopy];
    if (networkInfo) {
        networkInfo[@"ipAddress"] = ipAddress;
        self.joinedNetworks[key] = networkInfo;
        self.networkStatus[key] = [NSString stringWithFormat:@"已连接 (%@)", ipAddress];
        [self.networksTableView reloadData];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.joinedNetworks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NetworkCell" forIndexPath:indexPath];
    
    NSArray *allNetworks = self.joinedNetworks.allValues;
    NSDictionary *networkInfo = allNetworks[indexPath.row];
    
    NSString *networkID = networkInfo[@"networkID"];
    NSString *ipAddress = networkInfo[@"ipAddress"];
    
    // Get status
    NSString *status = self.networkStatus[@(strtoull([networkID UTF8String], NULL, 16))] ?: @"未知状态";
    
    if (ipAddress) {
        cell.textLabel.text = [NSString stringWithFormat:@"网络: %@ (IP: %@)", networkID, ipAddress];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"网络: %@ (%@)", networkID, status];
    }
    
    UIButton *leaveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [leaveButton setTitle:@"离开" forState:UIControlStateNormal];
    
    NSScanner *scanner = [NSScanner scannerWithString:networkID];
    uint64_t nwid = 0;
    [scanner scanHexLongLong:&nwid];
    leaveButton.tag = nwid;

    [leaveButton addTarget:self action:@selector(leaveRoomTapped:) forControlEvents:UIControlEventTouchUpInside];
    leaveButton.frame = CGRectMake(0, 0, 60, 30);
    cell.accessoryView = leaveButton;
    
    return cell;
}

#pragma mark - Helpers

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)startStatusUpdates {
    // Periodically check node status to ensure UI stays in sync
    __weak typeof(self) weakSelf = self;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if ([[ZeroTierBridge sharedInstance] isNodeOnline]) {
                uint64_t nodeID = [[ZeroTierBridge sharedInstance] nodeID];
                // Only update if not already showing a network status
                if (![strongSelf.statusLabel.text containsString:@"已加入网络"]) {
                    strongSelf.statusLabel.text = [NSString stringWithFormat:@"ZT 节点: %llx | 状态: 在线", nodeID];
                    [strongSelf.statusIndicator stopAnimating];
                }
            } else {
                // Only update if not already showing a network status
                if (![strongSelf.statusLabel.text containsString:@"正在加入网络"] && 
                    ![strongSelf.statusLabel.text containsString:@"加入"] && 
                    ![strongSelf.statusLabel.text containsString:@"失败"]) {
                    strongSelf.statusLabel.text = @"ZT 节点: 离线";
                    [strongSelf.statusIndicator startAnimating];
                }
            }
        }
    }];
    
    // Keep a reference to the timer
    self.statusUpdateTimer = timer;
}

- (void)dealloc {
    [self.statusUpdateTimer invalidate];
}

@end