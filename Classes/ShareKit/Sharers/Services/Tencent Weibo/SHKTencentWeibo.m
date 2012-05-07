//
//  SHKTencentWeibo.m
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

#include <ifaddrs.h>
#include <arpa/inet.h>

#import "SHKTencentWeibo.h"
#import "SHKConfiguration.h"
#import "NSMutableDictionary+NSNullsToEmptyStrings.h"
#import "TencentOAMutableURLRequest.h"
#import "TencentOAuthView.h"
#import "JSONKit.h"

#define API_DOMAIN  @"http://open.t.qq.com"

static NSString *const kSHKTencentWeiboUserInfo = @"kSHKTencentWeiboUserInfo";


@interface SHKTencentWeibo (Private)
- (NSString *)getIPAddress;
- (void)handleResponseData:(NSData *)data;
- (void)handleUnsuccessfulTicket:(NSData *)data;
@end


@implementation SHKTencentWeibo

- (id)init 
{    
    if ((self = [super init]))
	{		
		// OAuth
		self.consumerKey = SHKCONFIG(tencentWeiboConsumerKey);		
		self.secretKey = SHKCONFIG(tencentWeiboConsumerSecret);
 		self.authorizeCallbackURL = [NSURL URLWithString:SHKCONFIG(tencentWeiboCallbackUrl)];
		
		// -- //
		
		// You do not need to edit these, they are the same for everyone
		self.authorizeURL = [NSURL URLWithString:@"http://open.t.qq.com/cgi-bin/authorize"];
		self.requestURL = [NSURL URLWithString:@"http://open.t.qq.com/cgi-bin/request_token"];
		self.accessURL = [NSURL URLWithString:@"http://open.t.qq.com/cgi-bin/access_token"];
	}	
	return self;
}

#pragma mark -
#pragma mark Configuration : Service Defination

+ (NSString *)sharerTitle 
{
	return @"腾讯微博";
}

+ (BOOL)canShareURL 
{
	return YES;
}

+ (BOOL)canShareText 
{
	return YES;
}

+ (BOOL)canShareImage 
{
	return YES;
}


#pragma mark -
#pragma mark Configuration : Dynamic Enable

- (BOOL)shouldAutoShare 
{
	return NO;
}

#pragma mark -
#pragma mark Commit Share

- (void)share 
{
	BOOL itemPrepared = [self prepareItem];
	
	//the only case item is not prepared is when we wait for URL to be shortened on background thread. In this case [super share] is called in callback method
	if (itemPrepared) {
		[super share];
	}
}


#pragma mark -

- (BOOL)prepareItem 
{
	BOOL result = YES;
	
	if (item.shareType == SHKShareTypeURL)
	{
		BOOL isURLAlreadyShortened = [self shortenURL];
		result = isURLAlreadyShortened;
	}
	
	else if (item.shareType == SHKShareTypeImage)
	{
		[item setCustomValue:item.title forKey:@"status"];
	}
	
	else if (item.shareType == SHKShareTypeText)
    {		
		[item setCustomValue:item.text forKey:@"status"];
	}
	
	return result;
}


#pragma mark -
#pragma mark Authorization

+ (void)logout {
	
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kSHKTencentWeiboUserInfo];
	[super logout];    
}

#pragma mark -
#pragma mark UI Implementation

- (void)show
{
    if (item.shareType == SHKShareTypeURL)
	{
		[self showTencentWeiboForm];
	}
	
    else if (item.shareType == SHKShareTypeImage)
	{
		[self showTencentWeiboForm];
	}
	
	else if (item.shareType == SHKShareTypeText)
	{
		[self showTencentWeiboForm];
	}
    
    else if (item.shareType == SHKShareTypeUserInfo)
	{
		[self setQuiet:YES];
		[self tryToSend];
	}
}

- (void)showTencentWeiboForm
{
	SHKFormControllerLargeTextField *rootView = [[SHKFormControllerLargeTextField alloc] initWithNibName:nil bundle:nil delegate:self];	
	
	rootView.text = [item customValueForKey:@"status"];
	rootView.maxTextLength = 140;
	rootView.image = item.image;
	rootView.imageTextLength = 25;
	
	self.navigationBar.tintColor = SHKCONFIG_WITH_ARGUMENT(barTintForView:,self);
	
	[self pushViewController:rootView animated:NO];
	[rootView release];
	
	[[SHK currentHelper] showViewController:self];	
}

