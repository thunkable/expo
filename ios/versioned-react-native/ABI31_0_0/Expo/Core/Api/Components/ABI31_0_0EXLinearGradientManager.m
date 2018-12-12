// Copyright 2015-present 650 Industries. All rights reserved.

#import "ABI31_0_0EXLinearGradientManager.h"
#import "ABI31_0_0EXLinearGradient.h"
#import <ReactABI31_0_0/ABI31_0_0RCTBridge.h>

@implementation ABI31_0_0EXLinearGradientManager

ABI31_0_0RCT_EXPORT_MODULE(ExponentLinearGradientManager);

@synthesize bridge = _bridge;

- (UIView *)view
{
  return [[ABI31_0_0EXLinearGradient alloc] init];
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(colors, NSArray);
ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(startPoint, CGPoint);
ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(endPoint, CGPoint);
ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(locations, NSArray);

@end
