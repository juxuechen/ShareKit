//
//  SHKSinaWeibo.m
//  ShareKit
//
//  Created by jimneylee on 12-08-14.
//  Copyright 2012 jimneylee. All rights reserved.
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

#import "SHKSinaWeiboV2.h"
#import "SHKSinaWeiboV2OAuthView.h"
#import "JSON.h"
#import "SHKConfiguration.h"
#import "OAAsynchronousDataFetcher.h"
#import "NSHTTPCookieStorage+DeleteForURL.h"

#define API_DOMAIN  @"https://api.weibo.com"
static NSString *accessTokenKey = @"access_token";

@implementation SHKSinaWeibo

@synthesize xAuth;
@synthesize accessTokenString;
@synthesize uid;
- (id)init
{
	if ((self = [super init]))
	{		
        // OAuth2.0
        // Note: consumer key equal to client id
		self.consumerKey = SHKCONFIG(sinaWeiboConsumerKey);
		self.secretKey = SHKCONFIG(sinaWeiboConsumerSecret);
 		self.authorizeCallbackURL = [NSURL URLWithString:SHKCONFIG(sinaWeiboCallbackUrl)];
        NSLog(@"%@, %@, %@", self.consumerKey, self.secretKey, self.authorizeCallbackURL);
		
        // xAuth
		self.xAuth = SHKCONFIG(sinaWeiboUseXAuth) ? YES : NO;
		
		// You do not need to edit these, they are the same for everyone     
        self.authorizeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth2/authorize", API_DOMAIN]];
        self.accessURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth2/access_token", API_DOMAIN]];

	}	
	return self;
}

#pragma mark -
#pragma mark Configuration : Service Defination

+ (NSString *)sharerTitle
{
	return @"新浪微博";
}

+ (BOOL)canShareURL
{
	return YES;
}

+ (BOOL)canShareImage
{
	return YES;
}

+ (BOOL)canShareText
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
#pragma mark Authorization

- (BOOL)isAuthorized
{		
	return [self restoreAccessToken];
}

#pragma mark -
#pragma mark Access

- (void)promptAuthorization
{		
    NSString* urlStr = [NSString stringWithFormat:@"%@?client_id=%@&response_type=code&redirect_uri=%@&display=mobile", authorizeURL, self.consumerKey, [self.authorizeCallbackURL.absoluteString URLEncodedString]];
    NSLog(@"url str = %@", urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    
    SHKSinaWeiboV2OAuthView *auth = [[SHKSinaWeiboV2OAuthView alloc] initWithURL:url delegate:self];
    [[SHK currentHelper] showViewController:auth];	
}


- (void)tokenAccess:(BOOL)refresh
{
	if (!refresh)
		[[SHKActivityIndicator currentIndicator] displayActivity:@"正在验证..."];//SHKLocalizedString(@"Authenticating...")
            
    OAMutableURLRequest *oRequest = [[OAMutableURLRequest alloc] initWithURL:accessURL
                                                                    consumer:consumer
																	   token:(refresh ? accessToken : requestToken)
                                                                       realm:nil   // our service provider doesn't specify a realm
                                                           signatureProvider:nil];
    
    [oRequest setHTTPMethod:@"POST"];
	
    NSMutableArray *params = [NSMutableArray array];
    [params addObject:[[OARequestParameter alloc] initWithName:@"client_id" value:self.consumerKey]];
    [params addObject:[[OARequestParameter alloc] initWithName:@"client_secret" value:self.secretKey]];
    [params addObject:[[OARequestParameter alloc] initWithName:@"grant_type" value:@"authorization_code"]];
    [params addObject:[[OARequestParameter alloc] initWithName:@"redirect_uri" value:self.authorizeCallbackURL.absoluteString]];
    [params addObject:[[OARequestParameter alloc] initWithName:@"code" value:[self.authorizeResponseQueryVars objectForKey:@"code"]]];

    [oRequest setParameters:params];
    
    OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oRequest
                                                                                          delegate:self
                                                                                 didFinishSelector:@selector(tokenAccessTicket:didFinishWithData:)
                                                                                   didFailSelector:@selector(tokenAccessTicket:didFailWithError:)];
    // Note: you should know that oauth2.0 is no need to USE HMAC-SHA1 create signature
    // the progree is so simple! :)
    // jimneylee overwrite this method in OAAsynchronousDataFetcher
    [fetcher startWithoutPrepare];
}


