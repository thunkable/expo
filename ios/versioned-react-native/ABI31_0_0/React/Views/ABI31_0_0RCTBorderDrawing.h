/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <ReactABI31_0_0/ABI31_0_0RCTBorderStyle.h>

typedef struct {
  CGFloat topLeft;
  CGFloat topRight;
  CGFloat bottomLeft;
  CGFloat bottomRight;
} ABI31_0_0RCTCornerRadii;

typedef struct {
  CGSize topLeft;
  CGSize topRight;
  CGSize bottomLeft;
  CGSize bottomRight;
} ABI31_0_0RCTCornerInsets;

typedef struct {
  CGColorRef top;
  CGColorRef left;
  CGColorRef bottom;
  CGColorRef right;
} ABI31_0_0RCTBorderColors;

/**
 * Determine if the border widths, colors and radii are all equal.
 */
BOOL ABI31_0_0RCTBorderInsetsAreEqual(UIEdgeInsets borderInsets);
BOOL ABI31_0_0RCTCornerRadiiAreEqual(ABI31_0_0RCTCornerRadii cornerRadii);
BOOL ABI31_0_0RCTBorderColorsAreEqual(ABI31_0_0RCTBorderColors borderColors);

/**
 * Convert ABI31_0_0RCTCornerRadii to ABI31_0_0RCTCornerInsets by applying border insets.
 * Effectively, returns radius - inset, with a lower bound of 0.0.
 */
ABI31_0_0RCTCornerInsets ABI31_0_0RCTGetCornerInsets(ABI31_0_0RCTCornerRadii cornerRadii,
                                   UIEdgeInsets borderInsets);

/**
 * Create a CGPath representing a rounded rectangle with the specified bounds
 * and corner insets. Note that the CGPathRef must be released by the caller.
 */
CGPathRef ABI31_0_0RCTPathCreateWithRoundedRect(CGRect bounds,
                                       ABI31_0_0RCTCornerInsets cornerInsets,
                                       const CGAffineTransform *transform);

/**
 * Draw a CSS-compliant border as an image. You can determine if it's scalable
 * by inspecting the image's `capInsets`.
 *
 * `borderInsets` defines the border widths for each edge.
 */
UIImage *ABI31_0_0RCTGetBorderImage(ABI31_0_0RCTBorderStyle borderStyle,
                           CGSize viewSize,
                           ABI31_0_0RCTCornerRadii cornerRadii,
                           UIEdgeInsets borderInsets,
                           ABI31_0_0RCTBorderColors borderColors,
                           CGColorRef backgroundColor,
                           BOOL drawToEdge);
