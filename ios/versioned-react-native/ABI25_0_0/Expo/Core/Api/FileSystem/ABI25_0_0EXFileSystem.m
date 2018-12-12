// Copyright 2016-present 650 Industries. All rights reserved.

#import "ABI25_0_0EXDownloadDelegate.h"
#import "ABI25_0_0EXFileSystem.h"
#import "ABI25_0_0EXUtil.h"

#import <CommonCrypto/CommonDigest.h>
#import <ReactABI25_0_0/ABI25_0_0RCTConvert.h>

#import "ABI25_0_0EXFileSystemLocalFileHandler.h"
#import "ABI25_0_0EXFileSystemAssetLibraryHandler.h"

NSString * const ABI25_0_0EXDownloadProgressEventName = @"Exponent.downloadProgress";

@interface ABI25_0_0EXDownloadResumable : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) ABI25_0_0EXDownloadDelegate *delegate;

@end

@implementation ABI25_0_0EXDownloadResumable

- (instancetype)initWithId:(NSString *)uuid
               withSession:(NSURLSession *)session
              withDelegate:(ABI25_0_0EXDownloadDelegate *)delegate;
  {
    if ((self = [super init])) {
      _uuid = uuid;
      _session = session;
      _delegate = delegate;
    }
    return self;
  }

@end

@interface ABI25_0_0EXFileSystem ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, ABI25_0_0EXDownloadResumable*> *downloadObjects;
@property (nonatomic, weak) id<ABI25_0_0EXFileSystemScopedModuleDelegate> kernelFileSystemDelegate;

@end

ABI25_0_0EX_DEFINE_SCOPED_MODULE_GETTER(ABI25_0_0EXFileSystem, fileSystem)

@implementation NSData (ABI25_0_0EXFileSystem)

- (NSString *)md5String
{
  unsigned char digest[CC_MD5_DIGEST_LENGTH];
  CC_MD5(self.bytes, (CC_LONG) self.length, digest);
  NSMutableString *md5 = [NSMutableString stringWithCapacity:2 * CC_MD5_DIGEST_LENGTH];
  for (unsigned int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
    [md5 appendFormat:@"%02x", digest[i]];
  }
  return md5;
}

@end

@implementation ABI25_0_0EXFileSystem

ABI25_0_0EX_EXPORT_SCOPED_MODULE(ExponentFileSystem, FileSystemManager);

- (instancetype)initWithExperienceId:(NSString *)experienceId kernelServiceDelegate:(id)kernelServiceInstance params:(NSDictionary *)params
{
  if (self = [super initWithExperienceId:experienceId kernelServiceDelegate:kernelServiceInstance params:params]) {
    _kernelFileSystemDelegate = kernelServiceInstance;
    _documentDirectory = [[self class] documentDirectoryForExperienceId:self.experienceId];
    _cachesDirectory = [[self class] cachesDirectoryForExperienceId:self.experienceId];
    _downloadObjects = [NSMutableDictionary dictionary];
    [ABI25_0_0EXFileSystem ensureDirExistsWithPath:_documentDirectory];
    [ABI25_0_0EXFileSystem ensureDirExistsWithPath:_cachesDirectory];
  }
  return self;
}

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

- (NSDictionary *)constantsToExport
{
  NSString *bundleDirectory = [_kernelFileSystemDelegate bundleDirectoryForExperienceId:self.experienceId];
  return @{
    @"documentDirectory": [NSURL fileURLWithPath:_documentDirectory].absoluteString,
    @"cacheDirectory": [NSURL fileURLWithPath:_cachesDirectory].absoluteString,
    @"bundleDirectory":  bundleDirectory != nil ? [NSURL fileURLWithPath:bundleDirectory].absoluteString : [NSNull null],
    @"bundledAssets": [_kernelFileSystemDelegate bundledAssetsForExperienceId:self.experienceId] ?: [NSNull null],
  };
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[ABI25_0_0EXDownloadProgressEventName];
}

