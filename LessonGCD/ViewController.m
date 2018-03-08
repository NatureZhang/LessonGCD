//
//  ViewController.m
//  LessonGCD
//
//  Created by zhangdong on 16/5/17.
//  Copyright © 2016年 zhangdong. All rights reserved.
//

#import "ViewController.h"

/*
 
 GCD 
 
 1 GCD 是苹果公司为多和的并行运算提供解决方案
 2 GCD 会自动利用更多CPU内核
 3 GCD 会自动管理线程的生命周期（创建线程、调度任务、销毁线程），程序员只需要告诉GCD想要执行什么任务，不需要编写任何线程管理代码
 
 https://github.com/nixzhu/dev-blog/blob/master/2014-04-19-grand-central-dispatch-in-depth-part-1.md
 1 GCD 能通过推迟昂贵计算任务并在后台运行它们来改善你的应用的响应性能
 2 GCD 提供一个易于使用的并发模型而不仅仅只是锁和线程，以帮助我们避开并发陷阱
 3 GCD 具有在常见模式上用更高性能的原语优化你的代码的潜在能力
 
 */

/*
 基本概念：
 
 1 串行和并发：任务串行执行就是每次只有一个任务被执行，任务并发执行就是在同一时间可以有多个任务被执行
 
 2 同步和异步：一个同步函数只在完成了它预定的任务后才返回，一个异步函数会立即返回，预定的任务完成但不会等它完成。同步函数会阻塞当前线程, 不会开新线程，异步函数不会阻塞当前线程， 会开新线程
 
 3 临界区：两个线程不能同时执行这段代码

 4 死锁：两个线程都卡住了，第一个不能完成是因为他在等待第二个的完成，但第二个也不能完成，因为它在等待第一个的完成

 5 线程安全：线程安全的代码能在多线程或并发任务中被安全的调用，而不会导致任何问题。线程不安全的代码在某个时刻只能在一个上下文中运行。
 
 6 上下文切换：当你在单个进程里切换执行不同的线程时存储与恢复执行状态的过程。

 7 并行和并发：并行是真正的利用多核优势，通过并行来同时执行多个线程。为了使单核设备也能够这样，它必须先执行一个线程，执行一个上下文切换，然后运行另一个线程（类似于计算机的时间片轮转）

 8 队列：队列管理你提供给GCD的任务并用FIFO顺序执行这些任务，所有的调度队列自身都是线程安全的。
 
 9 串行队列：串行队列中的任务一次执行一个，每个任务只在前一个任务完成时才开始，并且按照我们添加到队列的顺序来执行

 10 并发队列：在并发队列中的任务能得到的保证是它们会按照被添加的顺序开始执行，任务可能以任意顺序完成，不会知道何时开始运行下一个任务，或者任意时刻有多少Block在运行。何时开始一个Block完全取决于GCD。如果一个Block的执行时间与另一个重叠，也是由GCD来决定是否将其运行在另一个不同的核心上，
 
 */

/*
 
 Dispatch barriers 是一组函数，在并发队列上工作时扮演一个串行式的瓶颈。使用GCD的barrierApi确保提交的Block 在那个特定时间上是指定队列上唯一被执行的条目。所有的先于调度障碍提交到队列的条目必能在这个block执行前完成
 
 何时会/不会使用barrier
 1  自定义串行队列：一个很坏的选择，障碍不会有任何帮助，因为不管怎样，一个串行队列一次都只执行一个操作
 2  全局并发队列：要小心，因为其他系统可能在使用队列，而你不能只为你工作
 3  *自定义并发队列：这对于原子或临界区代码来说是个不错的选择。任何你在设置或实例化的需要线程安全的事物都是使用障碍的最佳候选
 
 */

/*
 dispatch_sync() 同步的提交工作并在返回前等待它完成。如果你调用 dispatch_sync 并放在你已运行着的当前队列，这会导致死锁
 1  自定义串行队列：小心，如果你正在运行一个队列并调用dispatch_sync放在同一个队列，那你百分百的创建了一个死锁
 2  主队列（串行）：同上
 3  并发队列：这才是做同步工作的好选择，需要等待一个任务完成才能执行进一步处理的情况
 */

/*
 dispatch_async() 添加一个block到队列就立即返回了。任务会在之后又GCD决定执行，当你需要在后台执行一个基于网络或CPU紧张的任务时就是用 dispatch_async，这样就不会阻塞当前线程
 如何及何时使用在不同的队列上
 1  自定义串行队列：当你想串行执行后天任务并追踪它时就是一个好选择，这消除了资源征用，因为你知道一次只有一个任务在执行。注意若你需要来自某个方法的数据，你必须内联另一个block来找回它或考虑使用dispatch_sync.
 2  主队列（串行）：这是在一个并发队列上完成任务后更新UI的共同选择。要这样做，你将在一个Block内部编写另一个Block。以及，如果你在朱队列调用 dispatch_async 到主队列，你能确保这个新任务将在当前方法完成后的某个时间执行
 3  并发队列：这是在后台执行非UI工作的共同选择。
 
 */

