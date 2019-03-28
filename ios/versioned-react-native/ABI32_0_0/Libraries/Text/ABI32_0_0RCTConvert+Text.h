/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <ReactABI32_0_0/ABI32_0_0RCTConvert.h>

#import "ABI32_0_0RCTTextTransform.h"

NS_ASSUME_NONNULL_BEGIN

@interface ABI32_0_0RCTConvert (Text)

+ (UITextAutocorrectionType)UITextAutocorrectionType:(nullable id)json;
+ (UITextSpellCheckingType)UITextSpellCheckingType:(nullable id)json;
+ (ABI32_0_0RCTTextTransform)ABI32_0_0RCTTextTransform:(nullable id)json;

@end

NS_ASSUME_NONNULL_END
