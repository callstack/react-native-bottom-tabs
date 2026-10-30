#if defined(RCT_NEW_ARCH_ENABLED) || defined(SWIFT_PACKAGE)
#import <React/RCTViewComponentView.h>
#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#else
#import <UIKit/UIKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface RCTBottomAccessoryComponentView: RCTViewComponentView

@end

NS_ASSUME_NONNULL_END

#endif /* RCTBottomAccessoryComponentView_h */
