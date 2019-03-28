#import "ABI32_0_0REAModule.h"

#import "ABI32_0_0REANodesManager.h"

typedef void (^AnimatedOperation)(ABI32_0_0REANodesManager *nodesManager);

@implementation ABI32_0_0REAModule
{
  ABI32_0_0REANodesManager *_nodesManager;
  NSMutableArray<AnimatedOperation> *_operations;
}

ABI32_0_0RCT_EXPORT_MODULE(ReanimatedModule);

- (void)invalidate
{
  [_nodesManager invalidate];
  [self.bridge.eventDispatcher removeDispatchObserver:self];
  [self.bridge.uiManager.observerCoordinator removeObserver:self];
}

- (dispatch_queue_t)methodQueue
{
  // This module needs to be on the same queue as the UIManager to avoid
  // having to lock `_operations` and `_preOperations` since `uiManagerWillPerformMounting`
  // will be called from that queue.
  return ABI32_0_0RCTGetUIManagerQueue();
}

- (void)setBridge:(ABI32_0_0RCTBridge *)bridge
{
  [super setBridge:bridge];

  _nodesManager = [[ABI32_0_0REANodesManager alloc] initWithModule:self
                                                uiManager:self.bridge.uiManager];
  _operations = [NSMutableArray new];

  [bridge.eventDispatcher addDispatchObserver:self];
  [bridge.uiManager.observerCoordinator addObserver:self];
}

#pragma mark -- API

ABI32_0_0RCT_EXPORT_METHOD(createNode:(nonnull NSNumber *)nodeID
                  config:(NSDictionary<NSString *, id> *)config)
{
  [self addOperationBlock:^(ABI32_0_0REANodesManager *nodesManager) {
    [nodesManager createNode:nodeID config:config];
  }];
}

ABI32_0_0RCT_EXPORT_METHOD(dropNode:(nonnull NSNumber *)nodeID)
{
  [self addOperationBlock:^(ABI32_0_0REANodesManager *nodesManager) {
    [nodesManager dropNode:nodeID];
  }];
}

ABI32_0_0RCT_EXPORT_METHOD(getValue:(nonnull NSNumber *)nodeID
                  callback:(ABI32_0_0RCTResponseSenderBlock)callback) {
  [self addOperationBlock:^(ABI32_0_0REANodesManager *nodesManager) {
    [nodesManager getValue:nodeID callback:(ABI32_0_0RCTResponseSenderBlock)callback];
  }];
}

ABI32_0_0RCT_EXPORT_METHOD(connectNodes:(nonnull NSNumber *)parentID
                  childTag:(nonnull NSNumber *)childID)
{
  [self addOperationBlock:^(ABI32_0_0REANodesManager *nodesManager) {
    [nodesManager connectNodes:parentID childID:childID];
  }];
}

ABI32_0_0RCT_EXPORT_METHOD(disconnectNodes:(nonnull NSNumber *)parentID
                  childTag:(nonnull NSNumber *)childID)
{
  [self addOperationBlock:^(ABI32_0_0REANodesManager *nodesManager) {
    [nodesManager disconnectNodes:parentID childID:childID];
  }];
}

ABI32_0_0RCT_EXPORT_METHOD(connectNodeToView:(nonnull NSNumber *)nodeID
                  viewTag:(nonnull NSNumber *)viewTag)
{
  NSString *viewName = [self.bridge.uiManager viewNameForReactABI32_0_0Tag:viewTag];
  [self addOperationBlock:^(ABI32_0_0REANodesManager *nodesManager) {
    [nodesManager connectNodeToView:nodeID viewTag:viewTag viewName:viewName];
  }];
}

ABI32_0_0RCT_EXPORT_METHOD(disconnectNodeFromView:(nonnull NSNumber *)nodeID
                  viewTag:(nonnull NSNumber *)viewTag)
{
  [self addOperationBlock:^(ABI32_0_0REANodesManager *nodesManager) {
    [nodesManager disconnectNodeFromView:nodeID viewTag:viewTag];
  }];
}

ABI32_0_0RCT_EXPORT_METHOD(attachEvent:(nonnull NSNumber *)viewTag
                  eventName:(nonnull NSString *)eventName
                  eventNodeID:(nonnull NSNumber *)eventNodeID)
{
  [self addOperationBlock:^(ABI32_0_0REANodesManager *nodesManager) {
    [nodesManager attachEvent:viewTag eventName:eventName eventNodeID:eventNodeID];
  }];
}

ABI32_0_0RCT_EXPORT_METHOD(detachEvent:(nonnull NSNumber *)viewTag
                  eventName:(nonnull NSString *)eventName
                  eventNodeID:(nonnull NSNumber *)eventNodeID)
{
  [self addOperationBlock:^(ABI32_0_0REANodesManager *nodesManager) {
    [nodesManager detachEvent:viewTag eventName:eventName eventNodeID:eventNodeID];
  }];
}

ABI32_0_0RCT_EXPORT_METHOD(configureProps:(nonnull NSArray<NSString *> *)nativeProps
                         uiProps:(nonnull NSArray<NSString *> *)uiProps)
{
  [self addOperationBlock:^(ABI32_0_0REANodesManager *nodesManager) {
    [nodesManager configureProps:[NSSet setWithArray:nativeProps] uiProps:[NSSet setWithArray:uiProps]];
  }];
}


#pragma mark -- Batch handling

- (void)addOperationBlock:(AnimatedOperation)operation
{
  [_operations addObject:operation];
}

#pragma mark - ABI32_0_0RCTUIManagerObserver

- (void)uiManagerWillPerformMounting:(ABI32_0_0RCTUIManager *)uiManager
{
  if (_operations.count == 0) {
    return;
  }

  NSArray<AnimatedOperation> *operations = _operations;
  _operations = [NSMutableArray new];

  ABI32_0_0REANodesManager *nodesManager = _nodesManager;

  [uiManager addUIBlock:^(__unused ABI32_0_0RCTUIManager *manager, __unused NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    for (AnimatedOperation operation in operations) {
      operation(nodesManager);
    }
    [nodesManager operationsBatchDidComplete];
  }];
}

#pragma mark -- Events

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"onReanimatedCall", @"onReanimatedPropsChange"];
}

- (void)eventDispatcherWillDispatchEvent:(id<ABI32_0_0RCTEvent>)event
{
  // Events can be dispatched from any queue
  [_nodesManager dispatchEvent:event];
}

@end
