// Copyright 2016-present 650 Industries. All rights reserved.

#import <ABI32_0_0EXLocation/ABI32_0_0EXLocation.h>
#import <ABI32_0_0EXLocation/ABI32_0_0EXLocationDelegate.h>
#import <ABI32_0_0EXLocation/ABI32_0_0EXLocationTaskConsumer.h>
#import <ABI32_0_0EXLocation/ABI32_0_0EXGeofencingTaskConsumer.h>

#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <CoreLocation/CLHeading.h>
#import <CoreLocation/CLGeocoder.h>
#import <CoreLocation/CLPlacemark.h>
#import <CoreLocation/CLError.h>
#import <CoreLocation/CLCircularRegion.h>

#import <ABI32_0_0EXCore/ABI32_0_0EXEventEmitterService.h>
#import <ABI32_0_0EXCore/ABI32_0_0EXAppLifecycleService.h>
#import <ABI32_0_0EXPermissionsInterface/ABI32_0_0EXPermissionsInterface.h>
#import <ABI32_0_0EXTaskManagerInterface/ABI32_0_0EXTaskManagerInterface.h>

NS_ASSUME_NONNULL_BEGIN

NSString * const ABI32_0_0EXLocationChangedEventName = @"Exponent.locationChanged";
NSString * const ABI32_0_0EXHeadingChangedEventName = @"Exponent.headingChanged";

@interface ABI32_0_0EXLocation ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, ABI32_0_0EXLocationDelegate*> *delegates;
@property (nonatomic, strong) NSMutableSet<ABI32_0_0EXLocationDelegate *> *retainedDelegates;
@property (nonatomic, assign, getter=isPaused) BOOL paused;
@property (nonatomic, weak) id<ABI32_0_0EXEventEmitterService> eventEmitter;
@property (nonatomic, weak) id<ABI32_0_0EXPermissionsInterface> permissions;
@property (nonatomic, weak) id<ABI32_0_0EXAppLifecycleService> lifecycleService;
@property (nonatomic, weak) id<ABI32_0_0EXTaskManagerInterface> tasksManager;

@end

@implementation ABI32_0_0EXLocation

ABI32_0_0EX_EXPORT_MODULE(ExpoLocation);

- (instancetype)init
{
  if (self = [super init]) {
    _delegates = [NSMutableDictionary dictionary];
    _retainedDelegates = [NSMutableSet set];
  }
  return self;
}

- (void)setModuleRegistry:(ABI32_0_0EXModuleRegistry *)moduleRegistry
{
  if (_lifecycleService) {
    [_lifecycleService unregisterAppLifecycleListener:self];
  }

  _eventEmitter = [moduleRegistry getModuleImplementingProtocol:@protocol(ABI32_0_0EXEventEmitterService)];
  _permissions = [moduleRegistry getModuleImplementingProtocol:@protocol(ABI32_0_0EXPermissionsInterface)];
  _lifecycleService = [moduleRegistry getModuleImplementingProtocol:@protocol(ABI32_0_0EXAppLifecycleService)];
  _tasksManager = [moduleRegistry getModuleImplementingProtocol:@protocol(ABI32_0_0EXTaskManagerInterface)];

  if (_lifecycleService) {
    [_lifecycleService registerAppLifecycleListener:self];
  }
}

- (dispatch_queue_t)methodQueue
{
  // Location managers must be created on the main thread
  return dispatch_get_main_queue();
}

# pragma mark - ABI32_0_0EXEventEmitter

- (NSArray<NSString *> *)supportedEvents
{
  return @[ABI32_0_0EXLocationChangedEventName, ABI32_0_0EXHeadingChangedEventName];
}

- (void)startObserving {}
- (void)stopObserving {}

# pragma mark - Exported methods

ABI32_0_0EX_EXPORT_METHOD_AS(getProviderStatusAsync,
                    resolver:(ABI32_0_0EXPromiseResolveBlock)resolve
                    rejecter:(ABI32_0_0EXPromiseRejectBlock)reject)
{
  resolve(@{
            @"locationServicesEnabled": @([CLLocationManager locationServicesEnabled]),
            @"backgroundModeEnabled": @([_tasksManager hasBackgroundModeEnabled:@"location"]),
            });
}


