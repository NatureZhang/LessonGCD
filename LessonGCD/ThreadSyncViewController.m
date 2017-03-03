//
//  ThreadSyncViewController.m
//  LessonGCD
//
//  Created by zhangdong on 2017/3/3.
//  Copyright © 2017年 zhangdong. All rights reserved.
//

// 参考：http://www.cnblogs.com/Quains/p/3182823.html

#import "ThreadSyncViewController.h"

static NSString *imageUrlStr = @"http://avatar.csdn.net/B/2/2/1_u010013695.jpg";

@interface ThreadSyncViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSDate *startDate;
@end

@implementation ThreadSyncViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//辅助函数
- (UIImage *)imageDownloadFromNetWork {
    
    NSURL *url = [NSURL URLWithString:imageUrlStr];
    NSError *downloadError = nil;
    NSData *imageData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:nil error:&downloadError];
    if (downloadError == nil && imageData != nil) {
        return [UIImage imageWithData:imageData];
    }
    else if(downloadError != nil){
        NSLog(@"error happened = %@", downloadError);
    }
    else{
        NSLog(@"No data download");
    }

    return nil;
}

- (void)showImage:(UIImage *)image {
    
    if (image != nil) {
        self.imageView.image = image;
        NSDate *endTime = [NSDate date];
        NSLog(@"completed in %f time", [endTime timeIntervalSinceDate:_startDate]);
    }
    else{
        NSLog(@"image isn't downloaded, nothing to display");
    }
}
// 队列都是先进先出的，同步方式sync 和 异步方式async 配合串行队列和并行队列使用
- (IBAction)syncQueue:(id)sender {
    
    //清空图片
    self.imageView.image = nil;
    [self.imageView layoutSubviews];
    
//    sleep(2);
    
    //串行队列
    dispatch_queue_t serilQueue = dispatch_queue_create("com.image.queue", 0);
    
    //开始时间
    _startDate = [NSDate date];
    
    __block UIImage *image = nil;
    
    //网上下载图片
    dispatch_async(serilQueue, ^{
        


//        NSURLSession *imageSession = [NSURLSession sharedSession];
//        NSURLSessionDataTask *dataTask = [imageSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // 这个是异步的网络请求
//            if (error == nil &&  data != nil) {
//                image = [UIImage imageWithData:data];
//            }
//            else if (error != nil) {
//                NSLog(@"error happened = %@", error);
//            }
//            else {
//                NSLog(@"No data download");
//            }
//            
//            
//        }];
//        
//        [dataTask resume];
        
        image = [self imageDownloadFromNetWork];
    });
    
    //回到主线程刷新UI
    dispatch_async(serilQueue, ^{
    
        NSLog(@"%@",[NSThread currentThread]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showImage:image];
        });
        
    });
}

- (IBAction)asyncQueue:(id)sender {
    
    //清空图片
    self.imageView.image = nil;

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //创建一个队列
        dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        //记时
        _startDate = [NSDate date];
        
        //加入队列
        __block UIImage *image = nil;
        
        //下载图片
        dispatch_sync(concurrentQueue, ^{
            
            image = [self imageDownloadFromNetWork];
        });
        
        //在主线程显示
        dispatch_sync(concurrentQueue, ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showImage:image];
            });
            
        });
        
    });

}

- (IBAction)groupQueue:(id)sender {
    
    //清空图片
    self.imageView.image = nil;

    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    __block UIImage *image = nil;
    dispatch_group_async(group, queue, ^{
        //下载图片
        image = [self imageDownloadFromNetWork];
    });
    
    dispatch_group_notify(group, queue, ^{
       
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showImage:image];
        });
    });
}

- (IBAction)semaphore:(id)sender {
    
    //清空图片
    self.imageView.image = nil;
    
    //信号量初始化
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    __block UIImage *image = nil;
    
    // 这种形式并不能同步，因为先执行哪个队列是不能确定的
    
    dispatch_async(queue, ^{
       
        //获取这个信号量 wait操作-1
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
//        image = [self imageDownloadFromNetWork];
        NSLog(@"1_%@---------", [NSThread currentThread]);

        //释放这个信号量 signal操作+1
//        dispatch_semaphore_signal(semaphore);
        
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        //获取这个信号量 wait操作-1
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
//        [self showImage:image];
        NSLog(@"2_%@", [NSThread currentThread]);

        //释放这个信号量 signal+1
//        dispatch_semaphore_signal(semaphore);
        
    });

    // dispatch_wait 会阻塞线程并且检测信号量的值，直到信号量值大于0才会开始往下执行，同时对信号量执行 -1 操作，dispatch_signal则是+1操作
}

@end
