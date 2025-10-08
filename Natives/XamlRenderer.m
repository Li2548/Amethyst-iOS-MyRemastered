#import "XamlRenderer.h"
#import <objc/runtime.h>

@implementation XamlRenderer

+ (void)renderNodes:(NSArray<XamlNode *> *)nodes inView:(UIView *)parentView {
    for (XamlNode *node in nodes) {
        if ([node isKindOfClass:[CardNode class]]) {
            [self renderCard:(CardNode *)node inView:parentView];
        } else if ([node isKindOfClass:[StackPanelNode class]]) {
            [self renderStackPanel:(StackPanelNode *)node inView:parentView];
        } else if ([node isKindOfClass:[TextBlockNode class]]) {
            [self renderTextBlock:(TextBlockNode *)node inView:parentView];
        } else if ([node isKindOfClass:[ButtonNode class]]) {
            [self renderButton:(ButtonNode *)node inView:parentView];
        } else if ([node isKindOfClass:[TextButtonNode class]]) {
            [self renderTextButton:(TextButtonNode *)node inView:parentView];
        } else if ([node isKindOfClass:[HintNode class]]) {
            [self renderHint:(HintNode *)node inView:parentView];
        } else if ([node isKindOfClass:[ImageNode class]]) {
            [self renderImage:(ImageNode *)node inView:parentView];
        } else if ([node isKindOfClass:[UnknownNode class]]) {
            [self renderNodes:((UnknownNode *)node).children inView:parentView];
        }
    }
}

+ (void)renderCard:(CardNode *)node inView:(UIView *)parentView {
    // Create card view
    UIView *cardView = [[UIView alloc] init];
    cardView.backgroundColor = [UIColor systemGray5Color];
    cardView.layer.cornerRadius = 16.0;
    cardView.layer.cornerCurve = kCACornerCurveContinuous;
    
    // Create title label
    NSString *title = node.attributes[@"Title"] ?: @"Card";
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textColor = [UIColor labelColor];
    
    // Add title to card
    [cardView addSubview:titleLabel];
    
    // Check if card can be swapped (collapsed)
    BOOL canSwap = [[node.attributes objectForKey:@"CanSwap"] boolValue];
    BOOL isSwapped = [[node.attributes objectForKey:@"IsSwapped"] boolValue];
    
    // Create content view
    UIView *contentView = [[UIView alloc] init];
    
    // Add content view to card
    [cardView addSubview:contentView];
    
    // Add to parent
    [parentView addSubview:cardView];
    
    // Set up constraints
    cardView.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    [constraints addObjectsFromArray:@[
        [cardView.leadingAnchor constraintEqualToAnchor:parentView.leadingAnchor constant:16],
        [cardView.trailingAnchor constraintEqualToAnchor:parentView.trailingAnchor constant:-16],
        [cardView.topAnchor constraintEqualToAnchor:parentView.topAnchor constant:8]
    ]];
    
    [constraints addObjectsFromArray:@[
        [titleLabel.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:16],
        [titleLabel.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-16],
        [titleLabel.topAnchor constraintEqualToAnchor:cardView.topAnchor constant:16],
        [titleLabel.heightAnchor constraintEqualToConstant:24]
    ]];
    
    [constraints addObjectsFromArray:@[
        [contentView.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor],
        [contentView.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor],
        [contentView.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:8],
        [contentView.bottomAnchor constraintEqualToAnchor:cardView.bottomAnchor constant:-16]
    ]];
    
    // If card can be swapped, add tap gesture to collapse/expand
    if (canSwap) {
        // Create a tap gesture recognizer
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleCard:)];
        tapGesture.view = cardView; // Store reference to card view
        [titleLabel addGestureRecognizer:tapGesture];
        titleLabel.userInteractionEnabled = YES;
        
        // If card is initially swapped (collapsed), hide content
        contentView.hidden = isSwapped;
    }
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    // Render children in content view
    if (node.children.count > 0) {
        [self renderNodes:node.children inView:contentView];
    }
}

+ (void)renderStackPanel:(StackPanelNode *)node inView:(UIView *)parentView {
    // For simplicity, we'll just render the children directly
    if (node.children.count > 0) {
        [self renderNodes:node.children inView:parentView];
    }
}

