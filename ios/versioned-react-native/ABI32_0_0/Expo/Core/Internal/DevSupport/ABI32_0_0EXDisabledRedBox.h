// Copyright 2015-present 650 Industries. All rights reserved.

#import <ReactABI32_0_0/ABI32_0_0RCTBridgeModule.h>

@interface ABI32_0_0EXDisabledRedBox : NSObject <ABI32_0_0RCTBridgeModule>

- (void)showError:(NSError *)error;
- (void)showErrorMessage:(NSString *)message;
- (void)showErrorMessage:(NSString *)message withDetails:(NSString *)details;
- (void)showErrorMessage:(NSString *)message withStack:(NSArray<NSDictionary *> *)stack;
- (void)updateErrorMessage:(NSString *)message withStack:(NSArray<NSDictionary *> *)stack;

- (void)dismiss;

@end