- (void)sendForm:(SHKFormControllerLargeTextField *)form
{	
	[item setCustomValue:form.textView.text forKey:@"status"];
	[self tryToSend];
}

#pragma mark -

- (BOOL)shortenURL
{
    if ([SHKCONFIG(sinaWeiboConsumerKey) isEqualToString:@""] || SHKCONFIG(sinaWeiboConsumerKey) == nil)
        NSAssert(NO, @"ShareKit: Could not shorting url with empty sina weibo consumer key.");
    
	if (![SHK connected])
	{
		[item setCustomValue:[NSString stringWithFormat:@"%@ %@", item.title, [item.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] forKey:@"status"];
		return YES;
	}
    
	if (!quiet)
		[[SHKActivityIndicator currentIndicator] displayActivity:SHKLocalizedString(@"Shortening URL...")];
	
	self.request = [[[SHKRequest alloc] initWithURL:[NSURL URLWithString:[NSMutableString stringWithFormat:@"http://api.t.sina.com.cn/short_url/shorten.json?source=%@&url_long=%@",
																		  SHKCONFIG(sinaWeiboConsumerKey),						  
																		  SHKEncodeURL(item.URL)
																		  ]]
											 params:nil
										   delegate:self
								 isFinishedSelector:@selector(shortenURLFinished:)
											 method:@"GET"
										  autostart:YES] autorelease];
    
    return NO;
}

- (void)shortenURLFinished:(SHKRequest *)aRequest
{
	[[SHKActivityIndicator currentIndicator] hide];
    
    @try 
    {
        NSArray *result = [[aRequest getResult] objectFromJSONString];
        item.URL = [NSURL URLWithString:[[result objectAtIndex:0] objectForKey:@"url_short"]];
    }
    @catch (NSException *exception) 
	{
		// TODO - better error message
		[[[[UIAlertView alloc] initWithTitle:SHKLocalizedString(@"Shorten URL Error")
									 message:SHKLocalizedString(@"We could not shorten the URL.")
									delegate:nil
						   cancelButtonTitle:SHKLocalizedString(@"Continue")
						   otherButtonTitles:nil] autorelease] show];
    }
    
    [item setCustomValue:[NSString stringWithFormat:@"%@: %@", item.title, item.URL.absoluteString] 
                  forKey:@"status"];
    
	[super share];
}


#pragma mark -
#pragma mark Share API Methods

- (BOOL)validateItem
{		
	if (self.item.shareType == SHKShareTypeUserInfo) {
		return YES;
	}
	
	NSString *status = [item customValueForKey:@"status"];
	return status != nil;
}

- (BOOL)validateItemAfterUserEdit 
{
	BOOL result = NO;
    
	BOOL isValid = [self validateItem];    
	NSString *status = [item customValueForKey:@"status"];
	
	if (isValid && status.length <= 140) {
		result = YES;
	}
	
	return result;
}

- (BOOL)send
{	
	if (![self validateItemAfterUserEdit])
		return NO;
	
	switch (item.shareType) {
			
		case SHKShareTypeImage:            
			[self sendImage];
			break;
			
		case SHKShareTypeUserInfo:            
            //			[self sendUserInfo];
			break;
			
		default:
			[self sendStatus];
			break;
	}
	
	// Notify delegate
	[self sendDidStart];	
	
	return YES;
}

- (void)sendStatus
{
    TencentOAMutableURLRequest *oRequest = [[TencentOAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/api/t/add", API_DOMAIN]] 

                                                                                  consumer:consumer
                                                                                     token:accessToken
                                                                                     realm:nil
                                                                         signatureProvider:signatureProvider];
    
    
	[oRequest setHTTPMethod:@"POST"];
    
    NSArray *params =[NSArray arrayWithObjects:
                      [[OARequestParameter alloc] initWithName:@"format" value:@"json"], 
                      [[OARequestParameter alloc] initWithName:@"clientip" value:[self getIPAddress]],
                      [[OARequestParameter alloc] initWithName:@"content" value:[item customValueForKey:@"status"]], nil];
    
	[oRequest setParameters:params];
	
	OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oRequest
                                                                                          delegate:self
                                                                                 didFinishSelector:@selector(sendStatusTicket:didFinishWithData:)
                                                                                   didFailSelector:@selector(sendStatusTicket:didFailWithError:)];	
    
	[fetcher start];
	[oRequest release];
}

- (void)sendStatusTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data 
{	
    if (SHKDebugShowLogs) // check so we don't have to alloc the string with the data if we aren't logging
		SHKLog(@"sendStatusTicket Response Body: %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
    
	if (ticket.didSucceed) 
    {
        NSDictionary *result = [data objectFromJSONData];
        
        if ([[result valueForKey:@"ret"] intValue] == 0)
            [self sendDidFinish];
        else 
            [self handleUnsuccessfulTicket:data];
    }
	else
	{		
		[self handleUnsuccessfulTicket:data];
	}
}

- (void)sendStatusTicket:(OAServiceTicket *)ticket didFailWithError:(NSError*)error
{
	[self sendDidFailWithError:error];
}

//
//- (void)sendStatusTicket:(OAServiceTicket *)ticket finishedWithData:(NSMutableData *) data 
//{
//	if (ticket.didSucceed) {
//		[self sendDidFinish];
//		[self handleResponseData:data];
//	} else {
//		
//	}
//}
//
//- (void)sendStatusTicket:(OAServiceTicket *)ticket failedWithError:(NSError *) error 
//{
//	NSLog(@"%@", error);
//	[self sendDidFailWithError:error];
//}

//- (void)sendImage 
//{
//	SHKLog(@"%s", __FUNCTION__);
//
//	NSString *generatedNonce =[self _generateNonce];
//	if ([generatedNonce length] > NONCE_LENGTH_FOR_TENCENT) {
//		generatedNonce =[generatedNonce substringToIndex:NONCE_LENGTH_FOR_TENCENT];
//	}
//	
//	OAMutableURLRequest *oRequest =[[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://open.t.qq.com/api/t/add_pic"]
//																consumer:consumer
//																token:accessToken
//																realm:nil
//																signatureProvider:signatureProvider
//																nonce:generatedNonce
//																timestamp:[self _generateTimestamp]
//																serviceFlag:kTencentFlag];
//	[oRequest setHTTPMethod:@"POST"];
//
//	OARequestParameter *formatParam =[[OARequestParameter alloc] initWithName:@"format" value:@"json"];
//	OARequestParameter *descParam =[[OARequestParameter alloc] initWithName:@"content" value:item.text];
//	OARequestParameter *ipParam =[[OARequestParameter alloc] initWithName:@"clientip" value:[self getIPAddress]];
//	NSArray *params =[NSArray arrayWithObjects:formatParam, descParam, ipParam, nil];
//	[oRequest setParameters:params];
//	[formatParam release];
//	[descParam release];
//	[ipParam release];
//
//	[oRequest prepare];
//
//	NSData *imageData =[self compressJPEGImage:[item image] withCompression:0.9f];
//	[self prepareRequest:oRequest withMultipartFormData:imageData andContentKey:@"content"];
//	
//	//Notify delegate
//	[self sendDidStart];
//
//	//Start the request
//	OADataFetcher *fetcher =[[OADataFetcher alloc] init];
//	[fetcher fetchDataWithRequest:oRequest
//				delegate:self
//				didFinishSelector: @selector(sendImageTicket: finishedWithData:)
//				didFailSelector: @selector(sendImageTicket: failedWithError:)];
//
//	[oRequest release];
//	[fetcher release];
//}
//
//- (void)sendImageTicket:(OAServiceTicket *)ticket finishedWithData:(NSMutableData *) data 
//{
//	if (ticket.didSucceed) {
//		[self sendDidFinish];
//		//Finished uploading Image, now need to posh the message and url in twitter
//		[self handleResponseData:data];
//	} else {
//		[self sendDidFailWithError:nil];
//	}
//}
//
//- (void)sendImageTicket:(OAServiceTicket *)ticket failedWithError:(NSError *) error 
//{
//	[self sendDidFailWithError:error];
//}


#pragma mark -

- (void)handleUnsuccessfulTicket:(NSData *)data 
{
    if (SHKDebugShowLogs)
        SHKLog(@"%@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
    
    [self sendDidFailWithError:nil];
}


#pragma mark Request

- (void)tokenRequest
{
	[[SHKActivityIndicator currentIndicator] displayActivity:SHKLocalizedString(@"Connecting...")];
      
    TencentOAMutableURLRequest *oRequest = [[TencentOAMutableURLRequest alloc] initWithURL:requestURL
                                                                                  consumer:consumer
                                                                                     token:nil
                                                                                     realm:nil
                                                                         signatureProvider:signatureProvider];
	

	[oRequest setHTTPMethod:@"GET"];
    
    [oRequest setParameters:[NSArray arrayWithObject:
                             [[OARequestParameter alloc] initWithName:@"oauth_callback" 
                                                                value:[authorizeCallbackURL absoluteString]]]];
	
    OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oRequest
                                                                                          delegate:self
                                                                                 didFinishSelector:@selector(tokenRequestTicket:didFinishWithData:)
                                                                                   didFailSelector:@selector(tokenRequestTicket:didFailWithError:)];
	[fetcher start];	
	[oRequest release];
}

- (void)tokenAuthorize
{	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?oauth_token=%@", 
                                       authorizeURL.absoluteString, 
                                       requestToken.key]];
	
	TencentOAuthView *auth = [[TencentOAuthView alloc] initWithURL:url delegate:self];
	[[SHK currentHelper] showViewController:auth];	
	[auth release];
}

