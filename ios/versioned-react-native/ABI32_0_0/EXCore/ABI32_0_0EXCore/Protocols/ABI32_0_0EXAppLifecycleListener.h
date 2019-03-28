// Copyright © 2018 650 Industries. All rights reserved.

#import <Foundation/Foundation.h>

// Utility protocol helping modules to register with specific platform adapter
// for application lifecycle events.

@protocol ABI32_0_0EXAppLifecycleListener <NSObject>

- (void)onAppBackgrounded;
- (void)onAppForegrounded;

@end
