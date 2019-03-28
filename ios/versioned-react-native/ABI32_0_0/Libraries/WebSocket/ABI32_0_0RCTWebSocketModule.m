/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI32_0_0RCTWebSocketModule.h"

#import <objc/runtime.h>

#import <ReactABI32_0_0/ABI32_0_0RCTConvert.h>
#import <ReactABI32_0_0/ABI32_0_0RCTUtils.h>

#import "ABI32_0_0RCTSRWebSocket.h"

@implementation ABI32_0_0RCTSRWebSocket (ReactABI32_0_0)

- (NSNumber *)ReactABI32_0_0Tag
{
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setReactABI32_0_0Tag:(NSNumber *)ReactABI32_0_0Tag
{
  objc_setAssociatedObject(self, @selector(ReactABI32_0_0Tag), ReactABI32_0_0Tag, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

@interface ABI32_0_0RCTWebSocketModule () <ABI32_0_0RCTSRWebSocketDelegate>

@end

@implementation ABI32_0_0RCTWebSocketModule
{
  NSMutableDictionary<NSNumber *, ABI32_0_0RCTSRWebSocket *> *_sockets;
  NSMutableDictionary<NSNumber *, id<ABI32_0_0RCTWebSocketContentHandler>> *_contentHandlers;
}

ABI32_0_0RCT_EXPORT_MODULE()

// Used by ABI32_0_0RCTBlobModule
@synthesize methodQueue = _methodQueue;

- (NSArray *)supportedEvents
{
  return @[@"websocketMessage",
           @"websocketOpen",
           @"websocketFailed",
           @"websocketClosed"];
}

- (void)invalidate
{
  _contentHandlers = nil;
  for (ABI32_0_0RCTSRWebSocket *socket in _sockets.allValues) {
    socket.delegate = nil;
    [socket close];
  }
}

ABI32_0_0RCT_EXPORT_METHOD(connect:(NSURL *)URL protocols:(NSArray *)protocols options:(NSDictionary *)options socketID:(nonnull NSNumber *)socketID)
{
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];

  // We load cookies from sharedHTTPCookieStorage (shared with XHR and
  // fetch). To get secure cookies for wss URLs, replace wss with https
  // in the URL.
  NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:true];
  if ([components.scheme.lowercaseString isEqualToString:@"wss"]) {
    components.scheme = @"https";
  }

  // Load and set the cookie header.
  NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:components.URL];
  request.allHTTPHeaderFields = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];

  // Load supplied headers
  [options[@"headers"] enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
    [request addValue:[ABI32_0_0RCTConvert NSString:value] forHTTPHeaderField:key];
  }];

  ABI32_0_0RCTSRWebSocket *webSocket = [[ABI32_0_0RCTSRWebSocket alloc] initWithURLRequest:request protocols:protocols];
  [webSocket setDelegateDispatchQueue:_methodQueue];
  webSocket.delegate = self;
  webSocket.ReactABI32_0_0Tag = socketID;
  if (!_sockets) {
    _sockets = [NSMutableDictionary new];
  }
  _sockets[socketID] = webSocket;
  [webSocket open];
}

ABI32_0_0RCT_EXPORT_METHOD(send:(NSString *)message forSocketID:(nonnull NSNumber *)socketID)
{
  [_sockets[socketID] send:message];
}

ABI32_0_0RCT_EXPORT_METHOD(sendBinary:(NSString *)base64String forSocketID:(nonnull NSNumber *)socketID)
{
  [self sendData:[[NSData alloc] initWithBase64EncodedString:base64String options:0] forSocketID:socketID];
}

- (void)sendData:(NSData *)data forSocketID:(nonnull NSNumber *)socketID
{
  [_sockets[socketID] send:data];
}

ABI32_0_0RCT_EXPORT_METHOD(ping:(nonnull NSNumber *)socketID)
{
  [_sockets[socketID] sendPing:NULL];
}

ABI32_0_0RCT_EXPORT_METHOD(close:(nonnull NSNumber *)socketID)
{
  [_sockets[socketID] close];
  [_sockets removeObjectForKey:socketID];
}

- (void)setContentHandler:(id<ABI32_0_0RCTWebSocketContentHandler>)handler forSocketID:(NSString *)socketID
{
  if (!_contentHandlers) {
    _contentHandlers = [NSMutableDictionary new];
  }
  _contentHandlers[socketID] = handler;
}

#pragma mark - ABI32_0_0RCTSRWebSocketDelegate methods

- (void)webSocket:(ABI32_0_0RCTSRWebSocket *)webSocket didReceiveMessage:(id)message
{
  NSString *type;

  NSNumber *socketID = [webSocket ReactABI32_0_0Tag];
  id contentHandler = _contentHandlers[socketID];
  if (contentHandler) {
    message = [contentHandler processWebsocketMessage:message forSocketID:socketID withType:&type];
  } else {
    if ([message isKindOfClass:[NSData class]]) {
      type = @"binary";
      message = [message base64EncodedStringWithOptions:0];
    } else {
      type = @"text";
    }
  }

  [self sendEventWithName:@"websocketMessage" body:@{
    @"data": message,
    @"type": type,
    @"id": webSocket.ReactABI32_0_0Tag
  }];
}

- (void)webSocketDidOpen:(ABI32_0_0RCTSRWebSocket *)webSocket
{
  [self sendEventWithName:@"websocketOpen" body:@{
    @"id": webSocket.ReactABI32_0_0Tag
  }];
}

- (void)webSocket:(ABI32_0_0RCTSRWebSocket *)webSocket didFailWithError:(NSError *)error
{
  NSNumber *socketID = [webSocket ReactABI32_0_0Tag];
  _contentHandlers[socketID] = nil;
  _sockets[socketID] = nil;
  [self sendEventWithName:@"websocketFailed" body:@{
    @"message": error.localizedDescription,
    @"id": socketID
  }];
}

- (void)webSocket:(ABI32_0_0RCTSRWebSocket *)webSocket
 didCloseWithCode:(NSInteger)code
           reason:(NSString *)reason
         wasClean:(BOOL)wasClean
{
  NSNumber *socketID = [webSocket ReactABI32_0_0Tag];
  _contentHandlers[socketID] = nil;
  _sockets[socketID] = nil;
  [self sendEventWithName:@"websocketClosed" body:@{
    @"code": @(code),
    @"reason": ABI32_0_0RCTNullIfNil(reason),
    @"clean": @(wasClean),
    @"id": socketID
  }];
}

@end

@implementation ABI32_0_0RCTBridge (ABI32_0_0RCTWebSocketModule)

- (ABI32_0_0RCTWebSocketModule *)webSocketModule
{
  return [self moduleForClass:[ABI32_0_0RCTWebSocketModule class]];
}

@end
