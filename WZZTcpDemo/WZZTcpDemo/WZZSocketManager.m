//
//  WZZSocketManager.m
//  WZZTcpDemo
//
//  Created by 王泽众 on 16/10/21.
//  Copyright © 2016年 wzz. All rights reserved.
//

#import "WZZSocketManager.h"

#pragma mark - 服务端
@implementation WZZSocketServerManager
{
    void (^_handleDataBlock)(NSData *);//返回数据block
}

static WZZSocketServerManager *_sinstance;

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sinstance = [super allocWithZone:zone];
    });
    
    return _sinstance;
}

+ (instancetype)sharedServerManager
{
    if (_sinstance == nil) {
        _sinstance = [[WZZSocketServerManager alloc] init];
    }
    
    _sinstance->_serverSocket = [[WZZAsyncSocket alloc] initWithDelegate:_sinstance];
    
    return _sinstance;
}

//创建服务器
- (BOOL)creatServerWithPort:(NSString *)port timeOut:(int)timeOut handleData:(void (^)(NSData *))handleDataBlock {
    if (_handleDataBlock != handleDataBlock) {
        _handleDataBlock = handleDataBlock;
    }
    [_serverSocket disconnect];
    NSError * err;
    [_serverSocket acceptOnPort:[port intValue] error:&err];
    [_serverSocket readDataWithTimeout:-1 tag:0];
    if (err) {
        NSLog(@"服务端:错误信息:%@", err);
        return NO;
    }
    NSLog(@"服务端:socket监听创建成功");
    return YES;
}

//断开连接
- (void)disconnectClient {
    [_serverSocket disconnect];
}

//发送数据
- (void)sendDate:(NSData *)data {
    [_serverSocket writeData:data withTimeout:-1 tag:0];
}

//发送文本
- (void)sendString:(NSString *)string {
    [self sendDate:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark - 服务端代理
//客户端将要连接3.
- (BOOL)onSocketWillConnect:(WZZAsyncSocket *)sock {
    NSLog(@"服务端:将要连接");
    return YES;
}

//客户端要连接，服务端为客户端开辟新套接字2.
- (void)onSocket:(WZZAsyncSocket *)sock didAcceptNewSocket:(WZZAsyncSocket *)newSocket {
    _serverSocket = newSocket;
    [_serverSocket readDataWithTimeout:-1 tag:0];
    NSLog(@"服务端:\nserver IP:%@:%d\nclient IP:%@:%d", newSocket.localHost, newSocket.localPort, newSocket.connectedHost, newSocket.connectedPort);
}

//读到数据
- (void)onSocket:(WZZAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"服务端:读到数据");
    if (_handleDataBlock) {
        _handleDataBlock(data);
    }
    [_serverSocket readDataWithTimeout:-1 tag:0];
}

//写数据
- (void)onSocket:(WZZAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"服务端:写数据");
}

@end

#pragma mark - 客户端
@implementation WZZSocketClientManager

static WZZSocketClientManager *_cinstance;

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cinstance = [super allocWithZone:zone];
    });
    
    return _cinstance;
}

+ (instancetype)sharedClientManager
{
    if (_cinstance == nil) {
        _cinstance = [[WZZSocketClientManager alloc] init];
    }
    
    _cinstance->_clientSocket = [[WZZAsyncSocket alloc] initWithDelegate:_cinstance];
    
    return _cinstance;
}

//连接服务器
- (BOOL)connectServerWithHost:(NSString *)host port:(NSString *)port {
    [_clientSocket disconnect];
    NSError * err;
    [_clientSocket connectToHost:host onPort:[port intValue] error:&err];
    if (err) {
        NSLog(@"客户端:错误信息:%@", err);
        return NO;
    }
    [_clientSocket readDataWithTimeout:-1 tag:0];
    return YES;
}

//取消连接
- (void)disconnectServer {
    [_clientSocket disconnect];
}

//发送文本
- (void)sendString:(NSString *)string {
    [self sendDate:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

//发送数据
- (void)sendDate:(NSData *)data {
    [_clientSocket writeData:data withTimeout:-1 tag:0];
}

#pragma mark - 客户端代理
//客户端将要连接服务端1.
- (BOOL)onSocketWillConnect:(WZZAsyncSocket *)sock {
    NSLog(@"客户端:将要连接服务器");
    return YES;
}

//已经连接上服务端4.
- (void)onSocket:(WZZAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"客户端:已连接上:%@:%d", host, port);
}

//读到数据
- (void)onSocket:(WZZAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"客户端:读到数据");
    [_clientSocket readDataWithTimeout:-1 tag:0];
}

//写数据
- (void)onSocket:(WZZAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"客户端:写数据");
}

@end
