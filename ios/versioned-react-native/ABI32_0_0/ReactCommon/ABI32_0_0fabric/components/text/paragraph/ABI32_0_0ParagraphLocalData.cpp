/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include "ABI32_0_0ParagraphLocalData.h"

#include <ABI32_0_0fabric/ABI32_0_0debug/debugStringConvertibleUtils.h>

namespace facebook {
namespace ReactABI32_0_0 {

AttributedString ParagraphLocalData::getAttributedString() const {
  return attributedString_;
}

void ParagraphLocalData::setAttributedString(AttributedString attributedString) {
  ensureUnsealed();
  attributedString_ = attributedString;
}

SharedTextLayoutManager ParagraphLocalData::getTextLayoutManager() const {
  return textLayoutManager_;
}

void ParagraphLocalData::setTextLayoutManager(SharedTextLayoutManager textLayoutManager) {
  ensureUnsealed();
  textLayoutManager_ = textLayoutManager;
}

#pragma mark - DebugStringConvertible

std::string ParagraphLocalData::getDebugName() const {
  return "ParagraphLocalData";
}

SharedDebugStringConvertibleList ParagraphLocalData::getDebugProps() const {
  return {
    debugStringConvertibleItem("attributedString", attributedString_, "")
  };
}

} // namespace ReactABI32_0_0
} // namespace facebook
