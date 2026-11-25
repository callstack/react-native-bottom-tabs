// The private CoreSVG code is compiled only when SVG support is enabled.
// See ios/svg_configuration.rb and Package.swift.
#if RN_BOTTOM_TABS_ENABLE_SVG

#import "CoreSVG.h"
#import <dlfcn.h>
#import <objc/runtime.h>

#define kSVGTagEnd @"</svg>"

typedef struct CF_BRIDGED_TYPE(id) CGSVGDocument *CGSVGDocumentRef;

static CGSVGDocumentRef (*CoreSVGDocumentRetain)(CGSVGDocumentRef);
static void (*CoreSVGDocumentRelease)(CGSVGDocumentRef);
static CGSVGDocumentRef (*CoreSVGDocumentCreateFromData)(CFDataRef data, CFDictionaryRef options);
static void (*CoreSVGContextDrawSVGDocument)(CGContextRef context, CGSVGDocumentRef document);
static CGSize (*CoreSVGDocumentGetCanvasSize)(CGSVGDocumentRef document);

#if !TARGET_OS_OSX
static SEL CoreSVGImageWithDocumentSEL = NULL;
static SEL CoreSVGDocumentSEL = NULL;
#endif
#if TARGET_OS_OSX
static Class CoreSVGImageRepClass = NULL;
static Ivar CoreSVGImageRepDocumentIvar = NULL;
#endif

static inline NSString *Base64DecodedString(NSString *base64String) {
  NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
  if (!data) {
    return nil;
  }
  return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@implementation CoreSVGWrapper

+ (instancetype)shared {
  static dispatch_once_t onceToken;
  static CoreSVGWrapper *wrapper;
  dispatch_once(&onceToken, ^{
    wrapper = [[CoreSVGWrapper alloc] init];
  });
  return wrapper;
}

+ (void)initialize {
  CoreSVGDocumentRetain = (CGSVGDocumentRef (*)(CGSVGDocumentRef))dlsym(RTLD_DEFAULT, Base64DecodedString(@"Q0dTVkdEb2N1bWVudFJldGFpbg==").UTF8String);
  CoreSVGDocumentRelease = (void (*)(CGSVGDocumentRef))dlsym(RTLD_DEFAULT, Base64DecodedString(@"Q0dTVkdEb2N1bWVudFJlbGVhc2U=").UTF8String);
  CoreSVGDocumentCreateFromData = (CGSVGDocumentRef (*)(CFDataRef data, CFDictionaryRef options))dlsym(RTLD_DEFAULT, Base64DecodedString(@"Q0dTVkdEb2N1bWVudENyZWF0ZUZyb21EYXRh").UTF8String);
  CoreSVGContextDrawSVGDocument = (void (*)(CGContextRef context, CGSVGDocumentRef document))dlsym(RTLD_DEFAULT, Base64DecodedString(@"Q0dDb250ZXh0RHJhd1NWR0RvY3VtZW50").UTF8String);
  CoreSVGDocumentGetCanvasSize = (CGSize (*)(CGSVGDocumentRef document))dlsym(RTLD_DEFAULT, Base64DecodedString(@"Q0dTVkdEb2N1bWVudEdldENhbnZhc1NpemU=").UTF8String);
  
#if !TARGET_OS_OSX
  CoreSVGImageWithDocumentSEL = NSSelectorFromString(Base64DecodedString(@"X2ltYWdlV2l0aENHU1ZHRG9jdW1lbnQ6"));
  CoreSVGDocumentSEL = NSSelectorFromString(Base64DecodedString(@"X0NHU1ZHRG9jdW1lbnQ="));
#endif
#if TARGET_OS_OSX
  CoreSVGImageRepClass = NSClassFromString(Base64DecodedString(@"X05TU1ZHSW1hZ2VSZXA="));
  if (CoreSVGImageRepClass) {
    CoreSVGImageRepDocumentIvar = class_getInstanceVariable(CoreSVGImageRepClass, Base64DecodedString(@"X2RvY3VtZW50").UTF8String);
  }
#endif
}

- (PlatformImage *)imageFromSVGData:(NSData *)data {
  if (!data) {
    return nil;
  }
  
  if (![self.class supportsVectorSVGImage]) {
    return nil;
  }
  
  return [self createVectorSVGWithData:data];
}

- (PlatformImage *)createVectorSVGWithData:(NSData *)data {
  if (!data) return nil;
  
  PlatformImage *image;
  
#if TARGET_OS_OSX
  if (!CoreSVGImageRepClass) {
    return nil;
  }
  Class imageRepClass = CoreSVGImageRepClass;
  NSImageRep *imageRep = [[imageRepClass alloc] initWithData:data];
  if (!imageRep) {
    return nil;
  }
  image = [[NSImage alloc] initWithSize:imageRep.size];
  [image addRepresentation:imageRep];
#else
  if (!CoreSVGDocumentCreateFromData || !CoreSVGDocumentRelease) {
    return nil;
  }
  CGSVGDocumentRef document = CoreSVGDocumentCreateFromData((__bridge CFDataRef)data, NULL);
  
  if (!document) {
    return nil;
  }
  
  image = ((UIImage *(*)(id,SEL,CGSVGDocumentRef))[UIImage.class methodForSelector:CoreSVGImageWithDocumentSEL])(UIImage.class, CoreSVGImageWithDocumentSEL, document);
  CoreSVGDocumentRelease(document);
#endif
  
#if TARGET_OS_OSX
  // Test render to catch potential CoreSVG crashes on macOS
  NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc]
                              initWithBitmapDataPlanes:NULL
                              pixelsWide:1
                              pixelsHigh:1
                              bitsPerSample:8
                              samplesPerPixel:4
                              hasAlpha:YES
                              isPlanar:NO
                              colorSpaceName:NSCalibratedRGBColorSpace
                              bytesPerRow:0
                              bitsPerPixel:0];
  
  NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap];
  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext:context];
  
  @try {
    [image drawInRect:NSMakeRect(0, 0, 1, 1)];
  } @catch (...) {
    [NSGraphicsContext restoreGraphicsState];
    return nil;
  }
  
  [NSGraphicsContext restoreGraphicsState];
#else
  // Test render to catch potential CoreSVG crashes
  UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 1.0);
  @try {
    [image drawInRect:CGRectMake(0, 0, 1, 1)];
  } @catch (...) {
    UIGraphicsEndImageContext();
    return nil;
  }
  UIGraphicsEndImageContext();
#endif
  
  
  return image;
}

+ (BOOL)isSVGData:(NSData *)data {
  if (!data) {
    return NO;
  }
  // Check end with SVG tag
  return [data rangeOfData:[kSVGTagEnd dataUsingEncoding:NSUTF8StringEncoding] options:NSDataSearchBackwards range: NSMakeRange(data.length - MIN(100, data.length), MIN(100, data.length))].location != NSNotFound;
}

+ (BOOL)supportsVectorSVGImage {
  static dispatch_once_t onceToken;
  static BOOL supports;
  dispatch_once(&onceToken, ^{
#if TARGET_OS_OSX
    // macOS 10.15+ supports SVG built-in rendering, use selector to check is more accurate
    if (CoreSVGImageRepClass) {
      supports = YES;
    } else {
      supports = NO;
    }
#else
    // iOS 13+ supports SVG built-in rendering, use selector to check is more accurate
    if ([UIImage respondsToSelector:CoreSVGImageWithDocumentSEL]) {
      supports = YES;
    } else {
      supports = NO;
    }
#endif
  });
  return supports;
}

@end

#endif
