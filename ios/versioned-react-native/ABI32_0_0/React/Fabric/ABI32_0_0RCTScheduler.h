/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>
#import <memory>

#import <ReactABI32_0_0/ABI32_0_0RCTPrimitives.h>
#import <ABI32_0_0fabric/ABI32_0_0core/LayoutConstraints.h>
#import <ABI32_0_0fabric/ABI32_0_0core/LayoutContext.h>
#import <ABI32_0_0fabric/ABI32_0_0uimanager/FabricUIManager.h>
#import <ABI32_0_0fabric/ABI32_0_0uimanager/TreeMutationInstruction.h>

NS_ASSUME_NONNULL_BEGIN

@class ABI32_0_0RCTMountingManager;

/**
 * Exactly same semantic as `facebook::ReactABI32_0_0::SchedulerDelegate`.
 */
@protocol ABI32_0_0RCTSchedulerDelegate

- (void)schedulerDidComputeMutationInstructions:(facebook::ReactABI32_0_0::TreeMutationInstructionList)instructions rootTag:(ReactABI32_0_0Tag)rootTag;

- (void)schedulerDidRequestPreliminaryViewAllocationWithComponentName:(NSString *)componentName;

@end

/**
 * `facebook::ReactABI32_0_0::Scheduler` as an Objective-C class.
 */
@interface ABI32_0_0RCTScheduler : NSObject

@property (atomic, weak, nullable) id<ABI32_0_0RCTSchedulerDelegate> delegate;

- (void)registerRootTag:(ReactABI32_0_0Tag)tag;

- (void)unregisterRootTag:(ReactABI32_0_0Tag)tag;

- (CGSize)measureWithLayoutConstraints:(facebook::ReactABI32_0_0::LayoutConstraints)layoutConstraints
                         layoutContext:(facebook::ReactABI32_0_0::LayoutContext)layoutContext
                               rootTag:(ReactABI32_0_0Tag)rootTag;

- (void)constraintLayoutWithLayoutConstraints:(facebook::ReactABI32_0_0::LayoutConstraints)layoutConstraints
                                layoutContext:(facebook::ReactABI32_0_0::LayoutContext)layoutContext
                                      rootTag:(ReactABI32_0_0Tag)rootTag;

@end

@interface ABI32_0_0RCTScheduler (Deprecated)

- (std::shared_ptr<facebook::ReactABI32_0_0::FabricUIManager>)uiManager_DO_NOT_USE;

@end

NS_ASSUME_NONNULL_END
