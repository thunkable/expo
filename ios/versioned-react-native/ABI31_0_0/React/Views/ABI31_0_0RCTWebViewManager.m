/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI31_0_0RCTWebViewManager.h"

#import "ABI31_0_0RCTBridge.h"
#import "ABI31_0_0RCTUIManager.h"
#import "ABI31_0_0RCTWebView.h"
#import "UIView+ReactABI31_0_0.h"

@interface ABI31_0_0RCTWebViewManager () <ABI31_0_0RCTWebViewDelegate>

@end

@implementation ABI31_0_0RCTWebViewManager
{
  NSConditionLock *_shouldStartLoadLock;
  BOOL _shouldStartLoad;
}

ABI31_0_0RCT_EXPORT_MODULE()

- (UIView *)view
{
  ABI31_0_0RCTWebView *webView = [ABI31_0_0RCTWebView new];
  webView.delegate = self;
  return webView;
}

ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(source, NSDictionary)
ABI31_0_0RCT_REMAP_VIEW_PROPERTY(bounces, _webView.scrollView.bounces, BOOL)
ABI31_0_0RCT_REMAP_VIEW_PROPERTY(scrollEnabled, _webView.scrollView.scrollEnabled, BOOL)
ABI31_0_0RCT_REMAP_VIEW_PROPERTY(decelerationRate, _webView.scrollView.decelerationRate, CGFloat)
ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(scalesPageToFit, BOOL)
ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(messagingEnabled, BOOL)
ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(injectedJavaScript, NSString)
ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(contentInset, UIEdgeInsets)
ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(automaticallyAdjustContentInsets, BOOL)
ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(onLoadingStart, ABI31_0_0RCTDirectEventBlock)
ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(onLoadingFinish, ABI31_0_0RCTDirectEventBlock)
ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(onLoadingError, ABI31_0_0RCTDirectEventBlock)
ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(onMessage, ABI31_0_0RCTDirectEventBlock)
ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(onShouldStartLoadWithRequest, ABI31_0_0RCTDirectEventBlock)
ABI31_0_0RCT_REMAP_VIEW_PROPERTY(allowsInlineMediaPlayback, _webView.allowsInlineMediaPlayback, BOOL)
ABI31_0_0RCT_REMAP_VIEW_PROPERTY(mediaPlaybackRequiresUserAction, _webView.mediaPlaybackRequiresUserAction, BOOL)
ABI31_0_0RCT_REMAP_VIEW_PROPERTY(dataDetectorTypes, _webView.dataDetectorTypes, UIDataDetectorTypes)

ABI31_0_0RCT_EXPORT_METHOD(goBack:(nonnull NSNumber *)ReactABI31_0_0Tag)
{
  [self.bridge.uiManager addUIBlock:^(__unused ABI31_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, ABI31_0_0RCTWebView *> *viewRegistry) {
    ABI31_0_0RCTWebView *view = viewRegistry[ReactABI31_0_0Tag];
    if (![view isKindOfClass:[ABI31_0_0RCTWebView class]]) {
      ABI31_0_0RCTLogError(@"Invalid view returned from registry, expecting ABI31_0_0RCTWebView, got: %@", view);
    } else {
      [view goBack];
    }
  }];
}

ABI31_0_0RCT_EXPORT_METHOD(goForward:(nonnull NSNumber *)ReactABI31_0_0Tag)
{
  [self.bridge.uiManager addUIBlock:^(__unused ABI31_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, ABI31_0_0RCTWebView *> *viewRegistry) {
    ABI31_0_0RCTWebView *view = viewRegistry[ReactABI31_0_0Tag];
    if (![view isKindOfClass:[ABI31_0_0RCTWebView class]]) {
      ABI31_0_0RCTLogError(@"Invalid view returned from registry, expecting ABI31_0_0RCTWebView, got: %@", view);
    } else {
      [view goForward];
    }
  }];
}

