//
//  ViewController.m
//  gitTestDemo
//
//  Created by YooEE on 2018/7/20.
//  Copyright © 2018年 YooEE. All rights reserved.
//

#import "ViewController.h"
#import "RequestViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <SDWebImage/UIImageView+WebCache.h>


@interface ViewController ()<UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;



@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) RequestViewModel *requesViewModel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[[self.phoneField.rac_textSignal
      map:^id(id value) {
          NSString *text = value;
          return @(text.length);
      }]
     filter:^BOOL(NSNumber *length) {
         return [length integerValue]>3;
     }]
     subscribeNext:^(id x) {
         NSLog(@"%@",x);
     }];
    
   RACSignal *validPhoneSignal = [self.phoneField.rac_textSignal
   map:^id(NSString *text) {
       return @([self isValidUsername:text]);
   }];
    
    RACSignal *validPwdSignal = [self.pwdField.rac_textSignal
    map:^id(NSString *value) {
        return @([self isValidPassword:value]);
   }];
    
    
//    [[validPhoneSignal map:^id(NSNumber *photoValue) {
//        return [photoValue boolValue]?[UIColor clearColor]:[UIColor yellowColor];
//    }]
//
//     subscribeNext:^(UIColor *color){
//         self.phoneField.backgroundColor = color;
//     }];
    
    
    RAC(self.phoneField,backgroundColor) =
    [validPhoneSignal map:^id(NSNumber *photoValue) {
        return [photoValue boolValue]?[UIColor clearColor]:[UIColor yellowColor];
    }];
    
    RAC(self.pwdField,backgroundColor) =
    [validPwdSignal map:^id(NSNumber *numbervalue) {
        return [numbervalue boolValue]?[UIColor clearColor]:[UIColor greenColor];
    }];
    
    RACSignal *signUpActiveSignal = [RACSignal combineLatest:@[validPhoneSignal,validPwdSignal] reduce:^id(NSNumber *phoneVlid,NSNumber *pwdValid){
        return @([phoneVlid boolValue]&&[pwdValid boolValue]);
    }];
    
    [signUpActiveSignal subscribeNext:^(NSNumber *signalActive) {
        self.loginBtn.enabled = [signalActive boolValue];
    }];
    
    RACSignal *signSianal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:self.loginBtn];
        [subscriber sendCompleted];
        return nil;
    }];
    
    [self creatSignal];
    
    
    [self creatTableView];

}

- (void)creatSignal
{
    // 1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // block调用时刻：每当有订阅者订阅信号，就会调用block。
        
        
        // 2.发送信号
        [subscriber sendNext:@1];
        // 如果不在发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号
        [subscriber sendCompleted];
        
        // block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
        
        // 执行完Block后，当前信号就不在被订阅了。
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号被销毁");
        }];
    }];
    // 3.订阅信号,才会激活信号
    [signal subscribeNext:^(id x) {
        // block调用时刻：每当有信号发出数据，就会调用block
        NSLog(@"接收到数据：%@,",x);
    }];
    

}

//RACSubject替换代理
- (void)creatRACSubject
{
    //创建信号
    RACSubject *subject = [RACSubject subject];
    
    //订阅信号
    [subject subscribeNext:^(id x) {
        NSLog(@"收到信息");
    }];
    //发送信号
    [subject sendNext:@1];
}

//RACSequence  集合类，用于代替NSAarray ,NSDictionary ,可以使用它来快速遍历数组和字典
- (void)creatSequence
{
    // 1.遍历数组
    NSArray *numbers = @[@1,@2,@3,@4];
    [numbers.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 2.遍历字典,遍历出来的键值对 都会包装成 RACTuple(元组对象) @[key, value]
    NSDictionary *dic = @{@"name": @"BYqiu", @"age": @18};
    [dic.rac_sequence.signal subscribeNext:^(RACTuple *x) {
       //解元组包，会把元组的值，按顺序给参数里的变量赋值
        RACTupleUnpack(NSString *key,NSString *value) = x;
        NSLog(@"%@ %@",key,value);
    }];
    
    //字典转模型
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flags.plist" ofType:nil];
    
    NSArray *dicArray = [NSArray arrayWithContentsOfFile:filePath];
    
    NSMutableArray *items = [NSMutableArray array];

    [dicArray.rac_sequence.signal subscribeNext:^(id x) {
        //FlagItem *item = [FlagItem flagWithDict:dict];
        //[items addObject:item];
    }];
    
}

- (void)bindModel
{
    RAC(self.phoneField,text) = self.phoneField.rac_textSignal;
    [[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
    
    }];
}

- (BOOL)isValidUsername:(NSString *)text
{
    return text.length>3;
}


- (BOOL)isValidPassword:(NSString *)text
{
    return text.length>3;
}


- (IBAction)loginBtn:(UIButton *)sender {
     [self.view addSubview:self.tableView];
    
    RACSignal *requesSiganl = [self.requesViewModel.reuqesCommand execute:nil];
    
    //订阅信号
    [requesSiganl subscribeNext:^(NSArray *x) {
        
        self.requesViewModel.models = x;
        
        [self.tableView reloadData];
    }];
}

- (void)creatTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    
    self.tableView.dataSource = self;
    
   
    
    //
   

}

- (RequestViewModel *)requesViewModel
{
    if (_requesViewModel == nil) {
        _requesViewModel = [[RequestViewModel alloc] init];
    }
    return _requesViewModel;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.requesViewModel.models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    Book *book = self.requesViewModel.models[indexPath.row];
    cell.detailTextLabel.text = book.subtitle;
    cell.textLabel.text = book.title;
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:book.image] placeholderImage:[UIImage imageNamed:@"cellImage"]];
    
    return cell;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
