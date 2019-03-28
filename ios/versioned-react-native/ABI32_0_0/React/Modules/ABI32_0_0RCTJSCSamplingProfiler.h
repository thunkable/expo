/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import <ReactABI32_0_0/ABI32_0_0RCTBridgeModule.h>

@interface ABI32_0_0RCTJSCSamplingProfiler : NSObject <ABI32_0_0RCTBridgeModule>

/**
 * Receives a JSON string containing the result of a JSC CPU Profiling run,
 *  and sends them to the packager to be symbolicated and saved to disk.
 * It is safe to call this method from any thread.
 */
- (void)operationCompletedWithResults:(NSString *)results;

@end
