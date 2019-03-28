// Copyright (c) 2004-present, Facebook, Inc.

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

#pragma once

#include <string>
#include <cstdint>

namespace facebook {
namespace ReactABI32_0_0 {
namespace unicode {
__attribute__((visibility("default"))) std::string utf16toUTF8(const uint16_t* utf16, size_t length) noexcept;
}
}
}
