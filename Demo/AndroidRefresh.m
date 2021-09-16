

#import "AndroidRefresh.h"

@implementation AndroidTimerTarget

- (void)fire:(NSTimer *)timer {
    if (self.target && self.selector) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.selector withObject:timer.userInfo afterDelay:0.0f];
#pragma clang diagnostic pop
    } else {
        [self.timer invalidate];
    }
}

@end

@implementation AndroidTimer

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                     target:(id)aTarget
                                   selector:(SEL)aSelector
                                   userInfo:(id)userInfo
                                    repeats:(BOOL)repeats {
    AndroidTimerTarget *timerTarget = [[AndroidTimerTarget alloc] init];
    timerTarget.target = aTarget;
    timerTarget.selector = aSelector;
    timerTarget.timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                         target:timerTarget
                                                       selector:@selector(fire:)
                                                       userInfo:userInfo
                                                        repeats:repeats];
    return timerTarget.timer;
}

@end

#define STROKE_ANIMATION @"stroke_animation"
#define ROTATE_ANIMATION @"rotate_animation"

typedef NS_ENUM(NSUInteger, PullState) {
    PullStateReady = 0,
    PullStateDragging,
    PullStateRefreshing,
    PullStateFinished
};

@interface AndroidRefresh () {
    dispatch_once_t _initConstraits;
    NSLayoutConstraint *_topConstrait;

    UIScrollView *_scrollView;

    CAShapeLayer *_pathLayer;
    CAShapeLayer *_arrowLayer;
    UIView *_container;
    CGFloat _marginTop;

    BOOL _isDragging;
    BOOL _isFullyPulled;
    PullState _pullState;

    NSInteger _colorIndex;
    CGFloat _startOffSetY;
    CGPoint _location;
}
@end

@implementation AndroidRefresh

- (id)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];

        self.layer.opacity = 0;

        self.colors = @[self.tintColor];

        UIView *view = [[UIView alloc] init];
        _container = [[UIView alloc] init];
        [view addSubview:_container];

        _container.translatesAutoresizingMaskIntoConstraints = false;
        [[NSLayoutConstraint constraintWithItem:_container
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1
                                       constant:40]
                setActive:YES];
        [[NSLayoutConstraint constraintWithItem:_container
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1
                                       constant:40]
                setActive:YES];
        [[NSLayoutConstraint constraintWithItem:_container
                                      attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:view
                                      attribute:NSLayoutAttributeCenterX
                                     multiplier:1
                                       constant:0]
                setActive:YES];
        [[NSLayoutConstraint constraintWithItem:_container
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:view
                                      attribute:NSLayoutAttributeCenterY
                                     multiplier:1
                                       constant:0]
                setActive:YES];

        view.layer.backgroundColor = [UIColor whiteColor].CGColor;
        view.layer.cornerRadius = 20.0;

        view.layer.shadowOffset = CGSizeMake(0, .7f);
        view.layer.shadowColor = [[UIColor blackColor] CGColor];
        view.layer.shadowRadius = 1.f;
        view.layer.shadowOpacity = .12f;

        _pathLayer = [CAShapeLayer layer];
        _pathLayer.strokeStart = 0;
        _pathLayer.strokeEnd = 10;
        _pathLayer.fillColor = nil;
        _pathLayer.lineWidth = 2.5;

        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(20, 20)
                                                            radius:9
                                                        startAngle:0
                                                          endAngle:2 * M_PI
                                                         clockwise:YES];
        _pathLayer.path = path.CGPath;
        _pathLayer.strokeStart = 1;
        _pathLayer.strokeEnd = 1;
        _pathLayer.lineCap = kCALineCapSquare;

        _arrowLayer = [CAShapeLayer layer];
        _arrowLayer.strokeStart = 0;
        _arrowLayer.strokeEnd = 1;
        _arrowLayer.fillColor = nil;
        _arrowLayer.lineWidth = 3;
        _arrowLayer.strokeColor = [UIColor blueColor].CGColor;
        UIBezierPath *arrow = [AndroidRefresh bezierArrowFromPoint:CGPointMake(20, 20)
                                                           toPoint:CGPointMake(20, 21)
                                                             width:1];
        _arrowLayer.path = arrow.CGPath;
        _arrowLayer.transform = CATransform3DMakeTranslation(8.5, 0, 0);

        [_container.layer addSublayer:_pathLayer];
        [_container.layer addSublayer:_arrowLayer];

        [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:_container];

        [self addSubview:view];

        view.translatesAutoresizingMaskIntoConstraints = false;
        [[NSLayoutConstraint constraintWithItem:view
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1
                                       constant:40]
                setActive:YES];
        [[NSLayoutConstraint constraintWithItem:view
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1
                                       constant:40]
                setActive:YES];
        [[NSLayoutConstraint constraintWithItem:view
                                      attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self
                                      attribute:NSLayoutAttributeCenterX
                                     multiplier:1
                                       constant:0]
                setActive:YES];
        [[NSLayoutConstraint constraintWithItem:view
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self
                                      attribute:NSLayoutAttributeCenterY
                                     multiplier:1
                                       constant:0]
                setActive:YES];

        [[NSLayoutConstraint constraintWithItem:self
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1
                                       constant:40]
                setActive:YES];
        [[NSLayoutConstraint constraintWithItem:self
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1
                                       constant:40]
                setActive:YES];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)didMoveToSuperview {
    if (self.superview != nil) {
        dispatch_once(&_initConstraits, ^{
            _topConstrait = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.superview
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:0];
            NSLayoutConstraint *centerXConstrait = [NSLayoutConstraint constraintWithItem:self
                                                                                attribute:NSLayoutAttributeCenterX
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.superview
                                                                                attribute:NSLayoutAttributeCenterX
                                                                               multiplier:1.f
                                                                                 constant:0];

            [self setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self.superview addConstraint:_topConstrait];
            [self.superview addConstraint:centerXConstrait];
        });
    }
}

