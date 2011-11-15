//
//  RORequest+InitWithDelegate.m
//  RenrenSDKDemo
//
//  Created by renren-inc on 11-8-23.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//

#import "RORequest+InitWithDelegate.h"
#import "LogManager.h"

@implementation RORequest(InitWithDelegate)

+ (RORequest *)getRequestWithParam:(RORequestParam *)param httpMethod:(NSString *)httpMethod delegate:(id<RORequestDelegate>)delegate requestURL:(NSString *)url{
    RORequest* request = [[[RORequest alloc] init] autorelease];
    request.delegate = delegate;
    request.debugDelegate = [LogManager getInstance]; // 这里是category里面新加的。
    request.url = url;
    request.httpMethod = httpMethod;
    request.requestParamObject = param;
    request.params = [param requestParamToDictionary];
	NSLog(@"%@",request.params);
    request.connection = nil;
    request.responseData = nil;
    request.responseObject = nil;
    return request;
}

@end
