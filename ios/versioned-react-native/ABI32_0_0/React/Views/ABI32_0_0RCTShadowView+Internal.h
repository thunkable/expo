/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <ReactABI32_0_0/ABI32_0_0RCTShadowView.h>

@class ABI32_0_0RCTRootShadowView;

@interface ABI32_0_0RCTShadowView (Internal)

@property (nonatomic, weak, readwrite) ABI32_0_0RCTRootShadowView *rootView;

@end