ABI32_0_0EX_EXPORT_METHOD_AS(getCurrentPositionAsync,
                    options:(NSDictionary *)options
                    resolver:(ABI32_0_0EXPromiseResolveBlock)resolve
                    rejecter:(ABI32_0_0EXPromiseRejectBlock)reject)
{
  if (![self checkPermissions:reject]) {
    return;
  }

  CLLocationManager *locMgr = [self locationManagerWithOptions:options];

  __weak typeof(self) weakSelf = self;
  __block ABI32_0_0EXLocationDelegate *delegate;

  delegate = [[ABI32_0_0EXLocationDelegate alloc] initWithId:nil withLocMgr:locMgr onUpdateLocations:^(NSArray<CLLocation *> * _Nonnull locations) {
    if (delegate != nil) {
      if (locations.lastObject != nil) {
        resolve([ABI32_0_0EXLocation exportLocation:locations.lastObject]);
      } else {
        reject(@"E_LOCATION_NOT_FOUND", @"Current location not found.", nil);
      }
      [weakSelf.retainedDelegates removeObject:delegate];
      delegate = nil;
    }
  } onUpdateHeadings:nil onError:nil];

  // retain location manager delegate so it will not dealloc until onUpdateLocations gets called
  [_retainedDelegates addObject:delegate];

  locMgr.delegate = delegate;
  [locMgr requestLocation];
}

ABI32_0_0EX_EXPORT_METHOD_AS(watchPositionImplAsync,
                    watchId:(nonnull NSNumber *)watchId
                    options:(NSDictionary *)options
                    resolver:(ABI32_0_0EXPromiseResolveBlock)resolve
                    rejecter:(ABI32_0_0EXPromiseRejectBlock)reject)
{
  if (![self checkPermissions:reject]) {
    return;
  }

  __weak typeof(self) weakSelf = self;
  CLLocationManager *locMgr = [self locationManagerWithOptions:options];

  ABI32_0_0EXLocationDelegate *delegate = [[ABI32_0_0EXLocationDelegate alloc] initWithId:watchId withLocMgr:locMgr onUpdateLocations:^(NSArray<CLLocation *> *locations) {
    if (locations.lastObject != nil && weakSelf != nil) {
      __strong typeof(weakSelf) strongSelf = weakSelf;

      CLLocation *loc = locations.lastObject;
      NSDictionary *body = @{
                             @"watchId": watchId,
                             @"location": [ABI32_0_0EXLocation exportLocation:loc],
                             };

      [strongSelf->_eventEmitter sendEventWithName:ABI32_0_0EXLocationChangedEventName body:body];
    }
  } onUpdateHeadings:nil onError:^(NSError *error) {
    // TODO: report errors
    // (ben) error could be (among other things):
    //   - kCLErrorDenied - we should use the same UNAUTHORIZED behavior as elsewhere
    //   - kCLErrorLocationUnknown - we can actually ignore this error and keep tracking
    //     location (I think -- my knowledge might be a few months out of date)
  }];

  _delegates[delegate.watchId] = delegate;
  locMgr.delegate = delegate;
  [locMgr startUpdatingLocation];
  resolve([NSNull null]);
}

// Watch method for getting compass updates
ABI32_0_0EX_EXPORT_METHOD_AS(watchDeviceHeading,
                    watchHeadingWithWatchId:(nonnull NSNumber *)watchId
                    resolve:(ABI32_0_0EXPromiseResolveBlock)resolve
                    reject:(ABI32_0_0EXPromiseRejectBlock)reject) {
  if (![_permissions hasGrantedPermission:@"location"]) {
    reject(@"E_LOCATION_UNAUTHORIZED", @"Not authorized to use location services", nil);
    return;
  }

  __weak typeof(self) weakSelf = self;
  CLLocationManager *locMgr = [[CLLocationManager alloc] init];

  locMgr.distanceFilter = kCLDistanceFilterNone;
  locMgr.desiredAccuracy = kCLLocationAccuracyBest;
  locMgr.allowsBackgroundLocationUpdates = NO;

  ABI32_0_0EXLocationDelegate *delegate = [[ABI32_0_0EXLocationDelegate alloc] initWithId:watchId withLocMgr:locMgr onUpdateLocations: nil onUpdateHeadings:^(CLHeading *newHeading) {
    if (newHeading != nil && weakSelf != nil) {
      __strong typeof(weakSelf) strongSelf = weakSelf;
      NSNumber *accuracy;

      // Convert iOS heading accuracy to Android system
      // 3: high accuracy, 2: medium, 1: low, 0: none
      if (newHeading.headingAccuracy > 50 || newHeading.headingAccuracy < 0) {
        accuracy = @(0);
      } else if (newHeading.headingAccuracy > 35) {
        accuracy = @(1);
      } else if (newHeading.headingAccuracy > 20) {
        accuracy = @(2);
      } else {
        accuracy = @(3);
      }
      NSDictionary *body = @{@"watchId": watchId,
                             @"heading": @{
                                 @"trueHeading": @(newHeading.trueHeading),
                                 @"magHeading": @(newHeading.magneticHeading),
                                 @"accuracy": accuracy,
                                 },
                             };
      [strongSelf->_eventEmitter sendEventWithName:ABI32_0_0EXHeadingChangedEventName body:body];
    }
  } onError:^(NSError *error) {
    // Error getting updates
  }];

  _delegates[delegate.watchId] = delegate;
  locMgr.delegate = delegate;
  [locMgr startUpdatingHeading];
  resolve([NSNull null]);
}

