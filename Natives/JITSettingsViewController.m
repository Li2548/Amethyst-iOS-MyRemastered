//  JITSettingsViewController.m
//  Amethyst

#import "JITSettingsViewController.h"
#import "JITSupport/idevice/JITEnableContext.h"
#import "LauncherPreferencesViewController.h"

@interface JITSettingsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *prefItems;
@end

@implementation JITSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"JIT (iOS 26)";
    
    [self setupUI];
    [self setupPrefItems];
}

- (void)setupUI {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)setupPrefItems {
    // Define preference items for JIT settings
    self.prefItems = @[
        @[
            @{@"key": @"enable_jit_ios26",
              @"hasDetail": @NO,
              @"icon": @"bolt.horizontal",
              @"type": [LauncherPreferencesViewController shared].typeSwitch,
              @"title": @"Enable JIT for iOS 26",
              @"subtitle": @"Enable Just-In-Time compilation for better performance on iOS 26+"
            }
        ]
    ];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.prefItems count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.prefItems objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [[self.prefItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *key = item[@"key"];
    NSString *title = item[@"title"];
    NSString *subtitle = item[@"subtitle"];
    NSString *icon = item[@"icon"];
    NSString *type = item[@"type"];
    
    // Create and configure cell based on type
    if ([type isEqualToString:[LauncherPreferencesViewController shared].typeSwitch]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SwitchCell"];
        }
        
        cell.textLabel.text = title;
        cell.detailTextLabel.text = subtitle;
        cell.imageView.image = [UIImage systemImageNamed:icon];
        
        // Add switch
        UISwitch *switchView = [[UISwitch alloc] init];
        switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:key];
        switchView.tag = indexPath.row;
        [switchView addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchView;
        
        return cell;
    }
    
    return [[UITableViewCell alloc] init];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions

- (void)switchValueChanged:(UISwitch *)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    NSDictionary *item = [[self.prefItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *key = item[@"key"];
    
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Handle JIT enable/disable
    if ([key isEqualToString:@"enable_jit_ios26"]) {
        if (sender.isOn) {
            // Enable JIT functionality
            [self enableJIT];
        } else {
            // Disable JIT functionality
            [self disableJIT];
        }
    }
}

- (void)enableJIT {
    // Implement JIT enabling logic here
    NSLog(@"JIT enabled");
    
    // Example: Start heartbeat
    [[JITEnableContext shared] startHeartbeatWithCompletionHandler:^(int result, NSString *message) {
        NSLog(@"Heartbeat result: %d, message: %@", result, message);
    } logger:^(NSString *message) {
        NSLog(@"Heartbeat log: %@", message);
    }];
}

- (void)disableJIT {
    // Implement JIT disabling logic here
    NSLog(@"JIT disabled");
}

@end