+ (void)renderTextBlock:(TextBlockNode *)node inView:(UIView *)parentView {
    NSString *text = node.attributes[@"Text"];
    if (text == nil) return;
    
    // Replace XML entities
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@"\n"];
    
    // Create label
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor labelColor];
    
    // Apply font size if specified
    NSString *fontSizeStr = node.attributes[@"FontSize"];
    if (fontSizeStr != nil) {
        CGFloat fontSize = [fontSizeStr floatValue];
        if (fontSize > 0) {
            label.font = [UIFont systemFontOfSize:fontSize];
        }
    }
    
    // Apply font weight if specified
    NSString *fontWeight = node.attributes[@"FontWeight"];
    if ([fontWeight isEqualToString:@"Bold"]) {
        label.font = [UIFont boldSystemFontOfSize:label.font.pointSize];
    }
    
    // Apply foreground color if specified
    NSString *foreground = node.attributes[@"Foreground"];
    if (foreground != nil) {
        UIColor *color = [self parseColor:foreground];
        if (color != nil) {
            label.textColor = color;
        }
    }
    
    // Apply horizontal alignment if specified
    NSString *horizontalAlignment = node.attributes[@"HorizontalAlignment"];
    if ([horizontalAlignment isEqualToString:@"Center"]) {
        label.textAlignment = NSTextAlignmentCenter;
    } else if ([horizontalAlignment isEqualToString:@"Right"]) {
        label.textAlignment = NSTextAlignmentRight;
    } else if ([horizontalAlignment isEqualToString:@"Left"]) {
        label.textAlignment = NSTextAlignmentLeft;
    }
    
    // Apply width if specified
    NSString *widthStr = node.attributes[@"Width"];
    if (widthStr != nil) {
        CGFloat width = [widthStr floatValue];
        if (width > 0) {
            label.preferredMaxLayoutWidth = width;
        }
    }
    
    // Add to parent
    [parentView addSubview:label];
    
    // Set up constraints
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObject:[label.leadingAnchor constraintEqualToAnchor:parentView.leadingAnchor constant:16]];
    [constraints addObject:[label.trailingAnchor constraintEqualToAnchor:parentView.trailingAnchor constant:-16]];
    [constraints addObject:[label.topAnchor constraintEqualToAnchor:parentView.topAnchor constant:8]];
    
    // Apply width constraint if specified
    if (widthStr != nil) {
        CGFloat width = [widthStr floatValue];
        if (width > 0) {
            [constraints addObject:[label.widthAnchor constraintEqualToConstant:width]];
        }
    }
    
    [NSLayoutConstraint activateConstraints:constraints];
}

