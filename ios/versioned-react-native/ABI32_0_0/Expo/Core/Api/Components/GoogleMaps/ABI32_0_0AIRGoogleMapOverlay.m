//
//  ABI32_0_0AIRGoogleMapOverlay.m
//  Created by Nick Italiano on 3/5/17.
//

#import "ABI32_0_0AIRGoogleMapOverlay.h"

#import <ReactABI32_0_0/ABI32_0_0RCTEventDispatcher.h>
#import <ReactABI32_0_0/ABI32_0_0RCTImageLoader.h>
#import <ReactABI32_0_0/ABI32_0_0RCTUtils.h>
#import <ReactABI32_0_0/UIView+ReactABI32_0_0.h>

@interface ABI32_0_0AIRGoogleMapOverlay()
  @property (nonatomic, strong, readwrite) UIImage *overlayImage;
  @property (nonatomic, readwrite) GMSCoordinateBounds *overlayBounds;
@end

@implementation ABI32_0_0AIRGoogleMapOverlay {
  ABI32_0_0RCTImageLoaderCancellationBlock _reloadImageCancellationBlock;
  CLLocationCoordinate2D _southWest;
  CLLocationCoordinate2D _northEast;
}

- (instancetype)init
{
  if ((self = [super init])) {
    _overlay = [[GMSGroundOverlay alloc] init];
  }
  return self;
}

- (void)setImageSrc:(NSString *)imageSrc
{
  NSLog(@">>> SET IMAGESRC: %@", imageSrc);
  _imageSrc = imageSrc;

  if (_reloadImageCancellationBlock) {
    _reloadImageCancellationBlock();
    _reloadImageCancellationBlock = nil;
  }

  __weak typeof(self) weakSelf = self;
  _reloadImageCancellationBlock = [_bridge.imageLoader loadImageWithURLRequest:[ABI32_0_0RCTConvert NSURLRequest:_imageSrc]
                                                                          size:weakSelf.bounds.size
                                                                         scale:ABI32_0_0RCTScreenScale()
                                                                       clipped:YES
                                                                    resizeMode:ABI32_0_0RCTResizeModeCenter
                                                                 progressBlock:nil
                                                              partialLoadBlock:nil
                                                               completionBlock:^(NSError *error, UIImage *image) {
                                                                 if (error) {
                                                                   NSLog(@"%@", error);
                                                                 }
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                   NSLog(@">>> IMAGE: %@", image);
                                                                   weakSelf.overlayImage = image;
                                                                   weakSelf.overlay.icon = image;
                                                                 });
                                                               }];

}

- (void)setBoundsRect:(NSArray *)boundsRect
{
  _boundsRect = boundsRect;

  _southWest = CLLocationCoordinate2DMake([boundsRect[1][0] doubleValue], [boundsRect[0][1] doubleValue]);
  _northEast = CLLocationCoordinate2DMake([boundsRect[0][0] doubleValue], [boundsRect[1][1] doubleValue]);

  _overlayBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:_southWest
                                                        coordinate:_northEast];

  _overlay.bounds = _overlayBounds;
}

@end
