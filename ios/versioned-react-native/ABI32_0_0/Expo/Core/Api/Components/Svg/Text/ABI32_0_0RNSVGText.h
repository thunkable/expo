/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import "ABI32_0_0RNSVGGroup.h"

@interface ABI32_0_0RNSVGText : ABI32_0_0RNSVGGroup

@property (nonatomic, strong) ABI32_0_0RNSVGLength *textLength;
@property (nonatomic, strong) NSString *baselineShift;
@property (nonatomic, strong) NSString *lengthAdjust;
@property (nonatomic, strong) NSString *alignmentBaseline;
@property (nonatomic, strong) NSArray<ABI32_0_0RNSVGLength *> *deltaX;
@property (nonatomic, strong) NSArray<ABI32_0_0RNSVGLength *> *deltaY;
@property (nonatomic, strong) NSArray<ABI32_0_0RNSVGLength *> *positionX;
@property (nonatomic, strong) NSArray<ABI32_0_0RNSVGLength *> *positionY;
@property (nonatomic, strong) NSArray<ABI32_0_0RNSVGLength *> *rotate;

- (CGPathRef)getGroupPath:(CGContextRef)context;
- (CTFontRef)getFontFromContext;

@end
