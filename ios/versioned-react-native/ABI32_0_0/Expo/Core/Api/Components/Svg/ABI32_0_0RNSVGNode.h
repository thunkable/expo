/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <ReactABI32_0_0/UIView+ReactABI32_0_0.h>
#import "ABI32_0_0RNSVGCGFCRule.h"
#import "ABI32_0_0RNSVGSvgView.h"
@class ABI32_0_0RNSVGGroup;

/**
 * ABI32_0_0RNSVG nodes are implemented as base UIViews. They should be implementation for all basic
 ＊interfaces for all non-defination nodes.
 */

@interface ABI32_0_0RNSVGNode : UIView

/*
 N[1/Sqrt[2], 36]
 The inverse of the square root of 2.
 Provide enough digits for the 128-bit IEEE quad (36 significant digits).
 */
extern CGFloat const ABI32_0_0RNSVG_M_SQRT1_2l;
extern CGFloat const ABI32_0_0RNSVG_DEFAULT_FONT_SIZE;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) CGFloat opacity;
@property (nonatomic, assign) ABI32_0_0RNSVGCGFCRule clipRule;
@property (nonatomic, strong) NSString *clipPath;
@property (nonatomic, strong) NSString *mask;
@property (nonatomic, assign) BOOL responsible;
@property (nonatomic, assign) CGAffineTransform matrix;
@property (nonatomic, assign) CGAffineTransform transforms;
@property (nonatomic, assign) CGAffineTransform invmatrix;
@property (nonatomic, assign) CGAffineTransform invTransform;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) CGPathRef path;
@property (nonatomic, assign) CGRect clientRect;
@property (nonatomic, copy) ABI32_0_0RCTDirectEventBlock onLayout;


/**
 * ABI32_0_0RNSVGSvgView which ownes current ABI32_0_0RNSVGNode
 */
@property (nonatomic, readonly, weak) ABI32_0_0RNSVGSvgView *svgView;
@property (nonatomic, readonly, weak) ABI32_0_0RNSVGGroup *textRoot;

- (void)invalidate;

- (ABI32_0_0RNSVGGroup *)getParentTextRoot;

- (void)renderTo:(CGContextRef)context rect:(CGRect)rect;

/**
 * renderTo will take opacity into account and draw renderLayerTo off-screen if there is opacity
 * specified, then composite that onto the context. renderLayerTo always draws at opacity=1.
 * @abstract
 */
- (void)renderLayerTo:(CGContextRef)context rect:(CGRect)rect;

/**
 * get clipPath from cache
 */
- (CGPathRef)getClipPath;

/**
 * get clipPath through context
 */
- (CGPathRef)getClipPath:(CGContextRef)context;

/**
 * clip node by clipPath
 */
- (void)clip:(CGContextRef)context;

/**
 * getPath will return the path inside node as a ClipPath.
 */
- (CGPathRef)getPath:(CGContextRef) context;

- (CGFloat)relativeOnWidthString:(NSString *)length;

- (CGFloat)relativeOnHeightString:(NSString *)length;

- (CGFloat)relativeOnOtherString:(NSString *)length;

- (CGFloat)relativeOn:(ABI32_0_0RNSVGLength *)length relative:(CGFloat)relative;

- (CGFloat)relativeOnWidth:(ABI32_0_0RNSVGLength *)length;

- (CGFloat)relativeOnHeight:(ABI32_0_0RNSVGLength *)length;

- (CGFloat)relativeOnOther:(ABI32_0_0RNSVGLength *)length;

- (CGFloat)getFontSizeFromContext;

- (CGFloat)getContextWidth;

- (CGFloat)getContextHeight;

/**
 * save element`s reference into svg element.
 */
- (void)parseReference;

- (void)beginTransparencyLayer:(CGContextRef)context;

- (void)endTransparencyLayer:(CGContextRef)context;

- (void)traverseSubviews:(BOOL (^)(__kindof UIView *node))block;

- (void)releaseCachedPath;

@end