- (void)tokenAccessTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data 
{
#if SHKDebugShowLogs // check so we don't have to alloc the string with the data if we aren't logging
    SHKLog(@"tokenAccessTicket Response Body: %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
#endif
	
	[[SHKActivityIndicator currentIndicator] hide];
	
	if (ticket.didSucceed) 
	{
		NSString *responseBody = [[NSString alloc] initWithData:data
													   encoding:NSUTF8StringEncoding];
		// jimneylee: get access_token string
        SBJsonParser* parser = [[SBJsonParser alloc] init];
        id rootObject = [parser objectWithString:responseBody];
        if ([rootObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dic = (NSDictionary*)rootObject;
            self.accessTokenString = [dic objectForKey:@"access_token"];
            self.uid = [dic objectForKey:@"uid"];
        }
		
		[self storeAccessToken];
		
		[self tryPendingAction];
	}
	
	else
		// TODO - better error handling here
		[self tokenAccessTicket:ticket didFailWithError:[SHK error:SHKLocalizedString(@"There was a problem requesting access from %@", [self sharerTitle])]];
    
    [self authDidFinish:ticket.didSucceed];
}

- (void)storeAccessToken
{	
	[SHK setAuthValue:self.accessTokenString
               forKey:accessTokenKey
            forSharer:[self sharerId]];
}

- (BOOL)restoreAccessToken
{
	if (self.accessTokenString != nil)
		return YES;
    
	self.accessTokenString = [SHK getAuthValueForKey:accessTokenKey
                                     forSharer:[self sharerId]];
	
	return self.accessTokenString != nil;
}

+ (void)deleteStoredAccessToken
{
	NSString *sharerId = [self sharerId];
	
	[SHK removeAuthValueForKey:accessTokenKey forSharer:sharerId];
}

+ (void)logout
{
	[self deleteStoredAccessToken];
	
	// Clear cookies (for OAuth, doesn't affect XAuth)
	// TODO - move the authorizeURL out of the init call (into a define) so we don't have to create an object just to get it
	SHKOAuthSharer *sharer = [[self alloc] init];
	if (sharer.authorizeURL)
	{
		[NSHTTPCookieStorage deleteCookiesForURL:sharer.authorizeURL];
	}
}

#pragma mark xAuth

+ (NSString *)authorizationFormCaption
{
	return SHKLocalizedString(@"Create a free account at %@", @"weibo.com");
}

- (void)authorizationFormValidate:(SHKFormController *)form
{
	self.pendingForm = form;
	[self tokenAccess];
}

#pragma mark -
#pragma mark UI Implementation

- (void)show
{
    if (item.shareType == SHKShareTypeURL)
	{//到绑定
		[self shortenURL];
	}
	
    else if (item.shareType == SHKShareTypeImage)
	{
		[item setCustomValue:item.title forKey:@"status"];
		[self showSinaWeiboForm];
	}
	
	else if (item.shareType == SHKShareTypeText)
	{//到分享  文字
		[item setCustomValue:item.text forKey:@"status"];
//		[self showSinaWeiboForm];
        [self tryToSend];
	}
}

//- (void)showSinaWeiboForm
//{
//	SHKSinaWeiboV2Form *rootView = [[SHKSinaWeiboV2Form alloc] initWithNibName:nil bundle:nil];	
//	rootView.delegate = self;
//	
//	// force view to load so we can set textView text
//	[rootView view];
//	
//	rootView.textView.text = [item customValueForKey:@"status"];
//	rootView.hasAttachment = item.image != nil;
//	
//	[self pushViewController:rootView animated:NO];
//	
//	[[SHK currentHelper] showViewController:self];	
//}
//
//- (void)sendForm:(SHKSinaWeiboV2Form *)form
//{	
//	[item setCustomValue:form.textView.text forKey:@"status"];
//	[self tryToSend];
//}

#pragma mark -

- (void)shortenURL
{	
	if (![SHK connected])
	{
		[item setCustomValue:[NSString stringWithFormat:@"%@: %@", item.title, [item.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] forKey:@"status"];
		[self showSinaWeiboForm];		
		return;
	}
    
	if (!quiet)
		[[SHKActivityIndicator currentIndicator] displayActivity:SHKLocalizedString(@"Shortening URL...")];
	
	self.request = [[SHKRequest alloc] initWithURL:[NSURL URLWithString:[NSMutableString stringWithFormat:@"http://api.t.sina.com.cn/short_url/shorten.json?source=%@&url_long=%@",
																		  SHKCONFIG(sinaWeiboConsumerKey),
																		  SHKEncodeURL(item.URL)
																		  ]]
											 params:nil
										   delegate:self
								 isFinishedSelector:@selector(shortenURLFinished:)
											 method:@"GET"
										  autostart:YES];
    
    NSLog(@"short url: %@", self.request.url);
    
}

- (void)shortenURLFinished:(SHKRequest *)aRequest
{
	[[SHKActivityIndicator currentIndicator] hide];
    
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"(http://t.cn/(\\w+))"
                                                                      options:NSRegularExpressionCaseInsensitive 
                                                                        error:nil];
    
    NSArray *matches = [regex matchesInString:[aRequest getResult]
                                      options:0
                                        range:NSMakeRange(0, [[aRequest getResult] length])];
    
    NSString *result;
    for (NSTextCheckingResult *match in matches) 
    {
        NSRange range = [match rangeAtIndex:0];
        result = [[aRequest getResult] substringWithRange:range]; 
    }

	if (result == nil || [NSURL URLWithString:result] == nil)
	{
		// TODO - better error message
		/*[[[UIAlertView alloc] initWithTitle:SHKLocalizedString(@"Shorten URL Error")
									 message:SHKLocalizedString(@"We could not shorten the URL.")
									delegate:nil
						   cancelButtonTitle:SHKLocalizedString(@"Continue")
						   otherButtonTitles:nil] show];*/
		
		[item setCustomValue:[NSString stringWithFormat:@"%@: %@", item.text ? item.text : item.title, [item.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] forKey:@"status"];
	}
	
	else
	{		
		[item setCustomValue:[NSString stringWithFormat:@"%@: %@", item.text ? item.text : item.title, result] forKey:@"status"];
	}
	
	[self showSinaWeiboForm];
}

#pragma mark -
#pragma mark Share API Methods

- (BOOL)validate
{
	NSString *status = [item customValueForKey:@"status"];
	return status != nil && status.length > 0 && status.length <= 140;
}

- (BOOL)send
{		
	if (![self validate])
		[self show];
	
	else
	{	
		if (item.shareType == SHKShareTypeImage) {
			[self sendImage];
		} else {
			[self sendStatus];
		}
		
		// Notify delegate
		[self sendDidStart];	
		
		return YES;
	}
	
	return NO;
}

//api: http://open.weibo.com/wiki/2/statuses/update
- (void)sendStatus
{
    OAMutableURLRequest *oRequest = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/2/statuses/update.json", API_DOMAIN]]
                                                                    consumer:consumer
                                                                       token:accessToken
                                                                       realm:nil
                                                           signatureProvider:nil];
        
    [oRequest setHTTPMethod:@"POST"];
	
    NSMutableArray *params = [NSMutableArray array];
        
    [self restoreAccessToken];
    
    [params addObject:[[OARequestParameter alloc] initWithName:@"access_token" value:self.accessTokenString]];
    [params addObject:[[OARequestParameter alloc] initWithName:@"status" value:[item customValueForKey:@"status"]]];
    
    [oRequest setParameters:params];
	
	OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oRequest
                                                                                          delegate:self
                                                                                 didFinishSelector:@selector(sendStatusTicket:didFinishWithData:)
                                                                                   didFailSelector:@selector(sendStatusTicket:didFailWithError:)];	
    // Note: you should know that oauth2.0 is no need to USE HMAC-SHA1 create signature
    // the progree is so simple! :)
    // jimneylee overwrite this method in OAAsynchronousDataFetcher
	[fetcher startWithoutPrepare];
}

- (void)sendStatusTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data 
{	
	// TODO better error handling here
    
	if (ticket.didSucceed) 
		[self sendDidFinish];
	
	else
	{		
		if (SHKDebugShowLogs)
        {
            SHKLog(@"Sina Weibo Send Status Error: %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
        }
		
		// CREDIT: Oliver Drobnik
		
		NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];		
		
		// in case our makeshift parsing does not yield an error message
		NSString *errorMessage = @"Unknown Error";		
		
		NSScanner *scanner = [NSScanner scannerWithString:string];
		
		// skip until error message
		[scanner scanUpToString:@"\"error\":\"" intoString:nil];
		
		
		if ([scanner scanString:@"\"error\":\"" intoString:nil])
		{
			// get the message until the closing double quotes
			[scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\""] intoString:&errorMessage];
		}
		
		
		// this is the error message for revoked access
		if ([errorMessage isEqualToString:@"Invalid / used nonce"])
		{
            //TODO: what the hell is this????
			//[self sendDidFailShouldRelogin];
		}
		else 
		{
			NSError *error = [NSError errorWithDomain:@"Sina Weibo" code:2 userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey]];
			[self sendDidFailWithError:error];
		}
	}
}