@interface ViewController ()
@property (atomic,strong) dispatch_semaphore_t semaphore;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self disPatchGroup:nil];
//    [self asyncQueue];
//    [self syncSerial];
//    [self syncConcurrent];
//    [self asyncSerial];
//    [self asyncConcurrent];
    
//    [self OperationQueue];
}

/**
 *  异步：在新的线程中执行任务，具备开启新线程的能力
 */
// 异步并发
- (IBAction)asyncConcurrent {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSLog(@"异步并发1 ----%@", [NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
//        sleep(1);
        NSLog(@"异步并发2 ----%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
//        sleep(2);
        NSLog(@"异步并发3 ----%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
//        sleep(3);
        NSLog(@"异步并发4 ----%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{

        NSLog(@"异步并发5 ----%@", [NSThread currentThread]);
    });
    
//    NSLog(@"写在最后....%@", [NSThread currentThread]);
}

// 异步串行
- (IBAction)asyncSerial {
    
    dispatch_queue_t queue = dispatch_queue_create("com.zhang.dong", NULL);;
    dispatch_async(queue, ^{
        NSLog(@"异步串行1 ----%@", [NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
    
        NSLog(@"异步串行2 ----%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
      
        NSLog(@"异步串行3 ----%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{

        NSLog(@"异步串行4 ----%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{

        NSLog(@"异步串行5 ----%@", [NSThread currentThread]);
    });

    NSLog(@"写在最后....%@", [NSThread currentThread]);
}

/**
 *  同步不会开辟线程
 */
// 同步并发
- (IBAction)syncConcurrent {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        NSLog(@"同步并发1 ----%@", [NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        sleep(1);
        NSLog(@"同步并发2 ----%@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        sleep(2);
        NSLog(@"同步并发3 ----%@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        sleep(3);
        NSLog(@"同步并发4 ----%@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        sleep(4);
        NSLog(@"同步并发5 ----%@", [NSThread currentThread]);
    });

    
}

// 同步串行队列
- (IBAction)syncSerial {
    
    dispatch_queue_t queue = dispatch_queue_create("com.zhang.dong", NULL);;
    dispatch_sync(queue, ^{
        NSLog(@"同步串行1 ----%@", [NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        sleep(1);
        NSLog(@"同步串行2 ----%@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        sleep(2);
        NSLog(@"同步串行3 ----%@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        sleep(3);
        NSLog(@"同步串行4 ----%@", [NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        sleep(4);
        NSLog(@"同步串行5 ----%@", [NSThread currentThread]);
    });
}

/**
 *  异步到串行队列，异步函数要执行的任务会被排到队列的后面，只有当目前这个方法执行完毕后才会过来执行这个任务，如果有多个异步函数，那么任务会依次执行
 */
- (IBAction)asyncQueue {
    
    // 主队列
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//           
//            NSLog(@"任务一：%@", [NSThread currentThread]);
//        });
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            NSLog(@"任务二：%@", [NSThread currentThread]);
//        });
//        
//        NSLog(@"任务三：%@", [NSThread currentThread]);
//    }
    
    // 创建的串行队列
    {
    
        dispatch_queue_t queue = dispatch_queue_create("com.demo.serialQueue", DISPATCH_QUEUE_SERIAL);
        
        
        NSLog(@"任务一：%@", [NSThread currentThread]);
        dispatch_async(queue, ^{
            
            NSLog(@"任务二：%@", [NSThread currentThread]);
        });
        
        dispatch_async(queue, ^{
            
            NSLog(@"任务三：%@", [NSThread currentThread]);
        });
        
        NSLog(@"任务四：%@", [NSThread currentThread]);
    }
    
}

- (IBAction)deadLock:(id)sender {
    
    // 1 同步到所在队列会造成死锁
    dispatch_sync(dispatch_get_main_queue(), ^{
       
        // 这句代码永远不会执行
        NSLog(@"%@_%d", [NSThread currentThread], [NSThread isMainThread]);
    });
    
    // 这句也不会执行
    NSLog(@"方法执行完成");
}

- (IBAction)concurrentQueue:(id)sender {
    
    dispatch_queue_t concurrent_queue = dispatch_queue_create("com.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
    // 在非主队列并行执行一个异步函数
    dispatch_async(concurrent_queue, ^{
        NSLog(@"任务开始: %@", [NSThread currentThread]);
        // 执行异步函数
        dispatch_async(concurrent_queue, ^{
            NSLog(@"任务1: %@", [NSThread currentThread]);
        });
        // 执行同步函数
        dispatch_sync(concurrent_queue, ^{
            // 当前任务睡2秒
            sleep(2.0);
            NSLog(@"任务2: %@", [NSThread currentThread]);
        });
        // 执行异步函数
        dispatch_async(concurrent_queue, ^{
            NSLog(@"任务3: %@", [NSThread currentThread]);
        });
        NSLog(@"任务执行完毕");
    });
    NSLog(@"方法执行完毕");
}


/**
 *  执行dispatch_barrier_async必须在 自己创建的concurrent，如果在串行队列或者全局并发队列中使用，效果如同dispatch_async
 *
 *  在当前队列总执行dispatch_barrier_sync 会造成死锁，可以在其他并发队列中使用
 */
- (IBAction)barrierQueue:(id)sender {
    // 创建一个并发的队列
    dispatch_queue_t concurrent_queue = dispatch_queue_create("my_queue", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_queue_t concurrent_queue2 = dispatch_queue_create("com.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);

    // 执行异步函数
    dispatch_async(concurrent_queue, ^{
        NSLog(@"任务开始: %@", [NSThread currentThread]);
        
        dispatch_async(concurrent_queue, ^{
            NSLog(@"任务1: %@", [NSThread currentThread]);
        });
        dispatch_async(concurrent_queue, ^{
            NSLog(@"任务2: %@", [NSThread currentThread]);
        });
        // 执行栅栏函数
        //dispatch_barrier_sync 会造成死锁
//        dispatch_async(concurrent_queue2, ^{
//            NSLog(@"其他并发队列中 %@", [NSThread currentThread]);
//        });
//        
//        dispatch_barrier_sync(concurrent_queue2, ^{
//            NSLog(@"任务3: %@", [NSThread currentThread]);
//        });
        dispatch_barrier_async(concurrent_queue, ^{
             NSLog(@"任务3: %@", [NSThread currentThread]);
        });
        
        dispatch_async(concurrent_queue, ^{
            NSLog(@"任务4: %@", [NSThread currentThread]);
        });
        dispatch_async(concurrent_queue, ^{
            NSLog(@"任务5: %@", [NSThread currentThread]);
        });
        NSLog(@"任务完毕");
    });
}

/**
 *  迭代 在并发队列中
 *
 */
- (IBAction)dispatchApply:(id)sender {
    
    /**
     *  迭代函数
     *
     *  @param iterations 迭代次数
     *  @param queue      执行的队列
     *  @param size_t     当前迭代的索引
     *
     */
    
    dispatch_apply(5, dispatch_get_global_queue(0, 0), ^(size_t index) {
        
        // 需要迭代的代码，迭代顺序不确定
    });
    
}

- (IBAction)disPatchGroup:(id)sender {
    
    // 创建一个队列组函数
    dispatch_group_t group = dispatch_group_create();
    
    // 获得当前全局队列
//    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
//
//    // 执行组函数
//    dispatch_group_async(group, queue, ^{
//        NSLog(@"任务1: %@", [NSThread currentThread]);
//    });
//    dispatch_group_async(group, queue, ^{
//        NSLog(@"任务2: %@", [NSThread currentThread]);
//    });
//
//    // 当所有组函数执行完毕后执行dispatch_group_notify
//    dispatch_group_notify(group, queue, ^{
//        NSLog(@"当任务1和任务2执行完毕后通知执行任务3: %@", [NSThread currentThread]);
//    });
    
    dispatch_queue_t queue = dispatch_queue_create("group_test", DISPATCH_QUEUE_SERIAL);
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 5; i ++) {
            
//            self.semaphore = dispatch_semaphore_create(0);
            NSLog(@" ++++++++++ %@ +++++++++", self.semaphore);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSLog(@"- 1 --- %d ----- %@ ---", i, [NSThread currentThread]);
//                if (self.semaphore) {
//                    dispatch_semaphore_signal(self.semaphore);
//                }
                NSLog(@"- 2 --- %d ----- %@ ---", i, [NSThread currentThread]);
            });
            
            NSLog(@"- 3 --- %d ----- %@ ---", i, [NSThread currentThread]);
//            if (self.semaphore) {
//                dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
//            }
            NSLog(@"- 4 --- %d ----- %@ ---", i, [NSThread currentThread]);
            self.semaphore = nil;
        }
    });
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"========= %@ =========", [NSThread currentThread]);
    });
    
}

/**
 *  dispatch_suspend并不会立即暂停正在运行的block, 而是在当前block执行完成后, 暂停后续的block执行.
 *
 */
- (IBAction)disPatchSuspend:(id)sender {
//    dispatch_suspend(<#dispatch_object_t object#>)
}

- (IBAction)disPatchResume:(id)sender {
//    dispatch_resume(<#dispatch_object_t object#>)
}

- (void)OperationQueue {
    dispatch_group_t group = dispatch_group_create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(10);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (int i = 0; i < 20; i++)
    {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_group_async(group, queue, ^{
            NSLog(@"%i__%@",i, [NSThread currentThread]);
            sleep(2);
            dispatch_semaphore_signal(semaphore);
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//    dispatch_release(group);
//    dispatch_release(semaphore);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