ABI31_0_0RCT_EXPORT_METHOD(reload:(nonnull NSNumber *)ReactABI31_0_0Tag)
{
  [self.bridge.uiManager addUIBlock:^(__unused ABI31_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, ABI31_0_0RCTWebView *> *viewRegistry) {
    ABI31_0_0RCTWebView *view = viewRegistry[ReactABI31_0_0Tag];
    if (![view isKindOfClass:[ABI31_0_0RCTWebView class]]) {
      ABI31_0_0RCTLogError(@"Invalid view returned from registry, expecting ABI31_0_0RCTWebView, got: %@", view);
    } else {
      [view reload];
    }
  }];
}

ABI31_0_0RCT_EXPORT_METHOD(stopLoading:(nonnull NSNumber *)ReactABI31_0_0Tag)
{
  [self.bridge.uiManager addUIBlock:^(__unused ABI31_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, ABI31_0_0RCTWebView *> *viewRegistry) {
    ABI31_0_0RCTWebView *view = viewRegistry[ReactABI31_0_0Tag];
    if (![view isKindOfClass:[ABI31_0_0RCTWebView class]]) {
      ABI31_0_0RCTLogError(@"Invalid view returned from registry, expecting ABI31_0_0RCTWebView, got: %@", view);
    } else {
      [view stopLoading];
    }
  }];
}

ABI31_0_0RCT_EXPORT_METHOD(postMessage:(nonnull NSNumber *)ReactABI31_0_0Tag message:(NSString *)message)
{
  [self.bridge.uiManager addUIBlock:^(__unused ABI31_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, ABI31_0_0RCTWebView *> *viewRegistry) {
    ABI31_0_0RCTWebView *view = viewRegistry[ReactABI31_0_0Tag];
    if (![view isKindOfClass:[ABI31_0_0RCTWebView class]]) {
      ABI31_0_0RCTLogError(@"Invalid view returned from registry, expecting ABI31_0_0RCTWebView, got: %@", view);
    } else {
      [view postMessage:message];
    }
  }];
}

ABI31_0_0RCT_EXPORT_METHOD(injectJavaScript:(nonnull NSNumber *)ReactABI31_0_0Tag script:(NSString *)script)
{
  [self.bridge.uiManager addUIBlock:^(__unused ABI31_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, ABI31_0_0RCTWebView *> *viewRegistry) {
    ABI31_0_0RCTWebView *view = viewRegistry[ReactABI31_0_0Tag];
    if (![view isKindOfClass:[ABI31_0_0RCTWebView class]]) {
      ABI31_0_0RCTLogError(@"Invalid view returned from registry, expecting ABI31_0_0RCTWebView, got: %@", view);
    } else {
      [view injectJavaScript:script];
    }
  }];
}

#pragma mark - Exported synchronous methods

- (BOOL)webView:(__unused ABI31_0_0RCTWebView *)webView
shouldStartLoadForRequest:(NSMutableDictionary<NSString *, id> *)request
   withCallback:(ABI31_0_0RCTDirectEventBlock)callback
{
  _shouldStartLoadLock = [[NSConditionLock alloc] initWithCondition:arc4random()];
  _shouldStartLoad = YES;
  request[@"lockIdentifier"] = @(_shouldStartLoadLock.condition);
  callback(request);

  // Block the main thread for a maximum of 250ms until the JS thread returns
  if ([_shouldStartLoadLock lockWhenCondition:0 beforeDate:[NSDate dateWithTimeIntervalSinceNow:.25]]) {
    BOOL returnValue = _shouldStartLoad;
    [_shouldStartLoadLock unlock];
    _shouldStartLoadLock = nil;
    return returnValue;
  } else {
    ABI31_0_0RCTLogWarn(@"Did not receive response to shouldStartLoad in time, defaulting to YES");
    return YES;
  }
}

ABI31_0_0RCT_EXPORT_METHOD(startLoadWithResult:(BOOL)result lockIdentifier:(NSInteger)lockIdentifier)
{
  if ([_shouldStartLoadLock tryLockWhenCondition:lockIdentifier]) {
    _shouldStartLoad = result;
    [_shouldStartLoadLock unlockWithCondition:0];
  } else {
    ABI31_0_0RCTLogWarn(@"startLoadWithResult invoked with invalid lockIdentifier: "
               "got %lld, expected %lld", (long long)lockIdentifier, (long long)_shouldStartLoadLock.condition);
  }
}

@end
