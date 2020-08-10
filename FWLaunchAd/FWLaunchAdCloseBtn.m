//
//  FWLaunchAdCloseBtn.m
//  FWLaunchAd
//
//  Created by xfg on 2018/9/17.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "FWLaunchAdCloseBtn.h"
#import "FWLaunchAdMacro.h"

/** Progress颜色 */
#define kRoundProgressColor  [UIColor whiteColor]
/** 背景色 */
#define kBackgroundColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]
/** 字体颜色 */
#define kFontColor  [UIColor whiteColor]

/** 提示文字 */
static NSString *const kSkipTitle = @"跳过";
/** 倒计时单位 */
static NSString *const kDurationUnit = @"S";

/** 方形尺寸 */
#define kSquareSize CGSizeMake(70, 35)
/** 环形尺寸 */
#define kRoundSize CGSizeMake(42, 42)


@interface FWLaunchAdCloseBtn ()

@property (nonatomic, assign) AdSkipType skipType;
@property (nonatomic, assign) CGFloat leftRightSpace;
@property (nonatomic, assign) CGFloat topBottomSpace;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) CAShapeLayer *roundLayer;
@property (nonatomic, copy) dispatch_source_t roundTimer;
@property (nonatomic, assign) BOOL isHasWait;

@end


@implementation FWLaunchAdCloseBtn

- (instancetype)initWithSkipType:(AdSkipType)skipType
{
    self = [super init];
    if (self) {
        _skipType = skipType;
        
        if(skipType == AdSkipTypeRoundTime || skipType == AdSkipTypeRoundText || skipType == AdSkipTypeRoundProgressTime || skipType == AdSkipTypeRoundProgressText)
        {
            // 环形
            self.frame = CGRectMake(kADScreenWidth-kRoundSize.width-13, kADStatusBarHeight, kRoundSize.width, kRoundSize.height);
        }
        else
        {
            // 方形
            self.frame = CGRectMake(kADScreenWidth-kSquareSize.width-10, kADStatusBarHeight, kSquareSize.width, kSquareSize.height);
        }
        
        switch (skipType) {
            case AdSkipTypeNone:
            {
                self.hidden = YES;
            }
                break;
            case AdSkipTypeTime:
            {
                [self addSubview:self.timeLabel];
                self.leftRightSpace = 5;
                self.topBottomSpace = 2.5;
            }
                break;
            case AdSkipTypeText:
            {
                [self addSubview:self.timeLabel];
                self.leftRightSpace = 5;
                self.topBottomSpace = 2.5;
            }
                break;
            case AdSkipTypeTimeText:
            {
                [self addSubview:self.timeLabel];
                self.leftRightSpace = 5;
                self.topBottomSpace = 2.5;
            }
                break;
            case AdSkipTypeRoundTime:
            {
                [self addSubview:self.timeLabel];
            }
                break;
            case AdSkipTypeRoundText:
            {
                [self addSubview:self.timeLabel];
            }
                break;
            case AdSkipTypeRoundProgressTime:
            {
                [self addSubview:self.timeLabel];
                [self.timeLabel.layer addSublayer:self.roundLayer];
            }
                break;
            case AdSkipTypeRoundProgressText:
            {
                [self addSubview:self.timeLabel];
                [self.timeLabel.layer addSublayer:self.roundLayer];
            }
                break;
                
            default:
                break;
        }
    }
    return self;
}

