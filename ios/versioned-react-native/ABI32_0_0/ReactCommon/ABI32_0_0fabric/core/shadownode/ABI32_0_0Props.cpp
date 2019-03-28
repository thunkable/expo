/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include "ABI32_0_0Props.h"

#include <ABI32_0_0fabric/ABI32_0_0core/propsConversions.h>
#include <folly/dynamic.h>

namespace facebook {
namespace ReactABI32_0_0 {

Props::Props(const Props &sourceProps, const RawProps &rawProps):
  nativeId(convertRawProp(rawProps, "nativeID", sourceProps.nativeId)) {};

} // namespace ReactABI32_0_0
} // namespace facebook
