/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI32_0_0RCTConvert.h"

#import <objc/message.h>

#import <CoreText/CoreText.h>

#import "ABI32_0_0RCTDefines.h"
#import "ABI32_0_0RCTImageSource.h"
#import "ABI32_0_0RCTParserUtils.h"
#import "ABI32_0_0RCTUtils.h"

@implementation ABI32_0_0RCTConvert

ABI32_0_0RCT_CONVERTER(id, id, self)

ABI32_0_0RCT_CONVERTER(BOOL, BOOL, boolValue)
ABI32_0_0RCT_NUMBER_CONVERTER(double, doubleValue)
ABI32_0_0RCT_NUMBER_CONVERTER(float, floatValue)
ABI32_0_0RCT_NUMBER_CONVERTER(int, intValue)

ABI32_0_0RCT_NUMBER_CONVERTER(int64_t, longLongValue);
ABI32_0_0RCT_NUMBER_CONVERTER(uint64_t, unsignedLongLongValue);

ABI32_0_0RCT_NUMBER_CONVERTER(NSInteger, integerValue)
ABI32_0_0RCT_NUMBER_CONVERTER(NSUInteger, unsignedIntegerValue)

/**
 * This macro is used for creating converter functions for directly
 * representable json values that require no conversion.
 */
#if ABI32_0_0RCT_DEBUG
#define ABI32_0_0RCT_JSON_CONVERTER(type)           \
+ (type *)type:(id)json                    \
{                                          \
  if ([json isKindOfClass:[type class]]) { \
    return json;                           \
  } else if (json) {                       \
    ABI32_0_0RCTLogConvertError(json, @#type);      \
  }                                        \
  return nil;                              \
}
#else
#define ABI32_0_0RCT_JSON_CONVERTER(type)           \
+ (type *)type:(id)json { return json; }
#endif

ABI32_0_0RCT_JSON_CONVERTER(NSArray)
ABI32_0_0RCT_JSON_CONVERTER(NSDictionary)
ABI32_0_0RCT_JSON_CONVERTER(NSString)
ABI32_0_0RCT_JSON_CONVERTER(NSNumber)

ABI32_0_0RCT_CUSTOM_CONVERTER(NSSet *, NSSet, [NSSet setWithArray:json])
ABI32_0_0RCT_CUSTOM_CONVERTER(NSData *, NSData, [json dataUsingEncoding:NSUTF8StringEncoding])

+ (NSIndexSet *)NSIndexSet:(id)json
{
  json = [self NSNumberArray:json];
  NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
  for (NSNumber *number in json) {
    NSInteger index = number.integerValue;
    if (ABI32_0_0RCT_DEBUG && index < 0) {
      ABI32_0_0RCTLogError(@"Invalid index value %lld. Indices must be positive.", (long long)index);
    }
    [indexSet addIndex:index];
  }
  return indexSet;
}

+ (NSURL *)NSURL:(id)json
{
  NSString *path = [self NSString:json];
  if (!path) {
    return nil;
  }

  @try { // NSURL has a history of crashing with bad input, so let's be safe

    NSURL *URL = [NSURL URLWithString:path];
    if (URL.scheme) { // Was a well-formed absolute URL
      return URL;
    }

    // Check if it has a scheme
    if ([path rangeOfString:@":"].location != NSNotFound) {
      path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      URL = [NSURL URLWithString:path];
      if (URL) {
        return URL;
      }
    }

    // Assume that it's a local path
    path = path.stringByRemovingPercentEncoding;
    if ([path hasPrefix:@"~"]) {
      // Path is inside user directory
      path = path.stringByExpandingTildeInPath;
    } else if (!path.absolutePath) {
      // Assume it's a resource path
      path = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:path];
    }
    if (!(URL = [NSURL fileURLWithPath:path])) {
      ABI32_0_0RCTLogConvertError(json, @"a valid URL");
    }
    return URL;
  }
  @catch (__unused NSException *e) {
    ABI32_0_0RCTLogConvertError(json, @"a valid URL");
    return nil;
  }
}

ABI32_0_0RCT_ENUM_CONVERTER(NSURLRequestCachePolicy, (@{
                                               @"default": @(NSURLRequestUseProtocolCachePolicy),
                                               @"reload": @(NSURLRequestReloadIgnoringLocalCacheData),
                                               @"force-cache": @(NSURLRequestReturnCacheDataElseLoad),
                                               @"only-if-cached": @(NSURLRequestReturnCacheDataDontLoad),
                                               }), NSURLRequestUseProtocolCachePolicy, integerValue)


