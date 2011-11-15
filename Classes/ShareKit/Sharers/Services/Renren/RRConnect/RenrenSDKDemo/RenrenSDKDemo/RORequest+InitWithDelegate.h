//
//  RORequest+InitWithDelegate.h
//  RenrenSDKDemo
//
//  Created by renren-inc on 11-8-23.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//

#import <Foundation/Foundation.h>

@interface RORequest(InitWithDelegate) 

+ (RORequest *)getRequestWithParam:(RORequestParam *)param httpMethod:(NSString *)httpMethod delegate:(id<RORequestDelegate>)delegate requestURL:(NSString *)url;

@end
