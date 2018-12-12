//
//  ABI28_0_0EXHaptic.m
//  Exponent
//
//  Created by Evan Bacon on 2/23/18.
//  Copyright © 2018 650 Industries. All rights reserved.
//

#import "ABI28_0_0EXHaptic.h"

#if !TARGET_OS_TV
@implementation ABI28_0_0RCTConvert (UINotificationFeedback)

ABI28_0_0RCT_ENUM_CONVERTER(UINotificationFeedbackType, (@{
                                                  @"success": @(UINotificationFeedbackTypeSuccess),
                                                  @"warning": @(UINotificationFeedbackTypeWarning),
                                                  @"error": @(UINotificationFeedbackTypeError),
                                                  }), UINotificationFeedbackTypeSuccess, integerValue);

@end

@implementation ABI28_0_0RCTConvert (UIImpactFeedback)
ABI28_0_0RCT_ENUM_CONVERTER(UIImpactFeedbackStyle, (@{
                                             @"light": @(UIImpactFeedbackStyleLight),
                                             @"medium": @(UIImpactFeedbackStyleMedium),
                                             @"heavy": @(UIImpactFeedbackStyleHeavy),
                                             }), UIImpactFeedbackStyleMedium, integerValue);

@end
#endif

@implementation ABI28_0_0EXHaptic

ABI28_0_0RCT_EXPORT_MODULE(ExponentHaptic);

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

ABI28_0_0RCT_EXPORT_METHOD(notification:(UINotificationFeedbackType)type)
{
  UINotificationFeedbackGenerator *feedback = [UINotificationFeedbackGenerator new];
  [feedback prepare];
  [feedback notificationOccurred:type];
  feedback = nil;
}

ABI28_0_0RCT_EXPORT_METHOD(impact:(UIImpactFeedbackStyle)style)
{
  UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:style];
  [feedback prepare];
  [feedback impactOccurred];
  feedback = nil;
}

ABI28_0_0RCT_EXPORT_METHOD(selection)
{
  UISelectionFeedbackGenerator *feedback = [UISelectionFeedbackGenerator new];
  [feedback prepare];
  [feedback selectionChanged];
  feedback = nil;
}

@end