+ (NSURLRequest *)NSURLRequest:(id)json
{
  if ([json isKindOfClass:[NSString class]]) {
    NSURL *URL = [self NSURL:json];
    return URL ? [NSURLRequest requestWithURL:URL] : nil;
  }
  if ([json isKindOfClass:[NSDictionary class]]) {
    NSString *URLString = json[@"uri"] ?: json[@"url"];

    NSURL *URL;
    NSString *bundleName = json[@"bundle"];
    if (bundleName) {
      URLString = [NSString stringWithFormat:@"%@.bundle/%@", bundleName, URLString];
    }

    URL = [self NSURL:URLString];
    if (!URL) {
      return nil;
    }

    NSData *body = [self NSData:json[@"body"]];
    NSString *method = [self NSString:json[@"method"]].uppercaseString ?: @"GET";
    NSURLRequestCachePolicy cachePolicy = [self NSURLRequestCachePolicy:json[@"cache"]];
    NSDictionary *headers = [self NSDictionary:json[@"headers"]];
    if ([method isEqualToString:@"GET"] && headers == nil && body == nil && cachePolicy == NSURLRequestUseProtocolCachePolicy) {
      return [NSURLRequest requestWithURL:URL];
    }

    if (headers) {
      __block BOOL allHeadersAreStrings = YES;
      [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, id header, BOOL *stop) {
        if (![header isKindOfClass:[NSString class]]) {
          ABI32_0_0RCTLogError(@"Values of HTTP headers passed must be  of type string. "
                      "Value of header '%@' is not a string.", key);
          allHeadersAreStrings = NO;
          *stop = YES;
        }
      }];
      if (!allHeadersAreStrings) {
        // Set headers to nil here to avoid crashing later.
        headers = nil;
      }
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPBody = body;
    request.HTTPMethod = method;
    request.cachePolicy = cachePolicy;
    request.allHTTPHeaderFields = headers;
    return [request copy];
  }
  if (json) {
    ABI32_0_0RCTLogConvertError(json, @"a valid URLRequest");
  }
  return nil;
}

+ (ABI32_0_0RCTFileURL *)ABI32_0_0RCTFileURL:(id)json
{
  NSURL *fileURL = [self NSURL:json];
  if (!fileURL.fileURL) {
    ABI32_0_0RCTLogError(@"URI must be a local file, '%@' isn't.", fileURL);
    return nil;
  }
  if (![[NSFileManager defaultManager] fileExistsAtPath:fileURL.path]) {
    ABI32_0_0RCTLogError(@"File '%@' could not be found.", fileURL);
    return nil;
  }
  return fileURL;
}

+ (NSDate *)NSDate:(id)json
{
  if ([json isKindOfClass:[NSNumber class]]) {
    return [NSDate dateWithTimeIntervalSince1970:[self NSTimeInterval:json]];
  } else if ([json isKindOfClass:[NSString class]]) {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      formatter = [NSDateFormatter new];
      formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ";
      formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
      formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    });
    NSDate *date = [formatter dateFromString:json];
    if (!date) {
      ABI32_0_0RCTLogError(@"JSON String '%@' could not be interpreted as a date. "
                  "Expected format: YYYY-MM-DD'T'HH:mm:ss.sssZ", json);
    }
    return date;
  } else if (json) {
    ABI32_0_0RCTLogConvertError(json, @"a date");
  }
  return nil;
}

+ (NSLocale *)NSLocale:(id)json
{
  if ([json isKindOfClass:[NSString class]]) {
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:json];
    if (!locale) {
      ABI32_0_0RCTLogError(@"JSON String '%@' could not be interpreted as a valid locale. ", json);
    }
    return locale;
  } else if (json) {
    ABI32_0_0RCTLogConvertError(json, @"a locale");
  }
  return nil;
}

// JS Standard for time is milliseconds
ABI32_0_0RCT_CUSTOM_CONVERTER(NSTimeInterval, NSTimeInterval, [self double:json] / 1000.0)

// JS standard for time zones is minutes.
ABI32_0_0RCT_CUSTOM_CONVERTER(NSTimeZone *, NSTimeZone, [NSTimeZone timeZoneForSecondsFromGMT:[self double:json] * 60.0])

