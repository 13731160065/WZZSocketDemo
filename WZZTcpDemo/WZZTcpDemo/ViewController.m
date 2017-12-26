//
//  ViewController.m
//  WZZTcpDemo
//
//  Created by 王泽众 on 16/10/21.
//  Copyright © 2016年 wzz. All rights reserved.
//

#import "ViewController.h"
#import "WZZAsyncSocket.h"
#import "WZZSocketManager.h"

@interface ViewController ()
{
    WZZSocketServerManager * sManager;
    WZZSocketClientManager * cManager;
}

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UITextField *ipTF;
@property (weak, nonatomic) IBOutlet UITextField *textTF;
@property (weak, nonatomic) IBOutlet UITextField *myIpTF;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    sManager = [WZZSocketServerManager sharedServerManager];
    cManager = [WZZSocketClientManager sharedClientManager];
}

- (IBAction)sendButton:(id)sender {
    [cManager sendString:_textTF.text];
    [sManager sendString:_textTF.text];
}

- (IBAction)connect:(id)sender {
    NSArray * arr = [_ipTF.text componentsSeparatedByString:@":"];
    if (arr.count == 2) {
        //连接
        BOOL conOK = [cManager connectServerWithHost:arr[0] port:arr[1]];
    } else {
        [_textLabel setText:@"连接失败arr"];
    }
}

- (IBAction)startServer:(id)sender {
    //启动服务
    [sManager creatServerWithPort:_myIpTF.text timeOut:-1 handleData:^(NSData *data) {
        _textLabel.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }];
}

@end
