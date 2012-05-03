//
//  TencentOAMutableURLRequest.m
//  ShareKit
//
//  Created by icyleaf on 12-5-3.
//  Copyright (c) 2012年 icyleaf,com. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "TencentOAMutableURLRequest.h"
#import "OAConsumer.h"
#import "OAToken.h"
#import "OAHMAC_SHA1SignatureProvider.h"
#import "OASignatureProviding.h"
#import "NSMutableURLRequest+Parameters.h"
#import "NSURL+Base.h"


#define NONCE_LENGTH_FOR_TENCENT 32

@interface OAMutableURLRequest (Private)
- (void)_generateTimestamp;
- (void)_generateNonce;
- (NSString *)_signatureBaseString;
- (NSString *)normalizeRequestParameters;
@end


@implementation TencentOAMutableURLRequest
@synthesize firstLoading;


- (id)initWithURL:(NSURL *)aUrl
		 consumer:(OAConsumer *)aConsumer
			token:(OAToken *)aToken
            realm:(NSString *)aRealm
signatureProvider:(id<OASignatureProviding, NSObject>)aProvider 
	  serviceFlag:(NSString *)flagStr
	 loadingFirst:(BOOL)isFirst
{
	if (self = [super initWithURL:aUrl
					  cachePolicy:NSURLRequestReloadIgnoringCacheData
				  timeoutInterval:10.0])
	{
		consumer = [aConsumer retain];
		
		// empty token for Unauthorized Request Token transaction
		if (aToken == nil)
			token = [[OAToken alloc] init];
		else
			token = [aToken retain];
		
		if (aRealm == nil)
			realm = [[NSString alloc] initWithString:@""];
		else
			realm = [aRealm retain];
		
		// default to HMAC-SHA1
		if (aProvider == nil)
			signatureProvider = [[OAHMAC_SHA1SignatureProvider alloc] init];
		else
			signatureProvider = [aProvider retain];
		
		[self _generateTimestamp];
		[self _generateNonce];
		
		didPrepare = NO;
//		firstLoading = isFirst;
	}
    return self;
}

- (id)initWithURL:(NSURL *)aUrl
		 consumer:(OAConsumer *)aConsumer
			token:(OAToken *)aToken
            realm:(NSString *)aRealm
signatureProvider:(id<OASignatureProviding, NSObject>)aProvider
            nonce:(NSString *)aNonce
        timestamp:(NSString *)aTimestamp
	  serviceFlag:(NSString *)flagStr
{
	if (self = [super initWithURL:aUrl
					  cachePolicy:NSURLRequestReloadIgnoringCacheData
				  timeoutInterval:10.0])
	{
		consumer = [aConsumer retain];
		
		// empty token for Unauthorized Request Token transaction
		if (aToken == nil)
			token = [[OAToken alloc] init];
		else
			token = [aToken retain];
		
		if (aRealm == nil)
			realm = [[NSString alloc] initWithString:@""];
		else
			realm = [aRealm retain];
		
		// default to HMAC-SHA1
		if (aProvider == nil)
			signatureProvider = [[OAHMAC_SHA1SignatureProvider alloc] init];
		else
			signatureProvider = [aProvider retain];
		
		//set service flag before generating nonce as special nonce length for tencent service
//		serviceFlag = flagStr;
		
		timestamp = [aTimestamp retain];
		nonce = [aNonce retain];
		
		didPrepare = NO;
	}
    return self;
}


#pragma mark -
#pragma mark Private

- (void)_generateTimestamp
{
    timestamp = [[NSString stringWithFormat:@"%d", time(NULL)] retain];
}

- (void)_generateNonce
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    NSMakeCollectable(theUUID);
    NSString * random = (NSString *)string;
	
	nonce = [[random substringToIndex:NONCE_LENGTH_FOR_TENCENT] copy];

	[random release];
}

- (NSString *)_signatureBaseString
{
    NSString *normalizedRequestParameters = [self normalizeRequestParameters];
    
    // OAuth Spec, Section 9.1.2 "Concatenate Request Elements"
    NSString *ret = [NSString stringWithFormat:@"%@&%@&%@",
					 [self HTTPMethod],
					 [[[self URL] URLStringWithoutQuery] URLEncodedString],
					 [normalizedRequestParameters URLEncodedString]];
    
	NSLog(@"OAMutableURLRequest parameters %@", normalizedRequestParameters);
	
	return ret;
}

- (NSString *)normalizeRequestParameters {
	// OAuth Spec, Section 9.1.1 "Normalize Request Parameters"
    // build a sorted array of both request parameters and OAuth header parameters
    NSMutableArray *parameterPairs = [NSMutableArray arrayWithCapacity:(6)]; // 6 being the number of OAuth params in the Signature Base String
    
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_consumer_key" value:consumer.key] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_signature_method" value:[signatureProvider name]] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_timestamp" value:timestamp] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_nonce" value:nonce] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_version" value:@"1.0"] URLEncodedNameValuePair]];
	
	//新浪和腾讯 oauth特有
//    if (!firstLoading) {
//        [parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_verifier" value:[[NSUserDefaults standardUserDefaults] valueForKey:@"oauth_verifier"]] URLEncodedNameValuePair]];
//    }
	
//	if (firstLoading) {
        [parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_callback" value:@"http://www.qq.com"] URLEncodedNameValuePair]];
//    }
	
    if (![token.key isEqualToString:@""]) {
        [parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_token" value:token.key] URLEncodedNameValuePair]];
    }
	
	for(NSString *parameterName in [[extraOAuthParameters allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
		[parameterPairs addObject:[[OARequestParameter requestParameterWithName:[parameterName URLEncodedString] value: [[extraOAuthParameters objectForKey:parameterName] URLEncodedString]] URLEncodedNameValuePair]];
	}
	
	if (![[self valueForHTTPHeaderField:@"Content-Type"] hasPrefix:@"multipart/form-data"]) {
		for (OARequestParameter *param in [self parameters]) {
			[parameterPairs addObject:[param URLEncodedNameValuePair]];
		}
	}
    
    NSArray *sortedPairs = [parameterPairs sortedArrayUsingSelector:@selector(compare:)];
    NSString *normalizedRequestParameters = [sortedPairs componentsJoinedByString:@"&"];
	
	return normalizedRequestParameters;
}


@end