NSNumber *ABI32_0_0RCTConvertEnumValue(const char *typeName, NSDictionary *mapping, NSNumber *defaultValue, id json)
{
  if (!json) {
    return defaultValue;
  }
  if ([json isKindOfClass:[NSNumber class]]) {
    NSArray *allValues = mapping.allValues;
    if ([allValues containsObject:json] || [json isEqual:defaultValue]) {
      return json;
    }
    ABI32_0_0RCTLogError(@"Invalid %s '%@'. should be one of: %@", typeName, json, allValues);
    return defaultValue;
  }
  if (ABI32_0_0RCT_DEBUG && ![json isKindOfClass:[NSString class]]) {
    ABI32_0_0RCTLogError(@"Expected NSNumber or NSString for %s, received %@: %@",
                typeName, [json classForCoder], json);
  }
  id value = mapping[json];
  if (ABI32_0_0RCT_DEBUG && !value && [json description].length > 0) {
    ABI32_0_0RCTLogError(@"Invalid %s '%@'. should be one of: %@", typeName, json, [[mapping allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)]);
  }
  return value ?: defaultValue;
}

NSNumber *ABI32_0_0RCTConvertMultiEnumValue(const char *typeName, NSDictionary *mapping, NSNumber *defaultValue, id json)
{
  if ([json isKindOfClass:[NSArray class]]) {
    if ([json count] == 0) {
      return defaultValue;
    }
    long long result = 0;
    for (id arrayElement in json) {
      NSNumber *value = ABI32_0_0RCTConvertEnumValue(typeName, mapping, defaultValue, arrayElement);
      result |= value.longLongValue;
    }
    return @(result);
  }
  return ABI32_0_0RCTConvertEnumValue(typeName, mapping, defaultValue, json);
}

ABI32_0_0RCT_ENUM_CONVERTER(NSLineBreakMode, (@{
  @"clip": @(NSLineBreakByClipping),
  @"head": @(NSLineBreakByTruncatingHead),
  @"tail": @(NSLineBreakByTruncatingTail),
  @"middle": @(NSLineBreakByTruncatingMiddle),
  @"wordWrapping": @(NSLineBreakByWordWrapping),
}), NSLineBreakByTruncatingTail, integerValue)

ABI32_0_0RCT_ENUM_CONVERTER(NSTextAlignment, (@{
  @"auto": @(NSTextAlignmentNatural),
  @"left": @(NSTextAlignmentLeft),
  @"center": @(NSTextAlignmentCenter),
  @"right": @(NSTextAlignmentRight),
  @"justify": @(NSTextAlignmentJustified),
}), NSTextAlignmentNatural, integerValue)

ABI32_0_0RCT_ENUM_CONVERTER(NSUnderlineStyle, (@{
  @"solid": @(NSUnderlineStyleSingle),
  @"double": @(NSUnderlineStyleDouble),
  @"dotted": @(NSUnderlinePatternDot | NSUnderlineStyleSingle),
  @"dashed": @(NSUnderlinePatternDash | NSUnderlineStyleSingle),
}), NSUnderlineStyleSingle, integerValue)

ABI32_0_0RCT_ENUM_CONVERTER(ABI32_0_0RCTBorderStyle, (@{
  @"solid": @(ABI32_0_0RCTBorderStyleSolid),
  @"dotted": @(ABI32_0_0RCTBorderStyleDotted),
  @"dashed": @(ABI32_0_0RCTBorderStyleDashed),
}), ABI32_0_0RCTBorderStyleSolid, integerValue)

ABI32_0_0RCT_ENUM_CONVERTER(ABI32_0_0RCTTextDecorationLineType, (@{
  @"none": @(ABI32_0_0RCTTextDecorationLineTypeNone),
  @"underline": @(ABI32_0_0RCTTextDecorationLineTypeUnderline),
  @"line-through": @(ABI32_0_0RCTTextDecorationLineTypeStrikethrough),
  @"underline line-through": @(ABI32_0_0RCTTextDecorationLineTypeUnderlineStrikethrough),
}), ABI32_0_0RCTTextDecorationLineTypeNone, integerValue)

ABI32_0_0RCT_ENUM_CONVERTER(NSWritingDirection, (@{
  @"auto": @(NSWritingDirectionNatural),
  @"ltr": @(NSWritingDirectionLeftToRight),
  @"rtl": @(NSWritingDirectionRightToLeft),
}), NSWritingDirectionNatural, integerValue)

ABI32_0_0RCT_ENUM_CONVERTER(UITextAutocapitalizationType, (@{
  @"none": @(UITextAutocapitalizationTypeNone),
  @"words": @(UITextAutocapitalizationTypeWords),
  @"sentences": @(UITextAutocapitalizationTypeSentences),
  @"characters": @(UITextAutocapitalizationTypeAllCharacters)
}), UITextAutocapitalizationTypeSentences, integerValue)

