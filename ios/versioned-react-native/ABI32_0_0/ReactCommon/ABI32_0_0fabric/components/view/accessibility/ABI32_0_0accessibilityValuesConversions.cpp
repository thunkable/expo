/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include "ABI32_0_0accessibilityValuesConversions.h"

#include <folly/Conv.h>

namespace facebook {
namespace ReactABI32_0_0 {

AccessibilityTraits accessibilityTraitsFromDynamic(const folly::dynamic &value) {
  assert(value.isString());

  // FIXME: Not clear yet.
  abort();
}

} // namespace ReactABI32_0_0
} // namespace facebook
