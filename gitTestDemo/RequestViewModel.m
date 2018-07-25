//
//  RequestViewModel.m
//  gitTestDemo
//
//  Created by YooEE on 2018/7/24.
//  Copyright © 2018年 YooEE. All rights reserved.
//

#import "RequestViewModel.h"
#import "AFNetworking.h"


@implementation Book

- (instancetype)initWithValue:(NSDictionary *)value {
    
    if (self = [super init]) {
        
        self.title = value[@"title"];
        self.subtitle = value[@"subtitle"];
        self.image = value[@"image"];
    }
    return self;
}

+ (Book *)bookWithDict:(NSDictionary *)value {
    
    return [[self alloc] initWithValue:value];
}



@end

@implementation RequestViewModel

- (instancetype)init
{
    if (self = [super init]) {
        
        [self initialBind];
    }
    return self;
}


- (void)initialBind
{
    _reuqesCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        RACSignal *requestSiganl = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            parameters[@"q"] = @"悟空传";
            
            //
            [[AFHTTPSessionManager manager] GET:@"https://api.douban.com/v2/book/search" parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
                
                NSLog(@"downloadProgress: %@", downloadProgress);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                // 数据请求成功就讲数据发送出去
                NSLog(@"responseObject:%@", responseObject);
                
                [subscriber sendNext:responseObject];
                
                [subscriber sendCompleted];
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                NSLog(@"error: %@", error);
            }];
            
            
            return nil;
        }];
        
        // 在返回数据信号时，把数据中的字典映射成模型信号，传递出去
        return [requestSiganl map:^id(NSDictionary *value) {

            NSMutableArray *dictArr = value[@"books"];

            NSArray *modelArr = [[dictArr.rac_sequence map:^id(id value) {

                return [Book bookWithDict:value];

            }] array];

            return modelArr;

        }];
        
    }];
}


@end
