#ifdef RCT_NEW_ARCH_ENABLED
#import "RCTTabViewComponentView.h"

#import <react/renderer/components/RNCTabView/RNCTabViewComponentDescriptor.h>
#import <react/renderer/components/RNCTabView/EventEmitters.h>
#import <react/renderer/components/RNCTabView/Props.h>
#import <react/renderer/components/RNCTabView/RCTComponentViewHelpers.h>

#import <React/RCTFabricComponentsPlugins.h>

#if SWIFT_PACKAGE
#import "BottomTabsBridge.h"
#elif __has_include("react_native_bottom_tabs/react_native_bottom_tabs-Swift.h")
#import "react_native_bottom_tabs/react_native_bottom_tabs-Swift.h"
#else
#import "react_native_bottom_tabs-Swift.h"
#endif

#import <React/RCTImageLoader.h>
#import <React/RCTImageSource.h>
#import <React/RCTBridge+Private.h>
#if SWIFT_PACKAGE
#import <react/renderer/imagemanager/RCTImagePrimitivesConversions.h>
#elif __has_include(<React/RCTImagePrimitivesConversions.h>)
#import <React/RCTImagePrimitivesConversions.h>
#else
#import "RCTImagePrimitivesConversions.h"
#endif
#if __has_include(<React/RCTConversions.h>)
#import <React/RCTConversions.h>
#else
#import "RCTConversions.h"
#endif
#import <react/utils/ManagedObjectWrapper.h>

#if TARGET_OS_OSX
typedef NSView PlatformView;
#else
typedef UIView PlatformView;
#endif

// Overload `==` and `!=` operators for `RNCTabViewItemsStruct`

namespace facebook::react {

// The two SF Symbol option structs are generated separately, one per field,
// even though they are structurally identical. A template keeps the comparison
// and the conversion below written once.
template <typename SymbolOptions>
bool sfSymbolOptionsEqual(const SymbolOptions& lhs, const SymbolOptions& rhs) {
  return lhs.size == rhs.size &&
  lhs.weight == rhs.weight &&
  lhs.scale == rhs.scale &&
  lhs.color == rhs.color &&
  lhs.primaryColor == rhs.primaryColor &&
  lhs.secondaryColor == rhs.secondaryColor &&
  lhs.tertiaryColor == rhs.tertiaryColor &&
  lhs.renderingMode == rhs.renderingMode &&
  lhs.variableValue == rhs.variableValue &&
  lhs.variableValueMode == rhs.variableValueMode &&
  lhs.colorRenderingMode == rhs.colorRenderingMode;
}

bool operator==(const RNCTabViewItemsStruct& lhs, const RNCTabViewItemsStruct& rhs) {
  return lhs.key == rhs.key &&
  lhs.title == rhs.title &&
  lhs.sfSymbol == rhs.sfSymbol &&
  sfSymbolOptionsEqual(lhs.sfSymbolOptions, rhs.sfSymbolOptions) &&
  lhs.focusedSfSymbol == rhs.focusedSfSymbol &&
  sfSymbolOptionsEqual(lhs.focusedSfSymbolOptions, rhs.focusedSfSymbolOptions) &&
  lhs.badge == rhs.badge &&
  lhs.activeTintColor == rhs.activeTintColor &&
  lhs.iconRenderingMode == rhs.iconRenderingMode &&
  lhs.hidden == rhs.hidden &&
  lhs.testID == rhs.testID &&
  lhs.role == rhs.role &&
  lhs.preventsDefault == rhs.preventsDefault;
}

bool operator!=(const RNCTabViewItemsStruct& lhs, const RNCTabViewItemsStruct& rhs) {
  return !(lhs == rhs);
}

}


using namespace facebook::react;

#if SWIFT_PACKAGE
typedef UIView<RNCTabViewProvider> TabViewProvider;
typedef NSObject TabInfo;
@interface RCTTabViewComponentView () <RCTRNCTabViewViewProtocol, RNCTabViewProviderDelegate>
#else
@interface RCTTabViewComponentView () <RCTRNCTabViewViewProtocol, TabViewProviderDelegate>
#endif
{
}

