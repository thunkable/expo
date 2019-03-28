/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include "ABI32_0_0ImageResponse.h"

namespace facebook {
namespace ReactABI32_0_0 {

ImageResponse::ImageResponse(const std::shared_ptr<void> &image):
  image_(image) {}

std::shared_ptr<void> ImageResponse::getImage() const {
  return image_;
}

} // namespace ReactABI32_0_0
} // namespace facebook
