#ifdef RCT_NEW_ARCH_ENABLED
#import "RCTTabViewComponentView.h"

#import <react/renderer/components/RNCTabView/RNCTabViewComponentDescriptor.h>
#import <react/renderer/components/RNCTabView/EventEmitters.h>
#import <react/renderer/components/RNCTabView/Props.h>
#import <react/renderer/components/RNCTabView/RCTComponentViewHelpers.h>

#import <React/RCTFabricComponentsPlugins.h>

#if __has_include("react_native_bottom_tabs/react_native_bottom_tabs-Swift.h")
#import "react_native_bottom_tabs/react_native_bottom_tabs-Swift.h"
#else
#import "react_native_bottom_tabs-Swift.h"
#endif

#import <React/RCTImageLoader.h>
#import <React/RCTImageSource.h>
#import <React/RCTBridge+Private.h>
#import "RCTImagePrimitivesConversions.h"
#import "RCTConversions.h"
#import <react/utils/ManagedObjectWrapper.h>

#if TARGET_OS_OSX
typedef NSView PlatformView;
#else
typedef UIView PlatformView;
#endif

// Overload `==` and `!=` operators for `RNCTabViewItemsStruct`

namespace facebook::react {

bool operator==(const RNCTabViewItemsStruct& lhs, const RNCTabViewItemsStruct& rhs) {
  return lhs.key == rhs.key &&
  lhs.title == rhs.title &&
  lhs.sfSymbol == rhs.sfSymbol &&
  lhs.badge == rhs.badge &&
  lhs.activeTintColor == rhs.activeTintColor &&
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

@interface RCTTabViewComponentView () <RCTRNCTabViewViewProtocol, TabViewProviderDelegate> {
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
    _tabViewProvider = [[TabViewProvider alloc] initWithDelegate:self];
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

NSArray* convertItemsToArray(const std::vector<RNCTabViewItemsStruct>& items) {
  NSMutableArray<TabInfo *> *result = [NSMutableArray array];

  for (const auto& item : items) {
    auto tabInfo = [[TabInfo alloc] initWithKey:RCTNSStringFromString(item.key)
                                          title:RCTNSStringFromString(item.title)
                                          badge:RCTNSStringFromStringNilIfEmpty(item.badge)
                                       sfSymbol:RCTNSStringFromStringNilIfEmpty(item.sfSymbol)
                                activeTintColor:RCTUIColorFromSharedColor(item.activeTintColor)
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


