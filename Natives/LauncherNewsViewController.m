#import <WebKit/WebKit.h>
#import "LauncherMenuViewController.h"
#import "LauncherNewsViewController.h"
#import "LauncherPreferences.h"
#import "utils.h"
#import "PLProfiles.h"
#import "BaseAuthenticator.h"

@interface LauncherNewsViewController()<WKNavigationDelegate>
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) UIView *leftContentView;
@property (nonatomic, strong) UIView *rightSidebarView;
@property (nonatomic, strong) UIView *dividerView;
@property (nonatomic, strong) UIButton *launchButton;
@property (nonatomic, strong) UILabel *versionLabel;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *accountTypeLabel;
@property (nonatomic, strong) UIStackView *contentStackView;
@end

@implementation LauncherNewsViewController
WKWebView *webView;
UIEdgeInsets insets;

- (id)init {
    self = [super init];
    self.title = localize(@"Home", nil);
    return self;
}

- (NSString *)imageName {
    return @"MenuNews";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGSize size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    insets = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets;
    
    [self setupUI];
    [self setupConstraints];
    [self updateAccountInfo];
    
    if(!isJailbroken && getPrefBool(@"warnings.limited_ram_warn") && (roundf(NSProcessInfo.processInfo.physicalMemory / 0x1000000) < 3900)) {
        // "This device has a limited amount of memory available."
        [self showWarningAlert:@"limited_ram" hasPreference:YES exitWhenCompleted:NO];
    }
    
    if (@available(iOS 26.0, *)) {
        [self showWarningAlert:@"ios19_jitdead" hasPreference:NO exitWhenCompleted:YES];
    }

    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.rightBarButtonItem = [sidebarViewController drawAccountButton];
    self.navigationItem.leftItemsSupplementBackButton = true;
}

- (void)setupUI {
    // Main scroll view
    self.mainScrollView = [[UIScrollView alloc] init];
    self.mainScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.mainScrollView];
    
    // Content stack view
    self.contentStackView = [[UIStackView alloc] init];
    self.contentStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentStackView.axis = UILayoutConstraintAxisHorizontal;
    self.contentStackView.distribution = UIStackViewDistributionFill;
    self.contentStackView.alignment = UIStackViewAlignmentFill;
    self.contentStackView.spacing = 0;
    [self.mainScrollView addSubview:self.contentStackView];
    
    // Left content view
    self.leftContentView = [[UIView alloc] init];
    self.leftContentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.leftContentView.backgroundColor = [UIColor systemGray6Color];
    self.leftContentView.layer.cornerRadius = 22.0;
    self.leftContentView.layer.cornerCurve = kCACornerCurveContinuous;
    [self.contentStackView addArrangedSubview:self.leftContentView];
    
    // Divider view
    self.dividerView = [[UIView alloc] init];
    self.dividerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.dividerView.backgroundColor = [UIColor separatorColor];
    [self.contentStackView addArrangedSubview:self.dividerView];
    
    // Right sidebar view
    self.rightSidebarView = [[UIView alloc] init];
    self.rightSidebarView.translatesAutoresizingMaskIntoConstraints = NO;
    self.rightSidebarView.backgroundColor = [UIColor systemGray5Color];
    self.rightSidebarView.layer.cornerRadius = 22.0;
    self.rightSidebarView.layer.cornerCurve = kCACornerCurveContinuous;
    [self.contentStackView addArrangedSubview:self.rightSidebarView];
    
    // Add content to left view
    [self setupLeftContent];
    
    // Add content to right sidebar
    [self setupRightSidebar];
}

