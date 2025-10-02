#import "OnlineModeSelectViewController.h"
#import "LauncherOnlineViewController.h"

@interface OnlineModeSelectViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *modeTableView;
@property (nonatomic, strong) NSArray *modeOptions;

@end

@implementation OnlineModeSelectViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"联机";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // 初始化模式选项
    self.modeOptions = @[
        @{@"title": @"ZeroTier", @"description": @"使用ZeroTier进行联机，需要网络ID", @"icon": @"network"}
    ];
    
    [self setupUI];
}

- (void)setupUI {
    // 创建表格视图
    self.modeTableView = [[UITableView alloc] init];
    self.modeTableView.dataSource = self;
    self.modeTableView.delegate = self;
    self.modeTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.modeTableView];
    
    // 注册单元格
    [self.modeTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ModeCell"];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [self.modeTableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.modeTableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.modeTableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.modeTableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (NSString *)imageName {
    return @"MenuOnline";
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modeOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ModeCell" forIndexPath:indexPath];
    
    NSDictionary *modeOption = self.modeOptions[indexPath.row];
    
    cell.textLabel.text = modeOption[@"title"];
    cell.detailTextLabel.text = modeOption[@"description"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // 设置系统图标
    if ([modeOption[@"icon"] isEqualToString:@"network"]) {
        cell.imageView.image = [UIImage systemImageNamed:@"network"];
    } else if ([modeOption[@"icon"] isEqualToString:@"server"]) {
        cell.imageView.image = [UIImage systemImageNamed:@"server"];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *modeOption = self.modeOptions[indexPath.row];
    NSString *modeTitle = modeOption[@"title"];
    
    UIViewController *targetViewController = nil;
    
    if ([modeTitle isEqualToString:@"ZeroTier"]) {
        targetViewController = [[LauncherOnlineViewController alloc] init];
    }
    
    if (targetViewController) {
        // 获取导航控制器并推送新视图控制器
        UINavigationController *navController = self.navigationController;
        if (navController) {
            [navController pushViewController:targetViewController animated:YES];
        }
    }
}

@end