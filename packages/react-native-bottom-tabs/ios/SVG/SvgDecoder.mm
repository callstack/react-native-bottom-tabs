#import "SvgDecoder.h"
#import <React/RCTLog.h>

#if RN_BOTTOM_TABS_ENABLE_SVG
#import "CoreSVG.h"
#endif

#if !RN_BOTTOM_TABS_ENABLE_SVG && RCT_DEV
static BOOL RNBottomTabsLooksLikeSVGData(NSData *data)
{
  if (!data) {
    return NO;
  }
  NSData *tag = [@"</svg>" dataUsingEncoding:NSUTF8StringEncoding];
  NSUInteger length = MIN(100, data.length);
  return [data rangeOfData:tag options:NSDataSearchBackwards range:NSMakeRange(data.length - length, length)].location != NSNotFound;
}
#endif

@implementation SvgDecoder

RCT_EXPORT_MODULE()

@synthesize callableJSModules = _callableJSModules;

#if RCT_DEV
// RCTLogWarn alone does not show the message in React Native DevTools, so the
// warning goes through the JS console, which also shows it in LogBox.
- (void)logDevWarning:(NSString *)message
{
  RCTCallableJSModules *jsModules = self.callableJSModules;
  if (jsModules) {
    NSLog(@"%@", message);
    [jsModules invokeModule:@"RCTLog" method:@"logToConsole" withArgs:@[ @"warn", message ]];
  } else {
    RCTLogWarn(@"%@", message);
  }
}
#endif

- (BOOL)canDecodeImageData:(NSData *)imageData
{
#if RN_BOTTOM_TABS_ENABLE_SVG
  return [CoreSVGWrapper isSVGData:imageData];
#else
#if RCT_DEV
  if (RNBottomTabsLooksLikeSVGData(imageData)) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      [self logDevWarning:@"[react-native-bottom-tabs] SVG decoding is disabled, so SVG images are not shown. "
                          @"To enable it, set `$RNBottomTabsEnableSVG = true` in your Podfile, "
                          @"or `RN_BOTTOM_TABS_ENABLE_SVG=1` for Swift Package Manager."];
    });
  }
#endif
  return NO;
#endif
}

- (RCTImageLoaderCancellationBlock)decodeImageData:(NSData *)imageData
                                              size:(CGSize)size
                                             scale:(CGFloat)scale
                                        resizeMode:(RCTResizeMode)resizeMode
                                 completionHandler:(RCTImageLoaderCompletionBlock)completionHandler
{
#if RN_BOTTOM_TABS_ENABLE_SVG
#if RCT_DEV && RN_BOTTOM_TABS_SVG_DEFAULTED
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [self logDevWarning:@"[react-native-bottom-tabs] SVG decoding will be disabled by default in the next major version. "
                        @"To keep it, set `$RNBottomTabsEnableSVG = true` in your Podfile, "
                        @"or `RN_BOTTOM_TABS_ENABLE_SVG=1` for Swift Package Manager. "
                        @"Set it to `false` (or `0`) to remove the private CoreSVG code now."];
  });
#endif
  UIImage *image = [CoreSVGWrapper.shared imageFromSVGData:imageData];
#else
  UIImage *image = nil;
#endif

  if (image) {
    completionHandler(nil, image);
  } else {
    NSError *error = [NSError errorWithDomain:@"SVGDecoderErrorDomain"
                                         code:2
                                     userInfo:@{NSLocalizedDescriptionKey: @"Failed to render SVG to image"}];
    completionHandler(error, nil);
  }
  return ^{};
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
(const facebook::react::ObjCTurboModule::InitParams &)params
{
  return std::make_shared<facebook::react::NativeSVGDecoderSpecJSI>(params);
}

@end
