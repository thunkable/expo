/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once

#include <ABI32_0_0fabric/ABI32_0_0core/Sealable.h>
#include <ABI32_0_0fabric/ABI32_0_0debug/DebugStringConvertible.h>

namespace facebook {
namespace ReactABI32_0_0 {

class LocalData;

using SharedLocalData = std::shared_ptr<const LocalData>;

/*
 * Abstract class for any kind of concrete pieces of local data specific for
 * some kinds of `ShadowNode`s.
 * LocalData might be used to communicate some infomation between `ShadowNode`s
 * and native component views.
 * All `LocalData` objects *must* be immutable (sealed) when they became
 * a part of the shadow tree.
 */
class LocalData:
  public Sealable,
  public DebugStringConvertible {

  // Nothing.
};

} // namespace ReactABI32_0_0
} // namespace facebook
