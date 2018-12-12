/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <ReactABI30_0_0/ABI30_0_0RCTRootView.h>

#import "ABI30_0_0RCTSurfaceHostingView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This is a ABI30_0_0RCTRootView-compatible implementation of ABI30_0_0RCTSurfaceHostingView.
 * Use this class to replace all usages of ABI30_0_0RCTRootView in the app for easier migration
 * to ABI30_0_0RCTSurfaceHostingView.
 *
 * WARNING: In the future, ABI30_0_0RCTRootView will be deprecated in favor of ABI30_0_0RCTSurfaceHostingView.
 */
@interface ABI30_0_0RCTSurfaceHostingProxyRootView : ABI30_0_0RCTSurfaceHostingView

#pragma mark ABI30_0_0RCTRootView compatibility - keep these sync'ed with ABI30_0_0RCTRootView.h

@property (nonatomic, copy, readonly) NSString *moduleName;
@property (nonatomic, strong, readonly) ABI30_0_0RCTBridge *bridge;
@property (nonatomic, copy, readwrite) NSDictionary *appProperties;
@property (nonatomic, assign) ABI30_0_0RCTRootViewSizeFlexibility sizeFlexibility;
@property (nonatomic, weak) id<ABI30_0_0RCTRootViewDelegate> delegate;
@property (nonatomic, weak) UIViewController *ReactABI30_0_0ViewController;
@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, assign) BOOL passThroughTouches;
@property (nonatomic, assign) NSTimeInterval loadingViewFadeDelay;
@property (nonatomic, assign) NSTimeInterval loadingViewFadeDuration;

- (instancetype)initWithBridge:(ABI30_0_0RCTBridge *)bridge
                    moduleName:(NSString *)moduleName
             initialProperties:(NSDictionary *)initialProperties NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithBundleURL:(NSURL *)bundleURL
                       moduleName:(NSString *)moduleName
                initialProperties:(NSDictionary *)initialProperties
                    launchOptions:(NSDictionary *)launchOptions;

- (void)cancelTouches;

@end

NS_ASSUME_NONNULL_END