ABI32_0_0EX_EXPORT_METHOD_AS(removeWatchAsync,
                    watchId:(nonnull NSNumber *)watchId
                    resolver:(ABI32_0_0EXPromiseResolveBlock)resolve
                    rejecter:(ABI32_0_0EXPromiseRejectBlock)reject)
{
  ABI32_0_0EXLocationDelegate *delegate = _delegates[watchId];

  if (delegate) {
    // Unsuscribe from both location and heading updates
    [delegate.locMgr stopUpdatingLocation];
    [delegate.locMgr stopUpdatingHeading];
    delegate.locMgr.delegate = nil;
    [_delegates removeObjectForKey:watchId];
  }
  resolve([NSNull null]);
}

ABI32_0_0EX_EXPORT_METHOD_AS(geocodeAsync,
                    address:(nonnull NSString *)address
                    resolver:(ABI32_0_0EXPromiseResolveBlock)resolve
                    rejecter:(ABI32_0_0EXPromiseRejectBlock)reject)
{
  if ([self isPaused]) {
    return;
  }

  CLGeocoder *geocoder = [[CLGeocoder alloc] init];

  [geocoder geocodeAddressString:address completionHandler:^(NSArray* placemarks, NSError* error){
    if (!error) {
      NSMutableArray *results = [NSMutableArray arrayWithCapacity:placemarks.count];
      for (CLPlacemark* placemark in placemarks) {
        CLLocation *location = placemark.location;
        [results addObject:@{
                             @"latitude": @(location.coordinate.latitude),
                             @"longitude": @(location.coordinate.longitude),
                             @"altitude": @(location.altitude),
                             @"accuracy": @(location.horizontalAccuracy),
                             }];
      }
      resolve(results);
    } else if (error.code == kCLErrorGeocodeFoundNoResult || error.code == kCLErrorGeocodeFoundPartialResult) {
      resolve(@[]);
    } else if (error.code == kCLErrorNetwork) {
      reject(@"E_RATE_EXCEEDED", @"Rate limit exceeded - too many requests", error);
    } else {
      reject(@"E_GEOCODING_FAILED", @"Error while geocoding an address", error);
    }
  }];
}

ABI32_0_0EX_EXPORT_METHOD_AS(reverseGeocodeAsync,
                    locationMap:(nonnull NSDictionary *)locationMap
                    resolver:(ABI32_0_0EXPromiseResolveBlock)resolve
                    rejecter:(ABI32_0_0EXPromiseRejectBlock)reject)
{
  if ([self isPaused]) {
    return;
  }

  CLGeocoder *geocoder = [[CLGeocoder alloc] init];
  CLLocation *location = [[CLLocation alloc] initWithLatitude:[locationMap[@"latitude"] floatValue] longitude:[locationMap[@"longitude"] floatValue]];

  [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray* placemarks, NSError* error){
    if (!error) {
      NSMutableArray *results = [NSMutableArray arrayWithCapacity:placemarks.count];
      for (CLPlacemark* placemark in placemarks) {
        NSDictionary *address = @{
                                  @"city": placemark.locality ?: [NSNull null],
                                  @"street": placemark.thoroughfare ?: [NSNull null],
                                  @"region": placemark.administrativeArea ?: [NSNull null],
                                  @"country": placemark.country ?: [NSNull null],
                                  @"postalCode": placemark.postalCode ?: [NSNull null],
                                  @"name": placemark.name ?: [NSNull null],
                                  @"isoCountryCode": placemark.ISOcountryCode ?: [NSNull null],
                                  };
        [results addObject:address];
      }
      resolve(results);
    } else if (error.code == kCLErrorGeocodeFoundNoResult || error.code == kCLErrorGeocodeFoundPartialResult) {
      resolve(@[]);
    } else if (error.code == kCLErrorNetwork) {
      reject(@"E_RATE_EXCEEDED", @"Rate limit exceeded - too many requests", error);
    } else {
      reject(@"E_REVGEOCODING_FAILED", @"Error while reverse-geocoding a location", error);
    }
  }];
}

