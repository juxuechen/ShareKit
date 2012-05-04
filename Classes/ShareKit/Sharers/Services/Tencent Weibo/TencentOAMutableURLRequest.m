//
//  TencentOAMutableURLRequest.m
//  ShareKit
//
//  Created by icyleaf on 12-5-3.
//  Copyright (c) 2012年 icyleaf.com. All rights reserved.
//

//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//


#import <Foundation/Foundation.h>
#import "TencentOAMutableURLRequest.h"
#import "OAConsumer.h"
#import "OAToken.h"
#import "OAHMAC_SHA1SignatureProvider.h"
#import "OASignatureProviding.h"
#import "NSMutableURLRequest+Parameters.h"
#import "NSURL+Base.h"
#import "SHKConfiguration.h"


@interface OAMutableURLRequest (Private)
- (void)_generateTimestamp;
- (void)_generateNonce;
- (NSString *)_signatureBaseString:(NSMutableDictionary *)params;
- (NSString *)_generateQueryString;
@end


@implementation TencentOAMutableURLRequest

- (id)initWithURL:(NSURL *)aUrl 
         consumer:(OAConsumer *)aConsumer 
            token:(OAToken *)aToken 
            realm:(NSString *)aRealm 
signatureProvider:(id<OASignatureProviding,NSObject>)aProvider
  extraParameters:(NSDictionary *)extraParameters
{
    if ((self = [super initWithURL:aUrl
                       cachePolicy:NSURLRequestReloadIgnoringCacheData
                   timeoutInterval:10.0]))
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
        
        if (extraParameters != nil)
            extraOAuthParameters = [[NSMutableDictionary dictionaryWithDictionary:extraParameters] retain];
        
        aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [aUrl absoluteString], [self _generateQueryString]]];
        self = [super initWithURL:aUrl
                      cachePolicy:NSURLRequestReloadIgnoringCacheData
                  timeoutInterval:10.0];
        
        if (SHKDebugShowLogs) // check so we don't have to alloc the string with the data if we aren't logging
            SHKLog(@"Request url: %@", [aUrl absoluteString]);
        
		didPrepare = NO;
	}
    return self;
}

- (void)prepare
{
	if (didPrepare) {
		return;
	}
	didPrepare = YES;
}

#pragma mark -
#pragma mark Private

- (void)_generateTimestamp
{
    timestamp = [[NSString stringWithFormat:@"%d", time(NULL)] retain];
}

- (void)_generateNonce
{
    nonce = [NSString stringWithFormat:@"%u", arc4random() % (9999999 - 123400) + 123400];
}

- (NSString *)_signatureBaseString:(NSMutableDictionary *)params
{
    NSMutableArray *sortedPairs = [[NSMutableArray alloc] init];
    
    NSArray *sortedKeys = [[params allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in sortedKeys) {
		NSString *value = [params valueForKey:key];
		[sortedPairs addObject:[NSString stringWithFormat:@"%@=%@", key, [value URLEncodedString]]];
	}
    
    NSString *normalizedRequestParameters = [sortedPairs componentsJoinedByString:@"&"];
    
    // OAuth Spec, Section 9.1.2 "Concatenate Request Elements"
    NSString *ret = [NSString stringWithFormat:@"%@&%@&%@",
					 [self HTTPMethod],
					 [[[self URL] URLStringWithoutQuery] URLEncodedString],
					 [normalizedRequestParameters URLEncodedString]];
    
    return ret;
}

- (NSString *)_generateQueryString
{
    NSMutableDictionary *allParameters = [[NSMutableDictionary alloc] init];
    [allParameters setObject:nonce forKey:@"oauth_nonce"];
	[allParameters setObject:timestamp forKey:@"oauth_timestamp"];
	[allParameters setObject:@"1.0" forKey:@"oauth_version"];
	[allParameters setObject:[signatureProvider name] forKey:@"oauth_signature_method"];
	[allParameters setObject:consumer.key forKey:@"oauth_consumer_key"];
    
    if ( ! [token.key isEqualToString:@""]) 
    {
        [allParameters setObject:token.key forKey:@"oauth_token"];
    }
    
    if ([extraOAuthParameters objectForKey:@"v"] != nil) {
        [allParameters setObject:[extraOAuthParameters objectForKey:@"v"] forKey:@"oauth_verifier"];
    }
    else
    {
        [allParameters setObject:SHKCONFIG(tencentWeiboCallbackUrl) forKey:@"oauth_callback"];
    }
    
    signature = [signatureProvider signClearText:[self _signatureBaseString:allParameters]
                                      withSecret:[NSString stringWithFormat:@"%@&%@",
												  [consumer.secret URLEncodedString],
                                                  [token.secret URLEncodedString]]];
    
    [allParameters setObject:[signature URLEncodedString] forKey:@"oauth_signature"];
    
    NSMutableArray *parametersArray = [[NSMutableArray alloc] init];
    NSArray *sortedPairs = [[allParameters allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in sortedPairs) {
		NSString *value = [allParameters valueForKey:key];
        if ( ! [key isEqualToString:@"oauth_signature"])
            value = [value URLEncodedString];
        
		[parametersArray addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
	}    
    
    return [parametersArray componentsJoinedByString:@"&"];
}
@end