+ (void)renderButton:(ButtonNode *)node inView:(UIView *)parentView {
    NSString *text = node.attributes[@"Text"];
    if (text == nil) return;
    
    // Create button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:text forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    
    // Apply height if specified
    NSString *heightStr = node.attributes[@"Height"];
    if (heightStr != nil) {
        CGFloat height = [heightStr floatValue];
        if (height > 0) {
            [button.heightAnchor constraintEqualToConstant:height].active = YES;
        }
    }
    
    // Apply width if specified
    NSString *widthStr = node.attributes[@"Width"];
    if (widthStr != nil) {
        CGFloat width = [widthStr floatValue];
        if (width > 0) {
            [button.widthAnchor constraintEqualToConstant:width].active = YES;
        }
    }
    
    // Apply padding if specified
    NSString *paddingStr = node.attributes[@"Padding"];
    if (paddingStr != nil) {
        NSArray *paddingValues = [paddingStr componentsSeparatedByString:@","];
        if (paddingValues.count >= 2) {
            CGFloat leftPadding = [paddingValues[0] floatValue];
            CGFloat rightPadding = [paddingValues[1] floatValue];
            button.contentEdgeInsets = UIEdgeInsetsMake(0, leftPadding, 0, rightPadding);
        }
    }
    
    // Apply horizontal alignment if specified
    NSString *horizontalAlignment = node.attributes[@"HorizontalAlignment"];
    if ([horizontalAlignment isEqualToString:@"Center"]) {
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
    } else if ([horizontalAlignment isEqualToString:@"Right"]) {
        button.titleLabel.textAlignment = NSTextAlignmentRight;
    } else if ([horizontalAlignment isEqualToString:@"Left"]) {
        button.titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    // Add event handling
    NSString *eventType = node.attributes[@"EventType"];
    NSString *eventData = node.attributes[@"EventData"];
    
    if (eventType != nil && eventData != nil) {
        [button addTarget:self action:@selector(handleButtonEvent:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        // Store event data in the button's associated object
        objc_setAssociatedObject(button, @"eventType", eventType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(button, @"eventData", eventData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    // Add to parent
    [parentView addSubview:button];
    
    // Set up constraints
    button.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    // Apply horizontal alignment through constraints
    if ([horizontalAlignment isEqualToString:@"Center"]) {
        [constraints addObject:[button.centerXAnchor constraintEqualToAnchor:parentView.centerXAnchor]];
    } else if ([horizontalAlignment isEqualToString:@"Right"]) {
        [constraints addObject:[button.trailingAnchor constraintEqualToAnchor:parentView.trailingAnchor constant:-16]];
    } else {
        [constraints addObject:[button.leadingAnchor constraintEqualToAnchor:parentView.leadingAnchor constant:16]];
    }
    
    [constraints addObjectsFromArray:@[
        [button.topAnchor constraintEqualToAnchor:parentView.topAnchor constant:8]
    ]];
    
    // Add size constraints if specified
    if (widthStr != nil) {
        CGFloat width = [widthStr floatValue];
        if (width > 0) {
            [constraints addObject:[button.widthAnchor constraintEqualToConstant:width]];
        }
    }
    
    if (heightStr != nil) {
        CGFloat height = [heightStr floatValue];
        if (height > 0) {
            [constraints addObject:[button.heightAnchor constraintEqualToConstant:height]];
        }
    }
    
    [NSLayoutConstraint activateConstraints:constraints];
}

+ (void)renderTextButton:(TextButtonNode *)node inView:(UIView *)parentView {
    NSString *text = node.attributes[@"Text"];
    if (text == nil) return;
    
    // Create text button (no border)
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:text forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    
    // Make it look like a text button (no background, underlined)
    [button setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    // Use attributed string to add underline
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}];
    [button.setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    // Apply height if specified
    NSString *heightStr = node.attributes[@"Height"];
    if (heightStr != nil) {
        CGFloat height = [heightStr floatValue];
        if (height > 0) {
            [button.heightAnchor constraintEqualToConstant:height].active = YES;
        }
    }
    
    // Add to parent
    [parentView addSubview:button];
    
    // Set up constraints
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [button.leadingAnchor constraintEqualToAnchor:parentView.leadingAnchor constant:16],
        [button.trailingAnchor constraintEqualToAnchor:parentView.trailingAnchor constant:-16],
        [button.topAnchor constraintEqualToAnchor:parentView.topAnchor constant:8]
    ]];
}

+ (void)renderHint:(HintNode *)node inView:(UIView *)parentView {
    NSString *text = node.attributes[@"Text"];
    if (text == nil) return;
    
    // Replace XML entities
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@"\n"];
    
    // Create hint view
    UIView *hintView = [[UIView alloc] init];
    
    // Apply theme if specified
    NSString *theme = node.attributes[@"Theme"];
    if ([theme isEqualToString:@"Blue"]) {
        hintView.backgroundColor = [UIColor colorWithRed:0.906 green:0.953 blue:1.000 alpha:1.000]; // #E7F3FF
    } else if ([theme isEqualToString:@"Yellow"]) {
        hintView.backgroundColor = [UIColor colorWithRed:1.000 green:0.984 blue:0.902 alpha:1.000]; // #FFFBE6
    } else if ([theme isEqualToString:@"Red"]) {
        hintView.backgroundColor = [UIColor colorWithRed:0.992 green:0.886 blue:0.886 alpha:1.000]; // #FDE2E2
    } else {
        hintView.backgroundColor = [UIColor systemGray5Color];
    }
    
    hintView.layer.cornerRadius = 8.0;
    hintView.layer.cornerCurve = kCACornerCurveContinuous;
    
    // Create label
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:14];
    
    // Apply text color based on theme
    if ([theme isEqualToString:@"Blue"]) {
        label.textColor = [UIColor colorWithRed:0.000 green:0.322 blue:0.608 alpha:1.000]; // #00529B
    } else if ([theme isEqualToString:@"Yellow"]) {
        label.textColor = [UIColor colorWithRed:0.549 green:0.467 blue:0.129 alpha:1.000]; // #8C7721
    } else if ([theme isEqualToString:@"Red"]) {
        label.textColor = [UIColor colorWithRed:0.847 green:0.000 blue:0.047 alpha:1.000]; // #D8000C
    } else {
        label.textColor = [UIColor labelColor];
    }
    
    // Add label to hint view
    [hintView addSubview:label];
    
    // Add to parent
    [parentView addSubview:hintView];
    
    // Set up constraints
    hintView.translatesAutoresizingMaskIntoConstraints = NO;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Apply margin if specified
    NSString *marginStr = node.attributes[@"Margin"];
    UIEdgeInsets margin = UIEdgeInsetsZero;
    if (marginStr != nil) {
        NSArray *marginValues = [marginStr componentsSeparatedByString:@","];
        if (marginValues.count == 4) {
            margin = UIEdgeInsetsMake([marginValues[1] floatValue], [marginValues[0] floatValue], 
                                     [marginValues[3] floatValue], [marginValues[2] floatValue]);
        } else if (marginValues.count == 2) {
            CGFloat horizontal = [marginValues[0] floatValue];
            CGFloat vertical = [marginValues[1] floatValue];
            margin = UIEdgeInsetsMake(vertical, horizontal, vertical, horizontal);
        } else if (marginValues.count == 1) {
            CGFloat all = [marginValues[0] floatValue];
            margin = UIEdgeInsetsMake(all, all, all, all);
        }
    }
    
    [NSLayoutConstraint activateConstraints:@[
        [hintView.leadingAnchor constraintEqualToAnchor:parentView.leadingAnchor constant:16 + margin.left],
        [hintView.trailingAnchor constraintEqualToAnchor:parentView.trailingAnchor constant:-16 - margin.right],
        [hintView.topAnchor constraintEqualToAnchor:parentView.topAnchor constant:8 + margin.top],
        
        [label.leadingAnchor constraintEqualToAnchor:hintView.leadingAnchor constant:12],
        [label.trailingAnchor constraintEqualToAnchor:hintView.trailingAnchor constant:-12],
        [label.topAnchor constraintEqualToAnchor:hintView.topAnchor constant:12],
        [label.bottomAnchor constraintEqualToAnchor:hintView.bottomAnchor constant:-12]
    ]];
}

+ (void)renderImage:(ImageNode *)node inView:(UIView *)parentView {
    NSString *source = node.attributes[@"Source"];
    if (source == nil) return;
    
    // Create image view
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor systemGray6Color]; // Placeholder background
    
    // Apply height if specified
    NSString *heightStr = node.attributes[@"Height"];
    if (heightStr != nil) {
        CGFloat height = [heightStr floatValue];
        if (height > 0) {
            [imageView.heightAnchor constraintEqualToConstant:height].active = YES;
        }
    }
    
    // Apply width if specified
    NSString *widthStr = node.attributes[@"Width"];
    if (widthStr != nil) {
        CGFloat width = [widthStr floatValue];
        if (width > 0) {
            [imageView.widthAnchor constraintEqualToConstant:width].active = YES;
        }
    }
    
    // Apply horizontal alignment if specified
    NSString *horizontalAlignment = node.attributes[@"HorizontalAlignment"];
    // We'll handle alignment through constraints when setting up constraints
    
    // Add to parent
    [parentView addSubview:imageView];
    
    // Set up constraints
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObject:[imageView.topAnchor constraintEqualToAnchor:parentView.topAnchor constant:8]];
    
    // Apply horizontal alignment
    if ([horizontalAlignment isEqualToString:@"Center"]) {
        [constraints addObject:[imageView.centerXAnchor constraintEqualToAnchor:parentView.centerXAnchor]];
    } else if ([horizontalAlignment isEqualToString:@"Right"]) {
        [constraints addObject:[imageView.trailingAnchor constraintEqualToAnchor:parentView.trailingAnchor constant:-16]];
    } else {
        [constraints addObject:[imageView.leadingAnchor constraintEqualToAnchor:parentView.leadingAnchor constant:16]];
    }
    
    // Apply size constraints
    if (heightStr != nil) {
        CGFloat height = [heightStr floatValue];
        if (height > 0) {
            [constraints addObject:[imageView.heightAnchor constraintEqualToConstant:height]];
        }
    }
    
    if (widthStr != nil) {
        CGFloat width = [widthStr floatValue];
        if (width > 0) {
            [constraints addObject:[imageView.widthAnchor constraintEqualToConstant:width]];
        }
    }
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    // Load image from URL asynchronously
    NSURL *url = [NSURL URLWithString:source];
    if (url != nil) {
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (data && !error) {
                UIImage *image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = image;
                    imageView.backgroundColor = [UIColor clearColor]; // Remove placeholder background
                });
            }
        }];
        [task resume];
    }
}

