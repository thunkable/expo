/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI31_0_0RCTProgressViewManager.h"

#import "ABI31_0_0RCTConvert.h"

@implementation ABI31_0_0RCTConvert (ABI31_0_0RCTProgressViewManager)

ABI31_0_0RCT_ENUM_CONVERTER(UIProgressViewStyle, (@{
  @"default": @(UIProgressViewStyleDefault),
#if !TARGET_OS_TV
  @"bar": @(UIProgressViewStyleBar),
#endif
}), UIProgressViewStyleDefault, integerValue)

@end

@implementation ABI31_0_0RCTProgressViewManager

ABI31_0_0RCT_EXPORT_MODULE()

- (UIView *)view
{
  return [UIProgressView new];
}

ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(progressViewStyle, UIProgressViewStyle)
ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(progress, float)
ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(progressTintColor, UIColor)
ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(trackTintColor, UIColor)
ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(progressImage, UIImage)
ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(trackImage, UIImage)

@end
