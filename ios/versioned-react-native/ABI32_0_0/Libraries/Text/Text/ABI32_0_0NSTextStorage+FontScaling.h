/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

@interface NSTextStorage (ABI32_0_0_RCT_FontScaling)

- (void)abi32_0_0_rct_scaleFontSizeToFitSize:(CGSize)size
               minimumFontSize:(CGFloat)minimumFontSize
               maximumFontSize:(CGFloat)maximumFontSize;

- (void)abi32_0_0_rct_scaleFontSizeWithRatio:(CGFloat)ratio
               minimumFontSize:(CGFloat)minimumFontSize
               maximumFontSize:(CGFloat)maximumFontSize;

@end