+ (UIColor *)parseColor:(NSString *)colorStr {
    if (colorStr == nil) return nil;
    
    if ([colorStr hasPrefix:@"#"]) {
        // Parse hex color
        NSString *hexString = [colorStr substringFromIndex:1];
        if (hexString.length == 6) {
            unsigned int rgbValue;
            [[NSScanner scannerWithString:hexString] scanHexInt:&rgbValue];
            return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.0
                                   green:((rgbValue & 0xFF00) >> 8) / 255.0
                                    blue:(rgbValue & 0xFF) / 255.0
                                   alpha:1.0];
        }
    } else if ([colorStr hasPrefix:@"{DynamicResource"]) {
        // Parse dynamic resource colors
        if ([colorStr containsString:@"ColorBrush1"]) {
            return [UIColor systemBlueColor];
        } else if ([colorStr containsString:@"ColorBrush2"]) {
            return [UIColor systemGreenColor];
        } else if ([colorStr containsString:@"ColorBrush3"]) {
            return [UIColor systemOrangeColor];
        }
    }
    
    return nil;
}

+ (void)toggleCard:(UITapGestureRecognizer *)gesture {
    // Get the card view from the gesture recognizer
    UIView *cardView = gesture.view;
    
    // Find the content view within the card (assuming it's the second subview)
    if (cardView.subviews.count >= 2) {
        UIView *contentView = cardView.subviews[1]; // Assuming content view is the second subview
        contentView.hidden = !contentView.hidden;
    }
}

