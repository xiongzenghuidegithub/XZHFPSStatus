//
//  XZHFPSStatus.m
//  Demos
//
//  Created by xiongzenghui on 2/22/17.
//  Copyright © 2017 xiongzenghui. All rights reserved.
//

#import "XZHFPSStatus.h"
#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>

typedef id (^XZHWeakReferenceBlcok)(void);
static XZHWeakReferenceBlcok MakeWeakReferenceBlcokForTarget(id target) {
    id __weak weakTarget = target;
    return ^() {
        id __strong strongTarget = weakTarget;
        return strongTarget;
    };
}
static id GetWeakReferenceTargetFromBlock(XZHWeakReferenceBlcok block) {
    if (!block) {return nil;}
    return block();
}

@implementation XZHFPSStatus {
    UIWindow                *_fpsWindow;
    UILabel                 *_fpsLabel;
    CADisplayLink           *_displayLink;
    CFTimeInterval          _lastTime;
    NSUInteger              _count;
}

#pragma mark - Private

+ (instancetype)sharedInstance {
    static XZHFPSStatus *_status = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _status = [[XZHFPSStatus alloc] init];
    });
    return _status;
}

- (instancetype)init {
    if (self = [super init]) {
        _fpsLabel = [[UILabel alloc] init];
        _fpsLabel.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 55)/2.0+55, 0, 55, 20);
        _fpsLabel.font = [UIFont boldSystemFontOfSize:12];
        _fpsLabel.textColor = [UIColor greenColor];
        _fpsLabel.textAlignment = NSTextAlignmentRight;
        _fpsLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)start {
    if (!_fpsWindow) {
        _fpsWindow = [[UIWindow alloc] init];
        _fpsWindow.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20);
        _fpsWindow.windowLevel = UIWindowLevelStatusBar + 100;// make topest level window
        _fpsWindow.backgroundColor = [UIColor clearColor];
        _fpsWindow.tag = 10001;
        _fpsWindow.hidden = NO;
        _fpsWindow.userInteractionEnabled = NO;
        UIViewController *rootVC = [[UIViewController alloc] init];
        rootVC.view.backgroundColor = [UIColor clearColor];
        _fpsWindow.rootViewController = rootVC;
        [_fpsWindow addSubview:_fpsLabel];
    }
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:GetWeakReferenceTargetFromBlock(MakeWeakReferenceBlcokForTarget(self)) selector:@selector(_displayLinkDidCallback:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    if (_displayLink.paused == YES) {
        _displayLink.paused = NO;
    }
}

- (void)end {
    if (_displayLink) {
        _displayLink.paused = YES;
        [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [_displayLink invalidate];
    }
    
    if (_fpsWindow) {
        _fpsWindow.hidden = YES;
    }
    
    _count = 0;
    _lastTime = 0.0f;
}

#pragma mark - Public

+ (void)start {
    [[XZHFPSStatus sharedInstance] start];
}

+ (void)end {
    [[XZHFPSStatus sharedInstance] end];
}

#pragma mark - CADisplayLink Callback

- (void)_displayLinkDidCallback:(CADisplayLink *)displayLink {
    //第一次屏幕绘制，只记录开始时间
    if (_lastTime == 0) {
        _lastTime = displayLink.timestamp;
        return;
    }
    
    // 第二次及以后进行屏幕绘制
    _count++;
    CFTimeInterval duration = displayLink.timestamp - _lastTime;
    if (duration < 1.0) {return;}
    _lastTime = displayLink.timestamp;
    
    // 每一次屏幕绘制需要的单位时间 = 屏幕绘制的总次数 / 总时间
    NSInteger fps = lround(_count/duration);
#if DEBUG
    NSLog(@"fps = %ld", fps);
#endif
    
    // 设置fps label显示内容
    _fpsLabel.text = [NSString stringWithFormat:@"%@ FPS", @(fps)];
    if (fps >= kNormalFPS) {
        _fpsLabel.textColor = [UIColor greenColor];
    } else if (fps >= kLowerFPS) {
        _fpsLabel.textColor = [UIColor colorWithRed:255/255.0 green:215/255.0 blue:0/255.0 alpha:1];
    } else {
        _fpsLabel.textColor = [UIColor redColor];
    }
    
    // 清空数据，等待下一次的FPS计算
    _count = 0;
}

@end
