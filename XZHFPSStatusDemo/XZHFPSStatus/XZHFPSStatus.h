//
//  XZHFPSStatus.h
//  Demos
//
//  Created by xiongzenghui on 2/22/17.
//  Copyright © 2017 xiongzenghui. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSInteger kNormalFPS = 45;
static NSInteger kLowerFPS  = 30;

/**
 *  FPS运行时检测
 *  - 注意一、必须在真机运行，模拟器没什么效果
 *  - 注意二、必须在主线程上执行
 */
@interface XZHFPSStatus : NSObject
+ (void)start;
+ (void)end;
@end
