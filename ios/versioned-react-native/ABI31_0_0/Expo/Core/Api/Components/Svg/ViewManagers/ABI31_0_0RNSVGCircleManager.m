/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI31_0_0RNSVGCircleManager.h"

#import "ABI31_0_0RNSVGCircle.h"
#import "ABI31_0_0RCTConvert+RNSVG.h"

@implementation ABI31_0_0RNSVGCircleManager

ABI31_0_0RCT_EXPORT_MODULE()

- (ABI31_0_0RNSVGRenderable *)node
{
    return [ABI31_0_0RNSVGCircle new];
}

ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(cx, ABI31_0_0RNSVGLength*)
ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(cy, ABI31_0_0RNSVGLength*)
ABI31_0_0RCT_EXPORT_VIEW_PROPERTY(r, ABI31_0_0RNSVGLength*)

@end
