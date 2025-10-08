#import "XamlRenderer.h"

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
    
    // Add to parent
    [parentView addSubview:cardView];
    
    // Set up constraints (this is a simplified version)
    cardView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [cardView.leadingAnchor constraintEqualToAnchor:parentView.leadingAnchor constant:16],
        [cardView.trailingAnchor constraintEqualToAnchor:parentView.trailingAnchor constant:-16],
        [cardView.topAnchor constraintEqualToAnchor:parentView.topAnchor constant:8],
        [cardView.heightAnchor constraintGreaterThanOrEqualToConstant:100]
    ]];
    
    // Render children
    if (node.children.count > 0) {
        [self renderNodes:node.children inView:cardView];
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
    
    // Add to parent
    [parentView addSubview:label];
    
    // Set up constraints
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [label.leadingAnchor constraintEqualToAnchor:parentView.leadingAnchor constant:16],
        [label.trailingAnchor constraintEqualToAnchor:parentView.trailingAnchor constant:-16],
        [label.topAnchor constraintEqualToAnchor:parentView.topAnchor constant:8]
    ]];
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
            // Fix the constraint syntax
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
    
    [NSLayoutConstraint activateConstraints:@[
        [hintView.leadingAnchor constraintEqualToAnchor:parentView.leadingAnchor constant:16],
        [hintView.trailingAnchor constraintEqualToAnchor:parentView.trailingAnchor constant:-16],
        [hintView.topAnchor constraintEqualToAnchor:parentView.topAnchor constant:8],
        
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
    
    // Apply height if specified
    NSString *heightStr = node.attributes[@"Height"];
    if (heightStr != nil) {
        CGFloat height = [heightStr floatValue];
        if (height > 0) {
            // Fix the constraint syntax
            [imageView.heightAnchor constraintEqualToConstant:height].active = YES;
        }
    }
    
    // Load image from URL (simplified - in a real app you'd want async loading)
    NSURL *url = [NSURL URLWithString:source];
    if (url != nil) {
        // In a real implementation, you would use async image loading
        // For now, we'll just set a placeholder
        imageView.image = [UIImage systemImageNamed:@"photo"];
    }
    
    // Add to parent
    [parentView addSubview:imageView];
    
    // Set up constraints
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [imageView.leadingAnchor constraintEqualToAnchor:parentView.leadingAnchor constant:16],
        [imageView.trailingAnchor constraintEqualToAnchor:parentView.trailingAnchor constant:-16],
        [imageView.topAnchor constraintEqualToAnchor:parentView.topAnchor constant:8],
        [imageView.heightAnchor constraintEqualToConstant:50]
    ]];
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

@end