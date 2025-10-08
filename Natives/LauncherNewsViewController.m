#import <WebKit/WebKit.h>
#import "LauncherMenuViewController.h"
#import "LauncherNewsViewController.h"
#import "LauncherPreferences.h"
#import "utils.h"
#import "PLProfiles.h"
#import "XamlParser.h"
#import "XamlRenderer.h"

@interface LauncherNewsViewController()<WKNavigationDelegate>
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation LauncherNewsViewController
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
    
    // Content view
    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.backgroundColor = [UIColor systemGray6Color];
    self.contentView.layer.cornerRadius = 22.0;
    self.contentView.layer.cornerCurve = kCACornerCurveContinuous;
    [self.mainScrollView addSubview:self.contentView];
    
    // Add content to view
    [self setupContent];
}

- (void)setupContent {
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
    
    [self.contentView addSubview:welcomeCard];
    
    // Constraints for welcome card
    [NSLayoutConstraint activateConstraints:@[
        [welcomeCard.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:16],
        [welcomeCard.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [welcomeCard.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [welcomeCard.heightAnchor constraintGreaterThanOrEqualToConstant:100],
        
        [titleLabel.topAnchor constraintEqualToAnchor:welcomeCard.topAnchor constant:16],
        [titleLabel.leadingAnchor constraintEqualToAnchor:welcomeCard.leadingAnchor constant:16],
        [titleLabel.trailingAnchor constraintEqualToAnchor:welcomeCard.trailingAnchor constant:-16],
        
        [descriptionLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:8],
        [descriptionLabel.leadingAnchor constraintEqualToAnchor:welcomeCard.leadingAnchor constant:16],
        [descriptionLabel.trailingAnchor constraintEqualToAnchor:welcomeCard.trailingAnchor constant:-16],
        [descriptionLabel.bottomAnchor constraintEqualToAnchor:welcomeCard.bottomAnchor constant:-16]
    ]];
    
    // Load and render XAML content
    NSString *xamlContent = [self loadXaml:@"home.xaml"];
    if (xamlContent.length > 0) {
        NSArray<XamlNode *> *nodes = [XamlParser parseXaml:xamlContent];
        [XamlRenderer renderNodes:nodes inView:self.contentView];
    } else {
        // Fallback to news web view if no XAML content
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://amethyst.ct.ws/welcome"]];
        WKWebViewConfiguration *webConfig = [[WKWebViewConfiguration alloc] init];
        self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webConfig];
        self.webView.translatesAutoresizingMaskIntoConstraints = NO;
        self.webView.navigationDelegate = self;
        self.webView.opaque = NO;
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        NSString *javascript = @"var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);";
        WKUserScript *nozoom = [[WKUserScript alloc] initWithSource:javascript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [self.webView.configuration.userContentController addUserScript:nozoom];
        [self.webView.scrollView setShowsHorizontalScrollIndicator:NO];
        [self.webView loadRequest:request];
        [self.contentView addSubview:self.webView];
        
        // Constraints for web view
        [NSLayoutConstraint activateConstraints:@[
            [self.webView.topAnchor constraintEqualToAnchor:welcomeCard.bottomAnchor constant:16],
            [self.webView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
            [self.webView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
            [self.webView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-16]
        ]];
    }
}

- (void)setupConstraints {
    [NSLayoutConstraint activateConstraints:@[
        // Main scroll view
        [self.mainScrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.mainScrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.mainScrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.mainScrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        // Content view
        [self.contentView.topAnchor constraintEqualToAnchor:self.mainScrollView.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.mainScrollView.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.mainScrollView.trailingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.mainScrollView.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.mainScrollView.widthAnchor]
    ]];
}

- (NSString *)loadXaml:(NSString *)fileName {
    // First try to load from documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSError *error;
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (content != nil) {
        return content;
    }
    
    // If not found, try to load from bundle
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension] ofType:@"xaml"];
    if (bundlePath != nil) {
        content = [NSString stringWithContentsOfFile:bundlePath encoding:NSUTF8StringEncoding error:&error];
        if (content != nil) {
            return content;
        }
    }
    
    // Return default XAML content
    return @"<local:MyCard Title=\"Amethyst Launcher\" Margin=\"0,0,0,15\">\
    <StackPanel Margin=\"25,40,23,15\">\
        <TextBlock Margin=\"0,0,0,4\" FontSize=\"13\" HorizontalAlignment=\"Center\" Foreground=\"{DynamicResource ColorBrush1}\"\
                    Text=\"欢迎使用 Amethyst Launcher！本启动器为 iOS 平台定制。\" />\
    </StackPanel>\
</local:MyCard>";
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