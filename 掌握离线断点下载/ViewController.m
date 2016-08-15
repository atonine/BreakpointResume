//
//  ViewController.m
//  掌握离线断点下载
//
//  Created by 于洪志 on 16/8/14.
//  Copyright © 2016年 于洪志. All rights reserved.
//
#define YHZFileFullPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject]stringByAppendingPathComponent:[YHZFileURL lastPathComponent]]
#define YHZFileURL  self.url

#define YHZFileName [YHZFileURL lastPathComponent]

#define YHZDownLoadSize [[[NSFileManager defaultManager]attributesOfItemAtPath:YHZFileFullPath error:nil][NSFileSize] integerValue]


//储存文件总长度的文件路径(caches)
#define YHZTotalLenthFullPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject]stringByAppendingPathComponent:@"totalLenth.plist"]


#import "ViewController.h"
#import "NSString+Hash.h"
@interface ViewController ()<NSURLSessionDataDelegate>
@property(nonatomic,strong)NSURLSession*session;
/**task*/
@property(nonatomic,strong)NSURLSessionDataTask*task;




/**文件总长度*/
@property(nonatomic,assign)NSInteger totalLength;


/**<#注释#>*/
@property(nonatomic,strong)NSOutputStream*stream;

@end

@implementation ViewController
- (IBAction)startBtnClicked:(id)sender {

    [self.task resume];


}

-(NSURLSessionDataTask *)task{
    if (_task==nil) {
      //  self.url -
       // NSInteger totalSize = [[NSDictionary dictionaryWithContentsOfFile:YHZTotalLenthFullPath][YHZFileFullPath]integerValue];
        NSDictionary*dict =[NSDictionary dictionaryWithContentsOfFile:YHZTotalLenthFullPath];
        NSLog(@"%@",dict[YHZFileName]);
        NSInteger totalSize = [dict[YHZFileName] integerValue];
         NSLog(@"%zd",YHZDownLoadSize);
        if (YHZDownLoadSize==totalSize&&totalSize) {

            NSLog(@"已经下载过了");

        }
        NSMutableURLRequest*request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:YHZFileURL]];
        NSString* range = [NSString stringWithFormat:@"bytes=%zd-",YHZDownLoadSize];
        [request setValue:range forHTTPHeaderField:@"Range"];
         _task = [self.session dataTaskWithRequest:request];

    }
    return _task;
}
- (IBAction)suspendBtnClicked:(id)sender {
    [self.task suspend];

    
}
-(NSOutputStream *)stream{
    if (_stream==nil) {
        _stream =[NSOutputStream outputStreamToFileAtPath:YHZFileFullPath append:YES];
    }
    return _stream;
}
-(NSURLSession *)session{
    if (_session==nil) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]delegate:self delegateQueue:[[NSOperationQueue alloc]init]];
    }
    return _session;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.url = @"http://120.25.226.186:32812/resources/videos/minion_02.mp4";
    NSLog(@"%@",YHZFileFullPath);
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//
/**
 接收到响应
 */
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    [self.stream open];
     self.totalLength = [response.allHeaderFields[@"Content-Length"] integerValue]+YHZDownLoadSize;
    NSMutableDictionary*dict = [NSMutableDictionary dictionaryWithContentsOfFile:YHZTotalLenthFullPath];
    if (dict == nil) {
        dict = [NSMutableDictionary dictionary];

    }
    dict[YHZFileName] = @(self.totalLength);
    [dict writeToFile:YHZTotalLenthFullPath atomically:YES];
    completionHandler(NSURLSessionResponseAllow);


}
/**
 接受数据（可能会被调用多次）
 */
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    //写入文件
    [self.stream write:data.bytes maxLength:data.length];


    //目前的下载长度

    NSInteger downloadLength= [[[NSFileManager defaultManager] attributesOfItemAtPath:YHZFileFullPath error:nil][NSFileSize]integerValue];

    NSLog(@"%f",1.0*downloadLength/self.totalLength);


}
/**
 完成
 */
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    [self.stream close];
    self.stream = nil ;
    self.task = nil;


}
@end