- (id)initWithScrollView:(UIScrollView *)scrollView {
    self = [self init];
    if (self) {
        _scrollView = scrollView;
        _scrollView.bounces = NO;

        if (scrollView) {
            [scrollView addObserver:self
                         forKeyPath:@"contentOffset"
                            options:NSKeyValueObservingOptionNew
                            context:nil];
            [scrollView addObserver:self
                         forKeyPath:@"pan.state"
                            options:NSKeyValueObservingOptionNew
                            context:nil];
        }
    }

    return self;
}

- (void)dealloc {
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [_scrollView removeObserver:self forKeyPath:@"pan.state"];
}

- (void)setMarginTop:(CGFloat)topMargin {
    _marginTop = -topMargin;
    [self layoutIfNeeded];
}

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view {
    CGPoint oldOrigin = view.frame.origin;
    view.layer.anchorPoint = anchorPoint;
    CGPoint newOrigin = view.frame.origin;

    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = newOrigin.y - oldOrigin.y;

    view.center = CGPointMake(view.center.x - transition.x, view.center.y - transition.y);
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if ([keyPath isEqualToString:@"contentOffset"]) {
        UIPanGestureRecognizer *panGesture = [_scrollView valueForKey:@"pan"];
        _location = [panGesture locationInView:panGesture.view];
        switch (panGesture.state) {
            case UIGestureRecognizerStateBegan:
                _startOffSetY = _location.y;
                break;
            case UIGestureRecognizerStateChanged:
                _location.y = (_location.y - _startOffSetY) * -0.75f;
                break;
            default:
                break;
        }

        [self scrollViewDidScroll:_location];

    } else if ([keyPath isEqualToString:@"pan.state"]) {
        if (_pullState == PullStateRefreshing)
            return;

        NSInteger state = [[change valueForKey:NSKeyValueChangeNewKey] integerValue];
        if (state == UIGestureRecognizerStateChanged) {
            if (_pullState == PullStateFinished) {
                if (_location.y > -10 + _marginTop) {
                    _isDragging = YES;
                    _pullState = PullStateDragging;
                }
            } else {
                _isDragging = YES;
                _pullState = PullStateDragging;
            }

        } else if (state == UIGestureRecognizerStateEnded) {

            if (_pullState != PullStateDragging)
                return;

            _isDragging = NO;
            if (_isFullyPulled) {
                _pullState = PullStateRefreshing;
                [UIView animateWithDuration:.2f
                                 animations:^{
                                     _topConstrait.constant = 10 - _marginTop;
                                     [self.superview layoutIfNeeded];
                                 }];
                [self startAnimating];
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            } else {
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     _topConstrait.constant = -50 - _marginTop;
                                     [self.superview layoutIfNeeded];
                                 }
                                 completion:^(BOOL finished) {
                                     _pathLayer.strokeColor = ((UIColor *) self.colors[_colorIndex]).CGColor;
                                 }];
            }
        }
    }
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    if (_pullState == PullStateRefreshing)
        return;

    float newY = -contentOffset.y - 50;

    if (contentOffset.y - _marginTop > -100) {
        _isFullyPulled = NO;

        _pathLayer.strokeColor = ((UIColor *) self.colors[_colorIndex]).CGColor;
        _arrowLayer.strokeColor = ((UIColor *) self.colors[_colorIndex]).CGColor;

        [self updateWithPoint:contentOffset outside:NO];

        if (_isDragging) {
            _topConstrait.constant = newY;
            [self layoutIfNeeded];
        }

    } else {
        _isFullyPulled = YES;

        [self updateWithPoint:contentOffset outside:YES];
    }
}

