/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once

#include <ABI32_0_0fabric/ABI32_0_0attributedstring/AttributedString.h>
#include <ABI32_0_0fabric/ABI32_0_0core/LocalData.h>
#include <ABI32_0_0fabric/ABI32_0_0textlayoutmanager/TextLayoutManager.h>

namespace facebook {
namespace ReactABI32_0_0 {

class ParagraphLocalData;

using SharedParagraphLocalData = std::shared_ptr<const ParagraphLocalData>;

/*
 * LocalData for <Paragraph> component.
 * Represents what to render and how to render.
 */
class ParagraphLocalData:
  public LocalData {

public:

  /*
   * All content of <Paragraph> component represented as an `AttributedString`.
   */
  AttributedString getAttributedString() const;
  void setAttributedString(AttributedString attributedString);

  /*
   * `TextLayoutManager` provides a connection to platform-specific
   * text rendering infrastructure which is capable to render the
   * `AttributedString`.
   */
  SharedTextLayoutManager getTextLayoutManager() const;
  void setTextLayoutManager(SharedTextLayoutManager textLayoutManager);

#pragma mark - DebugStringConvertible

  std::string getDebugName() const override;
  SharedDebugStringConvertibleList getDebugProps() const override;

private:

  AttributedString attributedString_;
  SharedTextLayoutManager textLayoutManager_;
};

} // namespace ReactABI32_0_0
} // namespace facebook
