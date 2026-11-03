#ifdef SWIFT_PACKAGE
#pragma once
#import <UIKit/UIKit.h>
#import <React/RCTImageLoader.h>

// The Objective-C++ Fabric target talks to Swift through this Objective-C-only
// boundary. Xcode can import the Swift module in .m files without enabling C++
// modules for React Native's textual C++ headers.
@protocol RNCTabViewProviderDelegate <NSObject>
- (void)onPageSelectedWithKey:(NSString *)key reactTag:(NSNumber *)reactTag;
- (void)onLongPressWithKey:(NSString *)key reactTag:(NSNumber *)reactTag;
- (void)onTabBarMeasuredWithHeight:(NSInteger)height reactTag:(NSNumber *)reactTag;
- (void)onLayoutWithSize:(CGSize)size reactTag:(NSNumber *)reactTag;
@end

@protocol RNCBottomAccessoryProviderDelegate <NSObject>
- (void)onPlacementChangedWithPlacement:(NSString *)placement;
@end

@protocol RNCTabViewProvider <NSObject>
@property(nonatomic, copy) NSArray *icons;
@property(nonatomic, copy) NSArray *focusedIcons;
@property(nonatomic) BOOL sidebarAdaptable;
@property(nonatomic) BOOL disablePageAnimations;
@property(nonatomic) BOOL labeled;
@property(nonatomic, copy) NSString *selectedPage;
@property(nonatomic) BOOL hapticFeedbackEnabled;
@property(nonatomic, copy) NSString *layoutDirection;
@property(nonatomic, copy) NSString *scrollEdgeAppearance;
@property(nonatomic, copy) NSString *minimizeBehavior;
@property(nonatomic) BOOL translucent;
@property(nonatomic, strong) UIColor *barTintColor;
@property(nonatomic, strong) UIColor *activeTintColor;
@property(nonatomic, strong) UIColor *inactiveTintColor;
@property(nonatomic) BOOL experimentalBakedTintColors;
@property(nonatomic, copy) NSString *fontFamily;
@property(nonatomic, copy) NSString *fontWeight;
@property(nonatomic, strong) NSNumber *fontSize;
@property(nonatomic) BOOL tabBarHidden;
@property(nonatomic, copy) NSArray *itemsData;
- (void)setImageLoader:(RCTImageLoader *)imageLoader;
- (void)insertChild:(UIView *)child atIndex:(NSInteger)index;
- (void)removeChildAtIndex:(NSInteger)index;
@end

FOUNDATION_EXPORT UIView<RNCTabViewProvider> *RNCCreateTabViewProvider(id<RNCTabViewProviderDelegate> delegate);
FOUNDATION_EXPORT NSObject *RNCCreateBottomAccessoryProvider(id<RNCBottomAccessoryProviderDelegate> delegate);

@interface RNCTabInfo : NSObject
+ (NSObject *)createWithKey:(NSString *)key
                     title:(NSString *)title
                     badge:(NSString *)badge
                  sfSymbol:(NSString *)sfSymbol
           focusedSfSymbol:(NSString *)focusedSfSymbol
           activeTintColor:(UIColor *)activeTintColor
         iconRenderingMode:(NSString *)iconRenderingMode
                    hidden:(BOOL)hidden
                    testID:(NSString *)testID
                      role:(NSString *)role
           preventsDefault:(BOOL)preventsDefault;
@end
#endif
