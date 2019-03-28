#import "ABI32_0_0REAAlwaysNode.h"
#import "ABI32_0_0REANodesManager.h"
#import "ABI32_0_0REAStyleNode.h"
#import "ABI32_0_0REAModule.h"
#import <ReactABI32_0_0/ABI32_0_0RCTLog.h>
#import <ReactABI32_0_0/ABI32_0_0RCTUIManager.h>

@implementation ABI32_0_0REAAlwaysNode
{
  NSNumber * _nodeToBeEvaluated;
}

- (instancetype)initWithID:(ABI32_0_0REANodeID)nodeID config:(NSDictionary<NSString *,id> *)config
{
    if ((self = [super initWithID:nodeID config:config])) {
        _nodeToBeEvaluated = config[@"what"];
    }
    return self;
}

- (id)evaluate
{
  [[self.nodesManager findNodeByID:_nodeToBeEvaluated] value];
  return @(0);
}

- (void)update
{
  [self value];
}

@end