- (void)tokenAccess:(BOOL)refresh
{
	if (!refresh)
		[[SHKActivityIndicator currentIndicator] displayActivity:SHKLocalizedString(@"Authenticating...")];
	
    TencentOAMutableURLRequest *oRequest = [[TencentOAMutableURLRequest alloc] initWithURL:accessURL
                                                                                  consumer:consumer
                                                                                     token:(refresh ? accessToken : requestToken)
                                                                                     realm:nil
                                                                         signatureProvider:signatureProvider];
    
    [oRequest setHTTPMethod:@"GET"];
    [oRequest setParameters:[NSArray arrayWithObject:
                             [[OARequestParameter alloc] initWithName:@"oauth_verifier" 
                                                                value:[authorizeResponseQueryVars valueForKey:@"v"]]]];
	
    OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oRequest
                                                                                          delegate:self
                                                                                 didFinishSelector:@selector(tokenAccessTicket:didFinishWithData:)
                                                                                   didFailSelector:@selector(tokenAccessTicket:didFailWithError:)];
	[fetcher start];
	[oRequest release];
}


#pragma mark -
#pragma mark Hepler Functions

- (NSString *)getIPAddress 
{
	NSString *address = @"error";
	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *temp_addr = NULL;
	int success = 0;

	//retrieve the current interfaces - returns 0 on success
	success = getifaddrs(&interfaces);
	if (success == 0) {
		//Loop through linked list of interfaces
		temp_addr = interfaces;
		while (temp_addr != NULL) {
			if (temp_addr->ifa_addr->sa_family == AF_INET) {
				//Check if interface is en0 which is the wifi connection on the iPhone
				if ([[NSString stringWithUTF8String: temp_addr->ifa_name] isEqualToString:@"en0"]) {
					//Get NSString from C String
					address =[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) temp_addr->ifa_addr)->sin_addr)];
				}
			}
			temp_addr = temp_addr->ifa_next;
		}
	}
	//Free memory
	freeifaddrs(interfaces);
	SHKLog(@"current address: %@", address);
	return address;
}

- (void)handleResponseData:(NSData *)data
{
	NSString *responseBody =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	SHKLog(@"api获取的数据:%@", responseBody);
    
    
//	id jsonObject = [responseBody JSONValue];
//	if ([jsonObject isKindOfClass:[NSDictionary class]]) {
//		NSDictionary * responseDictionary = jsonObject;
//		NSString *retCode= [responseDictionary valueForKey:@"ret"];
//		NSString *retMsg = [responseDictionary valueForKey:@"msg"];
//		if ([retCode intValue] != RETURN_CODE_NO_ERROR) {
//			NSString *msgContent = [NSString stringWithFormat:@"ReturnCode:%d Message:%@", [retCode intValue], retMsg];
//			NSError * error = [NSError errorWithDomain:msgContent code:[retCode intValue] userInfo:responseDictionary];
//			[self sendDidFailWithError:error];
//		}
//	}
	[responseBody release];
}


@end
