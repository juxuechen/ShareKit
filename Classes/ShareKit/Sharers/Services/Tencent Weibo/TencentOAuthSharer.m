//
//  TencentOAuthSharer.m
//  ShareKit
//
//  Created by icyleaf on 12-5-3.
//  Copyright (c) 2012年 icyleaf.com. All rights reserved.
//

#import "TencentOAuthSharer.h"
#import "TencentOAMutableURLRequest.h"

@implementation TencentOAuthSharer

#pragma mark Request

- (void)tokenRequest
{
	SHKLog(@"%s", __FUNCTION__);
    
    SHKLog(@"Request URL: %@", requestURL);
    
    NSString *serviceStr;
	[[SHKActivityIndicator currentIndicator] displayActivity:@"正在连接..."];
	
    TencentOAMutableURLRequest *oRequest = [[TencentOAMutableURLRequest alloc] initWithURL:requestURL
                                                                    consumer:consumer
                                                                       token:nil   // we don't have a Token yet
                                                                       realm:nil   // our service provider doesn't specify a realm
														   signatureProvider:signatureProvider
                                                                 serviceFlag:serviceStr
																loadingFirst:YES];
	
	[oRequest setHTTPMethod:@"GET"];
	
	[self tokenRequestModifyRequest:oRequest];
	
    OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oRequest
                                                                                          delegate:self
                                                                                 didFinishSelector:@selector(tokenRequestTicket:didFinishWithData:)
                                                                                   didFailSelector:@selector(tokenRequestTicket:didFailWithError:)];
	[fetcher start];	
	[oRequest release];
}

@end