ABI25_0_0RCT_REMAP_METHOD(getInfoAsync,
                 getInfoAsyncWithURI:(NSURL *)uri
                 withOptions:(NSDictionary *)options
                 resolver:(ABI25_0_0RCTPromiseResolveBlock)resolve
                 rejecter:(ABI25_0_0RCTPromiseRejectBlock)reject)
{
  if (!([self permissionsForURI:uri] & ABI25_0_0EXFileSystemPermissionRead)) {
    reject(@"E_FILESYSTEM_PERMISSIONS",
           [NSString stringWithFormat:@"File '%@' isn't readable.", uri],
           nil);
    return;
  }

  if ([uri.scheme isEqualToString:@"file"]) {
    [ABI25_0_0EXFileSystemLocalFileHandler getInfoForFile:uri withOptions:options resolver:resolve rejecter:reject];
  } else if ([uri.scheme isEqualToString:@"assets-library"]) {
    [ABI25_0_0EXFileSystemAssetLibraryHandler getInfoForFile:uri withOptions:options resolver:resolve rejecter:reject];
  } else {
    reject(@"E_FILESYSTEM_INVALID_URI",
           [NSString stringWithFormat:@"Unsupported URI scheme for '%@'", uri],
           nil);
  }
}

ABI25_0_0RCT_REMAP_METHOD(readAsStringAsync,
                 readAsStringAsyncWithURI:(NSURL *)uri
                 withOptions:(NSDictionary *)options
                 resolver:(ABI25_0_0RCTPromiseResolveBlock)resolve
                 rejecter:(ABI25_0_0RCTPromiseRejectBlock)reject)
{
  if (!([self permissionsForURI:uri] & ABI25_0_0EXFileSystemPermissionRead)) {
    reject(@"E_FILESYSTEM_PERMISSIONS",
           [NSString stringWithFormat:@"File '%@' isn't readable.", uri],
           nil);
    return;
  }

  if ([uri.scheme isEqualToString:@"file"]) {
    NSError *error;
    NSString *string = [NSString stringWithContentsOfFile:uri.path encoding:NSUTF8StringEncoding error:&error];
    if (string) {
      resolve(string);
    } else {
      reject(@"E_FILE_NOT_READ",
             [NSString stringWithFormat:@"File '%@' could not be read.", uri],
             error);
    }
  } else {
    reject(@"E_FILESYSTEM_INVALID_URI",
           [NSString stringWithFormat:@"Unsupported URI scheme for '%@'", uri],
           nil);
  }
}