- (void)setupLeftContent {
    // Create a welcome card
    UIView *welcomeCard = [[UIView alloc] init];
    welcomeCard.translatesAutoresizingMaskIntoConstraints = NO;
    welcomeCard.backgroundColor = [UIColor systemGray4Color];
    welcomeCard.layer.cornerRadius = 16.0;
    welcomeCard.layer.cornerCurve = kCACornerCurveContinuous;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = localize(@"Welcome", nil);
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.textColor = [UIColor labelColor];
    
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    descriptionLabel.text = localize(@"Welcome back to Amethyst Launcher", nil);
    descriptionLabel.font = [UIFont systemFontOfSize:16];
    descriptionLabel.textColor = [UIColor secondaryLabelColor];
    descriptionLabel.numberOfLines = 0;
    
    [welcomeCard addSubview:titleLabel];
    [welcomeCard addSubview:descriptionLabel];
    
    [self.leftContentView addSubview:welcomeCard];
    
    // Constraints for welcome card
    [NSLayoutConstraint activateConstraints:@[
        [welcomeCard.topAnchor constraintEqualToAnchor:self.leftContentView.topAnchor constant:16],
        [welcomeCard.leadingAnchor constraintEqualToAnchor:self.leftContentView.leadingAnchor constant:16],
        [welcomeCard.trailingAnchor constraintEqualToAnchor:self.leftContentView.trailingAnchor constant:-16],
        [welcomeCard.heightAnchor constraintGreaterThanOrEqualToConstant:100],
        
        [titleLabel.topAnchor constraintEqualToAnchor:welcomeCard.topAnchor constant:16],
        [titleLabel.leadingAnchor constraintEqualToAnchor:welcomeCard.leadingAnchor constant:16],
        [titleLabel.trailingAnchor constraintEqualToAnchor:welcomeCard.trailingAnchor constant:-16],
        
        [descriptionLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:8],
        [descriptionLabel.leadingAnchor constraintEqualToAnchor:welcomeCard.leadingAnchor constant:16],
        [descriptionLabel.trailingAnchor constraintEqualToAnchor:welcomeCard.trailingAnchor constant:-16],
        [descriptionLabel.bottomAnchor constraintEqualToAnchor:welcomeCard.bottomAnchor constant:-16]
    ]];
    
    // Add news web view
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://amethyst.ct.ws/welcome"]];
    WKWebViewConfiguration *webConfig = [[WKWebViewConfiguration alloc] init];
    webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webConfig];
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    webView.navigationDelegate = self;
    webView.opaque = NO;
    webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    NSString *javascript = @"var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *nozoom = [[WKUserScript alloc] initWithSource:javascript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [webView.configuration.userContentController addUserScript:nozoom];
    [webView.scrollView setShowsHorizontalScrollIndicator:NO];
    [webView loadRequest:request];
    [self.leftContentView addSubview:webView];
    
    // Constraints for web view
    [NSLayoutConstraint activateConstraints:@[
        [webView.topAnchor constraintEqualToAnchor:welcomeCard.bottomAnchor constant:16],
        [webView.leadingAnchor constraintEqualToAnchor:self.leftContentView.leadingAnchor constant:16],
        [webView.trailingAnchor constraintEqualToAnchor:self.leftContentView.trailingAnchor constant:-16],
        [webView.bottomAnchor constraintEqualToAnchor:self.leftContentView.bottomAnchor constant:-16]
    ]];
}

