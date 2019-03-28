#import <ABI32_0_0EXCamera/ABI32_0_0EXCamera.h>
#import <ABI32_0_0EXCamera/ABI32_0_0EXCameraManager.h>
#import <ABI32_0_0EXCamera/ABI32_0_0EXCameraUtils.h>

#import <ABI32_0_0EXCore/ABI32_0_0EXUIManager.h>
#import <ABI32_0_0EXFileSystemInterface/ABI32_0_0EXFileSystemInterface.h>

@interface ABI32_0_0EXCameraManager ()

@property (nonatomic, weak) id<ABI32_0_0EXFileSystemInterface> fileSystem;
@property (nonatomic, weak) id<ABI32_0_0EXUIManager> uiManager;
@property (nonatomic, weak) ABI32_0_0EXModuleRegistry *moduleRegistry;

@end

@implementation ABI32_0_0EXCameraManager

ABI32_0_0EX_EXPORT_MODULE(ExponentCameraManager);

- (NSString *)viewName
{
  return @"ExponentCamera";
}

- (void)setModuleRegistry:(ABI32_0_0EXModuleRegistry *)moduleRegistry
{
  _moduleRegistry = moduleRegistry;
  _fileSystem = [moduleRegistry getModuleImplementingProtocol:@protocol(ABI32_0_0EXFileSystemInterface)];
  _uiManager = [moduleRegistry getModuleImplementingProtocol:@protocol(ABI32_0_0EXUIManager)];
}

- (UIView *)view
{
  return [[ABI32_0_0EXCamera alloc] initWithModuleRegistry:_moduleRegistry];
}

- (NSDictionary *)constantsToExport
{
  return @{
           @"Type" :
             @{@"front" : @(ABI32_0_0EXCameraTypeFront), @"back" : @(ABI32_0_0EXCameraTypeBack)},
           @"FlashMode" : @{
               @"off" : @(ABI32_0_0EXCameraFlashModeOff),
               @"on" : @(ABI32_0_0EXCameraFlashModeOn),
               @"auto" : @(ABI32_0_0EXCameraFlashModeAuto),
               @"torch" : @(ABI32_0_0EXCameraFlashModeTorch)
               },
           @"AutoFocus" :
             @{@"on" : @(ABI32_0_0EXCameraAutoFocusOn), @"off" : @(ABI32_0_0EXCameraAutoFocusOff)},
           @"WhiteBalance" : @{
               @"auto" : @(ABI32_0_0EXCameraWhiteBalanceAuto),
               @"sunny" : @(ABI32_0_0EXCameraWhiteBalanceSunny),
               @"cloudy" : @(ABI32_0_0EXCameraWhiteBalanceCloudy),
               @"shadow" : @(ABI32_0_0EXCameraWhiteBalanceShadow),
               @"incandescent" : @(ABI32_0_0EXCameraWhiteBalanceIncandescent),
               @"fluorescent" : @(ABI32_0_0EXCameraWhiteBalanceFluorescent)
               },
           @"VideoQuality": @{
               @"2160p": @(ABI32_0_0EXCameraVideo2160p),
               @"1080p": @(ABI32_0_0EXCameraVideo1080p),
               @"720p": @(ABI32_0_0EXCameraVideo720p),
               @"480p": @(ABI32_0_0EXCameraVideo4x3),
               @"4:3": @(ABI32_0_0EXCameraVideo4x3),
               },
           @"VideoStabilization": @{
               @"off": @(ABI32_0_0EXCameraVideoStabilizationModeOff),
               @"standard": @(ABI32_0_0EXCameraVideoStabilizationModeStandard),
               @"cinematic": @(ABI32_0_0EXCameraVideoStabilizationModeCinematic),
               @"auto": @(ABI32_0_0EXCameraAVCaptureVideoStabilizationModeAuto)
               },
           };
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[
           @"onCameraReady",
           @"onMountError",
           @"onPictureSaved",
           @"onBarCodeScanned",
           @"onFacesDetected",
           ];
}

+ (NSDictionary *)pictureSizes
{
  return @{
           @"3840x2160" : AVCaptureSessionPreset3840x2160,
           @"1920x1080" : AVCaptureSessionPreset1920x1080,
           @"1280x720" : AVCaptureSessionPreset1280x720,
           @"640x480" : AVCaptureSessionPreset640x480,
           @"352x288" : AVCaptureSessionPreset352x288,
           @"Photo" : AVCaptureSessionPresetPhoto,
           @"High" : AVCaptureSessionPresetHigh,
           @"Medium" : AVCaptureSessionPresetMedium,
           @"Low" : AVCaptureSessionPresetLow
           };
}

