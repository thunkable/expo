/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI32_0_0AIRMapMarkerManager.h"

#import <ReactABI32_0_0/ABI32_0_0RCTConvert+CoreLocation.h>
#import <ReactABI32_0_0/ABI32_0_0RCTUIManager.h>
#import <ReactABI32_0_0/UIView+ReactABI32_0_0.h>
#import "ABI32_0_0AIRMapMarker.h"

@interface ABI32_0_0AIRMapMarkerManager () <MKMapViewDelegate>

@end

@implementation ABI32_0_0AIRMapMarkerManager

ABI32_0_0RCT_EXPORT_MODULE()

- (UIView *)view
{
    ABI32_0_0AIRMapMarker *marker = [ABI32_0_0AIRMapMarker new];
    [marker addTapGestureRecognizer];
    marker.bridge = self.bridge;
    return marker;
}

ABI32_0_0RCT_EXPORT_VIEW_PROPERTY(identifier, NSString)
//ABI32_0_0RCT_EXPORT_VIEW_PROPERTY(reuseIdentifier, NSString)
ABI32_0_0RCT_EXPORT_VIEW_PROPERTY(title, NSString)
ABI32_0_0RCT_REMAP_VIEW_PROPERTY(description, subtitle, NSString)
ABI32_0_0RCT_EXPORT_VIEW_PROPERTY(coordinate, CLLocationCoordinate2D)
ABI32_0_0RCT_EXPORT_VIEW_PROPERTY(centerOffset, CGPoint)
ABI32_0_0RCT_EXPORT_VIEW_PROPERTY(calloutOffset, CGPoint)
ABI32_0_0RCT_REMAP_VIEW_PROPERTY(image, imageSrc, NSString)
ABI32_0_0RCT_EXPORT_VIEW_PROPERTY(pinColor, UIColor)
ABI32_0_0RCT_EXPORT_VIEW_PROPERTY(draggable, BOOL)
ABI32_0_0RCT_EXPORT_VIEW_PROPERTY(zIndex, NSInteger)
ABI32_0_0RCT_EXPORT_VIEW_PROPERTY(opacity, double)

ABI32_0_0RCT_EXPORT_VIEW_PROPERTY(onPress, ABI32_0_0RCTBubblingEventBlock)
ABI32_0_0RCT_EXPORT_VIEW_PROPERTY(onSelect, ABI32_0_0RCTDirectEventBlock)
ABI32_0_0RCT_EXPORT_VIEW_PROPERTY(onDeselect, ABI32_0_0RCTDirectEventBlock)
ABI32_0_0RCT_EXPORT_VIEW_PROPERTY(onCalloutPress, ABI32_0_0RCTDirectEventBlock)
ABI32_0_0RCT_EXPORT_VIEW_PROPERTY(onDragStart, ABI32_0_0RCTDirectEventBlock)
ABI32_0_0RCT_EXPORT_VIEW_PROPERTY(onDrag, ABI32_0_0RCTDirectEventBlock)
ABI32_0_0RCT_EXPORT_VIEW_PROPERTY(onDragEnd, ABI32_0_0RCTDirectEventBlock)


ABI32_0_0RCT_EXPORT_METHOD(showCallout:(nonnull NSNumber *)ReactABI32_0_0Tag)
{
    [self.bridge.uiManager addUIBlock:^(__unused ABI32_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        id view = viewRegistry[ReactABI32_0_0Tag];
        if (![view isKindOfClass:[ABI32_0_0AIRMapMarker class]]) {
            ABI32_0_0RCTLogError(@"Invalid view returned from registry, expecting ABI32_0_0AIRMap, got: %@", view);
        } else {
            [(ABI32_0_0AIRMapMarker *) view showCalloutView];
        }
    }];
}

ABI32_0_0RCT_EXPORT_METHOD(hideCallout:(nonnull NSNumber *)ReactABI32_0_0Tag)
{
    [self.bridge.uiManager addUIBlock:^(__unused ABI32_0_0RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        id view = viewRegistry[ReactABI32_0_0Tag];
        if (![view isKindOfClass:[ABI32_0_0AIRMapMarker class]]) {
            ABI32_0_0RCTLogError(@"Invalid view returned from registry, expecting ABI32_0_0AIRMap, got: %@", view);
        } else {
            [(ABI32_0_0AIRMapMarker *) view hideCalloutView];
        }
    }];
}

@end
