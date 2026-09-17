#ifdef SWIFT_PACKAGE
#import "BottomTabsBridge.h"
@import BottomTabsSwift;

UIView<RNCTabViewProvider> *RNCCreateTabViewProvider(id<RNCTabViewProviderDelegate> delegate) {
  return (UIView<RNCTabViewProvider> *)[[TabViewProvider alloc] initWithDelegate:(id<TabViewProviderDelegate>)delegate];
}

NSObject *RNCCreateBottomAccessoryProvider(id<RNCBottomAccessoryProviderDelegate> delegate) {
  return [[BottomAccessoryProvider alloc] initWithDelegate:(id<BottomAccessoryProviderDelegate>)delegate];
}

@implementation RNCTabInfo
+ (NSObject *)createWithKey:(NSString *)key
                     title:(NSString *)title
                     badge:(NSString *)badge
                  sfSymbol:(NSString *)sfSymbol
           sfSymbolOptions:(NSDictionary *)sfSymbolOptions
           focusedSfSymbol:(NSString *)focusedSfSymbol
    focusedSfSymbolOptions:(NSDictionary *)focusedSfSymbolOptions
           activeTintColor:(UIColor *)activeTintColor
         iconRenderingMode:(NSString *)iconRenderingMode
                    hidden:(BOOL)hidden
                    testID:(NSString *)testID
                      role:(NSString *)role
           preventsDefault:(BOOL)preventsDefault {
  return [[TabInfo alloc] initWithKey:key title:title badge:badge sfSymbol:sfSymbol
                    sfSymbolOptions:sfSymbolOptions
                    focusedSfSymbol:focusedSfSymbol
             focusedSfSymbolOptions:focusedSfSymbolOptions
                    activeTintColor:activeTintColor
                  iconRenderingMode:iconRenderingMode hidden:hidden testID:testID
                               role:role preventsDefault:preventsDefault];
}
@end
#endif
