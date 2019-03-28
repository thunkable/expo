/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#include <ABI32_0_0fabric/ABI32_0_0textlayoutmanager/ABI32_0_0RCTFontProperties.h>
#include <ABI32_0_0fabric/ABI32_0_0textlayoutmanager/ABI32_0_0RCTFontUtils.h>

using namespace facebook::ReactABI32_0_0;

inline static NSTextAlignment ABI32_0_0RCTNSTextAlignmentFromTextAlignment(TextAlignment textAlignment) {
  switch (textAlignment) {
    case TextAlignment::Natural: return NSTextAlignmentNatural;
    case TextAlignment::Left: return NSTextAlignmentLeft;
    case TextAlignment::Right: return NSTextAlignmentRight;
    case TextAlignment::Center: return NSTextAlignmentCenter;
    case TextAlignment::Justified: return NSTextAlignmentJustified;
  }
}

inline static NSWritingDirection ABI32_0_0RCTNSWritingDirectionFromWritingDirection(WritingDirection writingDirection) {
  switch (writingDirection) {
    case WritingDirection::Natural: return NSWritingDirectionNatural;
    case WritingDirection::LeftToRight: return NSWritingDirectionLeftToRight;
    case WritingDirection::RightToLeft: return NSWritingDirectionRightToLeft;
  }
}

inline static ABI32_0_0RCTFontStyle ABI32_0_0RCTFontStyleFromFontStyle(FontStyle fontStyle) {
  switch (fontStyle) {
    case FontStyle::Normal: return ABI32_0_0RCTFontStyleNormal;
    case FontStyle::Italic: return ABI32_0_0RCTFontStyleItalic;
    case FontStyle::Oblique: return ABI32_0_0RCTFontStyleOblique;
  }
}

inline static ABI32_0_0RCTFontVariant ABI32_0_0RCTFontVariantFromFontVariant(FontVariant fontVariant) {
  return (ABI32_0_0RCTFontVariant)fontVariant;
}

inline static NSUnderlineStyle ABI32_0_0RCTNSUnderlineStyleFromStyleAndPattern(TextDecorationLineStyle textDecorationLineStyle, TextDecorationLinePattern textDecorationLinePattern) {
  NSUnderlineStyle style = NSUnderlineStyleNone;

  switch (textDecorationLineStyle) {
    case TextDecorationLineStyle::Single:
      style = NSUnderlineStyle(style | NSUnderlineStyleSingle); break;
    case TextDecorationLineStyle::Thick:
      style = NSUnderlineStyle(style | NSUnderlineStyleThick); break;
    case TextDecorationLineStyle::Double:
      style = NSUnderlineStyle(style | NSUnderlineStyleDouble); break;
  }

  switch (textDecorationLinePattern) {
    case TextDecorationLinePattern::Solid:
      style = NSUnderlineStyle(style | NSUnderlinePatternSolid); break;
    case TextDecorationLinePattern::Dash:
      style = NSUnderlineStyle(style | NSUnderlinePatternDash); break;
    case TextDecorationLinePattern::Dot:
      style = NSUnderlineStyle(style | NSUnderlinePatternDot); break;
    case TextDecorationLinePattern::DashDot:
      style = NSUnderlineStyle(style | NSUnderlinePatternDashDot); break;
    case TextDecorationLinePattern::DashDotDot:
      style = NSUnderlineStyle(style | NSUnderlinePatternDashDotDot); break;
  }

  return style;
}

inline static UIColor *ABI32_0_0RCTUIColorFromSharedColor(const SharedColor &color) {
  return color ? [UIColor colorWithCGColor:color.get()] : nil;
}
