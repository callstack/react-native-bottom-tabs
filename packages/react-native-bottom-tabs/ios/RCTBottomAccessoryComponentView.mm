#ifdef RCT_NEW_ARCH_ENABLED
#import "RCTBottomAccessoryComponentView.h"

#import <react/renderer/components/RNCTabView/ComponentDescriptors.h>
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

using namespace facebook::react;

#if SWIFT_PACKAGE
typedef NSObject BottomAccessoryProvider;
@interface RCTBottomAccessoryComponentView () <RNCBottomAccessoryProviderDelegate>
#else
@interface RCTBottomAccessoryComponentView () <BottomAccessoryProviderDelegate>
#endif
{
  BottomAccessoryProvider* bottomAccessoryProvider;
}
@end

@implementation RCTBottomAccessoryComponentView

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<BottomAccessoryViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const BottomAccessoryViewProps>();
    if (@available(iOS 26.0, *)) {
#if SWIFT_PACKAGE
      bottomAccessoryProvider = RNCCreateBottomAccessoryProvider(self);
#else
      bottomAccessoryProvider = [[BottomAccessoryProvider alloc] initWithDelegate:self];
#endif
    }
  }

  return self;
}

- (void)setFrame:(CGRect)frame
{
  [super setFrame:frame];
  auto eventEmitter = std::static_pointer_cast<const BottomAccessoryViewEventEmitter>(_eventEmitter);
  if (eventEmitter) {
    // TODO: Rewrite this to emit synchronous layout events using shadow nodes
    eventEmitter->onNativeLayout(BottomAccessoryViewEventEmitter::OnNativeLayout {
      .height = frame.size.height,
      .width = frame.size.width
    });
  }
}

//  MARK: BottomAccessoryProviderDelegate

- (void)onPlacementChangedWithPlacement:(NSString *)placement
{
  auto eventEmitter = std::static_pointer_cast<const BottomAccessoryViewEventEmitter>(_eventEmitter);
  if (eventEmitter) {
    eventEmitter->onPlacementChanged(BottomAccessoryViewEventEmitter::OnPlacementChanged {
      .placement = std::string([placement UTF8String])
    });
  }
}


Class<RCTComponentViewProtocol> BottomAccessoryViewCls(void)
{
  return RCTBottomAccessoryComponentView.class;
}

@end

#endif
