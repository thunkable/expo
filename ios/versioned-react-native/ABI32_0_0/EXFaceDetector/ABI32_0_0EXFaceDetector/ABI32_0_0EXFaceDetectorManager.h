//
//  ABI32_0_0EXFaceDetectorManager.h
//  Exponent
//
//  Created by Stanisław Chmiela on 22.11.2017.
//  Copyright © 2017 650 Industries. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <GoogleMobileVision/GoogleMobileVision.h>
#import <GoogleMVDataOutput/GoogleMVDataOutput.h>
#import <ABI32_0_0EXFaceDetectorInterface/ABI32_0_0EXFaceDetectorManager.h>

@interface ABI32_0_0EXFaceDetectorManager : NSObject <ABI32_0_0EXFaceDetectorManager>

- (void)setOnFacesDetected:(void (^)(NSArray<NSDictionary *> *))onFacesDetected;

- (void)setIsEnabled:(BOOL)enabled;
- (void)updateSettings:(NSDictionary *)settings;

- (void)maybeStartFaceDetectionOnSession:(AVCaptureSession *)session withPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer;
- (void)stopFaceDetection;

@end