ABI25_0_0RCT_REMAP_METHOD(writeAsStringAsync,
                 writeAsStringAsyncWithURI:(NSURL *)uri
                 withString:(NSString *)string
                 withOptions:(NSDictionary *)options
                 resolver:(ABI25_0_0RCTPromiseResolveBlock)resolve
                 rejecter:(ABI25_0_0RCTPromiseRejectBlock)reject)
{
  if (!([self permissionsForURI:uri] & ABI25_0_0EXFileSystemPermissionWrite)) {
    reject(@"E_FILESYSTEM_PERMISSIONS",
           [NSString stringWithFormat:@"File '%@' isn't writable.", uri],
           nil);
    return;
  }

  if ([uri.scheme isEqualToString:@"file"]) {
    NSError *error;
    if ([string writeToFile:uri.path atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
      resolve(nil);
    } else {
      reject(@"E_FILE_NOT_WRITTEN",
             [NSString stringWithFormat:@"File '%@' could not be written.", uri],
             error);
    }
  } else {
    reject(@"E_FILESYSTEM_INVALID_URI",
           [NSString stringWithFormat:@"Unsupported URI scheme for '%@'", uri],
           nil);
  }
}

ABI25_0_0RCT_REMAP_METHOD(deleteAsync,
                 deleteAsyncWithURI:(NSURL *)uri
                 withOptions:(NSDictionary *)options
                 resolver:(ABI25_0_0RCTPromiseResolveBlock)resolve
                 rejecter:(ABI25_0_0RCTPromiseRejectBlock)reject)
{
  if (!([self permissionsForURI:[uri URLByAppendingPathComponent:@".."]] & ABI25_0_0EXFileSystemPermissionWrite)) {
    reject(@"E_FILESYSTEM_PERMISSIONS",
           [NSString stringWithFormat:@"Location '%@' isn't deletable.", uri],
           nil);
    return;
  }

  if ([uri.scheme isEqualToString:@"file"]) {
    NSString *path = uri.path;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
      NSError *error;
      if ([[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
        resolve(nil);
      } else {
        reject(@"E_FILE_NOT_DELETED",
               [NSString stringWithFormat:@"File '%@' could not be deleted.", uri],
               error);
      }
    } else {
      if (options[@"idempotent"]) {
        resolve(nil);
      } else {
        reject(@"E_FILE_NOT_FOUND",
               [NSString stringWithFormat:@"File '%@' could not be deleted because it could not be found.", uri],
               nil);
      }
    }
  } else {
    reject(@"E_FILESYSTEM_INVALID_URI",
           [NSString stringWithFormat:@"Unsupported URI scheme for '%@'", uri],
           nil);
  }
}

ABI25_0_0RCT_REMAP_METHOD(moveAsync,
                 moveAsyncWithOptions:(NSDictionary *)options
                 resolver:(ABI25_0_0RCTPromiseResolveBlock)resolve
                 rejecter:(ABI25_0_0RCTPromiseRejectBlock)reject)
{
  NSURL *from = [NSURL URLWithString:options[@"from"]];
  if (!from) {
    reject(@"E_MISSING_PARAMETER", @"Need a `from` location.", nil);
    return;
  }
  if (!([self permissionsForURI:[from URLByAppendingPathComponent:@".."]] & ABI25_0_0EXFileSystemPermissionWrite)) {
    reject(@"E_FILESYSTEM_PERMISSIONS",
           [NSString stringWithFormat:@"Location '%@' isn't movable.", from],
           nil);
    return;
  }
  NSURL *to = [NSURL URLWithString:options[@"to"]];
  if (!to) {
    reject(@"E_MISSING_PARAMETER", @"Need a `to` location.", nil);
    return;
  }
  if (!([self permissionsForURI:to] & ABI25_0_0EXFileSystemPermissionWrite)) {
    reject(@"E_FILESYSTEM_PERMISSIONS",
           [NSString stringWithFormat:@"File '%@' isn't writable.", to],
           nil);
    return;
  }

  // NOTE: The destination-delete and the move should happen atomically, but we hope for the best for now
  if ([from.scheme isEqualToString:@"file"]) {
    NSString *fromPath = [from.path stringByStandardizingPath];
    NSString *toPath = [to.path stringByStandardizingPath];
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:toPath]) {
      if (![[NSFileManager defaultManager] removeItemAtPath:toPath error:&error]) {
        reject(@"E_FILE_NOT_MOVED",
               [NSString stringWithFormat:@"File '%@' could not be moved to '%@' because a file already exists at "
                "the destination and could not be deleted.", from, to],
               error);
        return;
      }
    }
    if ([[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:&error]) {
      resolve(nil);
    } else {
      reject(@"E_FILE_NOT_MOVED",
             [NSString stringWithFormat:@"File '%@' could not be moved to '%@'.", from, to],
             error);
    }
  } else {
    reject(@"E_FILESYSTEM_INVALID_URI",
           [NSString stringWithFormat:@"Unsupported URI scheme for '%@'", from],
           nil);
  }
}

ABI25_0_0RCT_REMAP_METHOD(copyAsync,
                 copyAsyncWithOptions:(NSDictionary *)options
                 resolver:(ABI25_0_0RCTPromiseResolveBlock)resolve
                 rejecter:(ABI25_0_0RCTPromiseRejectBlock)reject)
{
  NSURL *from = [NSURL URLWithString:options[@"from"]];
  if (!from) {
    reject(@"E_MISSING_PARAMETER", @"Need a `from` location.", nil);
    return;
  }
  if (!([self permissionsForURI:from] & ABI25_0_0EXFileSystemPermissionRead)) {
    reject(@"E_FILESYSTEM_PERMISSIONS",
           [NSString stringWithFormat:@"File '%@' isn't readable.", from],
           nil);
    return;
  }
  NSURL *to = [NSURL URLWithString:options[@"to"]];
  if (!to) {
    reject(@"E_MISSING_PARAMETER", @"Need a `to` location.", nil);
    return;
  }
  if (!([self permissionsForURI:to] & ABI25_0_0EXFileSystemPermissionWrite)) {
    reject(@"E_FILESYSTEM_PERMISSIONS",
           [NSString stringWithFormat:@"File '%@' isn't writable.", to],
           nil);
    return;
  }

  if ([from.scheme isEqualToString:@"file"]) {
    [ABI25_0_0EXFileSystemLocalFileHandler copyFrom:from to:to resolver:resolve rejecter:reject];
  } else if ([from.scheme isEqualToString:@"assets-library"]) {
    [ABI25_0_0EXFileSystemAssetLibraryHandler copyFrom:from to:to resolver:resolve rejecter:reject];
  } else {
    reject(@"E_FILESYSTEM_INVALID_URI",
           [NSString stringWithFormat:@"Unsupported URI scheme for '%@'", from],
           nil);
  }
}

ABI25_0_0RCT_REMAP_METHOD(makeDirectoryAsync,
                 makeDirectoryAsyncWithURI:(NSURL *)uri
                 withOptions:(NSDictionary *)options
                 resolver:(ABI25_0_0RCTPromiseResolveBlock)resolve
                 rejecter:(ABI25_0_0RCTPromiseRejectBlock)reject)
{
  if (!([self permissionsForURI:uri] & ABI25_0_0EXFileSystemPermissionWrite)) {
    reject(@"E_FILESYSTEM_PERMISSIONS",
           [NSString stringWithFormat:@"Directory '%@' could not be created because the location isn't writable.", uri],
           nil);
    return;
  }

  if ([uri.scheme isEqualToString:@"file"]) {
    NSError *error;
    if ([[NSFileManager defaultManager] createDirectoryAtPath:uri.path
                                  withIntermediateDirectories:options[@"intermediates"]
                                                   attributes:nil
                                                        error:&error]) {
      resolve(nil);
    } else {
      reject(@"E_DIRECTORY_NOT_CREATED",
             [NSString stringWithFormat:@"Directory '%@' could not be created.", uri],
             error);
    }
  } else {
    reject(@"E_FILESYSTEM_INVALID_URI",
           [NSString stringWithFormat:@"Unsupported URI scheme for '%@'", uri],
           nil);
  }
}

ABI25_0_0RCT_REMAP_METHOD(readDirectoryAsync,
                 readDirectoryAsyncWithURI:(NSURL *)uri
                 withOptions:(NSDictionary *)options
                 resolver:(ABI25_0_0RCTPromiseResolveBlock)resolve
                 rejecter:(ABI25_0_0RCTPromiseRejectBlock)reject)
{
  if (!([self permissionsForURI:uri] & ABI25_0_0EXFileSystemPermissionRead)) {
    reject(@"E_FILESYSTEM_PERMISSIONS",
           [NSString stringWithFormat:@"Location '%@' isn't readable.", uri],
           nil);
    return;
  }

  if ([uri.scheme isEqualToString:@"file"]) {
    NSError *error;
    NSArray<NSString *> *children = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:uri.path error:&error];
    if (children) {
      resolve(children);
    } else {
      reject(@"E_DIRECTORY_NOT_READ",
             [NSString stringWithFormat:@"Directory '%@' could not be read.", uri],
             error);
    }
  } else {
    reject(@"E_FILESYSTEM_INVALID_URI",
           [NSString stringWithFormat:@"Unsupported URI scheme for '%@'", uri],
           nil);
  }
}