ABI32_0_0EX_VIEW_PROPERTY(type, NSNumber *, ABI32_0_0EXCamera)
{
  long longValue = [value longValue];
  if (view.presetCamera != longValue) {
    [view setPresetCamera:longValue];
    [view updateType];
  }
}

ABI32_0_0EX_VIEW_PROPERTY(flashMode, NSNumber *, ABI32_0_0EXCamera)
{
  long longValue = [value longValue];
  if (longValue != view.flashMode) {
    [view setFlashMode:longValue];
    [view updateFlashMode];
  }
}

ABI32_0_0EX_VIEW_PROPERTY(faceDetectorSettings, NSDictionary *, ABI32_0_0EXCamera)
{
  [view updateFaceDetectorSettings:value];
}

ABI32_0_0EX_VIEW_PROPERTY(barCodeScannerSettings, NSDictionary *, ABI32_0_0EXCamera)
{
  [view setBarCodeScannerSettings:value];
}

ABI32_0_0EX_VIEW_PROPERTY(autoFocus, NSNumber *, ABI32_0_0EXCamera)
{
  long longValue = [value longValue];
  if (longValue != view.autoFocus) {
    [view setAutoFocus:longValue];
    [view updateFocusMode];
  }
}

ABI32_0_0EX_VIEW_PROPERTY(focusDepth, NSNumber *, ABI32_0_0EXCamera)
{
  float floatValue = [value floatValue];
  if (fabsf(view.focusDepth - floatValue) > FLT_EPSILON) {
    [view setFocusDepth:floatValue];
    [view updateFocusDepth];
  }
}

ABI32_0_0EX_VIEW_PROPERTY(zoom, NSNumber *, ABI32_0_0EXCamera)
{
  double doubleValue = [value doubleValue];
  if (fabs(view.zoom - doubleValue) > DBL_EPSILON) {
    [view setZoom:doubleValue];
    [view updateZoom];
  }
}

ABI32_0_0EX_VIEW_PROPERTY(whiteBalance, NSNumber *, ABI32_0_0EXCamera)
{
  long longValue = [value longValue];
  if (longValue != view.whiteBalance) {
    [view setWhiteBalance:longValue];
    [view updateWhiteBalance];
  }
}

ABI32_0_0EX_VIEW_PROPERTY(pictureSize, NSString *, ABI32_0_0EXCamera) {
  [view setPictureSize:[[self class] pictureSizes][value]];
  [view updatePictureSize];
}

ABI32_0_0EX_VIEW_PROPERTY(faceDetectorEnabled, NSNumber *, ABI32_0_0EXCamera)
{
  bool boolValue = [value boolValue];
  if ([view isDetectingFaces] != boolValue) {
    [view setIsDetectingFaces:boolValue];
  }
}

ABI32_0_0EX_VIEW_PROPERTY(barCodeScannerEnabled, NSNumber *, ABI32_0_0EXCamera)
{
  bool boolValue = [value boolValue];
  if ([view isScanningBarCodes] != boolValue) {
    [view setIsScanningBarCodes:boolValue];
  }
}

ABI32_0_0EX_EXPORT_METHOD_AS(takePicture,
                    takePictureWithOptions:(NSDictionary *)options
                    ReactABI32_0_0Tag:(nonnull NSNumber *)ReactABI32_0_0Tag
                    resolver:(ABI32_0_0EXPromiseResolveBlock)resolve
                    rejecter:(ABI32_0_0EXPromiseRejectBlock)reject)
{
#if TARGET_IPHONE_SIMULATOR
  __weak ABI32_0_0EXCameraManager *weakSelf = self;
#endif
  [_uiManager addUIBlock:^(id view) {
    if (view != nil) {
#if TARGET_IPHONE_SIMULATOR
      __strong ABI32_0_0EXCameraManager *strongSelf = weakSelf;
      if (!strongSelf.fileSystem) {
        reject(@"E_IMAGE_SAVE_FAILED", @"No filesystem module", nil);
        return;
      }
    
      NSString *path = [strongSelf.fileSystem generatePathInDirectory:[strongSelf.fileSystem.cachesDirectory stringByAppendingPathComponent:@"Camera"] withExtension:@".jpg"];

      UIImage *generatedPhoto = [ABI32_0_0EXCameraUtils generatePhotoOfSize:CGSizeMake(200, 200)];
      BOOL useFastMode = options[@"fastMode"] && [options[@"fastMode"] boolValue];
      if (useFastMode) {
        resolve(nil);
      }

      float quality = [options[@"quality"] floatValue];
      NSData *photoData = UIImageJPEGRepresentation(generatedPhoto, quality);
    
      NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
      response[@"uri"] = [ABI32_0_0EXCameraUtils writeImage:photoData toPath:path];
      response[@"width"] = @(generatedPhoto.size.width);
      response[@"height"] = @(generatedPhoto.size.height);
      if ([options[@"base64"] boolValue]) {
        response[@"base64"] = [photoData base64EncodedStringWithOptions:0];
      }
      if (useFastMode) {
        [view onPictureSaved:@{@"data": response, @"id": options[@"id"]}];
      } else {
        resolve(response);
      }
#else
      [view takePicture:options resolve:resolve reject:reject];
#endif
    } else {
      NSString *reason = [NSString stringWithFormat:@"Invalid view returned from registry, expected ABI32_0_0EXCamera, got: %@", view];
      reject(@"E_INVALID_VIEW", reason, nil);
    }
  } forView:ReactABI32_0_0Tag ofClass:[ABI32_0_0EXCamera class]];

}

