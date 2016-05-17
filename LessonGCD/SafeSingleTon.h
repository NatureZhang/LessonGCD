//
//  SafeSingleTon.h
//  LessonGCD
//
//  Created by zhangdong on 16/5/17.
//  Copyright © 2016年 zhangdong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SafeSingleTon : NSObject

+ (SafeSingleTon *)shareInstance;

@end
