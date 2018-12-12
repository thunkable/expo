// Copyright (c) 2004-present, Facebook, Inc.

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

#pragma once

#include <functional>
#include <memory>
#include <string>

#include <cxxReactABI31_0_0/ABI31_0_0ReactMarker.h>
#include <ABI31_0_0jschelpers/ABI31_0_0JavaScriptCore.h>

#ifndef RN_EXPORT
#define RN_EXPORT __attribute__((visibility("default")))
#endif

namespace facebook {
namespace ReactABI31_0_0 {

namespace JSCNativeHooks {

using Hook = JSValueRef(*)(
  JSContextRef ctx,
  JSObjectRef function,
  JSObjectRef thisObject,
  size_t argumentCount,
  const JSValueRef arguments[],
  JSValueRef *exception);
extern RN_EXPORT Hook loggingHook;
extern RN_EXPORT Hook nowHook;

typedef void(*ConfigurationHook)(JSGlobalContextRef);
extern RN_EXPORT ConfigurationHook installPerfHooks;

}

} }
