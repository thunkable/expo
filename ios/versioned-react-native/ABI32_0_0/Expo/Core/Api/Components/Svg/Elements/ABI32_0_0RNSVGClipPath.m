/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI32_0_0RNSVGClipPath.h"

@implementation ABI32_0_0RNSVGClipPath

- (void)parseReference
{
    [self.svgView defineClipPath:self clipPathName:self.name];
}


- (BOOL)isSimpleClipPath
{
    NSArray<UIView*> *children = self.subviews;
    if (children.count == 1) {
        UIView* child = children[0];
        if ([child class] != [ABI32_0_0RNSVGGroup class]) {
            return true;
        }
    }
    return false;
}

@end