- (void)sendStatusTicket:(OAServiceTicket *)ticket didFailWithError:(NSError*)error
{
	[self sendDidFailWithError:error];
}

// api: http://open.weibo.com/wiki/2/statuses/upload
- (void)sendImage {
    NSURL *serviceURL = nil;
    serviceURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://upload.api.weibo.com/2/statuses/upload.json"]];    
    OAMutableURLRequest *oRequest = [[OAMutableURLRequest alloc] initWithURL:serviceURL
																	consumer:consumer
																	   token:accessToken
																	   realm:API_DOMAIN
														   signatureProvider:nil];
    
    [oRequest setHTTPMethod:@"POST"];
	    
    [self restoreAccessToken];
    
	CGFloat compression = 0.9f;
	NSData *imageData = UIImageJPEGRepresentation([item image], compression);
	
	// TODO
	// Note from Nate to creator of sendImage method - This seems like it could be a source of sluggishness.
	// For example, if the image is large (say 3000px x 3000px for example), it would be better to resize the image
	// to an appropriate size (max of img.ly) and then start trying to compress.
	
	while ([imageData length] > 700000 && compression > 0.1) {
		// NSLog(@"Image size too big, compression more: current data size: %d bytes",[imageData length]);
		compression -= 0.1;
		imageData = UIImageJPEGRepresentation([item image], compression);
		
	}
    
	// jimneylee learn from http://yefeng.iteye.com/blog/315847
    // --------------boundary
    // content
    // \r\n
    // --------------boundary
    // content
    // \r\n
    
	NSString *boundary = @"0xKhTmLbOuNdArY";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[oRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
	
	NSMutableData *body = [NSMutableData data];
	NSString *dispKey = @"";
	if([item customValueForKey:@"profile_update"]){
		dispKey = @"Content-Disposition: form-data; name=\"image\"; filename=\"upload.jpg\"\r\n";
	} else {
		dispKey = @"Content-Disposition: form-data; name=\"pic\"; filename=\"upload.jpg\"\r\n";
	}
    
    // --------------boundary
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
	[body appendData:[dispKey dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[@"Content-Type: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:imageData];
	[body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	
	if([item customValueForKey:@"profile_update"]){
		// no ops
	} else {
        // --------------boundary
		[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"access_token\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[self.accessTokenString dataUsingEncoding:NSUTF8StringEncoding]];
       	[body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        // --------------boundary
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
		[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"status\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[item customValueForKey:@"status"] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];	
	}
    
	// --------------boundary
	[body appendData:[[NSString stringWithFormat:@"--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// setting the body of the post to the reqeust
	[oRequest setHTTPBody:body];
    
	// Start the request
	OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oRequest
																						  delegate:self
																				 didFinishSelector:@selector(sendImageTicket:didFinishWithData:)
																				   didFailSelector:@selector(sendImageTicket:didFailWithError:)];	
    // Note: you should know that oauth2.0 is no need to USE HMAC-SHA1 create signature
    // the progree is so simple! :)
    // jimneylee overwrite this method in OAAsynchronousDataFetcher
	[fetcher startWithoutPrepare];
}

- (void)sendImageTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	// TODO better error handling here
    SHKLog(@"%@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
    
	// NSLog([[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
	
	if (ticket.didSucceed) {
		[self sendDidFinish];
		// Finished uploading Image, now need to posh the message and url in sina weibo
		NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSRange startingRange = [dataString rangeOfString:@"<url>" options:NSCaseInsensitiveSearch];
		//NSLog(@"found start string at %d, len %d",startingRange.location,startingRange.length);
		NSRange endingRange = [dataString rangeOfString:@"</url>" options:NSCaseInsensitiveSearch];
		//NSLog(@"found end string at %d, len %d",endingRange.location,endingRange.length);
		
		if (startingRange.location != NSNotFound && endingRange.location != NSNotFound) {
			NSString *urlString = [dataString substringWithRange:NSMakeRange(startingRange.location + startingRange.length, endingRange.location - (startingRange.location + startingRange.length))];
			//NSLog(@"extracted string: %@",urlString);
			[item setCustomValue:[NSString stringWithFormat:@"%@ %@",[item customValueForKey:@"status"],urlString] forKey:@"status"];
			[self sendStatus];
		}
		
		
	} else {
		[self sendDidFailWithError:nil];
	}
}

- (void)sendImageTicket:(OAServiceTicket *)ticket didFailWithError:(NSError*)error {
	[self sendDidFailWithError:error];
}
@end