- (void)updateWithPoint:(CGPoint)point outside:(BOOL)flag {

    CGFloat angle = -(point.y - _marginTop) / 130;

    _container.layer.transform = CATransform3DMakeRotation(angle * 10, 0, 0, 1);

    if (!flag && _pullState == PullStateDragging) {
        [self showView];

        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _pathLayer.strokeStart = 1 - angle;
        self.layer.opacity = angle * 2;
        [CATransaction commit];
    }
}

- (void)startAnimating {
    float currentAngle = [(NSNumber *) [_container.layer valueForKeyPath:@"transform.rotation.z"] floatValue];
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation";
    animation.duration = 3.f;
    animation.fromValue = @(currentAngle);
    animation.toValue = @(2 * M_PI + currentAngle);
    animation.removedOnCompletion = NO;
    animation.repeatCount = INFINITY;
    [_container.layer addAnimation:animation forKey:ROTATE_ANIMATION];

    CABasicAnimation *beginHeadAnimation = [CABasicAnimation animation];
    beginHeadAnimation.keyPath = @"strokeStart";
    beginHeadAnimation.duration = .5f;
    beginHeadAnimation.fromValue = @(.25f);
    beginHeadAnimation.toValue = @(1.f);
    beginHeadAnimation.timingFunction =
            [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    CABasicAnimation *beginTailAnimation = [CABasicAnimation animation];
    beginTailAnimation.keyPath = @"strokeEnd";
    beginTailAnimation.duration = .5f;
    beginTailAnimation.fromValue = @(1.f);
    beginTailAnimation.toValue = @(1.f);
    beginTailAnimation.timingFunction =
            [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    CABasicAnimation *endHeadAnimation = [CABasicAnimation animation];
    endHeadAnimation.keyPath = @"strokeStart";
    endHeadAnimation.beginTime = .5f;
    endHeadAnimation.duration = 1.f;
    endHeadAnimation.fromValue = @(.0f);
    endHeadAnimation.toValue = @(.25f);
    endHeadAnimation.timingFunction =
            [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    CABasicAnimation *endTailAnimation = [CABasicAnimation animation];
    endTailAnimation.keyPath = @"strokeEnd";
    endTailAnimation.beginTime = .5f;
    endTailAnimation.duration = 1.f;
    endTailAnimation.fromValue = @(0.f);
    endTailAnimation.toValue = @(1.f);
    endTailAnimation.timingFunction =
            [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    CAAnimationGroup *animations = [CAAnimationGroup animation];
    [animations setDuration:1.5f];
    [animations setRemovedOnCompletion:NO];
    [animations setAnimations:@[
            beginHeadAnimation,
            beginTailAnimation,
            endHeadAnimation,
            endTailAnimation
    ]];
    animations.repeatCount = INFINITY;
    [_pathLayer addAnimation:animations forKey:STROKE_ANIMATION];

    NSTimer *timer = [AndroidTimer scheduledTimerWithTimeInterval:.5
                                                           target:self
                                                         selector:@selector(changeColor)
                                                         userInfo:nil
                                                          repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)changeColor {
    NSLog(@"%@", @"changeColor");

    [self hideArrow];

    if (_pullState == PullStateRefreshing) {

        _colorIndex++;
        if (_colorIndex > self.colors.count - 1) {
            _colorIndex = 0;
        }

        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _pathLayer.strokeColor = ((UIColor *) self.colors[_colorIndex]).CGColor;
        [CATransaction commit];

        NSTimer *timer = [AndroidTimer scheduledTimerWithTimeInterval:1.5
                                                               target:self
                                                             selector:@selector(changeColor)
                                                             userInfo:nil
                                                              repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

- (void)hideArrow {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _arrowLayer.opacity = 0;
    [CATransaction commit];
}

- (void)showArrow {
    _arrowLayer.opacity = 1;
}

- (void)endAnimating {
    [_container.layer removeAnimationForKey:ROTATE_ANIMATION];
    [_pathLayer removeAnimationForKey:STROKE_ANIMATION];
}

- (void)showView {
    self.layer.transform = CATransform3DMakeScale(1, 1, 1);
    [self showArrow];
}

- (void)hideView {

    [UIView animateWithDuration:.3f
                     animations:^{
                         self.layer.opacity = 0;
                         self.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1);
                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [self endAnimating];

                         _pullState = PullStateFinished;
                         _colorIndex = 0;
                         _pathLayer.strokeColor = ((UIColor *) self.colors[_colorIndex]).CGColor;

                         _topConstrait.constant = -50 + _marginTop;
                     }];
}

- (void)startRefreshing {
    _pullState = PullStateRefreshing;
    self.layer.transform = CATransform3DMakeScale(0, 0, 1);
    _topConstrait.constant = 30 - _marginTop;
    [self layoutIfNeeded];

    [UIView animateWithDuration:.6f
                     animations:^{
                         self.layer.opacity = 1;
                         self.layer.transform = CATransform3DMakeScale(1, 1, 1);

                         _topConstrait.constant = 10 - _marginTop;
                         [self layoutIfNeeded];

                     }
                     completion:nil];

    [self startAnimating];
    [self hideArrow];
}

- (void)endRefreshing {
    [self hideView];
}

+ (UIBezierPath *)bezierArrowFromPoint:(CGPoint)startPoint
                               toPoint:(CGPoint)endPoint
                                 width:(CGFloat)width {
    CGFloat length = hypotf(endPoint.x - startPoint.x, endPoint.y - startPoint.y);

    CGPoint points[3];
    [self getAxisAlignedArrowPoints:points width:width length:length];

    CGAffineTransform transform =
            [self transformForStartPoint:startPoint endPoint:endPoint length:length];

    CGMutablePathRef cgPath = CGPathCreateMutable();
    CGPathAddLines(cgPath, &transform, points, sizeof points / sizeof *points);
    CGPathCloseSubpath(cgPath);

    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithCGPath:cgPath];
    CGPathRelease(cgPath);

    return bezierPath;
}

+ (void)getAxisAlignedArrowPoints:(CGPoint[3])points width:(CGFloat)width length:(CGFloat)length {
    points[0] = CGPointMake(0, width);
    points[1] = CGPointMake(length, 0);
    points[2] = CGPointMake(0, -width);
}

+ (CGAffineTransform)transformForStartPoint:(CGPoint)startPoint
                                   endPoint:(CGPoint)endPoint
                                     length:(CGFloat)length {
    CGFloat cosine = (endPoint.x - startPoint.x) / length;
    CGFloat sine = (endPoint.y - startPoint.y) / length;

    return (CGAffineTransform) {cosine, sine, -sine, cosine, startPoint.x, startPoint.y};
}

@end
