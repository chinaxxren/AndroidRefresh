
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

@property(nonatomic, retain, setter=setColors:) NSArray *colors;

- (id)initWithScrollView:(UIScrollView *)scrollView;

- (void)startRefreshing;

- (void)endRefreshing;

// in case when navigation bar is not tranparent set 0
- (void)setMarginTop:(CGFloat)topMargin;

@end
