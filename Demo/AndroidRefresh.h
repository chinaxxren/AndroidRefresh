
#import <UIKit/UIKit.h>

@interface AndroidTimerTarget : NSObject

@property(nonatomic, weak) id target;
@property(nonatomic, assign) SEL selector;
@property(nonatomic, weak) NSTimer *timer;

@end

@interface AndroidTimer : NSObject

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                     target:(id)aTarget
                                   selector:(SEL)aSelector
                                   userInfo:(id)userInfo
                                    repeats:(BOOL)repeats;

@end

@interface AndroidRefresh : UIControl

@property(nonatomic, assign) CGFloat refreshStartY;
@property(nonatomic, assign) CGFloat refreshingY;
@property(nonatomic, assign) CGFloat refreshEndY;

@property(nonatomic, retain, setter=setColors:) NSArray *colors;

- (id)initWithPanView:(UIView *)panView;

- (void)startRefresh;

- (void)startCenterRefresh;

- (void)endRefresh;

- (void)setMarginTop:(CGFloat)topMargin;

@end