ABI32_0_0EX_EXPORT_METHOD_AS(requestPermissionsAsync,
                    requestPermissionsResolver:(ABI32_0_0EXPromiseResolveBlock)resolve
                                      rejecter:(ABI32_0_0EXPromiseRejectBlock)reject)
{
  if (_permissions == nil) {
    return reject(@"E_NO_PERMISSIONS", @"Permissions module is null. Are you sure all the installed Expo modules are properly linked?", nil);
  }
  
  [_permissions askForPermission:@"location"
                      withResult:^(BOOL result){
                        if (!result) {
                          return reject(@"E_LOCATION_UNAUTHORIZED", @"Not authorized to use location services", nil);
                        }
                        resolve(nil);
                      }
                    withRejecter:reject];
}

ABI32_0_0EX_EXPORT_METHOD_AS(hasServicesEnabledAsync,
                    hasServicesEnabled:(ABI32_0_0EXPromiseResolveBlock)resolve
                    reject:(ABI32_0_0EXPromiseRejectBlock)reject)
{
  BOOL servicesEnabled = [CLLocationManager locationServicesEnabled];
  resolve(@(servicesEnabled));
}

# pragma mark - Background location

ABI32_0_0EX_EXPORT_METHOD_AS(startLocationUpdatesAsync,
                    startLocationUpdatesForTaskWithName:(nonnull NSString *)taskName
                    withOptions:(nonnull NSDictionary *)options
                    resolve:(ABI32_0_0EXPromiseResolveBlock)resolve
                    reject:(ABI32_0_0EXPromiseRejectBlock)reject)
{
  if (![self checkPermissions:reject] || ![self checkBackgroundServices:reject]) {
    return;
  }
  if (![CLLocationManager significantLocationChangeMonitoringAvailable]) {
    return reject(@"E_SIGNIFICANT_CHANGES_UNAVAILABLE", @"Significant location changes monitoring is not available.", nil);
  }

  @try {
    [_tasksManager registerTaskWithName:taskName consumer:[ABI32_0_0EXLocationTaskConsumer class] options:options];
  }
  @catch (NSException *e) {
    return reject(e.name, e.reason, nil);
  }
  resolve(nil);
}

ABI32_0_0EX_EXPORT_METHOD_AS(stopLocationUpdatesAsync,
                    stopLocationUpdatesForTaskWithName:(NSString *)taskName
                    resolve:(ABI32_0_0EXPromiseResolveBlock)resolve
                    reject:(ABI32_0_0EXPromiseRejectBlock)reject)
{
  @try {
    [_tasksManager unregisterTaskWithName:taskName consumerClass:[ABI32_0_0EXLocationTaskConsumer class]];
  } @catch (NSException *e) {
    return reject(e.name, e.reason, nil);
  }
  resolve(nil);
}

ABI32_0_0EX_EXPORT_METHOD_AS(hasStartedLocationUpdatesAsync,
                    hasStartedLocationUpdatesForTaskWithName:(nonnull NSString *)taskName
                    resolve:(ABI32_0_0EXPromiseResolveBlock)resolve
                    reject:(ABI32_0_0EXPromiseRejectBlock)reject)
{
  resolve(@([_tasksManager taskWithName:taskName hasConsumerOfClass:[ABI32_0_0EXLocationTaskConsumer class]]));
}

# pragma mark - Geofencing

