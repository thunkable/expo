/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI32_0_0RCTNetInfo.h"

#if !TARGET_OS_TV
  #import <CoreTelephony/CTTelephonyNetworkInfo.h>
#endif
#import <ReactABI32_0_0/ABI32_0_0RCTAssert.h>
#import <ReactABI32_0_0/ABI32_0_0RCTBridge.h>
#import <ReactABI32_0_0/ABI32_0_0RCTEventDispatcher.h>

// Based on the ConnectionType enum described in the W3C Network Information API spec
// (https://wicg.github.io/netinfo/).
static NSString *const ABI32_0_0RCTConnectionTypeUnknown = @"unknown";
static NSString *const ABI32_0_0RCTConnectionTypeNone = @"none";
static NSString *const ABI32_0_0RCTConnectionTypeWifi = @"wifi";
static NSString *const ABI32_0_0RCTConnectionTypeCellular = @"cellular";

// Based on the EffectiveConnectionType enum described in the W3C Network Information API spec
// (https://wicg.github.io/netinfo/).
static NSString *const ABI32_0_0RCTEffectiveConnectionTypeUnknown = @"unknown";
static NSString *const ABI32_0_0RCTEffectiveConnectionType2g = @"2g";
static NSString *const ABI32_0_0RCTEffectiveConnectionType3g = @"3g";
static NSString *const ABI32_0_0RCTEffectiveConnectionType4g = @"4g";

// The ABI32_0_0RCTReachabilityState* values are deprecated.
static NSString *const ABI32_0_0RCTReachabilityStateUnknown = @"unknown";
static NSString *const ABI32_0_0RCTReachabilityStateNone = @"none";
static NSString *const ABI32_0_0RCTReachabilityStateWifi = @"wifi";
static NSString *const ABI32_0_0RCTReachabilityStateCell = @"cell";

@implementation ABI32_0_0RCTNetInfo
{
  SCNetworkReachabilityRef _firstTimeReachability;
  SCNetworkReachabilityRef _reachability;
  NSString *_connectionType;
  NSString *_effectiveConnectionType;
  NSString *_statusDeprecated;
  NSString *_host;
  BOOL _isObserving;
  ABI32_0_0RCTPromiseResolveBlock _resolve;
}

ABI32_0_0RCT_EXPORT_MODULE()

static void ABI32_0_0RCTReachabilityCallback(__unused SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info)
{
  ABI32_0_0RCTNetInfo *self = (__bridge id)info;
  BOOL didSetReachabilityFlags = [self setReachabilityStatus:flags];
  if (self->_firstTimeReachability && self->_resolve) {
    SCNetworkReachabilityUnscheduleFromRunLoop(self->_firstTimeReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    CFRelease(self->_firstTimeReachability);
    self->_resolve(@{@"connectionType": self->_connectionType ?: ABI32_0_0RCTConnectionTypeUnknown,
                     @"effectiveConnectionType": self->_effectiveConnectionType ?: ABI32_0_0RCTEffectiveConnectionTypeUnknown,
                     @"network_info": self->_statusDeprecated ?: ABI32_0_0RCTReachabilityStateUnknown});
    self->_firstTimeReachability = nil;
    self->_resolve = nil;
  }

  if (didSetReachabilityFlags && self->_isObserving) {
    [self sendEventWithName:@"networkStatusDidChange" body:@{@"connectionType": self->_connectionType,
                                                             @"effectiveConnectionType": self->_effectiveConnectionType,
                                                             @"network_info": self->_statusDeprecated}];
  }
}

#pragma mark - Lifecycle

- (instancetype)initWithHost:(NSString *)host
{
  ABI32_0_0RCTAssertParam(host);
  ABI32_0_0RCTAssert(![host hasPrefix:@"http"], @"Host value should just contain the domain, not the URL scheme.");

  if ((self = [self init])) {
    _host = [host copy];
  }
  return self;
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"networkStatusDidChange"];
}

- (void)startObserving
{
  _isObserving = YES;
  _connectionType = ABI32_0_0RCTConnectionTypeUnknown;
  _effectiveConnectionType = ABI32_0_0RCTEffectiveConnectionTypeUnknown;
  _statusDeprecated = ABI32_0_0RCTReachabilityStateUnknown;
  _reachability = [self getReachabilityRef];
}

- (void)stopObserving
{
  _isObserving = NO;
  if (_reachability) {
    SCNetworkReachabilityUnscheduleFromRunLoop(_reachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    CFRelease(_reachability);
  }
}

- (SCNetworkReachabilityRef)getReachabilityRef
{
  SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, _host.UTF8String ?: "apple.com");
  SCNetworkReachabilityContext context = { 0, ( __bridge void *)self, NULL, NULL, NULL };
  SCNetworkReachabilitySetCallback(reachability, ABI32_0_0RCTReachabilityCallback, &context);
  SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    
  return reachability;
}

- (BOOL)setReachabilityStatus:(SCNetworkReachabilityFlags)flags
{
  NSString *connectionType = ABI32_0_0RCTConnectionTypeUnknown;
  NSString *effectiveConnectionType = ABI32_0_0RCTEffectiveConnectionTypeUnknown;
  NSString *status = ABI32_0_0RCTReachabilityStateUnknown;
  if ((flags & kSCNetworkReachabilityFlagsReachable) == 0 ||
      (flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0) {
    connectionType = ABI32_0_0RCTConnectionTypeNone;
    status = ABI32_0_0RCTReachabilityStateNone;
  }
  
#if !TARGET_OS_TV
  
  else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
    connectionType = ABI32_0_0RCTConnectionTypeCellular;
    status = ABI32_0_0RCTReachabilityStateCell;
    
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    if (netinfo) {
      if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS] ||
          [netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] ||
          [netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
        effectiveConnectionType = ABI32_0_0RCTEffectiveConnectionType2g;
      } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA] ||
                 [netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA] ||
                 [netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA] ||
                 [netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
                 [netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
                 [netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||
                 [netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]) {
        effectiveConnectionType = ABI32_0_0RCTEffectiveConnectionType3g;
      } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
        effectiveConnectionType = ABI32_0_0RCTEffectiveConnectionType4g;
      }
    }
  }
  
#endif
  
  else {
    connectionType = ABI32_0_0RCTConnectionTypeWifi;
    status = ABI32_0_0RCTReachabilityStateWifi;
  }
  
  if (![connectionType isEqualToString:self->_connectionType] ||
      ![effectiveConnectionType isEqualToString:self->_effectiveConnectionType] ||
      ![status isEqualToString:self->_statusDeprecated]) {
    self->_connectionType = connectionType;
    self->_effectiveConnectionType = effectiveConnectionType;
    self->_statusDeprecated = status;
    return YES;
  }
  
  return NO;
}

#pragma mark - Public API

ABI32_0_0RCT_EXPORT_METHOD(getCurrentConnectivity:(ABI32_0_0RCTPromiseResolveBlock)resolve
                  reject:(__unused ABI32_0_0RCTPromiseRejectBlock)reject)
{
  _firstTimeReachability = [self getReachabilityRef];
  _resolve = resolve;
}

@end
