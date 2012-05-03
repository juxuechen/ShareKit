//
//  TencentOAMutableURLRequest.h
//  ShareKit
//
//  Created by icyleaf on 12-5-3.
//  Copyright (c) 2012年 icyleaf.com. All rights reserved.
//

#import "OAMutableURLRequest.h"

@interface TencentOAMutableURLRequest : OAMutableURLRequest
{
@protected
    BOOL firstLoading;

}
@property BOOL firstLoading;

- (id)initWithURL:(NSURL *)aUrl
		 consumer:(OAConsumer *)aConsumer
			token:(OAToken *)aToken
            realm:(NSString *)aRealm
signatureProvider:(id<OASignatureProviding, NSObject>)aProvider
	  serviceFlag:(NSString *)flagStr
	 loadingFirst:(BOOL)isFirst;

- (id)initWithURL:(NSURL *)aUrl
		 consumer:(OAConsumer *)aConsumer
			token:(OAToken *)aToken
            realm:(NSString *)aRealm
signatureProvider:(id<OASignatureProviding, NSObject>)aProvider
            nonce:(NSString *)aNonce
        timestamp:(NSString *)aTimestamp
	  serviceFlag:(NSString *)flagStr;

@end
