//
//  LockViewController.m
//  LessonGCD
//
//  Created by zhangdong on 2017/3/2.
//  Copyright © 2017年 zhangdong. All rights reserved.
//

#import "LockViewController.h"
#import "TestObj.h"
#import <pthread.h>

@interface LockViewController ()

@end

@implementation LockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)NSLock:(id)sender {
    
    // 假设obj是一个共享的资源
    TestObj *obj = [[TestObj alloc] init];
    NSLock *lock = [[NSLock alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [lock lock];
        [obj method1];
        sleep(10);
        [lock unlock];
        
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        sleep(1);
        [lock lock];
        [obj method2];
        [lock unlock];
        
    });
}

- (IBAction)Synchronized:(id)sender {
    //@synchronized(obj) obj 是唯一标识，只有当标识相同时，才为满足互斥
    
    TestObj *obj = [[TestObj alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (obj) {
            [obj method1];
            sleep(5);
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        sleep(1);
        @synchronized (obj) {
            [obj method2];
        }
    });
}

- (IBAction)pthreadMutexLock:(id)sender {
    //主线程中
    TestObj *obj = [[TestObj alloc] init];
    __block pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    //线程1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        pthread_mutex_lock(&mutex);
        [obj method1];
        sleep(5);
        pthread_mutex_unlock(&mutex);
    });
    //线程2
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        pthread_mutex_lock(&mutex);
        [obj method2];
        pthread_mutex_unlock(&mutex);
    });
}

- (IBAction)dispatchSemaphore:(id)sender {
    //主线程中
    TestObj *obj = [[TestObj alloc] init];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    //线程1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [obj method1];
        sleep(10);
        dispatch_semaphore_signal(semaphore);
    });
    //线程2
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [obj method2];
        dispatch_semaphore_signal(semaphore);
    });
}

//递归锁
/*
 NSRecursiveLock类定义的锁可以在同一线程多次lock，而不会造成死锁。递归锁会跟踪它被多少次lock。每次成功的lock都必须平衡调用unlock操作。只有所有的锁住和解锁操作都平衡的时候，锁才真正被释放给其他线程获得
 */
- (IBAction)NSRecursiveLock:(id)sender {
    //主线程中
    NSRecursiveLock *theLock = [[NSRecursiveLock alloc] init];//如果把NSRecursiveLock改为NSLock则会造成死锁
    TestObj *obj = [[TestObj alloc] init];
    //线程1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void(^TestMethod)(int);
        TestMethod = ^(int value)
        {
            [theLock lock];
            if (value > 0)
            {
                [obj method1];
                sleep(5);
                TestMethod(value-1);
            }
            [theLock unlock];
        };
        TestMethod(5);
    });
}

//条件锁
- (IBAction)NSConditionLock:(id)sender {
    
    //主线程中
    NSConditionLock *theLock = [[NSConditionLock alloc] init];
    //线程1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i=0; i<=2; i++)
        {
            [theLock lock];
            NSLog(@"%@_%d", [NSThread currentThread], i);
            sleep(2);
            [theLock unlockWithCondition:1];//释放锁 并设置锁的内部条件
        }
    });
    
    //线程2
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [theLock lockWhenCondition:1]; //根据锁的内部条件，获得锁
        NSLog(@"%@", [NSThread currentThread]);
        [theLock unlock];
    });
    
    //lock,lockWhenCondition:与unlock，unlockWithCondition:是可以随意组合的
}

//分布式锁
- (IBAction)NSDistributedLock:(id)sender {
    NSLog(@"适用于多个进程或多个程序之间需要构建互斥的情景！！！");
}
@end
