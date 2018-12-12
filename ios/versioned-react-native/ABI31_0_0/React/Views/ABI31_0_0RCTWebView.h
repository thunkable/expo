/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <ReactABI31_0_0/ABI31_0_0RCTView.h>

@class ABI31_0_0RCTWebView;

/**
 * Special scheme used to pass messages to the injectedJavaScript
 * code without triggering a page load. Usage:
 *
 *   window.location.href = ABI31_0_0RCTJSNavigationScheme + '://hello'
 */
extern NSString *const ABI31_0_0RCTJSNavigationScheme;

@protocol ABI31_0_0RCTWebViewDelegate <NSObject>

- (BOOL)webView:(ABI31_0_0RCTWebView *)webView
shouldStartLoadForRequest:(NSMutableDictionary<NSString *, id> *)request
   withCallback:(ABI31_0_0RCTDirectEventBlock)callback;

@end

@interface ABI31_0_0RCTWebView : ABI31_0_0RCTView

@property (nonatomic, weak) id<ABI31_0_0RCTWebViewDelegate> delegate;

@property (nonatomic, copy) NSDictionary *source;
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, assign) BOOL automaticallyAdjustContentInsets;
@property (nonatomic, assign) BOOL messagingEnabled;
@property (nonatomic, copy) NSString *injectedJavaScript;
@property (nonatomic, assign) BOOL scalesPageToFit;

- (void)goForward;
- (void)goBack;
- (void)reload;
- (void)stopLoading;
- (void)postMessage:(NSString *)message;
- (void)injectJavaScript:(NSString *)script;

@end
