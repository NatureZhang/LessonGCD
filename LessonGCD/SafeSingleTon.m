//
//  SafeSingleTon.m
//  LessonGCD
//
//  Created by zhangdong on 16/5/17.
//  Copyright © 2016年 zhangdong. All rights reserved.
//

#import "SafeSingleTon.h"

@interface SafeSingleTon ()

@property (nonatomic, strong) NSMutableArray *books;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue;

@end

@implementation SafeSingleTon

+ (SafeSingleTon *)shareInstance {
    
    static SafeSingleTon *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[SafeSingleTon alloc] init];
        shareInstance->_books = [NSMutableArray array];
        shareInstance->_concurrentQueue = dispatch_queue_create("com.zhangdong.bookQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return shareInstance;
}

- (NSArray *)books {
    
    __block NSArray *array;
    dispatch_sync(self.concurrentQueue, ^{
        array = [NSMutableArray arrayWithArray:_books];
    });
    
    return array;
}

- (void)addBook:(id)book {
    if (book) {
        
        dispatch_barrier_async(self.concurrentQueue, ^{
            
            [_books addObject:book];
        });
    }
}
@end