ABI25_0_0RCT_REMAP_METHOD(downloadAsync,
                 downloadAsyncWithUrl:(NSURL *)url
                 withLocalURI:(NSURL *)localUri
                 withOptions:(NSDictionary *)options
                 resolver:(ABI25_0_0RCTPromiseResolveBlock)resolve
                 rejecter:(ABI25_0_0RCTPromiseRejectBlock)reject)
{
  if (!([self permissionsForURI:localUri] & ABI25_0_0EXFileSystemPermissionWrite)) {
    reject(@"E_FILESYSTEM_PERMISSIONS",
           [NSString stringWithFormat:@"File '%@' isn't writable.", localUri],
           nil);
    return;
  }
  NSString *path = localUri.path;

  NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
  sessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
  sessionConfiguration.URLCache = nil;
  NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
  NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error) {
      reject(@"E_DOWNLOAD_FAILED",
             [NSString stringWithFormat:@"Could not download from '%@'", url],
             error);
      return;
    }
    [data writeToFile:path atomically:YES];

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[@"uri"] = [NSURL fileURLWithPath:path].absoluteString;
    if (options[@"md5"]) {
      result[@"md5"] = [data md5String];
    }
    result[@"status"] = @([httpResponse statusCode]);
    result[@"headers"] = [httpResponse allHeaderFields];
    resolve(result);
  }];
  [task resume];
}

