/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#ifdef __cplusplus

#include <memory>

#import <Foundation/Foundation.h>

/**
 * Type erased wrapper over any cxx value that can be passed as an argument
 * to native method.
 */

@interface ABI32_0_0RCTManagedPointer: NSObject

@property (nonatomic, readonly) void *voidPointer;

- (instancetype)initWithPointer:(std::shared_ptr<void>)pointer;

@end

namespace facebook {
namespace ReactABI32_0_0 {

template <typename T, typename P>
ABI32_0_0RCTManagedPointer *managedPointer(P initializer)
{
  auto ptr = std::shared_ptr<void>(new T(initializer));
  return [[ABI32_0_0RCTManagedPointer alloc] initWithPointer:std::move(ptr)];
}

} }

#endif
