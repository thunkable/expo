#import "ABI32_0_0RNForceTouchHandler.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

#import <ReactABI32_0_0/ABI32_0_0RCTConvert.h>

@interface ABI32_0_0RNForceTouchGestureRecognizer : UIGestureRecognizer

@property (nonatomic) CGFloat maxForce;
@property (nonatomic) CGFloat minForce;
@property (nonatomic) CGFloat force;
@property (nonatomic) BOOL feedbackOnActivation;

- (id)initWithGestureHandler:(ABI32_0_0RNGestureHandler*)gestureHandler;

@end

@implementation ABI32_0_0RNForceTouchGestureRecognizer {
  __weak ABI32_0_0RNGestureHandler *_gestureHandler;
  UITouch *_firstTouch;
}


- (id)initWithGestureHandler:(ABI32_0_0RNGestureHandler*)gestureHandler
{
  if ((self = [super initWithTarget:gestureHandler action:@selector(handleGesture:)])) {
    _gestureHandler = gestureHandler;
    _force = 0;
    _minForce = 0.2;
    _maxForce = NAN;
    _feedbackOnActivation = NO;
  }
  return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  if (_firstTouch) {
    // ignore rest of fingers
    return;
  }
  [super touchesBegan:touches withEvent:event];
  _firstTouch = [touches anyObject];
  [self handleForceWithTouches:touches];
  self.state = UIGestureRecognizerStatePossible;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  if (![touches containsObject:_firstTouch]) {
    // Considered only the very first touch
    return;
  }
  [super touchesMoved:touches withEvent:event];
  
  [self handleForceWithTouches:touches];
  
  if ([self shouldFail]) {
    self.state = UIGestureRecognizerStateFailed;
    return;
  }
  
  if (self.state == UIGestureRecognizerStatePossible && [self shouldActivate]) {
    [self performFeedbackIfRequired];
    self.state = UIGestureRecognizerStateBegan;
  }
}

- (BOOL)shouldActivate {
  return (_force >= _minForce);
}

- (BOOL)shouldFail {
  return TEST_MAX_IF_NOT_NAN(_force, _maxForce);
}

- (void)performFeedbackIfRequired
{
  if (_feedbackOnActivation) {
    [[[UIImpactFeedbackGenerator alloc] initWithStyle:(UIImpactFeedbackStyleMedium)] impactOccurred];
  }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  if (![touches containsObject:_firstTouch]) {
    // Considered only the very first touch
    return;
  }
  [super touchesEnded:touches withEvent:event];
  if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged) {
    self.state = UIGestureRecognizerStateEnded;
  } else {
    self.state = UIGestureRecognizerStateFailed;
  }
}

- (void)handleForceWithTouches:(NSSet<UITouch *> *)touches {
  _force = _firstTouch.force / _firstTouch.maximumPossibleForce;
}

- (void)reset {
  [super reset];
  _force = 0;
  _firstTouch = NULL;
}

@end

@implementation ABI32_0_0RNForceTouchHandler

- (instancetype)initWithTag:(NSNumber *)tag
{
  if ((self = [super initWithTag:tag])) {
    _recognizer = [[ABI32_0_0RNForceTouchGestureRecognizer alloc] initWithGestureHandler:self];
  }
  return self;
}

- (void)configure:(NSDictionary *)config
{
  [super configure:config];
  ABI32_0_0RNForceTouchGestureRecognizer *recognizer = (ABI32_0_0RNForceTouchGestureRecognizer *)_recognizer;

  APPLY_FLOAT_PROP(maxForce);
  APPLY_FLOAT_PROP(minForce);

  id prop = config[@"feedbackOnActivation"];
  if (prop != nil) {
    recognizer.feedbackOnActivation = [ABI32_0_0RCTConvert BOOL:prop];
  }
}

- (ABI32_0_0RNGestureHandlerEventExtraData *)eventExtraData:(ABI32_0_0RNForceTouchGestureRecognizer *)recognizer
{
  return [ABI32_0_0RNGestureHandlerEventExtraData
          forForce: recognizer.force
          forPosition:[recognizer locationInView:recognizer.view]
          withAbsolutePosition:[recognizer locationInView:recognizer.view.window]
          withNumberOfTouches:recognizer.numberOfTouches];
}

@end

