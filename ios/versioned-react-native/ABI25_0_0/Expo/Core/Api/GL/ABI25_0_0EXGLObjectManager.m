// Copyright 2015-present 650 Industries. All rights reserved.

#import "ABI25_0_0EXGLObjectManager.h"

@implementation ABI25_0_0EXGLObjectManager

ABI25_0_0RCT_EXPORT_MODULE(ExponentGLObjectManager);

ABI25_0_0RCT_EXPORT_METHOD(createObjectAsync:(NSDictionary *)config
                  resolver:(ABI25_0_0RCTPromiseResolveBlock)resolve
                  rejecter:(ABI25_0_0RCTPromiseRejectBlock)reject)
{
  reject(@"E_GL_UNSUPPORTED_METHOD", @"`createObjectAsync` method has been removed from SDK 25. Please use `createCameraTexture` instead after upgrading to the newer SDK version.", nil);
}

ABI25_0_0RCT_EXPORT_METHOD(destroyObjectAsync:(nonnull NSNumber *)exglObjId
                           resolver:(ABI25_0_0RCTPromiseResolveBlock)resolve
                           rejecter:(ABI25_0_0RCTPromiseRejectBlock)reject)
{
  reject(@"E_GL_UNSUPPORTED_METHOD", @"`destroyObjectAsync` is no longer supported in SDK 25. Please upgrade to the newer SDK version.", nil);
}

@end
