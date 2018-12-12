/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>
#import "ABI31_0_0RNSVGPainter.h"
#import "ABI31_0_0RNSVGContainer.h"
#import "ABI31_0_0RNSVGVBMOS.h"

@class ABI31_0_0RNSVGNode;

@interface ABI31_0_0RNSVGSvgView : UIView <ABI31_0_0RNSVGContainer>

@property (nonatomic, strong) NSString *bbWidth;
@property (nonatomic, strong) NSString *bbHeight;
@property (nonatomic, assign) CGFloat minX;
@property (nonatomic, assign) CGFloat minY;
@property (nonatomic, assign) CGFloat vbWidth;
@property (nonatomic, assign) CGFloat vbHeight;
@property (nonatomic, strong) NSString *align;
@property (nonatomic, assign) ABI31_0_0RNSVGVBMOS meetOrSlice;
@property (nonatomic, assign) BOOL responsible;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) CGRect boundingBox;
@property (nonatomic, assign) CGAffineTransform initialCTM;
@property (nonatomic, assign) CGAffineTransform invInitialCTM;



/**
 * define <ClipPath></ClipPath> content as clipPath template.
 */
- (void)defineClipPath:(__kindof ABI31_0_0RNSVGNode *)clipPath clipPathName:(NSString *)clipPathName;

- (ABI31_0_0RNSVGNode *)getDefinedClipPath:(NSString *)clipPathName;

- (void)defineTemplate:(__kindof ABI31_0_0RNSVGNode *)template templateName:(NSString *)templateName;

- (ABI31_0_0RNSVGNode *)getDefinedTemplate:(NSString *)templateName;

- (void)definePainter:(ABI31_0_0RNSVGPainter *)painter painterName:(NSString *)painterName;

- (ABI31_0_0RNSVGPainter *)getDefinedPainter:(NSString *)painterName;

- (void)defineMask:(ABI31_0_0RNSVGNode *)mask maskName:(NSString *)maskName;

- (ABI31_0_0RNSVGNode *)getDefinedMask:(NSString *)maskName;

- (NSString *)getDataURL;

- (CGRect)getContextBounds;

- (void)drawRect:(CGRect)rect;

- (void)drawToContext:(CGContextRef)context withRect:(CGRect)rect;

- (CGAffineTransform)getViewBoxTransform;

@end
