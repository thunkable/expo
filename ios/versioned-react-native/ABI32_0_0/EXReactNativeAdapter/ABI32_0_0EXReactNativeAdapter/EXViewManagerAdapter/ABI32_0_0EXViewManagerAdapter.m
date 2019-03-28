// Copyright 2018-present 650 Industries. All rights reserved.

#import <ABI32_0_0EXReactNativeAdapter/ABI32_0_0EXViewManagerAdapter.h>

@interface ABI32_0_0EXViewManagerAdapter ()

@property ABI32_0_0EXViewManager *viewManager;

@end

@implementation ABI32_0_0EXViewManagerAdapter

- (instancetype)initWithViewManager:(ABI32_0_0EXViewManager *)viewManager
{
  if (self = [super init]) {
    _viewManager = viewManager;
  }
  return self;
}

- (NSArray<NSString *> *)supportedEvents
{
  return [_viewManager supportedEvents];
}

// This class is not used directly --- usually it's subclassed
// in runtime by ABI32_0_0EXNativeModulesProxy for each exported view manager.
// Each created class has different class name, conforming to convention.
// This way we can provide ReactABI32_0_0 Native with different ABI32_0_0RCTViewManagers
// returning different modules names.

+ (NSString *)moduleName
{
  return NSStringFromClass(self);
}

- (UIView *)view
{
  return [_viewManager view];
}

// The adapter multiplexes custom view properties in one "big object prop" that is passed here.

ABI32_0_0RCT_CUSTOM_VIEW_PROPERTY(proxiedProperties, NSDictionary, UIView)
{
  __weak ABI32_0_0EXViewManagerAdapter *weakSelf = self;
  [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
    __strong ABI32_0_0EXViewManagerAdapter *strongSelf = weakSelf;
    [strongSelf.viewManager updateProp:key withValue:obj onView:view];
  }];
}

@end
