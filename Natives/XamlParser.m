#import "XamlParser.h"
#import <libxml/parser.h>
#import <libxml/tree.h>

@implementation XamlNode
@end

@implementation CardNode
- (instancetype)initWithAttributes:(NSDictionary<NSString *, NSString *> *)attributes children:(NSArray<XamlNode *> *)children {
    self = [super init];
    if (self) {
        _attributes = [attributes copy];
        _children = [children copy];
    }
    return self;
}
@end

@implementation StackPanelNode
- (instancetype)initWithAttributes:(NSDictionary<NSString *, NSString *> *)attributes children:(NSArray<XamlNode *> *)children {
    self = [super init];
    if (self) {
        _attributes = [attributes copy];
        _children = [children copy];
    }
    return self;
}
@end

@implementation TextBlockNode
- (instancetype)initWithAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
    self = [super init];
    if (self) {
        _attributes = [attributes copy];
    }
    return self;
}
@end

@implementation ButtonNode
- (instancetype)initWithAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
    self = [super init];
    if (self) {
        _attributes = [attributes copy];
    }
    return self;
}
@end

@implementation TextButtonNode
- (instancetype)initWithAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
    self = [super init];
    if (self) {
        _attributes = [attributes copy];
    }
    return self;
}
@end

@implementation HintNode
- (instancetype)initWithAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
    self = [super init];
    if (self) {
        _attributes = [attributes copy];
    }
    return self;
}
@end

@implementation ImageNode
- (instancetype)initWithAttributes:(NSDictionary<NSString *, NSString *> *)attributes {
    self = [super init];
    if (self) {
        _attributes = [attributes copy];
    }
    return self;
}
@end

@implementation UnknownNode
- (instancetype)initWithTagName:(NSString *)tagName children:(NSArray<XamlNode *> *)children {
    self = [super init];
    if (self) {
        _tagName = [tagName copy];
        _children = [children copy];
    }
    return self;
}
@end

@implementation XamlParser

+ (NSArray<XamlNode *> *)parseXaml:(NSString *)xaml {
    // Wrap XAML in a root element to make it valid XML
    NSString *wrappedXaml = [NSString stringWithFormat:@"<root>%@</root>", xaml];
    
    // Convert NSString to UTF-8 C string
    const char *xmlContent = [wrappedXaml UTF8String];
    int xmlLength = (int)strlen(xmlContent);
    
    // Parse XML
    xmlDocPtr doc = xmlReadMemory(xmlContent, xmlLength, NULL, NULL, 0);
    if (doc == NULL) {
        return [NSArray array];
    }
    
    xmlNodePtr root = xmlDocGetRootElement(doc);
    if (root == NULL) {
        xmlFreeDoc(doc);
        return [NSArray array];
    }
    
    // Parse children
    NSMutableArray<XamlNode *> *nodes = [NSMutableArray array];
    xmlNodePtr child = root->children;
    while (child != NULL) {
        if (child->type == XML_ELEMENT_NODE) {
            XamlNode *node = [self parseNode:child];
            if (node != nil) {
                [nodes addObject:node];
            }
        }
        child = child->next;
    }
    
    xmlFreeDoc(doc);
    return [nodes copy];
}

+ (XamlNode *)parseNode:(xmlNodePtr)node {
    // Get tag name
    NSString *tagName = [NSString stringWithUTF8String:(const char *)node->name];
    
    // Get attributes
    NSMutableDictionary<NSString *, NSString *> *attributes = [NSMutableDictionary dictionary];
    xmlAttrPtr attr = node->properties;
    while (attr != NULL) {
        NSString *attrName = [NSString stringWithUTF8String:(const char *)attr->name];
        xmlChar *attrValue = xmlNodeListGetString(node->doc, attr->children, 1);
        if (attrValue != NULL) {
            NSString *attrValueStr = [NSString stringWithUTF8String:(const char *)attrValue];
            attributes[attrName] = attrValueStr;
            xmlFree(attrValue);
        }
        attr = attr->next;
    }
    
    // Parse children
    NSMutableArray<XamlNode *> *children = [NSMutableArray array];
    xmlNodePtr child = node->children;
    while (child != NULL) {
        if (child->type == XML_ELEMENT_NODE) {
            XamlNode *childNode = [self parseNode:child];
            if (childNode != nil) {
                [children addObject:childNode];
            }
        }
        child = child->next;
    }
    
    // Create appropriate node based on tag name
    if ([tagName isEqualToString:@"local:MyCard"]) {
        return [[CardNode alloc] initWithAttributes:attributes children:children];
    } else if ([tagName isEqualToString:@"StackPanel"]) {
        return [[StackPanelNode alloc] initWithAttributes:attributes children:children];
    } else if ([tagName isEqualToString:@"TextBlock"]) {
        return [[TextBlockNode alloc] initWithAttributes:attributes];
    } else if ([tagName isEqualToString:@"local:MyButton"]) {
        return [[ButtonNode alloc] initWithAttributes:attributes];
    } else if ([tagName isEqualToString:@"local:MyTextButton"]) {
        return [[TextButtonNode alloc] initWithAttributes:attributes];
    } else if ([tagName isEqualToString:@"local:MyHint"]) {
        return [[HintNode alloc] initWithAttributes:attributes];
    } else if ([tagName isEqualToString:@"local:MyImage"]) {
        return [[ImageNode alloc] initWithAttributes:attributes];
    } else {
        // Handle other local:My* elements as generic nodes for now
        if ([tagName hasPrefix:@"local:My"]) {
            // For now, treat all local:My* elements as generic nodes
            // In a more complete implementation, we would have specific classes for each
            return [[UnknownNode alloc] initWithTagName:tagName children:children];
        } else {
            return [[UnknownNode alloc] initWithTagName:tagName children:children];
        }
    }
}

@end