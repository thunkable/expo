/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once

#include <ABI32_0_0fabric/ABI32_0_0attributedstring/TextAttributes.h>
#include <ABI32_0_0fabric/ABI32_0_0components/text/BaseTextProps.h>
#include <ABI32_0_0fabric/ABI32_0_0core/Props.h>
#include <ABI32_0_0fabric/ABI32_0_0graphics/Color.h>
#include <ABI32_0_0fabric/ABI32_0_0graphics/Geometry.h>

namespace facebook {
namespace ReactABI32_0_0 {

class TextProps:
  public Props,
  public BaseTextProps {

public:
  TextProps() = default;
  TextProps(const TextProps &sourceProps, const RawProps &rawProps);

#pragma mark - DebugStringConvertible

  SharedDebugStringConvertibleList getDebugProps() const override;
};

} // namespace ReactABI32_0_0
} // namespace facebook
