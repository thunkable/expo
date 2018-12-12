//
//  ABI30_0_0EXAnimationViewManager.m
//  LottieReactABI30_0_0Native
//
//  Created by Leland Richardson on 12/12/16.
//  Copyright © 2016 Airbnb. All rights reserved.
//

#import "ABI30_0_0EXAnimationViewManager.h"

#import "ABI30_0_0EXContainerView.h"

// import ABI30_0_0RCTBridge.h
#if __has_include(<ReactABI30_0_0/ABI30_0_0RCTBridge.h>)
#import <ReactABI30_0_0/ABI30_0_0RCTBridge.h>
#elif __has_include("ABI30_0_0RCTBridge.h")
#import "ABI30_0_0RCTBridge.h"
#else
#import "ReactABI30_0_0/ABI30_0_0RCTBridge.h"
#endif

// import ABI30_0_0RCTUIManager.h
#if __has_include(<ReactABI30_0_0/ABI30_0_0RCTUIManager.h>)
#import <ReactABI30_0_0/ABI30_0_0RCTUIManager.h>
#elif __has_include("ABI30_0_0RCTUIManager.h")
#import "ABI30_0_0RCTUIManager.h"
#else
#import "ReactABI30_0_0/ABI30_0_0RCTUIManager.h"
#endif

#import <Lottie/Lottie.h>

@implementation ABI30_0_0EXAnimationViewManager

ABI30_0_0RCT_EXPORT_MODULE(LottieAnimationView)

- (UIView *)view
{
  return [ABI30_0_0EXContainerView new];
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (NSDictionary *)constantsToExport
{
  return @{
    @"VERSION": @1,
  };
}

ABI30_0_0RCT_EXPORT_VIEW_PROPERTY(resizeMode, NSString)
ABI30_0_0RCT_EXPORT_VIEW_PROPERTY(sourceJson, NSString);
ABI30_0_0RCT_EXPORT_VIEW_PROPERTY(sourceName, NSString);
ABI30_0_0RCT_EXPORT_VIEW_PROPERTY(progress, CGFloat);
ABI30_0_0RCT_EXPORT_VIEW_PROPERTY(loop, BOOL);
ABI30_0_0RCT_EXPORT_VIEW_PROPERTY(speed, CGFloat);

ABI30_0_0RCT_EXPORT_METHOD(play:(nonnull NSNumber *)ReactABI30_0_0Tag
                  fromFrame:(nonnull NSNumber *) startFrame
                  toFrame:(nonnull NSNumber *) endFrame)
{
  [self.bridge.uiManager addUIBlock:^(__unused ABI30_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    id view = viewRegistry[ReactABI30_0_0Tag];
    if (![view isKindOfClass:[ABI30_0_0EXContainerView class]]) {
      ABI30_0_0RCTLogError(@"Invalid view returned from registry, expecting LottieContainerView, got: %@", view);
    } else {
      ABI30_0_0EXContainerView *lottieView = (ABI30_0_0EXContainerView *)view;
      if ([startFrame intValue] != -1 && [endFrame intValue] != -1) {
        [lottieView playFromFrame:startFrame toFrame:endFrame];
      } else {
        [lottieView play];
      }
    }
  }];
}

ABI30_0_0RCT_EXPORT_METHOD(reset:(nonnull NSNumber *)ReactABI30_0_0Tag)
{
  [self.bridge.uiManager addUIBlock:^(__unused ABI30_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    id view = viewRegistry[ReactABI30_0_0Tag];
    if (![view isKindOfClass:[ABI30_0_0EXContainerView class]]) {
      ABI30_0_0RCTLogError(@"Invalid view returned from registry, expecting LottieContainerView, got: %@", view);
    } else {
      ABI30_0_0EXContainerView *lottieView = (ABI30_0_0EXContainerView *)view;
      [lottieView reset];
    }
  }];
}

@end
