#import <UIKit/UIKit.h>
#import "XamlParser.h"

@interface XamlRenderer : NSObject
+ (void)renderNodes:(NSArray<XamlNode *> *)nodes inView:(UIView *)parentView;
@end