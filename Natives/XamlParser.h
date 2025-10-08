#import <Foundation/Foundation.h>

// Base class for XAML nodes
@interface XamlNode : NSObject
@end

// Card node
@interface CardNode : XamlNode
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *attributes;
@property (nonatomic, strong) NSArray<XamlNode *> *children;
- (instancetype)initWithAttributes:(NSDictionary<NSString *, NSString *> *)attributes children:(NSArray<XamlNode *> *)children;
@end

// StackPanel node
@interface StackPanelNode : XamlNode
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *attributes;
@property (nonatomic, strong) NSArray<XamlNode *> *children;
- (instancetype)initWithAttributes:(NSDictionary<NSString *, NSString *> *)attributes children:(NSArray<XamlNode *> *)children;
@end

// TextBlock node
@interface TextBlockNode : XamlNode
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *attributes;
- (instancetype)initWithAttributes:(NSDictionary<NSString *, NSString *> *)attributes;
@end

// Button node
@interface ButtonNode : XamlNode
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *attributes;
- (instancetype)initWithAttributes:(NSDictionary<NSString *, NSString *> *)attributes;
@end

// Hint node
@interface HintNode : XamlNode
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *attributes;
- (instancetype)initWithAttributes:(NSDictionary<NSString *, NSString *> *)attributes;
@end

// Image node
@interface ImageNode : XamlNode
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *attributes;
- (instancetype)initWithAttributes:(NSDictionary<NSString *, NSString *> *)attributes;
@end

// Unknown node
@interface UnknownNode : XamlNode
@property (nonatomic, strong) NSString *tagName;
@property (nonatomic, strong) NSArray<XamlNode *> *children;
- (instancetype)initWithTagName:(NSString *)tagName children:(NSArray<XamlNode *> *)children;
@end

@interface XamlParser : NSObject
+ (NSArray<XamlNode *> *)parseXaml:(NSString *)xaml;
@end