- (void)setTitleWithSkipType:(AdSkipType)skipType duration:(NSInteger)duration waitUntilShowCloseBtn:(NSUInteger)waitUntilShowCloseBtn
{
    if (skipType == AdSkipTypeNone)
    {
        self.hidden = YES;
    }
    else
    {
        if (waitUntilShowCloseBtn > 0 && !self.isHasWait)
        {
            self.isHasWait = YES;
            [self performSelector:@selector(showSelf) withObject:nil afterDelay:waitUntilShowCloseBtn];
        }
        else if (waitUntilShowCloseBtn == 0)
        {
            [self showSelf];
        }
        
        switch (skipType) {
            case AdSkipTypeTime:
            {
                self.timeLabel.text = [NSString stringWithFormat:@"%ld %@", duration, kDurationUnit];
            }
                break;
            case AdSkipTypeText:
            {
                self.timeLabel.text = kSkipTitle;
            }
                break;
            case AdSkipTypeTimeText:
            {
                self.timeLabel.text = [NSString stringWithFormat:@"%ld %@", duration, kSkipTitle];
            }
                break;
            case AdSkipTypeRoundTime:
            {
                self.timeLabel.text = [NSString stringWithFormat:@"%ld %@", duration, kDurationUnit];
            }
                break;
            case AdSkipTypeRoundText:
            {
                self.timeLabel.text = kSkipTitle;
            }
                break;
            case AdSkipTypeRoundProgressTime:
            {
                self.timeLabel.text = [NSString stringWithFormat:@"%ld %@", duration, kDurationUnit];
            }
                break;
            case AdSkipTypeRoundProgressText:
            {
                self.timeLabel.text = kSkipTitle;
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)showSelf
{
    self.hidden = NO;
}

- (void)startRoundDispathTimerWithDuration:(CGFloat)duration
{
    NSTimeInterval period = 0.05;
    __block CGFloat roundDuration = duration;
    _roundTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(_roundTimer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_roundTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(roundDuration <= 0)
            {
                self.roundLayer.strokeStart = 1;
                DISPATCH_SOURCE_CANCEL_SAFE(self.roundTimer);
            }
            self.roundLayer.strokeStart += 1/(duration/period);
            roundDuration -= period;
        });
    });
    dispatch_resume(_roundTimer);
}


- (UILabel *)timeLabel
{
    if(!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _timeLabel.textColor = kFontColor;
        _timeLabel.backgroundColor = kBackgroundColor;
        _timeLabel.layer.masksToBounds = YES;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:13.5];
        [self cornerRadiusWithView:_timeLabel];
    }
    return _timeLabel;
}

- (CAShapeLayer *)roundLayer
{
    if(!_roundLayer) {
        _roundLayer = [CAShapeLayer layer];
        _roundLayer.fillColor = kBackgroundColor.CGColor;
        _roundLayer.strokeColor = kRoundProgressColor.CGColor;
        _roundLayer.lineCap = kCALineCapRound;
        _roundLayer.lineJoin = kCALineJoinRound;
        _roundLayer.lineWidth = 2;
        _roundLayer.frame = self.bounds;
        _roundLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(self.timeLabel.frame)/2.0, CGRectGetWidth(self.timeLabel.frame)/2.0) radius:CGRectGetWidth(self.timeLabel.frame)/2.0-1.0 startAngle:-0.5*M_PI endAngle:1.5*M_PI clockwise:YES].CGPath;
        _roundLayer.strokeStart = 0;
    }
    return _roundLayer;
}

- (void)setLeftRightSpace:(CGFloat)leftRightSpace
{
    _leftRightSpace = leftRightSpace;
    CGRect frame = self.timeLabel.frame;
    CGFloat width = frame.size.width;
    if(leftRightSpace<=0 || leftRightSpace*2>=width) return;
    frame = CGRectMake(leftRightSpace, frame.origin.y, width-2*leftRightSpace, frame.size.height);
    self.timeLabel.frame = frame;
    [self cornerRadiusWithView:self.timeLabel];
}

- (void)setTopBottomSpace:(CGFloat)topBottomSpace
{
    _topBottomSpace = topBottomSpace;
    CGRect frame = self.timeLabel.frame;
    CGFloat height = frame.size.height;
    if(topBottomSpace<=0 || topBottomSpace*2>=height) return;
    frame = CGRectMake(frame.origin.x, topBottomSpace, frame.size.width, height-2*topBottomSpace);
    self.timeLabel.frame = frame;
    [self cornerRadiusWithView:self.timeLabel];
}

- (void)cornerRadiusWithView:(UIView *)view
{
    CGFloat min = view.frame.size.height;
    if(view.frame.size.height > view.frame.size.width)
    {
        min = view.frame.size.width;
    }
    view.layer.cornerRadius = min/2.0;
    view.layer.masksToBounds = YES;
}

@end
