// Copyright 2018-present 650 Industries. All rights reserved.

#import <EXFirebaseAnalytics/EXFirebaseAnalytics.h>
#import <FirebaseAnalytics/FirebaseAnalytics/FIRAnalytics.h>
#import <FirebaseCore/FIRAnalyticsConfiguration.h>
#import <EXCore/EXUtilities.h>

@implementation EXFirebaseAnalytics
EX_EXPORT_MODULE(ExpoFirebaseAnalytics);

EX_EXPORT_METHOD_AS(logEvent,
                    logEvent:(NSString *)name
                    props:(NSDictionary *)props
                    resolver:(EXPromiseResolveBlock)resolve
                    rejecter:(EXPromiseRejectBlock)reject) {
    [FIRAnalytics logEventWithName:name parameters:props];
    resolve([NSNull null]);
}

EX_EXPORT_METHOD_AS(setAnalyticsCollectionEnabled,
                    setAnalyticsCollectionEnabled:(NSNumber *)enabled
                    resolver:(EXPromiseResolveBlock)resolve
                    rejecter:(EXPromiseRejectBlock)reject) {
    [[FIRAnalyticsConfiguration sharedInstance] setAnalyticsCollectionEnabled:[enabled boolValue]];
    resolve([NSNull null]);
}

EX_EXPORT_METHOD_AS(setCurrentScreen,
                    setCurrentScreen:(NSString *)screenName
                    screenClass:(NSString *)screenClass
                    resolver:(EXPromiseResolveBlock)resolve
                    rejecter:(EXPromiseRejectBlock)reject) {
    [EXUtilities performSynchronouslyOnMainThread:^{
        [FIRAnalytics setScreenName:screenName screenClass:screenClass];
    }];
    resolve([NSNull null]);
}

EX_EXPORT_METHOD_AS(setUserId,
                    setUserId:(NSString *)userId
                    resolver:(EXPromiseResolveBlock)resolve
                    rejecter:(EXPromiseRejectBlock)reject) {
    [FIRAnalytics setUserID:userId];
    resolve([NSNull null]);
}

EX_EXPORT_METHOD_AS(setUserProperty,
                    setUserProperty:(NSString *)name
                    value:(NSString *)value
                    resolver:(EXPromiseResolveBlock)resolve
                    rejecter:(EXPromiseRejectBlock)reject) {
    [FIRAnalytics setUserPropertyString:value forName:name];
    resolve([NSNull null]);
}

EX_EXPORT_METHOD_AS(reset,
                    reset:(EXPromiseResolveBlock)resolve
                    rejecter:(EXPromiseRejectBlock)reject) {
  [FIRAnalytics resetAnalyticsData];
  resolve([NSNull null]);
}

// not implemented on iOS sdk
EX_EXPORT_METHOD_AS(setMinimumSessionDuration,
                    setMinimumSessionDuration:(nonnull NSNumber *)milliseconds
                    resolver:(EXPromiseResolveBlock)resolve
                    rejecter:(EXPromiseRejectBlock)reject) {
    resolve([NSNull null]);
}
EX_EXPORT_METHOD_AS(setSessionTimeoutDuration,
                    setSessionTimeoutDuration:(nonnull NSNumber *)milliseconds
                    resolver:(EXPromiseResolveBlock)resolve
                    rejecter:(EXPromiseRejectBlock)reject) {
    resolve([NSNull null]);
}
@end

