/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import <ReactABI31_0_0/ABI31_0_0RCTBridge.h>
#import <ReactABI31_0_0/ABI31_0_0RCTBridgeModule.h>

extern NSString *const ABI31_0_0RCTAccessibilityManagerDidUpdateMultiplierNotification; // posted when multiplier is changed

@interface ABI31_0_0RCTAccessibilityManager : NSObject <ABI31_0_0RCTBridgeModule>

@property (nonatomic, readonly) CGFloat multiplier;

/// map from UIKit categories to multipliers
@property (nonatomic, copy) NSDictionary<NSString *, NSNumber *> *multipliers;

@property (nonatomic, assign) BOOL isVoiceOverEnabled;

@end

@interface ABI31_0_0RCTBridge (ABI31_0_0RCTAccessibilityManager)

@property (nonatomic, readonly) ABI31_0_0RCTAccessibilityManager *accessibilityManager;

@end