+ (void)handleButtonEvent:(UIButton *)sender forEvent:(UIEvent *)event {
    // Retrieve event data from the button's associated object
    NSString *eventType = objc_getAssociatedObject(sender, @"eventType");
    NSString *eventData = objc_getAssociatedObject(sender, @"eventData");
    
    if ([eventType isEqualToString:@"打开网页"]) {
        // Open URL
        NSURL *url = [NSURL URLWithString:eventData];
        if (url) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    } else if ([eventType isEqualToString:@"弹出窗口"]) {
        // Show alert
        NSArray *parts = [eventData componentsSeparatedByString:@"|"];
        NSString *title = parts.firstObject;
        NSString *message = parts.count > 1 ? parts[1] : @"";
        
        // Create and show alert
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        
        // Find the current view controller to present the alert
        UIViewController *currentVC = [self getCurrentViewController];
        if (currentVC) {
            [currentVC presentViewController:alert animated:YES completion:nil];
        }
    } else if ([eventType isEqualToString:@"启动游戏"]) {
        // Handle game launch event
        // This would need to be implemented based on the app's game launching logic
        NSLog(@"Launch game event: %@", eventData);
    }
}

+ (UIViewController *)getCurrentViewController {
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    if (window == nil) {
        // Fallback to keyWindow if window is nil
        window = [UIApplication sharedApplication].keyWindow;
    }
    
    UIViewController *vc = window.rootViewController;
    if (vc == nil) {
        return nil;
    }
    
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)vc topViewController];
    }
    
    if ([vc isKindOfClass:[UITabBarController class]]) {
        return [(UITabBarController *)vc selectedViewController];
    }
    
    return vc;
}

@end