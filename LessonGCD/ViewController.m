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
 
 2 同步和异步：一个同步函数只在完成了它预定的任务后才返回，一个异步函数会立即返回，预定的任务完成但不会等它完成。同步函数会阻塞当前线程，异步函数不会阻塞当前线程
 
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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"任务1_%@_%d", [NSThread currentThread], [NSThread isMainThread]);
//    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//            NSLog(@"任务2_%@_%d", [NSThread currentThread], [NSThread isMainThread]);
//    });

    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"任务2_%@_%d", [NSThread currentThread], [NSThread isMainThread]);
    });
    

    for (int i = 0; i < 5000; i ++) {
        NSLog(@"任务3_%@_%d", [NSThread currentThread], [NSThread isMainThread]);
    }
    for (int i = 0; i < 5000; i ++) {
        NSLog(@"任务4_%@_%d", [NSThread currentThread], [NSThread isMainThread]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