@end

@implementation RCTTabViewComponentView {
  TabViewProvider *_tabViewProvider;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<RNCTabViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const RNCTabViewProps>();
#if SWIFT_PACKAGE
    _tabViewProvider = RNCCreateTabViewProvider(self);
#else
    _tabViewProvider = [[TabViewProvider alloc] initWithDelegate:self];
#endif
    self.contentView = _tabViewProvider;
    _props = defaultProps;
  }

  return self;
}

// Opt out of recycling for now, it's not working properly.
+ (BOOL)shouldBeRecycled
{
  return NO;
}

- (void)mountChildComponentView:(PlatformView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index {
  [_tabViewProvider insertChild:childComponentView atIndex:index];
}

- (void)unmountChildComponentView:(PlatformView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index {
  [_tabViewProvider removeChildAtIndex:index];
  [childComponentView removeFromSuperview];
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  const auto &oldViewProps = *std::static_pointer_cast<RNCTabViewProps const>(_props);
  const auto &newViewProps = *std::static_pointer_cast<RNCTabViewProps const>(props);

  if (oldViewProps.items != newViewProps.items) {
    _tabViewProvider.itemsData = convertItemsToArray(newViewProps.items);
  }

  if (oldViewProps.translucent != newViewProps.translucent) {
    _tabViewProvider.translucent = newViewProps.translucent;
  }

  if (oldViewProps.icons != newViewProps.icons) {
    auto iconsArray = [[NSMutableArray alloc] init];
    for (auto &source: newViewProps.icons) {
      auto imageSource = [[RCTImageSource alloc] initWithURLRequest:NSURLRequestFromImageSource(source) size:CGSizeMake(source.size.width, source.size.height) scale:source.scale];
      [iconsArray addObject:imageSource];
    }

    _tabViewProvider.icons = iconsArray;
  }

  if (oldViewProps.focusedIcons != newViewProps.focusedIcons) {
    auto focusedIconsArray = [[NSMutableArray alloc] init];
    for (auto &source: newViewProps.focusedIcons) {
      auto imageSource = [[RCTImageSource alloc] initWithURLRequest:NSURLRequestFromImageSource(source) size:CGSizeMake(source.size.width, source.size.height) scale:source.scale];
      [focusedIconsArray addObject:imageSource];
    }

    _tabViewProvider.focusedIcons = focusedIconsArray;
  }

  if (oldViewProps.sidebarAdaptable != newViewProps.sidebarAdaptable) {
    _tabViewProvider.sidebarAdaptable = newViewProps.sidebarAdaptable;
  }
  
  if (oldViewProps.minimizeBehavior != newViewProps.minimizeBehavior) {
    _tabViewProvider.minimizeBehavior = RCTNSStringFromString(newViewProps.minimizeBehavior);
  }

  if (oldViewProps.disablePageAnimations != newViewProps.disablePageAnimations) {
    _tabViewProvider.disablePageAnimations = newViewProps.disablePageAnimations;
  }

  if (oldViewProps.labeled != newViewProps.labeled) {
    _tabViewProvider.labeled = newViewProps.labeled;
  }

  if (oldViewProps.selectedPage != newViewProps.selectedPage) {
    _tabViewProvider.selectedPage = RCTNSStringFromString(newViewProps.selectedPage);
  }

  if (oldViewProps.scrollEdgeAppearance != newViewProps.scrollEdgeAppearance) {
    _tabViewProvider.scrollEdgeAppearance = RCTNSStringFromString(newViewProps.scrollEdgeAppearance);
  }

  if (oldViewProps.labeled != newViewProps.labeled) {
    _tabViewProvider.labeled = newViewProps.labeled;
  }

  if (oldViewProps.barTintColor != newViewProps.barTintColor) {
    _tabViewProvider.barTintColor = RCTUIColorFromSharedColor(newViewProps.barTintColor);
  }

  if (oldViewProps.activeTintColor != newViewProps.activeTintColor) {
    _tabViewProvider.activeTintColor = RCTUIColorFromSharedColor(newViewProps.activeTintColor);
  }

  if (oldViewProps.inactiveTintColor != newViewProps.inactiveTintColor) {
    _tabViewProvider.inactiveTintColor = RCTUIColorFromSharedColor(newViewProps.inactiveTintColor);
  }

  if (oldViewProps.experimentalBakedTintColors != newViewProps.experimentalBakedTintColors) {
    _tabViewProvider.experimentalBakedTintColors = newViewProps.experimentalBakedTintColors;
  }

  if (oldViewProps.hapticFeedbackEnabled != newViewProps.hapticFeedbackEnabled) {
    _tabViewProvider.hapticFeedbackEnabled = newViewProps.hapticFeedbackEnabled;
  }

  if (oldViewProps.layoutDirection != newViewProps.layoutDirection) {
    _tabViewProvider.layoutDirection = RCTNSStringFromStringNilIfEmpty(newViewProps.layoutDirection);
  }

  if (oldViewProps.fontSize != newViewProps.fontSize) {
    _tabViewProvider.fontSize = [NSNumber numberWithInt:newViewProps.fontSize];
  }

  if (oldViewProps.fontWeight != newViewProps.fontWeight) {
    _tabViewProvider.fontWeight = RCTNSStringFromStringNilIfEmpty(newViewProps.fontWeight);
  }

  if (oldViewProps.fontFamily != newViewProps.fontFamily) {
    _tabViewProvider.fontFamily = RCTNSStringFromStringNilIfEmpty(newViewProps.fontFamily);
  }

  if (oldViewProps.tabBarHidden != newViewProps.tabBarHidden) {
    _tabViewProvider.tabBarHidden = newViewProps.tabBarHidden;
  }


  [super updateProps:props oldProps:oldProps];
}

// Converts the flattened SF Symbol options into a dictionary the Swift side
// parses. Sentinel values (`0` for size and weight, `-1` for variableValue,
// empty strings) mean "not configured" and are dropped, so Swift sees `nil` and
// leaves the corresponding platform default alone.
template <typename SymbolOptions>
static NSDictionary* convertSymbolOptions(const SymbolOptions& options) {
  NSMutableDictionary *result = [NSMutableDictionary dictionary];

  if (options.size > 0) {
    result[@"size"] = @(options.size);
  }

  if (options.weight > 0) {
    result[@"weight"] = @(options.weight);
  }

  if (!options.scale.empty()) {
    result[@"scale"] = RCTNSStringFromString(options.scale);
  }

  if (UIColor *color = RCTUIColorFromSharedColor(options.color)) {
    result[@"color"] = color;
  }

  if (UIColor *color = RCTUIColorFromSharedColor(options.primaryColor)) {
    result[@"primaryColor"] = color;
  }

  if (UIColor *color = RCTUIColorFromSharedColor(options.secondaryColor)) {
    result[@"secondaryColor"] = color;
  }

  if (UIColor *color = RCTUIColorFromSharedColor(options.tertiaryColor)) {
    result[@"tertiaryColor"] = color;
  }

  if (!options.renderingMode.empty()) {
    result[@"renderingMode"] = RCTNSStringFromString(options.renderingMode);
  }

  if (options.variableValue >= 0) {
    result[@"variableValue"] = @(options.variableValue);
  }

  if (!options.variableValueMode.empty()) {
    result[@"variableValueMode"] = RCTNSStringFromString(options.variableValueMode);
  }

  if (!options.colorRenderingMode.empty()) {
    result[@"colorRenderingMode"] = RCTNSStringFromString(options.colorRenderingMode);
  }

  return result.count > 0 ? result : nil;
}

NSArray* convertItemsToArray(const std::vector<RNCTabViewItemsStruct>& items) {
  NSMutableArray<TabInfo *> *result = [NSMutableArray array];

  for (const auto& item : items) {
    // Options only ever apply alongside a symbol name, and the generated struct
    // cannot be null, so an item without a symbol carries default values that
    // must not be mistaken for configuration.
    NSDictionary *symbolOptions =
      item.sfSymbol.empty() ? nil : convertSymbolOptions(item.sfSymbolOptions);
    NSDictionary *focusedSymbolOptions =
      item.focusedSfSymbol.empty() ? nil : convertSymbolOptions(item.focusedSfSymbolOptions);

#if SWIFT_PACKAGE
    auto tabInfo = [RNCTabInfo createWithKey:RCTNSStringFromString(item.key)
#else
    auto tabInfo = [[TabInfo alloc] initWithKey:RCTNSStringFromString(item.key)
#endif
                                          title:RCTNSStringFromString(item.title)
                                          badge:RCTNSStringFromStringNilIfEmpty(item.badge)
                                       sfSymbol:RCTNSStringFromStringNilIfEmpty(item.sfSymbol)
                                sfSymbolOptions:symbolOptions
                                 focusedSfSymbol:RCTNSStringFromStringNilIfEmpty(item.focusedSfSymbol)
                         focusedSfSymbolOptions:focusedSymbolOptions
                                activeTintColor:RCTUIColorFromSharedColor(item.activeTintColor)
                             iconRenderingMode:RCTNSStringFromStringNilIfEmpty(item.iconRenderingMode)
                                         hidden:item.hidden
                                         testID:RCTNSStringFromStringNilIfEmpty(item.testID)
                                         role:RCTNSStringFromStringNilIfEmpty(item.role)
                              preventsDefault:item.preventsDefault
    ];

    [result addObject:tabInfo];
  }

  return result;
}

- (void)updateState:(const facebook::react::State::Shared &)state oldState:(const facebook::react::State::Shared &)oldState
{
  auto _state = std::static_pointer_cast<RNCTabViewShadowNode::ConcreteState const>(state);
  auto data = _state->getData();
  if (auto imgLoaderPtr = _state.get()->getData().getImageLoader().lock()) {
    [_tabViewProvider setImageLoader:unwrapManagedObject(imgLoaderPtr)];
  }
}

//  MARK: TabViewProviderDelegate

- (void)onPageSelectedWithKey:(NSString *)key reactTag:(NSNumber *)reactTag {
  auto eventEmitter = std::static_pointer_cast<const RNCTabViewEventEmitter>(_eventEmitter);
  if (eventEmitter) {
    eventEmitter->onPageSelected(RNCTabViewEventEmitter::OnPageSelected{
      .key = [key cStringUsingEncoding:kCFStringEncodingUTF8]
    });
  }
}

- (void)onLongPressWithKey:(NSString *)key reactTag:(NSNumber *)reactTag {
  auto eventEmitter = std::static_pointer_cast<const RNCTabViewEventEmitter>(_eventEmitter);
  if (eventEmitter) {
    eventEmitter->onTabLongPress(RNCTabViewEventEmitter::OnTabLongPress {
      .key = [key cStringUsingEncoding:kCFStringEncodingUTF8]
    });
  }
}

- (void)onTabBarMeasuredWithHeight:(NSInteger)height reactTag:(NSNumber *)reactTag {
  auto eventEmitter = std::static_pointer_cast<const RNCTabViewEventEmitter>(_eventEmitter);
  if (eventEmitter) {
    eventEmitter->onTabBarMeasured(RNCTabViewEventEmitter::OnTabBarMeasured {
      .height = (int)height
    });
  }
}

- (void)onLayoutWithSize:(CGSize)size reactTag:(NSNumber *)reactTag {
  auto eventEmitter = std::static_pointer_cast<const RNCTabViewEventEmitter>(_eventEmitter);
  if (eventEmitter) {
    eventEmitter->onNativeLayout(RNCTabViewEventEmitter::OnNativeLayout {
      .height = size.height,
      .width = size.width
    });
  }
}

@end

Class<RCTComponentViewProtocol> RNCTabViewCls(void)
{
  return RCTTabViewComponentView.class;
}

#endif // RCT_NEW_ARCH_ENABLED