ABI32_0_0RCT_ENUM_CONVERTER(UITextFieldViewMode, (@{
  @"never": @(UITextFieldViewModeNever),
  @"while-editing": @(UITextFieldViewModeWhileEditing),
  @"unless-editing": @(UITextFieldViewModeUnlessEditing),
  @"always": @(UITextFieldViewModeAlways),
}), UITextFieldViewModeNever, integerValue)

ABI32_0_0RCT_ENUM_CONVERTER(UIKeyboardType, (@{
  @"default": @(UIKeyboardTypeDefault),
  @"ascii-capable": @(UIKeyboardTypeASCIICapable),
  @"numbers-and-punctuation": @(UIKeyboardTypeNumbersAndPunctuation),
  @"url": @(UIKeyboardTypeURL),
  @"number-pad": @(UIKeyboardTypeNumberPad),
  @"phone-pad": @(UIKeyboardTypePhonePad),
  @"name-phone-pad": @(UIKeyboardTypeNamePhonePad),
  @"email-address": @(UIKeyboardTypeEmailAddress),
  @"decimal-pad": @(UIKeyboardTypeDecimalPad),
  @"twitter": @(UIKeyboardTypeTwitter),
  @"web-search": @(UIKeyboardTypeWebSearch),
  // Added for Android compatibility
  @"numeric": @(UIKeyboardTypeDecimalPad),
}), UIKeyboardTypeDefault, integerValue)

#if !TARGET_OS_TV
ABI32_0_0RCT_MULTI_ENUM_CONVERTER(UIDataDetectorTypes, (@{
  @"phoneNumber": @(UIDataDetectorTypePhoneNumber),
  @"link": @(UIDataDetectorTypeLink),
  @"address": @(UIDataDetectorTypeAddress),
  @"calendarEvent": @(UIDataDetectorTypeCalendarEvent),
  @"none": @(UIDataDetectorTypeNone),
  @"all": @(UIDataDetectorTypeAll),
}), UIDataDetectorTypePhoneNumber, unsignedLongLongValue)

#if WEBKIT_IOS_10_APIS_AVAILABLE
ABI32_0_0RCT_MULTI_ENUM_CONVERTER(WKDataDetectorTypes, (@{
 @"phoneNumber": @(WKDataDetectorTypePhoneNumber),
 @"link": @(WKDataDetectorTypeLink),
 @"address": @(WKDataDetectorTypeAddress),
 @"calendarEvent": @(WKDataDetectorTypeCalendarEvent),
 @"trackingNumber": @(WKDataDetectorTypeTrackingNumber),
 @"flightNumber": @(WKDataDetectorTypeFlightNumber),
 @"lookupSuggestion": @(WKDataDetectorTypeLookupSuggestion),
 @"none": @(WKDataDetectorTypeNone),
 @"all": @(WKDataDetectorTypeAll),
 }), WKDataDetectorTypePhoneNumber, unsignedLongLongValue)
 #endif // WEBKIT_IOS_10_APIS_AVAILABLE

 #endif // !TARGET_OS_TV

ABI32_0_0RCT_ENUM_CONVERTER(UIKeyboardAppearance, (@{
  @"default": @(UIKeyboardAppearanceDefault),
  @"light": @(UIKeyboardAppearanceLight),
  @"dark": @(UIKeyboardAppearanceDark),
}), UIKeyboardAppearanceDefault, integerValue)

ABI32_0_0RCT_ENUM_CONVERTER(UIReturnKeyType, (@{
  @"default": @(UIReturnKeyDefault),
  @"go": @(UIReturnKeyGo),
  @"google": @(UIReturnKeyGoogle),
  @"join": @(UIReturnKeyJoin),
  @"next": @(UIReturnKeyNext),
  @"route": @(UIReturnKeyRoute),
  @"search": @(UIReturnKeySearch),
  @"send": @(UIReturnKeySend),
  @"yahoo": @(UIReturnKeyYahoo),
  @"done": @(UIReturnKeyDone),
  @"emergency-call": @(UIReturnKeyEmergencyCall),
}), UIReturnKeyDefault, integerValue)

ABI32_0_0RCT_ENUM_CONVERTER(UIViewContentMode, (@{
  @"scale-to-fill": @(UIViewContentModeScaleToFill),
  @"scale-aspect-fit": @(UIViewContentModeScaleAspectFit),
  @"scale-aspect-fill": @(UIViewContentModeScaleAspectFill),
  @"redraw": @(UIViewContentModeRedraw),
  @"center": @(UIViewContentModeCenter),
  @"top": @(UIViewContentModeTop),
  @"bottom": @(UIViewContentModeBottom),
  @"left": @(UIViewContentModeLeft),
  @"right": @(UIViewContentModeRight),
  @"top-left": @(UIViewContentModeTopLeft),
  @"top-right": @(UIViewContentModeTopRight),
  @"bottom-left": @(UIViewContentModeBottomLeft),
  @"bottom-right": @(UIViewContentModeBottomRight),
  // Cross-platform values
  @"cover": @(UIViewContentModeScaleAspectFill),
  @"contain": @(UIViewContentModeScaleAspectFit),
  @"stretch": @(UIViewContentModeScaleToFill),
}), UIViewContentModeScaleAspectFill, integerValue)

