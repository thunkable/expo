/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <ReactABI32_0_0/ABI32_0_0RCTMountItemProtocol.h>
#import <ReactABI32_0_0/ABI32_0_0RCTPrimitives.h>
#import <ABI32_0_0fabric/ABI32_0_0core/LocalData.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Updates local data of a component view.
 */
@interface ABI32_0_0RCTUpdateLocalDataMountItem : NSObject <ABI32_0_0RCTMountItemProtocol>

- (instancetype)initWithTag:(ReactABI32_0_0Tag)tag
               oldLocalData:(facebook::ReactABI32_0_0::SharedLocalData)oldLocalData
               newLocalData:(facebook::ReactABI32_0_0::SharedLocalData)newLocalData;

@end

NS_ASSUME_NONNULL_END