ABI25_0_0RCT_REMAP_METHOD(downloadResumableStartAsync,
                 downloadResumableStartAsyncWithUrl:(NSURL *)url
                 withFileURI:(NSString *)fileUri
                 withUUID:(NSString *)uuid
                 withOptions:(NSDictionary *)options
                 withResumeData:(NSString * _Nullable)data
                 resolver:(ABI25_0_0RCTPromiseResolveBlock)resolve
                 rejecter:(ABI25_0_0RCTPromiseRejectBlock)reject)
{
  NSURL *localUrl = [NSURL URLWithString:fileUri];
  if (![localUrl.scheme isEqualToString:@"file"]) {
    reject(@"E_FILESYSTEM_PERMISSIONS",
           [NSString stringWithFormat:@"Cannot download to '%@': only 'file://' URI destinations are supported.", fileUri],
           nil);
    return;
  }

  NSString *path = localUrl.path;
  if (!([self _permissionsForPath:path] & ABI25_0_0EXFileSystemPermissionWrite)) {
    reject(@"E_FILESYSTEM_PERMISSIONS",
           [NSString stringWithFormat:@"File '%@' isn't writable.", fileUri],
           nil);
    return;
  }

  NSData *resumeData = data ? [ABI25_0_0RCTConvert NSData:data]:nil;
  [self _downloadResumableCreateSessionWithUrl:url
                               withScopedPath:path
                                     withUUID:uuid
                                  withOptions:options
                               withResumeData:resumeData
                                 withResolver:resolve
                                 withRejecter:reject];
}

ABI25_0_0RCT_REMAP_METHOD(downloadResumablePauseAsync,
                 downloadResumablePauseAsyncWithUUID:(NSString *)uuid
                 resolver:(ABI25_0_0RCTPromiseResolveBlock)resolve
                 rejecter:(ABI25_0_0RCTPromiseRejectBlock)reject)
{
  ABI25_0_0EXDownloadResumable *downloadResumable = (ABI25_0_0EXDownloadResumable *)self.downloadObjects[uuid];
  if (downloadResumable == nil) {
    reject(@"E_UNABLE_TO_PAUSE",
           [NSString stringWithFormat:@"There is no download object with UUID: %@", uuid],
           nil);
  } else {
    [downloadResumable.session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
      NSURLSessionDownloadTask *downloadTask = [downloadTasks firstObject];
      if (downloadTask) {
        [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
          NSString *data = [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding];
          resolve(@{@"resumeData": data ?: [NSNull null]});
        }];
      } else {
        reject(@"E_UNABLE_TO_PAUSE",
               @"There was an error producing resume data",
               nil);
      }
    }];
  }
}

#pragma mark - Internal methods

- (void)_downloadResumableCreateSessionWithUrl:(NSURL *)url withScopedPath:(NSString *)scopedPath withUUID:(NSString *)uuid withOptions:(NSDictionary *)options withResumeData:(NSData * _Nullable)resumeData withResolver:(ABI25_0_0RCTPromiseResolveBlock)resolve withRejecter:(ABI25_0_0RCTPromiseRejectBlock)reject
{
  NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
  sessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
  sessionConfiguration.URLCache = nil;

  __weak typeof(self) weakSelf = self;
  ABI25_0_0EXDownloadDelegate *downloadDelegate = [[ABI25_0_0EXDownloadDelegate alloc] initWithId:uuid
                                                                        onWrite:^(NSURLSessionDownloadTask *task, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
    if(bytesWritten > 0)
      [weakSelf sendEventWithName:ABI25_0_0EXDownloadProgressEventName
                             body:@{@"uuid":uuid,
                                    @"data":@{
                                        @"totalBytesWritten": @(totalBytesWritten),
                                        @"totalBytesExpectedToWrite": @(totalBytesExpectedToWrite),
                                        },
                                    }];
  } onDownload:^(NSURLSessionDownloadTask *task, NSURL *location) {
    NSURL *scopedLocation = [NSURL fileURLWithPath:scopedPath];
    NSData *locationData = [NSData dataWithContentsOfURL:location];
    [locationData writeToFile:scopedPath atomically:YES];
    NSData *data = [NSData dataWithContentsOfURL:scopedLocation];
    if (!data) {
      reject(@"E_UNABLE_TO_SAVE",
             nil,
             ABI25_0_0RCTErrorWithMessage(@"Unable to save file to local URI"));
      return;
    }
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[@"uri"] = scopedLocation.absoluteString;
    result[@"complete"] = @(YES);
          if (options[@"md5"]) {
      result[@"md5"] = [data md5String];
    }
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
    result[@"status"] = @([httpResponse statusCode]);
    result[@"headers"] = [httpResponse allHeaderFields];

    [self.downloadObjects removeObjectForKey:uuid];

    resolve(result);
  } onError:^(NSError *error) {
    //"cancelled" description when paused.  Don't throw.
    if ([error.localizedDescription isEqualToString:@"cancelled"]) {
      [self.downloadObjects removeObjectForKey:uuid];
      resolve(nil);
    } else {
      reject(@"E_UNABLE_TO_DOWNLOAD",
             [NSString stringWithFormat:@"Unable to download from: %@", url.absoluteString],
             error);
    }
  }];

  NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                        delegate:downloadDelegate
                                                   delegateQueue:[NSOperationQueue mainQueue]];

  ABI25_0_0EXDownloadResumable *downloadResumable = [[ABI25_0_0EXDownloadResumable alloc] initWithId:uuid
                                                                       withSession:session
                                                                      withDelegate:downloadDelegate];
  self.downloadObjects[downloadResumable.uuid] = downloadResumable;

  NSURLSessionDownloadTask *downloadTask;
  if (resumeData) {
    downloadTask = [session downloadTaskWithResumeData:resumeData];
  } else {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    if (options[@"headers"]) {
      NSDictionary *headerDict = (NSDictionary *) [options objectForKey:@"headers"];
      for (NSString *key in headerDict) {
        NSString *value = (NSString *) [headerDict objectForKey:key];
        [request addValue:value forHTTPHeaderField:key];
      }
    }
    downloadTask = [session downloadTaskWithRequest:request];
  }
  [downloadTask resume];
}