#if !TARGET_OS_TV
ABI32_0_0RCT_ENUM_CONVERTER(UIBarStyle, (@{
  @"default": @(UIBarStyleDefault),
  @"black": @(UIBarStyleBlack),
}), UIBarStyleDefault, integerValue)
#endif

static void convertCGStruct(const char *type, NSArray *fields, CGFloat *result, id json)
{
  NSUInteger count = fields.count;
  if ([json isKindOfClass:[NSArray class]]) {
    if (ABI32_0_0RCT_DEBUG && [json count] != count) {
      ABI32_0_0RCTLogError(@"Expected array with count %llu, but count is %llu: %@", (unsigned long long)count, (unsigned long long)[json count], json);
    } else {
      for (NSUInteger i = 0; i < count; i++) {
        result[i] = [ABI32_0_0RCTConvert CGFloat:ABI32_0_0RCTNilIfNull(json[i])];
      }
    }
  } else if ([json isKindOfClass:[NSDictionary class]]) {
    for (NSUInteger i = 0; i < count; i++) {
      result[i] = [ABI32_0_0RCTConvert CGFloat:ABI32_0_0RCTNilIfNull(json[fields[i]])];
    }
  } else if (json) {
    ABI32_0_0RCTLogConvertError(json, @(type));
  }
}

/**
 * This macro is used for creating converter functions for structs that consist
 * of a number of CGFloat properties, such as CGPoint, CGRect, etc.
 */
