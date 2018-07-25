//
//  RequestViewModel.h
//  gitTestDemo
//
//  Created by YooEE on 2018/7/24.
//  Copyright © 2018年 YooEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface Book : NSObject

@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *image;


@end


@interface RequestViewModel : NSObject

// 请求命令
@property (nonatomic, strong, readonly) RACCommand *reuqesCommand;

//模型数组
@property (nonatomic, strong) NSArray *models;
@end
