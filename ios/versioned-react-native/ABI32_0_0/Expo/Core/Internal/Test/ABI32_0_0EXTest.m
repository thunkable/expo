// Copyright 2015-present 650 Industries. All rights reserved.

#import "ABI32_0_0EXTest.h"
#import "ABI32_0_0EXUnversioned.h"

#import <os/log.h>

NSNotificationName ABI32_0_0EXTestSuiteCompletedNotification = @"ABI32_0_0EXTestSuiteCompletedNotification";

@interface ABI32_0_0EXTest ()

@property (class, nonatomic, assign, readonly) os_log_t log;
@property (nonatomic, assign) ABI32_0_0EXTestEnvironment environment;

@end

@implementation ABI32_0_0EXTest

+ (NSString *)moduleName { return @"ExponentTest"; }

+ (os_log_t)log {
  static os_log_t log;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    log = os_log_create("host.exp.Exponent", "test");
  });
  return log;
}

- (instancetype)initWithEnvironment:(ABI32_0_0EXTestEnvironment)environment
{
  if (self = [super init]) {
    _environment = environment;
  }
  return self;
}

ABI32_0_0RCT_EXPORT_METHOD(log:(NSString *)message)
{
  os_log(ABI32_0_0EXTest.log, "%{public}@", message);
}

ABI32_0_0RCT_EXPORT_METHOD(completed:(NSString *)jsonStringifiedResult)
{
  NSDictionary *failedResult = @{ @"failed": @(1) };
  
  NSError *jsonError;
  NSData *jsonData = [jsonStringifiedResult dataUsingEncoding:NSUTF8StringEncoding];
  id resultObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
  if (jsonError) {
    resultObj = failedResult;
  }

  [[NSNotificationCenter defaultCenter] postNotificationName:@"EXTestSuiteCompletedNotification"
                                                      object:nil
                                                    userInfo:resultObj];
  
  // Apple's unified logging more precisely ensures the output is visible in a standalone app built
  // for release and for us to filter for this message
  os_log(ABI32_0_0EXTest.log, "[TEST-SUITE-END] %{public}@", jsonStringifiedResult);
}

ABI32_0_0RCT_REMAP_METHOD(action,
                 actionWithParams:(NSDictionary *)params
                 withResolver:(ABI32_0_0RCTPromiseResolveBlock)resolve
                 rejecter:(__unused ABI32_0_0RCTPromiseRejectBlock)reject)
{
  // stub on iOS
  resolve(@{});
}

ABI32_0_0RCT_REMAP_METHOD(shouldSkipTestsRequiringPermissionsAsync,
                 shouldSkipTestsRequiringPermissionsWithResolver:(ABI32_0_0RCTPromiseResolveBlock)resolve
                 rejecter:(__unused ABI32_0_0RCTPromiseRejectBlock)reject)
{
  resolve(@(_environment == ABI32_0_0EXTestEnvironmentCI));
}

#pragma mark - util

+ (ABI32_0_0EXTestEnvironment)testEnvironmentFromString:(NSString *)testEnvironmentString
{
  if ([testEnvironmentString isEqualToString:@"local"]) {
    return ABI32_0_0EXTestEnvironmentLocal;
  } else if ([testEnvironmentString isEqualToString:@"ci"]) {
    return ABI32_0_0EXTestEnvironmentCI;
  }
  return ABI32_0_0EXTestEnvironmentNone;
}

@end
