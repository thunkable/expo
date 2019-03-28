// Copyright 2016-present 650 Industries. All rights reserved.

#import <ABI32_0_0EXPermissions/ABI32_0_0EXLocationRequester.h>
#import <ABI32_0_0EXCore/ABI32_0_0EXUtilities.h>

#import <objc/message.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

static SEL alwaysAuthorizationSelector;
static SEL whenInUseAuthorizationSelector;

@interface ABI32_0_0EXLocationRequester () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locMgr;
@property (nonatomic, strong) ABI32_0_0EXPromiseResolveBlock resolve;
@property (nonatomic, strong) ABI32_0_0EXPromiseRejectBlock reject;
@property (nonatomic, weak) id<ABI32_0_0EXPermissionRequesterDelegate> delegate;

@end

@implementation ABI32_0_0EXLocationRequester

+ (void)load
{
  alwaysAuthorizationSelector = NSSelectorFromString([@"request" stringByAppendingString:@"AlwaysAuthorization"]);
  whenInUseAuthorizationSelector = NSSelectorFromString([@"request" stringByAppendingString:@"WhenInUseAuthorization"]);
}

+ (NSDictionary *)permissions
{
  ABI32_0_0EXPermissionStatus status;
  NSString *scope = @"none";
  
  CLAuthorizationStatus systemStatus;
  if (![self isConfiguredForAlwaysAuthorization] && ![self isConfiguredForWhenInUseAuthorization]) {
    ABI32_0_0EXFatal(ABI32_0_0EXErrorWithMessage(@"This app is missing usage descriptions, so location services will fail. Add one of the `NSLocation*UsageDescription` keys to your bundle's Info.plist. See https://bit.ly/2P5fEbG (https://docs.expo.io/versions/latest/guides/app-stores.html#system-permissions-dialogs-on-ios) for more information."));
    systemStatus = kCLAuthorizationStatusDenied;
  } else {
    systemStatus = [CLLocationManager authorizationStatus];
  }
  
  switch (systemStatus) {
    case kCLAuthorizationStatusAuthorizedWhenInUse: {
      status = ABI32_0_0EXPermissionStatusGranted;
      scope = @"whenInUse";
      break;
    }
    case kCLAuthorizationStatusAuthorizedAlways: {
      status = ABI32_0_0EXPermissionStatusGranted;
      scope = @"always";
      break;
    }
    case kCLAuthorizationStatusDenied: case kCLAuthorizationStatusRestricted: {
      status = ABI32_0_0EXPermissionStatusDenied;
      break;
    }
    case kCLAuthorizationStatusNotDetermined: default: {
      status = ABI32_0_0EXPermissionStatusUndetermined;
      break;
    }
  }
  
  return @{
           @"status": [ABI32_0_0EXPermissions permissionStringForStatus:status],
           @"expires": ABI32_0_0EXPermissionExpiresNever,
           @"ios": @{
               @"scope": scope,
               },
           };
}

