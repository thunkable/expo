/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI32_0_0RCTInsertMountItem.h"

#import "ABI32_0_0RCTComponentViewRegistry.h"

@implementation ABI32_0_0RCTInsertMountItem {
  ReactABI32_0_0Tag _childTag;
  ReactABI32_0_0Tag _parentTag;
  NSInteger _index;
}

- (instancetype)initWithChildTag:(ReactABI32_0_0Tag)childTag
                       parentTag:(ReactABI32_0_0Tag)parentTag
                           index:(NSInteger)index
{
  if (self = [super init]) {
    _childTag = childTag;
    _parentTag = parentTag;
    _index = index;
  }

  return self;
}

- (void)executeWithRegistry:(ABI32_0_0RCTComponentViewRegistry *)registry
{
  UIView<ABI32_0_0RCTComponentViewProtocol> *childComponentView = [registry componentViewByTag:_childTag];
  UIView<ABI32_0_0RCTComponentViewProtocol> *parentComponentView = [registry componentViewByTag:_parentTag];

  if (childComponentView == nil || parentComponentView == nil) {
    return;
  }

  [parentComponentView mountChildComponentView:childComponentView
                                         index:_index];
}

@end
