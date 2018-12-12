/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI31_0_0RNSVGBrush.h"
#import <ReactABI31_0_0/ABI31_0_0RCTDefines.h>

@implementation ABI31_0_0RNSVGBrush

- (instancetype)initWithArray:(NSArray *)data
{
    return [super init];
}

ABI31_0_0RCT_NOT_IMPLEMENTED(- (instancetype)init)

- (void)paint:(CGContextRef)context opacity:(CGFloat)opacity painter:(ABI31_0_0RNSVGPainter *)painter bounds:(CGRect)bounds
{

}

- (BOOL)applyFillColor:(CGContextRef)context opacity:(CGFloat)opacity
{
    return NO;
}

- (BOOL)applyStrokeColor:(CGContextRef)context opacity:(CGFloat)opacity
{
    return NO;
}

- (void)paint:(CGContextRef)context opacity:(CGFloat)opacity painter:(ABI31_0_0RNSVGPainter *)painter
{
    // abstract
}
@end
