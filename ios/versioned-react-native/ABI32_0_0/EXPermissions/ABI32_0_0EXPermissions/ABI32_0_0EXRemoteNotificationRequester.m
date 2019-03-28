// Copyright 2016-present 650 Industries. All rights reserved.

#import <ABI32_0_0EXPermissions/ABI32_0_0EXRemoteNotificationRequester.h>
#import <ABI32_0_0EXCore/ABI32_0_0EXUtilities.h>
#import <ABI32_0_0EXPermissions/ABI32_0_0EXUserNotificationRequester.h>

NSString * const ABI32_0_0EXAppDidRegisterForRemoteNotificationsNotificationName = @"kEXAppDidRegisterForRemoteNotificationsNotification";

@interface ABI32_0_0EXRemoteNotificationRequester ()

@property (nonatomic, strong) ABI32_0_0EXPromiseResolveBlock resolve;
@property (nonatomic, strong) ABI32_0_0EXPromiseRejectBlock reject;
@property (nonatomic, weak) id<ABI32_0_0EXPermissionRequesterDelegate> delegate;
@property (nonatomic, assign) BOOL remoteNotificationsRegistrationIsPending;
@property (nonatomic, strong) ABI32_0_0EXUserNotificationRequester *localNotificationRequester;
@property (nonatomic, weak) ABI32_0_0EXModuleRegistry *moduleRegistry;

@end

@implementation ABI32_0_0EXRemoteNotificationRequester

- (instancetype)initWithModuleRegistry: (ABI32_0_0EXModuleRegistry *) moduleRegistry {
  if (self = [super init]) {
    _remoteNotificationsRegistrationIsPending = NO;
    _moduleRegistry = moduleRegistry;
  }
  return self;
}

+ (NSDictionary *)permissionsWithModuleRegistry:(ABI32_0_0EXModuleRegistry *)moduleRegistry
{
  __block ABI32_0_0EXPermissionStatus status;
  [ABI32_0_0EXUtilities performSynchronouslyOnMainThread:^{
    status = (ABI32_0_0EXSharedApplication().isRegisteredForRemoteNotifications) ?
    ABI32_0_0EXPermissionStatusGranted :
    ABI32_0_0EXPermissionStatusUndetermined;
  }];
  NSMutableDictionary *permissions = [[ABI32_0_0EXUserNotificationRequester permissionsWithModuleRegistry:moduleRegistry] mutableCopy];
  [permissions setValuesForKeysWithDictionary:@{
                                                @"status": [ABI32_0_0EXPermissions permissionStringForStatus:status],
                                                @"expires": ABI32_0_0EXPermissionExpiresNever,
                                                }];
  return permissions;
}

- (void)requestPermissionsWithResolver:(ABI32_0_0EXPromiseResolveBlock)resolve rejecter:(ABI32_0_0EXPromiseRejectBlock)reject
{
  if (_resolve != nil || _reject != nil) {
    reject(@"E_AWAIT_PROMISE", @"Another request for the same permission is already being handled.", nil);
    return;
  }

  _resolve = resolve;
  _reject = reject;

  BOOL __block isRegisteredForRemoteNotifications = NO;
  [ABI32_0_0EXUtilities performSynchronouslyOnMainThread:^{
    isRegisteredForRemoteNotifications = ABI32_0_0EXSharedApplication().isRegisteredForRemoteNotifications;
  }];

  if (isRegisteredForRemoteNotifications) {
    // resolve immediately if already registered
    [self _maybeConsumeResolverWithCurrentPermissions];
  } else {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_handleDidRegisterForRemoteNotifications:)
                                                 name:ABI32_0_0EXAppDidRegisterForRemoteNotificationsNotificationName
                                               object:nil];
    _localNotificationRequester = [[ABI32_0_0EXUserNotificationRequester alloc] initWithModuleRegistry:_moduleRegistry];
    [_localNotificationRequester setDelegate:self];
    [_localNotificationRequester requestPermissionsWithResolver:nil rejecter:nil];
    _remoteNotificationsRegistrationIsPending = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
      [ABI32_0_0EXSharedApplication() registerForRemoteNotifications];
    });
  }
}

- (void)setDelegate:(id<ABI32_0_0EXPermissionRequesterDelegate>)delegate
{
  _delegate = delegate;
}

- (void)dealloc
{
  [self _clearObserver];
}

- (void)_handleDidRegisterForRemoteNotifications:(__unused NSNotification *)notif
{
  [self _clearObserver];
  id<ABI32_0_0EXPermissionsModule> permissionsModule = [_moduleRegistry getModuleImplementingProtocol:@protocol(ABI32_0_0EXPermissionsModule)];
  NSAssert(permissionsModule, @"Permissions module is required to properly consume result.");
  __weak typeof(self) weakSelf = self;
  dispatch_async(permissionsModule.methodQueue, ^{
    [weakSelf _maybeConsumeResolverWithCurrentPermissions];
  });
}

- (void)_clearObserver
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  _remoteNotificationsRegistrationIsPending = NO;
}

- (void)_maybeConsumeResolverWithCurrentPermissions
{
  if (_localNotificationRequester == nil && !_remoteNotificationsRegistrationIsPending) {
    if (_resolve) {
      _resolve([[self class] permissionsWithModuleRegistry:_moduleRegistry]);
      _resolve = nil;
      _reject = nil;
    }
    if (_delegate) {
      [_delegate permissionRequesterDidFinish:self];
    }
  }
}

# pragma mark - ABI32_0_0EXPermissionRequesterDelegate

- (void)permissionRequesterDidFinish:(NSObject<ABI32_0_0EXPermissionRequester> *)requester
{
  if (requester == _localNotificationRequester) {
    _localNotificationRequester = nil;
    NSString *localNotificationsStatus = [[ABI32_0_0EXUserNotificationRequester permissionsWithModuleRegistry:_moduleRegistry] objectForKey:@"status"];
    // We may assume that `ABI32_0_0EXLocalNotificationRequester`'s permission request will always finish
    // when the user responds to the dialog or has already responded in the past.
    // However, `UIApplication.registerForRemoteNotification` results in calling
    // `application:didRegisterForRemoteNotificationsWithDeviceToken:` or
    // `application:didFailToRegisterForRemoteNotificationsWithError:` on the application delegate
    // ONLY when the notifications are enabled in settings (by allowing sound, alerts or app badge).
    // So, when the local notifications are disabled, the application delegate's callbacks will not be called instantly.
    if ([localNotificationsStatus isEqualToString:[ABI32_0_0EXPermissions permissionStringForStatus:ABI32_0_0EXPermissionStatusDenied]]) {
      [self _clearObserver];
    }
    [self _maybeConsumeResolverWithCurrentPermissions];
  }
}

@end
