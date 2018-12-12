/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import <ReactABI31_0_0/ABI31_0_0RCTMultipartStreamReader.h>

typedef void (^ABI31_0_0RCTMultipartDataTaskCallback)(NSInteger statusCode, NSDictionary *headers, NSData *content, NSError *error, BOOL done);

@interface ABI31_0_0RCTMultipartDataTask : NSObject

- (instancetype)initWithURL:(NSURL *)url
                partHandler:(ABI31_0_0RCTMultipartDataTaskCallback)partHandler
            progressHandler:(ABI31_0_0RCTMultipartProgressCallback)progressHandler;

- (void)startTask;

@end
