/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once

#include <ABI32_0_0fabric/ABI32_0_0components/switch/SwitchEventEmitter.h>
#include <ABI32_0_0fabric/ABI32_0_0components/switch/SwitchProps.h>
#include <ABI32_0_0fabric/ABI32_0_0components/view/ConcreteViewShadowNode.h>

namespace facebook {
namespace ReactABI32_0_0 {

extern const char SwitchComponentName[];

/*
 * `ShadowNode` for <Switch> component.
 */
using SwitchShadowNode =
  ConcreteViewShadowNode<
    SwitchComponentName,
    SwitchProps,
    SwitchEventEmitter
  >;

} // namespace ReactABI32_0_0
} // namespace facebook
