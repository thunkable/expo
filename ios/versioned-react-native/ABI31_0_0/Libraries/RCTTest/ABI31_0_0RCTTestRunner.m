/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI31_0_0RCTTestRunner.h"

#import <ReactABI31_0_0/ABI31_0_0RCTAssert.h>
#import <ReactABI31_0_0/ABI31_0_0RCTBridge+Private.h>
#import <ReactABI31_0_0/ABI31_0_0RCTDevSettings.h>
#import <ReactABI31_0_0/ABI31_0_0RCTLog.h>
#import <ReactABI31_0_0/ABI31_0_0RCTRootView.h>
#import <ReactABI31_0_0/ABI31_0_0RCTUIManager.h>
#import <ReactABI31_0_0/ABI31_0_0RCTUtils.h>

#import "ABI31_0_0FBSnapshotTestController.h"
#import "ABI31_0_0RCTTestModule.h"

static const NSTimeInterval kTestTimeoutSeconds = 120;

@implementation ABI31_0_0RCTTestRunner
{
  FBSnapshotTestController *_testController;
  ABI31_0_0RCTBridgeModuleListProvider _moduleProvider;
  NSString *_appPath;
}

- (instancetype)initWithApp:(NSString *)app
         referenceDirectory:(NSString *)referenceDirectory
             moduleProvider:(ABI31_0_0RCTBridgeModuleListProvider)block
                  scriptURL:(NSURL *)scriptURL
{
  ABI31_0_0RCTAssertParam(app);
  ABI31_0_0RCTAssertParam(referenceDirectory);

  if ((self = [super init])) {
    if (!referenceDirectory.length) {
      referenceDirectory = [[NSBundle bundleForClass:self.class].resourcePath stringByAppendingPathComponent:@"ReferenceImages"];
    }

    NSString *sanitizedAppName = [app stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    sanitizedAppName = [sanitizedAppName stringByReplacingOccurrencesOfString:@"\\" withString:@"-"];
    _testController = [[FBSnapshotTestController alloc] initWithTestName:sanitizedAppName];
    _testController.referenceImagesDirectory = referenceDirectory;
    _moduleProvider = [block copy];
    _appPath = app;

    if (scriptURL != nil) {
      _scriptURL = scriptURL;
    } else {
      [self updateScript];
    }
  }
  return self;
}

ABI31_0_0RCT_NOT_IMPLEMENTED(- (instancetype)init)

- (void)updateScript
{
  if (getenv("CI_USE_PACKAGER") || _useBundler) {
    _scriptURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:8081/%@.bundle?platform=ios&dev=true", _appPath]];
  } else {
    _scriptURL = [[NSBundle bundleForClass:[ABI31_0_0RCTBridge class]] URLForResource:@"main" withExtension:@"jsbundle"];
  }
  ABI31_0_0RCTAssert(_scriptURL != nil, @"No scriptURL set");
}

- (void)setRecordMode:(BOOL)recordMode
{
  _testController.recordMode = recordMode;
}

- (BOOL)recordMode
{
  return _testController.recordMode;
}

- (void)setUseBundler:(BOOL)useBundler
{
  _useBundler = useBundler;
  [self updateScript];
}

- (void)runTest:(SEL)test module:(NSString *)moduleName
{
  [self runTest:test module:moduleName initialProps:nil configurationBlock:nil expectErrorBlock:nil];
}

- (void)runTest:(SEL)test module:(NSString *)moduleName
   initialProps:(NSDictionary<NSString *, id> *)initialProps
configurationBlock:(void(^)(ABI31_0_0RCTRootView *rootView))configurationBlock
{
  [self runTest:test module:moduleName initialProps:initialProps configurationBlock:configurationBlock expectErrorBlock:nil];
}

- (void)runTest:(SEL)test module:(NSString *)moduleName
   initialProps:(NSDictionary<NSString *, id> *)initialProps
configurationBlock:(void(^)(ABI31_0_0RCTRootView *rootView))configurationBlock
expectErrorRegex:(NSString *)errorRegex
{
  BOOL(^expectErrorBlock)(NSString *error)  = ^BOOL(NSString *error){
    return [error rangeOfString:errorRegex options:NSRegularExpressionSearch].location != NSNotFound;
  };

  [self runTest:test module:moduleName initialProps:initialProps configurationBlock:configurationBlock expectErrorBlock:expectErrorBlock];
}

- (void)runTest:(SEL)test module:(NSString *)moduleName
   initialProps:(NSDictionary<NSString *, id> *)initialProps
configurationBlock:(void(^)(ABI31_0_0RCTRootView *rootView))configurationBlock
expectErrorBlock:(BOOL(^)(NSString *error))expectErrorBlock
{
  __weak ABI31_0_0RCTBridge *batchedBridge;
  NSNumber *rootTag;
  ABI31_0_0RCTLogFunction defaultLogFunction = ABI31_0_0RCTGetLogFunction();
  // Catch all error logs, that are equivalent to redboxes in dev mode.
  __block NSMutableArray<NSString *> *errors = nil;
  ABI31_0_0RCTSetLogFunction(^(ABI31_0_0RCTLogLevel level, ABI31_0_0RCTLogSource source, NSString *fileName, NSNumber *lineNumber, NSString *message) {
    defaultLogFunction(level, source, fileName, lineNumber, message);
    if (level >= ABI31_0_0RCTLogLevelError) {
      if (errors == nil) {
        errors = [NSMutableArray new];
      }
      [errors addObject:message];
    }
  });

  @autoreleasepool {
    ABI31_0_0RCTBridge *bridge = [[ABI31_0_0RCTBridge alloc] initWithBundleURL:_scriptURL
                                              moduleProvider:_moduleProvider
                                               launchOptions:nil];
    [bridge.devSettings setIsDebuggingRemotely:_useJSDebugger];
    batchedBridge = [bridge batchedBridge];

    UIViewController *vc = ABI31_0_0RCTSharedApplication().delegate.window.rootViewController;
    vc.view = [UIView new];

    ABI31_0_0RCTTestModule *testModule = [bridge moduleForClass:[ABI31_0_0RCTTestModule class]];
    ABI31_0_0RCTAssert(_testController != nil, @"_testController should not be nil");
    testModule.controller = _testController;
    testModule.testSelector = test;
    testModule.testSuffix = _testSuffix;

    @autoreleasepool {
      // The rootView needs to be deallocated after this @autoreleasepool block exits.
      ABI31_0_0RCTRootView *rootView = [[ABI31_0_0RCTRootView alloc] initWithBridge:bridge moduleName:moduleName initialProperties:initialProps];
#if TARGET_OS_TV
      rootView.frame = CGRectMake(0, 0, 1920, 1080); // Standard screen size for tvOS
#else
      rootView.frame = CGRectMake(0, 0, 320, 2000); // Constant size for testing on multiple devices
#endif

      rootTag = rootView.ReactABI31_0_0Tag;
      testModule.view = rootView;

      [vc.view addSubview:rootView]; // Add as subview so it doesn't get resized

      if (configurationBlock) {
        configurationBlock(rootView);
      }

      NSDate *date = [NSDate dateWithTimeIntervalSinceNow:kTestTimeoutSeconds];
      while (date.timeIntervalSinceNow > 0 && testModule.status == ABI31_0_0RCTTestStatusPending && errors == nil) {
        [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        [[NSRunLoop mainRunLoop] runMode:NSRunLoopCommonModes beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
      }

      [rootView removeFromSuperview];
      testModule.view = nil;
    }

    // From this point on catch only fatal errors.
    ABI31_0_0RCTSetLogFunction(^(ABI31_0_0RCTLogLevel level, ABI31_0_0RCTLogSource source, NSString *fileName, NSNumber *lineNumber, NSString *message) {
      defaultLogFunction(level, source, fileName, lineNumber, message);
      if (level >= ABI31_0_0RCTLogLevelFatal) {
        if (errors == nil) {
          errors = [NSMutableArray new];
        }
        [errors addObject:message];
      }
    });

#if ABI31_0_0RCT_DEV
    NSArray<UIView *> *nonLayoutSubviews = [vc.view.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id subview, NSDictionary *bindings) {
      return ![NSStringFromClass([subview class]) isEqualToString:@"_UILayoutGuide"];
    }]];

    ABI31_0_0RCTAssert(nonLayoutSubviews.count == 0, @"There shouldn't be any other views: %@", nonLayoutSubviews);
#endif

    if (expectErrorBlock) {
      ABI31_0_0RCTAssert(expectErrorBlock(errors[0]), @"Expected an error but the first one was missing or did not match.");
    } else {
      ABI31_0_0RCTAssert(errors == nil, @"RedBox errors: %@", errors);
      ABI31_0_0RCTAssert(testModule.status != ABI31_0_0RCTTestStatusPending, @"Test didn't finish within %0.f seconds", kTestTimeoutSeconds);
      ABI31_0_0RCTAssert(testModule.status == ABI31_0_0RCTTestStatusPassed, @"Test failed");
    }

    // Wait for the rootView to be deallocated completely before invalidating the bridge.
    ABI31_0_0RCTUIManager *uiManager = [bridge moduleForClass:[ABI31_0_0RCTUIManager class]];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:5];
    while (date.timeIntervalSinceNow > 0 && [uiManager viewForReactABI31_0_0Tag:rootTag]) {
      [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
      [[NSRunLoop mainRunLoop] runMode:NSRunLoopCommonModes beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    ABI31_0_0RCTAssert([uiManager viewForReactABI31_0_0Tag:rootTag] == nil, @"RootView should have been deallocated after removed.");

    [bridge invalidate];
  }

  // Wait for the bridge to disappear before continuing to the next test.
  NSDate *invalidateTimeout = [NSDate dateWithTimeIntervalSinceNow:30];
  while (invalidateTimeout.timeIntervalSinceNow > 0 && batchedBridge != nil) {
    [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    [[NSRunLoop mainRunLoop] runMode:NSRunLoopCommonModes beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
  }
  ABI31_0_0RCTAssert(errors == nil, @"RedBox errors during bridge invalidation: %@", errors);
  ABI31_0_0RCTAssert(batchedBridge == nil, @"Bridge should be deallocated after the test");

  ABI31_0_0RCTSetLogFunction(defaultLogFunction);
}

@end
