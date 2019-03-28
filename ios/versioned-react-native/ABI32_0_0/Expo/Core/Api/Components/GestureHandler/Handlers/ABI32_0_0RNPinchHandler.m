//
//  ABI32_0_0RNPinchHandler.m
//  ABI32_0_0RNGestureHandler
//
//  Created by Krzysztof Magiera on 12/10/2017.
//  Copyright © 2017 Software Mansion. All rights reserved.
//

#import "ABI32_0_0RNPinchHandler.h"

@implementation ABI32_0_0RNPinchGestureHandler

- (instancetype)initWithTag:(NSNumber *)tag
{
    if ((self = [super initWithTag:tag])) {
        _recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    }
    return self;
}

- (ABI32_0_0RNGestureHandlerEventExtraData *)eventExtraData:(UIPinchGestureRecognizer *)recognizer
{
    return [ABI32_0_0RNGestureHandlerEventExtraData
            forPinch:recognizer.scale
            withFocalPoint:[recognizer locationInView:recognizer.view]
            withVelocity:recognizer.velocity
            withNumberOfTouches:recognizer.numberOfTouches];
}

@end