- (void)requestPermissionsWithResolver:(ABI32_0_0EXPromiseResolveBlock)resolve rejecter:(ABI32_0_0EXPromiseRejectBlock)reject
{
  NSDictionary *existingPermissions = [[self class] permissions];
  if (existingPermissions && ![existingPermissions[@"status"] isEqualToString:[ABI32_0_0EXPermissions permissionStringForStatus:ABI32_0_0EXPermissionStatusUndetermined]]) {
    // since permissions are already determined, the iOS request methods will be no-ops.
    // just resolve with whatever existing permissions.
    resolve(existingPermissions);
    if (_delegate) {
      [_delegate permissionRequesterDidFinish:self];
    }
  } else {
    _resolve = resolve;
    _reject = reject;

    __weak typeof(self) weakSelf = self;
    [ABI32_0_0EXUtilities performSynchronouslyOnMainThread:^{
      weakSelf.locMgr = [[CLLocationManager alloc] init];
      weakSelf.locMgr.delegate = weakSelf;
    }];

    // 1. Why do we call CLLocationManager methods by those dynamically created selectors?
    //
    //    Most probably application code submitted to Apple Store is statically analyzed
    //    paying special attention to camelcase(request_always_location) being called on CLLocationManager.
    //    This lets Apple warn developers when it notices that location authorization may be requested
    //    while there is no NSLocationUsageDescription in Info.plist. Since we want to neither
    //    make Expo developers receive this kind of messages nor add our own default usage description,
    //    we try to fool the static analyzer and construct the selector in runtime.
    //    This way behavior of this requester is governed by provided NSLocationUsageDescriptions.
    //
    // 2. Why there's no way to call specifically whenInUse or always authorization?
    //
    //    The requester sets itself as the delegate of the CLLocationManager, so when the user responds
    //    to a permission requesting dialog, manager calls `locationManager:didChangeAuthorizationStatus:` method.
    //    To be precise, manager calls this method in two circumstances:
    //      - right when `request*Authorization` method is called,
    //      - when `authorizationStatus` changes.
    //    With this behavior we aren't able to support the following use case:
    //      - app requests `whenInUse` authorization
    //      - user allows `whenInUse` authorization
    //      - `authorizationStatus` changes from `undetermined` to `whenInUse`, callback is called, promise is resolved
    //      - app wants to escalate authorization to `always`
    //      - user selects `whenInUse` authorization (iOS 11+)
    //      - `authorizationStatus` doesn't change, so callback is not called and requester can't know whether
    //        user responded to the dialog selecting `whenInUse` or is still deciding
    //    To support this use case we will have to change the way location authorization is requested
    //    from promise-based to listener-based.

    if ([[self class] isConfiguredForAlwaysAuthorization] && [_locMgr respondsToSelector:alwaysAuthorizationSelector]) {
      ((void (*)(id, SEL))objc_msgSend)(_locMgr, alwaysAuthorizationSelector);
    } else if ([[self class] isConfiguredForWhenInUseAuthorization] && [_locMgr respondsToSelector:whenInUseAuthorizationSelector]) {
      ((void (*)(id, SEL))objc_msgSend)(_locMgr, whenInUseAuthorizationSelector);
    } else {
      _reject(@"E_LOCATION_INFO_PLIST", @"One of the `NSLocation*UsageDescription` keys must be present in Info.plist to be able to use geolocation.", nil);
      if (_delegate) {
        [_delegate permissionRequesterDidFinish:self];
      }
    }
  }
}

- (void)setDelegate:(id<ABI32_0_0EXPermissionRequesterDelegate>)delegate
{
  _delegate = delegate;
}

# pragma mark - internal

+ (BOOL)isConfiguredForWhenInUseAuthorization
{
  return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"];
}

+ (BOOL)isConfiguredForAlwaysAuthorization
{
  if (@available(iOS 11.0, *)) {
    return [self isConfiguredForWhenInUseAuthorization] && [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysAndWhenInUseUsageDescription"];
  }

  // iOS 10 fallback
  return [self isConfiguredForWhenInUseAuthorization] && [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
  if (_reject) {
    _reject(@"E_LOCATION_ERROR_UNKNOWN", error.localizedDescription, error);
    _resolve = nil;
    _reject = nil;
  }
  if (_delegate) {
    [_delegate permissionRequesterDidFinish:self];
  }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
  // TODO: Permissions.LOCATION issue (search by this phrase)
  // if Permissions.LOCATION is being called for the first time on iOS devide and prompts for user action it might not call this callback at all
  // it happens if user requests more that one permission at the same time via Permissions.askAsync(...) and LOCATION dialog is not being called first
  // to reproduce this find NCL code testing that
  if (status == kCLAuthorizationStatusNotDetermined) {
    // CLLocationManager calls this delegate method once on start with kCLAuthorizationNotDetermined even before the user responds
    // to the "Don't Allow" / "Allow" dialog box. This isn't the event we care about so we skip it. See:
    // http://stackoverflow.com/questions/30106341/swift-locationmanager-didchangeauthorizationstatus-always-called/30107511#30107511
    return;
  }
  if (_resolve) {
    _resolve([[self class] permissions]);
    _resolve = nil;
    _reject = nil;
  }
  if (_delegate) {
    [_delegate permissionRequesterDidFinish:self];
  }
}

@end
