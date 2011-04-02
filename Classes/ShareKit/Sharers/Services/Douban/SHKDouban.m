//
//  SHKDouban.m
//  ShareKit
//
//  Created by icyleaf on 11-04-01.
//  Copyright 2011 icyleaf.com. All rights reserved.

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


#import "SHKDouban.h"

#define API_DOMAIN      @"http://api.douban.com"

@implementation SHKDouban

- (id)init
{
	if ((self = [super init]))
	{	
		// OAUTH		
		self.consumerKey = SHKDoubanConsumerKey;		
		self.secretKey = SHKDoubanConsumerSecret;
 		self.authorizeCallbackURL = [NSURL URLWithString:SHKDoubanCallbackUrl];// HOW-TO: In your Douban application settings, use the "Callback URL" field.  If you do not have this field in the settings, set your application type to 'Browser'.
		
		
		// You do not need to edit these, they are the same for everyone
	    self.authorizeURL = [NSURL URLWithString:@"http://www.douban.com/service/auth/authorize"];
	    self.requestURL = [NSURL URLWithString:@"http://www.douban.com/service/auth/request_token"];
	    self.accessURL = [NSURL URLWithString:@"http://www.douban.com/service/auth/access_token"]; 
	}	
	return self;
}


#pragma mark -
#pragma mark Configuration : Service Defination

+ (NSString *)sharerTitle
{
	return @"豆瓣";
}

+ (BOOL)canShareURL
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

- (void)promptAuthorization
{		
	[super promptAuthorization]; // OAuth process		
}


#pragma mark -
#pragma mark UI Implementation

- (void)show
{
	if (item.shareType == SHKShareTypeURL)
	{
		[self shortenURL];
	}
	
	else if (item.shareType == SHKShareTypeImage)
	{
		[item setCustomValue:item.title forKey:@"status"];
		[self showDoubanForm];
	}
	
	else if (item.shareType == SHKShareTypeText)
	{
		[item setCustomValue:item.text forKey:@"status"];
		[self showDoubanForm];
	}
}

- (void)showDoubanForm
{
	SHKDoubanForm *rootView = [[SHKDoubanForm alloc] initWithNibName:nil bundle:nil];	
	rootView.delegate = self;
	
	// force view to load so we can set textView text
	[rootView view];
	
	rootView.textView.text = [item customValueForKey:@"status"];
	rootView.hasAttachment = item.image != nil;
	
	[self pushViewController:rootView animated:NO];
	
	[[SHK currentHelper] showViewController:self];	
}

- (void)sendForm:(SHKDoubanForm *)form
{	
	[item setCustomValue:form.textView.text forKey:@"status"];
	[self tryToSend];
}


#pragma mark -

- (void)shortenURL
{	
	if (![SHK connected])
	{
		[item setCustomValue:[NSString stringWithFormat:@"%@: %@", item.title, [item.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] forKey:@"status"];
		[self showDoubanForm];		
		return;
	}

	if (!quiet)
		[[SHKActivityIndicator currentIndicator] displayActivity:SHKLocalizedString(@"Shortening URL...")];
	
	self.request = [[[SHKRequest alloc] initWithURL:[NSURL URLWithString:[NSMutableString stringWithFormat:@"http://api.bit.ly/v3/shorten?login=%@&apikey=%@&longUrl=%@&format=txt",
																		  SHKBitLyLogin,
																		  SHKBitLyKey,																		  
																		  SHKEncodeURL(item.URL)
																		  ]]
											 params:nil
										   delegate:self
								 isFinishedSelector:@selector(shortenURLFinished:)
											 method:@"GET"
										  autostart:YES] autorelease];
}

- (void)shortenURLFinished:(SHKRequest *)aRequest
{
	[[SHKActivityIndicator currentIndicator] hide];
	
	NSString *result = [[aRequest getResult] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	
	if (result == nil || [NSURL URLWithString:result] == nil)
	{
		// TODO - better error message
		[[[[UIAlertView alloc] initWithTitle:SHKLocalizedString(@"Shorten URL Error")
									 message:SHKLocalizedString(@"We could not shorten the URL.")
									delegate:nil
						   cancelButtonTitle:SHKLocalizedString(@"Continue")
						   otherButtonTitles:nil] autorelease] show];
		
		[item setCustomValue:[NSString stringWithFormat:@"%@ %@", item.text ? item.text : item.title, [item.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] forKey:@"status"];
	}
	
	else
	{		
		///if already a bitly login, use url instead
		if ([result isEqualToString:@"ALREADY_A_BITLY_LINK"])
			result = [item.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		[item setCustomValue:[NSString stringWithFormat:@"%@ %@", item.text ? item.text : item.title, result] forKey:@"status"];
	}
	
	[self showDoubanForm];
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
		[self sendStatus];
		
		// Notify delegate
		[self sendDidStart];	
		
		return YES;
	}
	
	return NO;
}

- (void)sendStatus
{
	OAMutableURLRequest *oRequest = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/miniblog/saying", API_DOMAIN]]
																	consumer:consumer
																	   token:accessToken
																	   realm:nil
														   signatureProvider:nil];
	
	[oRequest setHTTPMethod:@"POST"];
	[oRequest addValue:@"application/atom+xml" forHTTPHeaderField:@"Content-Type"];
    
	NSMutableString *body = [NSMutableString stringWithFormat:@"<?xml version='1.0' encoding='UTF-8'?>"];
    [body appendFormat:@"<entry xmlns:ns0=\"http://www.w3.org/2005/Atom\" xmlns:db=\"http://www.douban.com/xmlns/\">"];
    [body appendFormat:@"<content><![CDATA[%@]]></content>", [item customValueForKey:@"status"]];
    [body appendFormat:@"</entry>"];
    
    [oRequest setHTTPBody:[body dataUsingEncoding:NSUnicodeStringEncoding allowLossyConversion:YES]];
	
	OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oRequest
																						  delegate:self
																				 didFinishSelector:@selector(sendStatusTicket:didFinishWithData:)
																				   didFailSelector:@selector(sendStatusTicket:didFailWithError:)];	
	
	[fetcher start];
	[oRequest release];
}

- (void)sendStatusTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data 
{	
	// TODO better error handling here
	SHKLog(@"%@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
    
    
	if (ticket.didSucceed) 
		[self sendDidFinish];
	
	else
	{		
		if (SHKDebugShowLogs)
        {
            SHKLog(@"Douban Send Status Error: %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
        }
		
		// CREDIT: Oliver Drobnik
		
		NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];		
		
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
		if ([errorMessage isEqualToString:@"Invalid / used nonce"] || [errorMessage isEqualToString:@"Could not authenticate with OAuth."])
		{
			[self sendDidFailShouldRelogin];
		}
		else 
		{
			NSError *error = [NSError errorWithDomain:@"Douban" code:2 userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey]];
			[self sendDidFailWithError:error];
		}
	}
}

- (void)sendStatusTicket:(OAServiceTicket *)ticket didFailWithError:(NSError*)error
{
	[self sendDidFailWithError:error];
}

@end