- (void)setupRightSidebar {
    // Avatar image view
    self.avatarImageView = [[UIImageView alloc] init];
    self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.avatarImageView.image = [UIImage imageNamed:@"DefaultAccount"];
    self.avatarImageView.layer.cornerRadius = 35.0;
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    // Username label
    self.usernameLabel = [[UILabel alloc] init];
    self.usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.usernameLabel.text = localize(@"Player", nil);
    self.usernameLabel.font = [UIFont boldSystemFontOfSize:20];
    self.usernameLabel.textAlignment = NSTextAlignmentCenter;
    self.usernameLabel.textColor = [UIColor labelColor];
    
    // Account type label
    self.accountTypeLabel = [[UILabel alloc] init];
    self.accountTypeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.accountTypeLabel.text = localize(@"Microsoft Account", nil);
    self.accountTypeLabel.font = [UIFont systemFontOfSize:14];
    self.accountTypeLabel.textAlignment = NSTextAlignmentCenter;
    self.accountTypeLabel.textColor = [UIColor secondaryLabelColor];
    
    // Version label
    self.versionLabel = [[UILabel alloc] init];
    self.versionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.versionLabel.text = [NSString stringWithFormat:@"%@: 1.20.1", localize(@"Version", nil)];
    self.versionLabel.font = [UIFont systemFontOfSize:16];
    self.versionLabel.textAlignment = NSTextAlignmentCenter;
    self.versionLabel.textColor = [UIColor labelColor];
    
    // Launch button
    self.launchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.launchButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.launchButton setTitle:localize(@"Launch Game", nil) forState:UIControlStateNormal];
    self.launchButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.launchButton.backgroundColor = [UIColor systemBlueColor];
    [self.launchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.launchButton.layer.cornerRadius = 22.0;
    self.launchButton.layer.cornerCurve = kCACornerCurveContinuous;
    [self.launchButton addTarget:self action:@selector(launchGame) forControlEvents:UIControlEventTouchUpInside];
    
    // Add subviews to sidebar
    [self.rightSidebarView addSubview:self.avatarImageView];
    [self.rightSidebarView addSubview:self.usernameLabel];
    [self.rightSidebarView addSubview:self.accountTypeLabel];
    [self.rightSidebarView addSubview:self.versionLabel];
    [self.rightSidebarView addSubview:self.launchButton];
    
    // Constraints for sidebar content
    [NSLayoutConstraint activateConstraints:@[
        // Avatar
        [self.avatarImageView.topAnchor constraintEqualToAnchor:self.rightSidebarView.topAnchor constant:32],
        [self.avatarImageView.centerXAnchor constraintEqualToAnchor:self.rightSidebarView.centerXAnchor],
        [self.avatarImageView.widthAnchor constraintEqualToConstant:70],
        [self.avatarImageView.heightAnchor constraintEqualToConstant:70],
        
        // Username
        [self.usernameLabel.topAnchor constraintEqualToAnchor:self.avatarImageView.bottomAnchor constant:16],
        [self.usernameLabel.leadingAnchor constraintEqualToAnchor:self.rightSidebarView.leadingAnchor constant:16],
        [self.usernameLabel.trailingAnchor constraintEqualToAnchor:self.rightSidebarView.trailingAnchor constant:-16],
        
        // Account type
        [self.accountTypeLabel.topAnchor constraintEqualToAnchor:self.usernameLabel.bottomAnchor constant:4],
        [self.accountTypeLabel.leadingAnchor constraintEqualToAnchor:self.rightSidebarView.leadingAnchor constant:16],
        [self.accountTypeLabel.trailingAnchor constraintEqualToAnchor:self.rightSidebarView.trailingAnchor constant:-16],
        
        // Version
        [self.versionLabel.topAnchor constraintEqualToAnchor:self.accountTypeLabel.bottomAnchor constant:32],
        [self.versionLabel.leadingAnchor constraintEqualToAnchor:self.rightSidebarView.leadingAnchor constant:16],
        [self.versionLabel.trailingAnchor constraintEqualToAnchor:self.rightSidebarView.trailingAnchor constant:-16],
        
        // Launch button
        [self.launchButton.bottomAnchor constraintEqualToAnchor:self.rightSidebarView.bottomAnchor constant:-32],
        [self.launchButton.leadingAnchor constraintEqualToAnchor:self.rightSidebarView.leadingAnchor constant:16],
        [self.launchButton.trailingAnchor constraintEqualToAnchor:self.rightSidebarView.trailingAnchor constant:-16],
        [self.launchButton.heightAnchor constraintEqualToConstant:44]
    ]];
}