ABI32_0_0EX_EXPORT_METHOD_AS(record,
                    recordWithOptions:(NSDictionary *)options
                    ReactABI32_0_0Tag:(nonnull NSNumber *)ReactABI32_0_0Tag
                    resolver:(ABI32_0_0EXPromiseResolveBlock)resolve
                    rejecter:(ABI32_0_0EXPromiseRejectBlock)reject)
{
#if TARGET_IPHONE_SIMULATOR
  reject(@"E_RECORDING_FAILED", @"Video recording is not supported on a simulator.", nil);
  return;
#endif
  [_uiManager addUIBlock:^(id view) {
    if (view != nil) {
      [view record:options resolve:resolve reject:reject];
    } else {
      NSString *reason = [NSString stringWithFormat:@"Invalid view returned from registry, expected ABI32_0_0EXCamera, got: %@", view];
      reject(@"E_INVALID_VIEW", reason, nil);
    }
  } forView:ReactABI32_0_0Tag ofClass:[ABI32_0_0EXCamera class]];
}

ABI32_0_0EX_EXPORT_METHOD_AS(stopRecording,
                    stopRecordingOfReactABI32_0_0Tag:(nonnull NSNumber *)ReactABI32_0_0Tag
                    resolver:(ABI32_0_0EXPromiseResolveBlock)resolve
                    rejecter:(ABI32_0_0EXPromiseRejectBlock)reject)
{
  [_uiManager addUIBlock:^(id view) {
    if (view != nil) {
      [view stopRecording];
      resolve(nil);
    } else {
      ABI32_0_0EXLogError(@"Invalid view returned from registry, expected ABI32_0_0EXCamera, got: %@", view);
    }
  } forView:ReactABI32_0_0Tag ofClass:[ABI32_0_0EXCamera class]];
}

ABI32_0_0EX_EXPORT_METHOD_AS(resumePreview,
                    resumePreview:(nonnull NSNumber *)tag
                         resolver:(ABI32_0_0EXPromiseResolveBlock)resolve
                         rejecter:(ABI32_0_0EXPromiseRejectBlock)reject)
{
#if TARGET_IPHONE_SIMULATOR
  reject(@"E_SIM_PREVIEW", @"Resuming preview is not supported on simulator.", nil);
  return;
#endif
  [_uiManager addUIBlock:^(id view) {
    if (view != nil) {
      [view resumePreview];
      resolve(nil);
    } else {
      ABI32_0_0EXLogError(@"Invalid view returned from registry, expected ABI32_0_0EXCamera, got: %@", view);
    }
  } forView:tag ofClass:[ABI32_0_0EXCamera class]];
}

ABI32_0_0EX_EXPORT_METHOD_AS(pausePreview,
                    pausePreview:(nonnull NSNumber *)tag
                        resolver:(ABI32_0_0EXPromiseResolveBlock)resolve
                         rejecter:(ABI32_0_0EXPromiseRejectBlock)reject)
{
#if TARGET_IPHONE_SIMULATOR
  reject(@"E_SIM_PREVIEW", @"Pausing preview is not supported on simulator.", nil);
  return;
#endif
  [_uiManager addUIBlock:^(id view) {
    if (view != nil) {
      [view pausePreview];
      resolve(nil);
    } else {
      ABI32_0_0EXLogError(@"Invalid view returned from registry, expected ABI32_0_0EXCamera, got: %@", view);
    }
  } forView:tag ofClass:[ABI32_0_0EXCamera class]];
}

ABI32_0_0EX_EXPORT_METHOD_AS(getAvailablePictureSizes,
                     getAvailablePictureSizesWithRatio:(NSString *)ratio
                                                   tag:(nonnull NSNumber *)tag
                                              resolver:(ABI32_0_0EXPromiseResolveBlock)resolve
                                              rejecter:(ABI32_0_0EXPromiseRejectBlock)reject)
{
  resolve([[[self class] pictureSizes] allKeys]);
}

@end