- (ABI25_0_0EXFileSystemPermissionFlags)_permissionsForPath:(NSString *)path
{
  path = [path stringByStandardizingPath];
  if ([path hasPrefix:[_documentDirectory stringByAppendingString:@"/"]]) {
    return ABI25_0_0EXFileSystemPermissionRead | ABI25_0_0EXFileSystemPermissionWrite;
  }
  if ([path isEqualToString:_documentDirectory])  {
    return ABI25_0_0EXFileSystemPermissionRead | ABI25_0_0EXFileSystemPermissionWrite;
  }
  if ([path hasPrefix:[_cachesDirectory stringByAppendingString:@"/"]]) {
    return ABI25_0_0EXFileSystemPermissionRead | ABI25_0_0EXFileSystemPermissionWrite;
  }
  if ([path isEqualToString:_cachesDirectory])  {
    return ABI25_0_0EXFileSystemPermissionRead | ABI25_0_0EXFileSystemPermissionWrite;
  }
  NSString *bundleDirectory = [_kernelFileSystemDelegate bundleDirectoryForExperienceId:self.experienceId];
  if (bundleDirectory != nil && [path hasPrefix:[bundleDirectory stringByAppendingString:@"/"]]) {
    return ABI25_0_0EXFileSystemPermissionRead;
  }
  return ABI25_0_0EXFileSystemPermissionNone;
}

#pragma mark - Public utils

- (ABI25_0_0EXFileSystemPermissionFlags)permissionsForURI:(NSURL *)uri
{
  if ([uri.scheme isEqualToString:@"assets-library"]) {
    return ABI25_0_0EXFileSystemPermissionRead;
  }
  if ([uri.scheme isEqualToString:@"file"]) {
    return [self _permissionsForPath:uri.path];
  }
  return ABI25_0_0EXFileSystemPermissionNone;
}

#pragma mark - Class methods

+ (BOOL)ensureDirExistsWithPath:(NSString *)path
{
  BOOL isDir = NO;
  NSError *error;
  BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
  if (!(exists && isDir)) {
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
      return NO;
    }
  }
  return YES;
}

+ (NSString *)documentDirectoryForExperienceId:(NSString *)experienceId
{
  NSString *subdir = [ABI25_0_0EXUtil escapedResourceName:experienceId];
  return [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject
            stringByAppendingPathComponent:@"ExponentExperienceData"]
           stringByAppendingPathComponent:subdir] stringByStandardizingPath];
}

+ (NSString *)cachesDirectoryForExperienceId:(NSString *)experienceId
{
  NSString *subdir = [ABI25_0_0EXUtil escapedResourceName:experienceId];
  return [[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
            stringByAppendingPathComponent:@"ExponentExperienceData"]
           stringByAppendingPathComponent:subdir] stringByStandardizingPath];
}

+ (NSString *)generatePathInDirectory:(NSString *)directory withExtension:(NSString *)extension
{
  NSString *fileName = [[[NSUUID UUID] UUIDString] stringByAppendingString:extension];
  [ABI25_0_0EXFileSystem ensureDirExistsWithPath:directory];
  return [directory stringByAppendingPathComponent:fileName];
}

@end
