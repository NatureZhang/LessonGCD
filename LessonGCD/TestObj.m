//
//  TestObj.m
//  LessonGCD
//
//  Created by zhangdong on 2017/3/2.
//  Copyright © 2017年 zhangdong. All rights reserved.
//

#import "TestObj.h"

@implementation TestObj

- (void)method1 {
    NSLog(@"%@_%@", [NSThread currentThread], NSStringFromSelector(_cmd));
}

- (void)method2 {
    NSLog(@"%@_%@", [NSThread currentThread], NSStringFromSelector(_cmd));
}

@end