#define ABI32_0_0RCT_CGSTRUCT_CONVERTER(type, values)                \
+ (type)type:(id)json                                       \
{                                                           \
  static NSArray *fields;                                   \
  static dispatch_once_t onceToken;                         \
  dispatch_once(&onceToken, ^{                              \
    fields = values;                                        \
  });                                                       \
  type result;                                              \
  convertCGStruct(#type, fields, (CGFloat *)&result, json); \
  return result;                                            \
}

ABI32_0_0RCT_CUSTOM_CONVERTER(CGFloat, CGFloat, [self double:json])

ABI32_0_0RCT_CGSTRUCT_CONVERTER(CGPoint, (@[@"x", @"y"]))
ABI32_0_0RCT_CGSTRUCT_CONVERTER(CGSize, (@[@"width", @"height"]))
ABI32_0_0RCT_CGSTRUCT_CONVERTER(CGRect, (@[@"x", @"y", @"width", @"height"]))
ABI32_0_0RCT_CGSTRUCT_CONVERTER(UIEdgeInsets, (@[@"top", @"left", @"bottom", @"right"]))

ABI32_0_0RCT_ENUM_CONVERTER(CGLineJoin, (@{
  @"miter": @(kCGLineJoinMiter),
  @"round": @(kCGLineJoinRound),
  @"bevel": @(kCGLineJoinBevel),
}), kCGLineJoinMiter, intValue)

ABI32_0_0RCT_ENUM_CONVERTER(CGLineCap, (@{
  @"butt": @(kCGLineCapButt),
  @"round": @(kCGLineCapRound),
  @"square": @(kCGLineCapSquare),
}), kCGLineCapButt, intValue)

ABI32_0_0RCT_CGSTRUCT_CONVERTER(CGAffineTransform, (@[
  @"a", @"b", @"c", @"d", @"tx", @"ty"
]))

+ (UIColor *)UIColor:(id)json
{
  if (!json) {
    return nil;
  }
  if ([json isKindOfClass:[NSArray class]]) {
    NSArray *components = [self NSNumberArray:json];
    CGFloat alpha = components.count > 3 ? [self CGFloat:components[3]] : 1.0;
    return [UIColor colorWithRed:[self CGFloat:components[0]]
                           green:[self CGFloat:components[1]]
                            blue:[self CGFloat:components[2]]
                           alpha:alpha];
  } else if ([json isKindOfClass:[NSNumber class]]) {
    NSUInteger argb = [self NSUInteger:json];
    CGFloat a = ((argb >> 24) & 0xFF) / 255.0;
    CGFloat r = ((argb >> 16) & 0xFF) / 255.0;
    CGFloat g = ((argb >> 8) & 0xFF) / 255.0;
    CGFloat b = (argb & 0xFF) / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
  } else {
    ABI32_0_0RCTLogConvertError(json, @"a UIColor. Did you forget to call processColor() on the JS side?");
    return nil;
  }
}

+ (CGColorRef)CGColor:(id)json
{
  return [self UIColor:json].CGColor;
}

+ (ABI32_0_0YGValue)ABI32_0_0YGValue:(id)json
{
  if (!json) {
    return ABI32_0_0YGValueUndefined;
  } else if ([json isKindOfClass:[NSNumber class]]) {
    return (ABI32_0_0YGValue) { [json floatValue], ABI32_0_0YGUnitPoint };
  } else if ([json isKindOfClass:[NSString class]]) {
    NSString *s = (NSString *) json;
    if ([s isEqualToString:@"auto"]) {
      return (ABI32_0_0YGValue) { ABI32_0_0YGUndefined, ABI32_0_0YGUnitAuto };
    } else if ([s hasSuffix:@"%"]) {
      return (ABI32_0_0YGValue) { [[s substringToIndex:s.length] floatValue], ABI32_0_0YGUnitPercent };
    } else {
      ABI32_0_0RCTLogConvertError(json, @"a ABI32_0_0YGValue. Did you forget the % or pt suffix?");
    }
  } else {
    ABI32_0_0RCTLogConvertError(json, @"a ABI32_0_0YGValue.");
  }
  return ABI32_0_0YGValueUndefined;
}

NSArray *ABI32_0_0RCTConvertArrayValue(SEL type, id json)
{
  __block BOOL copy = NO;
  __block NSArray *values = json = [ABI32_0_0RCTConvert NSArray:json];
  [json enumerateObjectsUsingBlock:^(id jsonValue, NSUInteger idx, __unused BOOL *stop) {
    id value = ((id(*)(Class, SEL, id))objc_msgSend)([ABI32_0_0RCTConvert class], type, jsonValue);
    if (copy) {
      if (value) {
        [(NSMutableArray *)values addObject:value];
      }
    } else if (value != jsonValue) {
      // Converted value is different, so we'll need to copy the array
      values = [[NSMutableArray alloc] initWithCapacity:values.count];
      for (NSUInteger i = 0; i < idx; i++) {
        [(NSMutableArray *)values addObject:json[i]];
      }
      if (value) {
        [(NSMutableArray *)values addObject:value];
      }
      copy = YES;
    }
  }];
  return values;
}

ABI32_0_0RCT_ARRAY_CONVERTER(NSURL)
ABI32_0_0RCT_ARRAY_CONVERTER(ABI32_0_0RCTFileURL)
ABI32_0_0RCT_ARRAY_CONVERTER(UIColor)

/**
 * This macro is used for creating converter functions for directly
 * representable json array values that require no conversion.
 */
#if ABI32_0_0RCT_DEBUG
#define ABI32_0_0RCT_JSON_ARRAY_CONVERTER_NAMED(type, name) ABI32_0_0RCT_ARRAY_CONVERTER_NAMED(type, name)
#else
#define ABI32_0_0RCT_JSON_ARRAY_CONVERTER_NAMED(type, name) + (NSArray *)name##Array:(id)json { return json; }
#endif
#define ABI32_0_0RCT_JSON_ARRAY_CONVERTER(type) ABI32_0_0RCT_JSON_ARRAY_CONVERTER_NAMED(type, type)

ABI32_0_0RCT_JSON_ARRAY_CONVERTER(NSArray)
ABI32_0_0RCT_JSON_ARRAY_CONVERTER(NSString)
ABI32_0_0RCT_JSON_ARRAY_CONVERTER_NAMED(NSArray<NSString *>, NSStringArray)
ABI32_0_0RCT_JSON_ARRAY_CONVERTER(NSDictionary)
ABI32_0_0RCT_JSON_ARRAY_CONVERTER(NSNumber)

// Can't use ABI32_0_0RCT_ARRAY_CONVERTER due to bridged cast
+ (NSArray *)CGColorArray:(id)json
{
  NSMutableArray *colors = [NSMutableArray new];
  for (id value in [self NSArray:json]) {
    [colors addObject:(__bridge id)[self CGColor:value]];
  }
  return colors;
}

static id ABI32_0_0RCTConvertPropertyListValue(id json)
{
  if (!json || json == (id)kCFNull) {
    return nil;
  }

  if ([json isKindOfClass:[NSDictionary class]]) {
    __block BOOL copy = NO;
    NSMutableDictionary *values = [[NSMutableDictionary alloc] initWithCapacity:[json count]];
    [json enumerateKeysAndObjectsUsingBlock:^(NSString *key, id jsonValue, __unused BOOL *stop) {
      id value = ABI32_0_0RCTConvertPropertyListValue(jsonValue);
      if (value) {
        values[key] = value;
      }
      copy |= value != jsonValue;
    }];
    return copy ? values : json;
  }

  if ([json isKindOfClass:[NSArray class]]) {
    __block BOOL copy = NO;
    __block NSArray *values = json;
    [json enumerateObjectsUsingBlock:^(id jsonValue, NSUInteger idx, __unused BOOL *stop) {
      id value = ABI32_0_0RCTConvertPropertyListValue(jsonValue);
      if (copy) {
        if (value) {
          [(NSMutableArray *)values addObject:value];
        }
      } else if (value != jsonValue) {
        // Converted value is different, so we'll need to copy the array
        values = [[NSMutableArray alloc] initWithCapacity:values.count];
        for (NSUInteger i = 0; i < idx; i++) {
          [(NSMutableArray *)values addObject:json[i]];
        }
        if (value) {
          [(NSMutableArray *)values addObject:value];
        }
        copy = YES;
      }
    }];
    return values;
  }

  // All other JSON types are supported by property lists
  return json;
}

+ (NSPropertyList)NSPropertyList:(id)json
{
  return ABI32_0_0RCTConvertPropertyListValue(json);
}

ABI32_0_0RCT_ENUM_CONVERTER(css_backface_visibility_t, (@{
  @"hidden": @NO,
  @"visible": @YES
}), YES, boolValue)

ABI32_0_0RCT_ENUM_CONVERTER(ABI32_0_0YGOverflow, (@{
  @"hidden": @(ABI32_0_0YGOverflowHidden),
  @"visible": @(ABI32_0_0YGOverflowVisible),
  @"scroll": @(ABI32_0_0YGOverflowScroll),
}), ABI32_0_0YGOverflowVisible, intValue)

ABI32_0_0RCT_ENUM_CONVERTER(ABI32_0_0YGDisplay, (@{
  @"flex": @(ABI32_0_0YGDisplayFlex),
  @"none": @(ABI32_0_0YGDisplayNone),
}), ABI32_0_0YGDisplayFlex, intValue)

ABI32_0_0RCT_ENUM_CONVERTER(ABI32_0_0YGFlexDirection, (@{
  @"row": @(ABI32_0_0YGFlexDirectionRow),
  @"row-reverse": @(ABI32_0_0YGFlexDirectionRowReverse),
  @"column": @(ABI32_0_0YGFlexDirectionColumn),
  @"column-reverse": @(ABI32_0_0YGFlexDirectionColumnReverse)
}), ABI32_0_0YGFlexDirectionColumn, intValue)

ABI32_0_0RCT_ENUM_CONVERTER(ABI32_0_0YGJustify, (@{
  @"flex-start": @(ABI32_0_0YGJustifyFlexStart),
  @"flex-end": @(ABI32_0_0YGJustifyFlexEnd),
  @"center": @(ABI32_0_0YGJustifyCenter),
  @"space-between": @(ABI32_0_0YGJustifySpaceBetween),
  @"space-around": @(ABI32_0_0YGJustifySpaceAround),
  @"space-evenly": @(ABI32_0_0YGJustifySpaceEvenly)
}), ABI32_0_0YGJustifyFlexStart, intValue)

ABI32_0_0RCT_ENUM_CONVERTER(ABI32_0_0YGAlign, (@{
  @"flex-start": @(ABI32_0_0YGAlignFlexStart),
  @"flex-end": @(ABI32_0_0YGAlignFlexEnd),
  @"center": @(ABI32_0_0YGAlignCenter),
  @"auto": @(ABI32_0_0YGAlignAuto),
  @"stretch": @(ABI32_0_0YGAlignStretch),
  @"baseline": @(ABI32_0_0YGAlignBaseline),
  @"space-between": @(ABI32_0_0YGAlignSpaceBetween),
  @"space-around": @(ABI32_0_0YGAlignSpaceAround)
}), ABI32_0_0YGAlignFlexStart, intValue)

ABI32_0_0RCT_ENUM_CONVERTER(ABI32_0_0YGDirection, (@{
  @"inherit": @(ABI32_0_0YGDirectionInherit),
  @"ltr": @(ABI32_0_0YGDirectionLTR),
  @"rtl": @(ABI32_0_0YGDirectionRTL),
}), ABI32_0_0YGDirectionInherit, intValue)

ABI32_0_0RCT_ENUM_CONVERTER(ABI32_0_0YGPositionType, (@{
  @"absolute": @(ABI32_0_0YGPositionTypeAbsolute),
  @"relative": @(ABI32_0_0YGPositionTypeRelative)
}), ABI32_0_0YGPositionTypeRelative, intValue)

ABI32_0_0RCT_ENUM_CONVERTER(ABI32_0_0YGWrap, (@{
  @"wrap": @(ABI32_0_0YGWrapWrap),
  @"nowrap": @(ABI32_0_0YGWrapNoWrap),
  @"wrap-reverse": @(ABI32_0_0YGWrapWrapReverse)
}), ABI32_0_0YGWrapNoWrap, intValue)

ABI32_0_0RCT_ENUM_CONVERTER(ABI32_0_0RCTPointerEvents, (@{
  @"none": @(ABI32_0_0RCTPointerEventsNone),
  @"box-only": @(ABI32_0_0RCTPointerEventsBoxOnly),
  @"box-none": @(ABI32_0_0RCTPointerEventsBoxNone),
  @"auto": @(ABI32_0_0RCTPointerEventsUnspecified)
}), ABI32_0_0RCTPointerEventsUnspecified, integerValue)

ABI32_0_0RCT_ENUM_CONVERTER(ABI32_0_0RCTAnimationType, (@{
  @"spring": @(ABI32_0_0RCTAnimationTypeSpring),
  @"linear": @(ABI32_0_0RCTAnimationTypeLinear),
  @"easeIn": @(ABI32_0_0RCTAnimationTypeEaseIn),
  @"easeOut": @(ABI32_0_0RCTAnimationTypeEaseOut),
  @"easeInEaseOut": @(ABI32_0_0RCTAnimationTypeEaseInEaseOut),
  @"keyboard": @(ABI32_0_0RCTAnimationTypeKeyboard),
}), ABI32_0_0RCTAnimationTypeEaseInEaseOut, integerValue)

@end

@interface ABI32_0_0RCTImageSource (Packager)

@property (nonatomic, assign) BOOL packagerAsset;

@end

@implementation ABI32_0_0RCTConvert (Deprecated)

/* This method is only used when loading images synchronously, e.g. for tabbar icons */
+ (UIImage *)UIImage:(id)json
{
  if (!json) {
    return nil;
  }

  ABI32_0_0RCTImageSource *imageSource = [self ABI32_0_0RCTImageSource:json];
  if (!imageSource) {
    return nil;
  }

  __block UIImage *image;
  if (!ABI32_0_0RCTIsMainQueue()) {
    // It seems that none of the UIImage loading methods can be guaranteed
    // thread safe, so we'll pick the lesser of two evils here and block rather
    // than run the risk of crashing
    ABI32_0_0RCTLogWarn(@"Calling [ABI32_0_0RCTConvert UIImage:] on a background thread is not recommended");
    ABI32_0_0RCTUnsafeExecuteOnMainQueueSync(^{
      image = [self UIImage:json];
    });
    return image;
  }

  NSURL *URL = imageSource.request.URL;
  NSString *scheme = URL.scheme.lowercaseString;
  if ([scheme isEqualToString:@"file"]) {
    image = ABI32_0_0RCTImageFromLocalAssetURL(URL);
    if (!image) {
      ABI32_0_0RCTLogConvertError(json, @"an image. File not found.");
    }
  } else if ([scheme isEqualToString:@"data"]) {
    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:URL]];
  } else if ([scheme isEqualToString:@"http"] && imageSource.packagerAsset) {
    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:URL]];
  } else {
    ABI32_0_0RCTLogConvertError(json, @"an image. Only local files or data URIs are supported.");
    return nil;
  }

  CGFloat scale = imageSource.scale;
  if (!scale && imageSource.size.width) {
    // If no scale provided, set scale to image width / source width
    scale = CGImageGetWidth(image.CGImage) / imageSource.size.width;
  }

  if (scale) {
    image = [UIImage imageWithCGImage:image.CGImage
                                scale:scale
                          orientation:image.imageOrientation];
  }

  if (!CGSizeEqualToSize(imageSource.size, CGSizeZero) &&
      !CGSizeEqualToSize(imageSource.size, image.size)) {
    ABI32_0_0RCTLogError(@"Image source %@ size %@ does not match loaded image size %@.",
                URL.path.lastPathComponent,
                NSStringFromCGSize(imageSource.size),
                NSStringFromCGSize(image.size));
  }

  return image;
}

+ (CGImageRef)CGImage:(id)json
{
  return [self UIImage:json].CGImage;
}

@end