- (void)setupConstraints {
    [NSLayoutConstraint activateConstraints:@[
        // Main scroll view
        [self.mainScrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.mainScrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.mainScrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.mainScrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        // Content stack view
        [self.contentStackView.topAnchor constraintEqualToAnchor:self.mainScrollView.topAnchor],
        [self.contentStackView.leadingAnchor constraintEqualToAnchor:self.mainScrollView.leadingAnchor],
        [self.contentStackView.trailingAnchor constraintEqualToAnchor:self.mainScrollView.trailingAnchor],
        [self.contentStackView.bottomAnchor constraintEqualToAnchor:self.mainScrollView.bottomAnchor],
        [self.contentStackView.widthAnchor constraintEqualToAnchor:self.mainScrollView.widthAnchor],
        
        // Left content view
        [self.leftContentView.widthAnchor constraintEqualToAnchor:self.contentStackView.widthAnchor multiplier:0.65],
        
        // Divider view
        [self.dividerView.widthAnchor constraintEqualToConstant:1],
        
        // Right sidebar view
        [self.rightSidebarView.widthAnchor constraintEqualToAnchor:self.contentStackView.widthAnchor multiplier:0.35]
    ]];
}

- (void)updateAccountInfo {
    NSDictionary *selected = BaseAuthenticator.current.authData;
    
    if (selected == nil) {
        self.usernameLabel.text = localize(@"Player", nil);
        self.accountTypeLabel.text = localize(@"No account selected", nil);
        self.avatarImageView.image = [UIImage imageNamed:@"DefaultAccount"];
        return;
    }

    // Remove the prefix "Demo." if there is
    BOOL isDemo = [selected[@"username"] hasPrefix:@"Demo."];
    NSString *username = [selected[@"username"] substringFromIndex:(isDemo?5:0)];
    self.usernameLabel.text = username;

    if (isDemo) {
        self.accountTypeLabel.text = localize(@"Demo Account", nil);
    } else if (selected[@"xboxGamertag"] == nil) {
        self.accountTypeLabel.text = localize(@"Local Account", nil);
    } else {
        // Display the Xbox gamertag for online accounts
        self.accountTypeLabel.text = selected[@"xboxGamertag"];
    }

    // Set avatar image
    NSURL *url = [NSURL URLWithString:[selected[@"profilePicURL"] stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"]];
    if (url) {
        UIImage *placeholder = [UIImage imageNamed:@"DefaultAccount"];
        [self.avatarImageView setImageWithURL:url placeholderImage:placeholder];
    }
}

- (void)launchGame {
    // TODO: Implement game launching logic
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:localize(@"Game Launch", nil)
        message:localize(@"Game launch functionality will be implemented here", nil)
        preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:localize(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)showWarningAlert:(NSString *)key hasPreference:(BOOL)isPreferenced exitWhenCompleted:(BOOL)shouldExit {
    UIAlertController *warning = [UIAlertController
                                      alertControllerWithTitle:localize([NSString stringWithFormat:@"login.warn.title.%@", key], nil)
                                      message:localize([NSString stringWithFormat:@"login.warn.message.%@", key], nil)
                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action;
    if(isPreferenced) {
        action = [UIAlertAction actionWithTitle:localize(@"OK", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
            setPrefBool([NSString stringWithFormat:@"warnings.%@_warn", key], NO);
        }];
    } else if(shouldExit) {
        action = [UIAlertAction actionWithTitle:localize(@"OK", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
            [UIApplication.sharedApplication performSelector:@selector(suspend)];
            usleep(100*1000);
            exit(0);
        }];
    } else {
        action = [UIAlertAction actionWithTitle:localize(@"OK", nil) style:UIAlertActionStyleCancel handler:nil];
    }
    warning.popoverPresentationController.sourceView = self.view;
    warning.popoverPresentationController.sourceRect = self.view.bounds;
    [warning addAction:action];
    [self presentViewController:warning animated:YES completion:nil];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > 0)
        scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    // Adjust layout for different screen sizes
    if (size.width > size.height) {
        // Landscape mode - make sidebar wider
        [NSLayoutConstraint deactivateConstraints:@[
            self.leftContentView.widthAnchor.constraintEqualToAnchor:self.contentStackView.widthAnchor multiplier:0.65),
            self.rightSidebarView.widthAnchor.constraintEqualToAnchor:self.contentStackView.widthAnchor multiplier:0.35)
        ]];
        
        [NSLayoutConstraint activateConstraints:@[
            self.leftContentView.widthAnchor.constraintEqualToAnchor:self.contentStackView.widthAnchor multiplier:0.6),
            self.rightSidebarView.widthAnchor.constraintEqualToAnchor:self.contentStackView.widthAnchor multiplier:0.4)
        ]];
    } else {
        // Portrait mode - use default widths
        [NSLayoutConstraint deactivateConstraints:@[
            self.leftContentView.widthAnchor.constraintEqualToAnchor:self.contentStackView.widthAnchor multiplier:0.6),
            self.rightSidebarView.widthAnchor.constraintEqualToAnchor:self.contentStackView.widthAnchor multiplier:0.4)
        ]];
        
        [NSLayoutConstraint activateConstraints:@[
            self.leftContentView.widthAnchor.constraintEqualToAnchor:self.contentStackView.widthAnchor multiplier:0.65),
            self.rightSidebarView.widthAnchor.constraintEqualToAnchor:self.contentStackView.widthAnchor multiplier:0.35)
        ]];
    }
}

- (void)webView:(WKWebView *)webView 
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction 
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
     if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        openLink(self, navigationAction.request.URL);
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end