/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI32_0_0RCTUpdateEventEmitterMountItem.h"

#import "ABI32_0_0RCTComponentViewRegistry.h"

using namespace facebook::ReactABI32_0_0;

@implementation ABI32_0_0RCTUpdateEventEmitterMountItem {
  ReactABI32_0_0Tag _tag;
  SharedEventEmitter _eventEmitter;
}

- (instancetype)initWithTag:(ReactABI32_0_0Tag)tag
              eventEmitter:(SharedEventEmitter)eventEmitter
{
  if (self = [super init]) {
    _tag = tag;
    _eventEmitter = eventEmitter;
  }

  return self;
}

- (void)executeWithRegistry:(ABI32_0_0RCTComponentViewRegistry *)registry
{
  UIView<ABI32_0_0RCTComponentViewProtocol> *componentView = [registry componentViewByTag:_tag];

  [componentView updateEventEmitter:_eventEmitter];
}

@end
