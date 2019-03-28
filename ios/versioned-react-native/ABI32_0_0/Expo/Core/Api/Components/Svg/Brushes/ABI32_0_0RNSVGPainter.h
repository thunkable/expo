/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI32_0_0RCTConvert+RNSVG.h"
#import "ABI32_0_0RNSVGBrushType.h"
#import "ABI32_0_0RNSVGUnits.h"
#import "ABI32_0_0RNSVGLength.h"

@class ABI32_0_0RNSVGPattern;

@interface ABI32_0_0RNSVGPainter : NSObject

@property (nonatomic, assign) ABI32_0_0RNSVGPattern* pattern;
@property (nonatomic, assign) CGRect paintBounds;

- (instancetype)initWithPointsArray:(NSArray<ABI32_0_0RNSVGLength *> *)pointsArray NS_DESIGNATED_INITIALIZER;

- (void)paint:(CGContextRef)context bounds:(CGRect)bounds;

- (void)setUnits:(ABI32_0_0RNSVGUnits)unit;

- (void)setContentUnits:(ABI32_0_0RNSVGUnits)unit;

- (void)setUserSpaceBoundingBox:(CGRect)userSpaceBoundingBox;

- (void)setTransform:(CGAffineTransform)transform;

- (void)setLinearGradientColors:(NSArray<NSNumber *> *)colors;

- (void)setRadialGradientColors:(NSArray<NSNumber *> *)colors;

@end
