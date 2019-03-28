/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


#import "ABI32_0_0RCTFileReaderModule.h"

#import <ReactABI32_0_0/ABI32_0_0RCTBridge.h>
#import <ReactABI32_0_0/ABI32_0_0RCTConvert.h>

#import "ABI32_0_0RCTBlobManager.h"


@implementation ABI32_0_0RCTFileReaderModule

ABI32_0_0RCT_EXPORT_MODULE(FileReaderModule)

@synthesize bridge = _bridge;

ABI32_0_0RCT_EXPORT_METHOD(readAsText:(NSDictionary<NSString *, id> *)blob
                  encoding:(NSString *)encoding
                  resolve:(ABI32_0_0RCTPromiseResolveBlock)resolve
                  reject:(ABI32_0_0RCTPromiseRejectBlock)reject)
{
  ABI32_0_0RCTBlobManager *blobManager = [[self bridge] moduleForClass:[ABI32_0_0RCTBlobManager class]];
  NSData *data = [blobManager resolve:blob];

  if (data == nil) {
    reject(ABI32_0_0RCTErrorUnspecified,
           [NSString stringWithFormat:@"Unable to resolve data for blob: %@", [ABI32_0_0RCTConvert NSString:blob[@"blobId"]]], nil);
  } else {
    NSStringEncoding stringEncoding;

    if (encoding == nil) {
      stringEncoding = NSUTF8StringEncoding;
    } else {
      stringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef) encoding));
    }

    NSString *text = [[NSString alloc] initWithData:data encoding:stringEncoding];

    resolve(text);
  }
}

ABI32_0_0RCT_EXPORT_METHOD(readAsDataURL:(NSDictionary<NSString *, id> *)blob
                  resolve:(ABI32_0_0RCTPromiseResolveBlock)resolve
                  reject:(ABI32_0_0RCTPromiseRejectBlock)reject)
{
  ABI32_0_0RCTBlobManager *blobManager = [[self bridge] moduleForClass:[ABI32_0_0RCTBlobManager class]];
  NSData *data = [blobManager resolve:blob];

  if (data == nil) {
    reject(ABI32_0_0RCTErrorUnspecified,
           [NSString stringWithFormat:@"Unable to resolve data for blob: %@", [ABI32_0_0RCTConvert NSString:blob[@"blobId"]]], nil);
  } else {
    NSString *type = [ABI32_0_0RCTConvert NSString:blob[@"type"]];
    NSString *text = [NSString stringWithFormat:@"data:%@;base64,%@",
                      type != nil && [type length] > 0 ? type : @"application/octet-stream",
                      [data base64EncodedStringWithOptions:0]];

    resolve(text);
  }
}

@end
