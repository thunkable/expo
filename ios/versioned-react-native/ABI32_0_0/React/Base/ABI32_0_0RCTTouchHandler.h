/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <ReactABI32_0_0/ABI32_0_0RCTFrameUpdate.h>

@class ABI32_0_0RCTBridge;

@interface ABI32_0_0RCTTouchHandler : UIGestureRecognizer

- (instancetype)initWithBridge:(ABI32_0_0RCTBridge *)bridge NS_DESIGNATED_INITIALIZER;

- (void)attachToView:(UIView *)view;
- (void)detachFromView:(UIView *)view;

- (void)cancel;

@end
