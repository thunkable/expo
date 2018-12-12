/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI30_0_0RCTTestModule.h"

#import <ReactABI30_0_0/ABI30_0_0RCTAssert.h>
#import <ReactABI30_0_0/ABI30_0_0RCTEventDispatcher.h>
#import <ReactABI30_0_0/ABI30_0_0RCTLog.h>
#import <ReactABI30_0_0/ABI30_0_0RCTUIManager.h>

#import "ABI30_0_0FBSnapshotTestController.h"

@implementation ABI30_0_0RCTTestModule {
  NSMutableDictionary<NSString *, NSNumber *> *_snapshotCounter;
}

@synthesize bridge = _bridge;

ABI30_0_0RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue
{
  return _bridge.uiManager.methodQueue;
}

ABI30_0_0RCT_EXPORT_METHOD(verifySnapshot:(ABI30_0_0RCTResponseSenderBlock)callback)
{
  ABI30_0_0RCTAssert(_controller != nil, @"No snapshot controller configured.");

  [_bridge.uiManager addUIBlock:^(ABI30_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    NSString *testName = NSStringFromSelector(self->_testSelector);
    if (!self->_snapshotCounter) {
      self->_snapshotCounter = [NSMutableDictionary new];
    }

    NSNumber *counter = @([self->_snapshotCounter[testName] integerValue] + 1);
    self->_snapshotCounter[testName] = counter;

    NSError *error = nil;
    NSString *identifier = [counter stringValue];
    if (self->_testSuffix) {
      identifier = [identifier stringByAppendingString:self->_testSuffix];
    }
    BOOL success = [self->_controller compareSnapshotOfView:self->_view
                                                   selector:self->_testSelector
                                                 identifier:identifier
                                                      error:&error];
    if (!success) {
      ABI30_0_0RCTLogInfo(@"Failed to verify snapshot %@ (error: %@)", identifier, error);
    }
    callback(@[@(success)]);
  }];
}

ABI30_0_0RCT_EXPORT_METHOD(sendAppEvent:(NSString *)name body:(nullable id)body)
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  [_bridge.eventDispatcher sendAppEventWithName:name body:body];
#pragma clang diagnostic pop
}

ABI30_0_0RCT_REMAP_METHOD(shouldResolve, shouldResolve_resolve:(ABI30_0_0RCTPromiseResolveBlock)resolve reject:(ABI30_0_0RCTPromiseRejectBlock)reject)
{
  resolve(@1);
}

ABI30_0_0RCT_REMAP_METHOD(shouldReject, shouldReject_resolve:(ABI30_0_0RCTPromiseResolveBlock)resolve reject:(ABI30_0_0RCTPromiseRejectBlock)reject)
{
  reject(nil, nil, nil);
}

ABI30_0_0RCT_EXPORT_METHOD(markTestCompleted)
{
  [self markTestPassed:YES];
}

ABI30_0_0RCT_EXPORT_METHOD(markTestPassed:(BOOL)success)
{
  [_bridge.uiManager addUIBlock:^(__unused ABI30_0_0RCTUIManager *uiManager, __unused NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    self->_status = success ? ABI30_0_0RCTTestStatusPassed : ABI30_0_0RCTTestStatusFailed;
  }];
}

@end
