#import <Foundation/Foundation.h>
#import <TargetConditionals.h>

#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#else
#import <UIKit/UIKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif

#if TARGET_OS_OSX
NSImage *_Nullable RNBottomTabsDecodeSVGData(NSData *data);
#else
UIImage *_Nullable RNBottomTabsDecodeSVGData(NSData *data);
#endif

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END