ABI32_0_0EX_EXPORT_METHOD_AS(startGeofencingAsync,
                    startGeofencingWithTaskName:(nonnull NSString *)taskName
                    withOptions:(nonnull NSDictionary *)options
                    resolve:(ABI32_0_0EXPromiseResolveBlock)resolve
                    reject:(ABI32_0_0EXPromiseRejectBlock)reject)
{
  if (![self checkPermissions:reject] || ![self checkBackgroundServices:reject]) {
    return;
  }
  if (![CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
    return reject(@"E_GEOFENCING_UNAVAILABLE", @"Geofencing is not available", nil);
  }

  @try {
    [_tasksManager registerTaskWithName:taskName consumer:[ABI32_0_0EXGeofencingTaskConsumer class] options:options];
  } @catch (NSException *e) {
    return reject(e.name, e.reason, nil);
  }
  resolve(nil);
}

ABI32_0_0EX_EXPORT_METHOD_AS(stopGeofencingAsync,
                    stopGeofencingWithTaskName:(nonnull NSString *)taskName
                    resolve:(ABI32_0_0EXPromiseResolveBlock)resolve
                    reject:(ABI32_0_0EXPromiseRejectBlock)reject)
{
  if (![self checkBackgroundServices:reject]) {
    return;
  }

  @try {
    [_tasksManager unregisterTaskWithName:taskName consumerClass:[ABI32_0_0EXGeofencingTaskConsumer class]];
  } @catch (NSException *e) {
    return reject(e.name, e.reason, nil);
  }
  resolve(nil);
}

ABI32_0_0EX_EXPORT_METHOD_AS(hasStartedGeofencingAsync,
                    hasStartedGeofencingForTaskWithName:(NSString *)taskName
                    resolve:(ABI32_0_0EXPromiseResolveBlock)resolve
                    reject:(ABI32_0_0EXPromiseRejectBlock)reject)
{
  resolve(@([_tasksManager taskWithName:taskName hasConsumerOfClass:[ABI32_0_0EXGeofencingTaskConsumer class]]));
}

# pragma mark - helpers

- (CLLocationManager *)locationManagerWithOptions:(NSDictionary *)options
{
  CLLocationManager *locMgr = [[CLLocationManager alloc] init];

  locMgr.distanceFilter = options[@"distanceInterval"] ? [options[@"distanceInterval"] doubleValue] ?: kCLDistanceFilterNone : kCLLocationAccuracyHundredMeters;
  locMgr.desiredAccuracy = [options[@"enableHighAccuracy"] boolValue] ? kCLLocationAccuracyBest : kCLLocationAccuracyHundredMeters;
  locMgr.allowsBackgroundLocationUpdates = NO;

  if (options[@"accuracy"]) {
    ABI32_0_0EXLocationAccuracy accuracy = [options[@"accuracy"] unsignedIntegerValue] ?: ABI32_0_0EXLocationAccuracyBalanced;
    locMgr.desiredAccuracy = [self.class CLLocationAccuracyFromOption:accuracy];
  }
  return locMgr;
}

- (BOOL)checkPermissions:(ABI32_0_0EXPromiseRejectBlock)reject
{
  if (![CLLocationManager locationServicesEnabled]) {
    reject(@"E_LOCATION_SERVICES_DISABLED", @"Location services are disabled", nil);
    return NO;
  }
  if (![_permissions hasGrantedPermission:@"location"]) {
    reject(@"E_NO_PERMISSIONS", @"LOCATION permission is required to do this operation.", nil);
    return NO;
  }
  return YES;
}

- (BOOL)checkBackgroundServices:(ABI32_0_0EXPromiseRejectBlock)reject
{
  if (_tasksManager == nil) {
    reject(@"E_TASKMANAGER_NOT_FOUND", @"`expo-task-manager` module is required to use background services.", nil);
    return NO;
  }
  if (![_tasksManager hasBackgroundModeEnabled:@"location"]) {
    reject(@"E_BACKGROUND_SERVICES_DISABLED", @"Background Location has not been configured. To enable it, add `location` to `UIBackgroundModes` in Info.plist file.", nil);
    return NO;
  }
  return YES;
}

# pragma mark - static helpers

+ (NSDictionary *)exportLocation:(CLLocation *)location
{
  return @{
    @"coords": @{
        @"latitude": @(location.coordinate.latitude),
        @"longitude": @(location.coordinate.longitude),
        @"altitude": @(location.altitude),
        @"accuracy": @(location.horizontalAccuracy),
        @"altitudeAccuracy": @(location.verticalAccuracy),
        @"heading": @(location.course),
        @"speed": @(location.speed),
        },
    @"timestamp": @([location.timestamp timeIntervalSince1970] * 1000),
    };
}

+ (CLLocationAccuracy)CLLocationAccuracyFromOption:(ABI32_0_0EXLocationAccuracy)accuracy
{
  switch (accuracy) {
    case ABI32_0_0EXLocationAccuracyLowest:
      return kCLLocationAccuracyThreeKilometers;
    case ABI32_0_0EXLocationAccuracyLow:
      return kCLLocationAccuracyKilometer;
    case ABI32_0_0EXLocationAccuracyBalanced:
      return kCLLocationAccuracyHundredMeters;
    case ABI32_0_0EXLocationAccuracyHigh:
      return kCLLocationAccuracyNearestTenMeters;
    case ABI32_0_0EXLocationAccuracyHighest:
      return kCLLocationAccuracyBest;
    case ABI32_0_0EXLocationAccuracyBestForNavigation:
      return kCLLocationAccuracyBestForNavigation;
    default:
      return kCLLocationAccuracyHundredMeters;
  }
}

# pragma mark - ABI32_0_0EXAppLifecycleListener

- (void)onAppForegrounded
{
  if ([self isPaused]) {
    [self setPaused:NO];
  }
}

- (void)onAppBackgrounded
{
  if (![self isPaused]) {
    [self setPaused:YES];
  }
}

@end

NS_ASSUME_NONNULL_END
