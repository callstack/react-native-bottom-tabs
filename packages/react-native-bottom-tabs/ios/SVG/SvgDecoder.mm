#import "SvgDecoder.h"
#import "CoreSVG.h"

PlatformImage *RNBottomTabsDecodeSVGData(NSData *data)
{
  if (![CoreSVGWrapper isSVGData:data]) {
    return nil;
  }

  return [CoreSVGWrapper.shared imageFromSVGData:data];
}
