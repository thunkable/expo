/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI32_0_0RNSVGGroup.h"
#import "ABI32_0_0RNSVGClipPath.h"

@implementation ABI32_0_0RNSVGGroup
{
    ABI32_0_0RNSVGGlyphContext *_glyphContext;
}

- (void)setFont:(NSDictionary*)font
{
    if (font == _font) {
        return;
    }

    [self invalidate];
    _font = font;
}

- (void)renderLayerTo:(CGContextRef)context rect:(CGRect)rect
{
    [self clip:context];
    [self setupGlyphContext:context];
    [self renderGroupTo:context rect:rect];
}

- (void)renderGroupTo:(CGContextRef)context rect:(CGRect)rect
{
    [self pushGlyphContext];

    __block CGRect bounds = CGRectNull;

    [self traverseSubviews:^(UIView *node) {
        if ([node isKindOfClass:[ABI32_0_0RNSVGNode class]]) {
            ABI32_0_0RNSVGNode* svgNode = (ABI32_0_0RNSVGNode*)node;
            if (svgNode.responsible && !self.svgView.responsible) {
                self.svgView.responsible = YES;
            }

            if ([node isKindOfClass:[ABI32_0_0RNSVGRenderable class]]) {
                [(ABI32_0_0RNSVGRenderable*)node mergeProperties:self];
            }

            [svgNode renderTo:context rect:rect];

            CGRect nodeRect = svgNode.clientRect;
            if (!CGRectIsEmpty(nodeRect)) {
                bounds = CGRectUnion(bounds, nodeRect);
            }

            if ([node isKindOfClass:[ABI32_0_0RNSVGRenderable class]]) {
                [(ABI32_0_0RNSVGRenderable*)node resetProperties];
            }
        } else if ([node isKindOfClass:[ABI32_0_0RNSVGSvgView class]]) {
            ABI32_0_0RNSVGSvgView* svgView = (ABI32_0_0RNSVGSvgView*)node;
            CGFloat width = [self relativeOnWidthString:svgView.bbWidth];
            CGFloat height = [self relativeOnHeightString:svgView.bbHeight];
            CGRect rect = CGRectMake(0, 0, width, height);
            CGContextClipToRect(context, rect);
            [svgView drawToContext:context withRect:rect];
        } else {
            [node drawRect:rect];
        }

        return YES;
    }];
    [self setHitArea:[self getPath:context]];
    self.clientRect = bounds;

    CGAffineTransform matrix = self.matrix;
    CGPoint mid = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    CGPoint center = CGPointApplyAffineTransform(mid, matrix);

    self.bounds = bounds;
    if (!isnan(center.x) && !isnan(center.y)) {
        self.center = center;
    }
    self.frame = bounds;

    [self popGlyphContext];
}

- (void)setupGlyphContext:(CGContextRef)context
{
    CGRect clipBounds = CGContextGetClipBoundingBox(context);
    clipBounds = CGRectApplyAffineTransform(clipBounds, self.matrix);
    clipBounds = CGRectApplyAffineTransform(clipBounds, self.transforms);
    CGFloat width = CGRectGetWidth(clipBounds);
    CGFloat height = CGRectGetHeight(clipBounds);

    _glyphContext = [[ABI32_0_0RNSVGGlyphContext alloc] initWithWidth:width
                                                      height:height];
}

- (ABI32_0_0RNSVGGlyphContext *)getGlyphContext
{
    return _glyphContext;
}

- (void)pushGlyphContext
{
    __weak typeof(self) weakSelf = self;
    [[self.textRoot getGlyphContext] pushContext:weakSelf font:self.font];
}

- (void)popGlyphContext
{
    [[self.textRoot getGlyphContext] popContext];
}

- (void)renderPathTo:(CGContextRef)context rect:(CGRect)rect
{
    [super renderLayerTo:context rect:rect];
}

- (CGPathRef)getPath:(CGContextRef)context
{
    CGMutablePathRef __block path = CGPathCreateMutable();
    [self traverseSubviews:^(ABI32_0_0RNSVGNode *node) {
        if ([node isKindOfClass:[ABI32_0_0RNSVGNode class]]) {
            CGAffineTransform transform = CGAffineTransformConcat(node.matrix, node.transforms);
            CGPathAddPath(path, &transform, [node getPath:context]);
        }
        return YES;
    }];

    return (CGPathRef)CFAutorelease(path);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint transformed = CGPointApplyAffineTransform(point, self.invmatrix);
    transformed = CGPointApplyAffineTransform(transformed, self.invTransform);

    if (self.clipPath) {
        ABI32_0_0RNSVGClipPath *clipNode = (ABI32_0_0RNSVGClipPath*)[self.svgView getDefinedClipPath:self.clipPath];
        if ([clipNode isSimpleClipPath]) {
            CGPathRef clipPath = [self getClipPath];
            if (clipPath && !CGPathContainsPoint(clipPath, nil, transformed, clipNode.clipRule == kRNSVGCGFCRuleEvenodd)) {
                return nil;
            }
        } else {
            ABI32_0_0RNSVGRenderable *clipGroup = (ABI32_0_0RNSVGRenderable*)clipNode;
            if (![clipGroup hitTest:transformed withEvent:event]) {
                return nil;
            }
        }
    }

    if (!event) {
        NSPredicate *const anyActive = [NSPredicate predicateWithFormat:@"active == TRUE"];
        NSArray *const filtered = [self.subviews filteredArrayUsingPredicate:anyActive];
        if ([filtered count] != 0) {
            return [filtered.firstObject hitTest:transformed withEvent:event];
        }
    }

    for (ABI32_0_0RNSVGNode *node in [self.subviews reverseObjectEnumerator]) {
        if (![node isKindOfClass:[ABI32_0_0RNSVGNode class]]) {
            continue;
        }

        if (event) {
            node.active = NO;
        }

        UIView *hitChild = [node hitTest:transformed withEvent:event];

        if (hitChild) {
            node.active = YES;
            return (node.responsible || (node != hitChild)) ? hitChild : self;
        }
    }

    UIView *hitSelf = [super hitTest:transformed withEvent:event];
    if (hitSelf) {
        return hitSelf;
    }

    return nil;
}

- (void)parseReference
{
    if (self.name) {
        typeof(self) __weak weakSelf = self;
        [self.svgView defineTemplate:weakSelf templateName:self.name];
    }

    [self traverseSubviews:^(__kindof ABI32_0_0RNSVGNode *node) {
        if ([node isKindOfClass:[ABI32_0_0RNSVGNode class]]) {
            [node parseReference];
        }
        return YES;
    }];
}

- (void)resetProperties
{
    [self traverseSubviews:^(__kindof ABI32_0_0RNSVGNode *node) {
        if ([node isKindOfClass:[ABI32_0_0RNSVGRenderable class]]) {
            [(ABI32_0_0RNSVGRenderable*)node resetProperties];
        }
        return YES;
    }];
}

@end
