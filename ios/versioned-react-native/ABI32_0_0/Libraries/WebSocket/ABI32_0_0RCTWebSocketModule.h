/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <ReactABI32_0_0/ABI32_0_0RCTEventEmitter.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ABI32_0_0RCTWebSocketContentHandler <NSObject>

- (id)processWebsocketMessage:(id __nullable)message
                  forSocketID:(NSNumber *)socketID
                     withType:(NSString *__nonnull __autoreleasing *__nonnull)type;

@end

@interface ABI32_0_0RCTWebSocketModule : ABI32_0_0RCTEventEmitter

// Register a custom handler for a specific websocket. The handler will be strongly held by the WebSocketModule.
- (void)setContentHandler:(id<ABI32_0_0RCTWebSocketContentHandler> __nullable)handler forSocketID:(NSNumber *)socketID;

- (void)sendData:(NSData *)data forSocketID:(nonnull NSNumber *)socketID;

@end

@interface ABI32_0_0RCTBridge (ABI32_0_0RCTWebSocketModule)

- (ABI32_0_0RCTWebSocketModule *)webSocketModule;

@end

NS_ASSUME_NONNULL_END
