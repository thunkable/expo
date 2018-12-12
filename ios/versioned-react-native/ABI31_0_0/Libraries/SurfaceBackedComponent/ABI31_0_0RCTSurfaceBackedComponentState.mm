/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI31_0_0RCTSurfaceBackedComponentState.h"

#import <ReactABI31_0_0/ABI31_0_0RCTSurface.h>

@implementation ABI31_0_0RCTSurfaceBackedComponentState

+ (instancetype)newWithSurface:(ABI31_0_0RCTSurface *)surface
{
  return [[self alloc] initWithSurface:surface];
}

- (instancetype)initWithSurface:(ABI31_0_0RCTSurface *)surface
{
  if (self == [super init]) {
    _surface = surface;
  }

  return self;
}

@end
