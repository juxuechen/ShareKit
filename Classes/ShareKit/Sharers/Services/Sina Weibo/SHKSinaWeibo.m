//
//  SHKSinaWeibo.m
//  ShareKit
//
//  Created by Nathan icyleaf on 11-03-31.

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

#import "SHKSinaWeibo.h"

#define API_DOMAIN  @"http://api.t.sina.com.cn"

@implementation SHKSinaWeibo

@synthesize xAuth;

- (id)init
{
	if ((self = [super init]))
	{		
        // OAuth
		self.consumerKey = SHKSinaWeiboConsumerKey;		
		self.secretKey = SHKSinaWeiboConsumerSecret;
 		self.authorizeCallbackURL = [NSURL URLWithString:SHKSinaWeiboCallbackUrl];
		
        // xAuth
		self.xAuth = SHKSinaWeiboUseXAuth ? YES : NO;
		
		// You do not need to edit these, they are the same for everyone
        self.authorizeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/authorize", API_DOMAIN]];
	    self.requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/request_token", API_DOMAIN]];
	    self.accessURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/access_token", API_DOMAIN]];
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

- (void)promptAuthorization
{		
	if (xAuth)
		[super authorizationFormShow]; // xAuth process
	
	else
		[super promptAuthorization]; // OAuth process		
}

#pragma mark xAuth

+ (NSString *)authorizationFormCaption
{
	return SHKLocalizedString(@"Create a free account at %@", @"T.CN");
}

+ (NSArray *)authorizationFormFields
{
	if ([SHKSinaWeiboUserID isEqualToString:@""])
		return [super authorizationFormFields];
	
    NSString *followMeString = SHKLocalizedString(@"Follow us");
    if ( ! [SHKSinaWeiboScreenName isEqualToString:@""]) {
        followMeString = SHKLocalizedString(@"Follow %@", SHKSinaWeiboScreenName);
    }
    
    return [NSArray arrayWithObjects:
			[SHKFormFieldSettings label:SHKLocalizedString(@"Username") key:@"username" type:SHKFormFieldTypeText start:nil],
			[SHKFormFieldSettings label:SHKLocalizedString(@"Password") key:@"password" type:SHKFormFieldTypePassword start:nil],
			[SHKFormFieldSettings label:followMeString key:@"followMe" type:SHKFormFieldTypeSwitch start:SHKFormFieldSwitchOn],			
			nil];
}

- (void)authorizationFormValidate:(SHKFormController *)form
{
	self.pendingForm = form;
	[self tokenAccess];
}

- (void)tokenAccessModifyRequest:(OAMutableURLRequest *)oRequest
{	
	if (xAuth)
	{
		NSDictionary *formValues = [pendingForm formValues];
		
		OARequestParameter *username = [[[OARequestParameter alloc] initWithName:@"x_auth_username"
                                                                           value:[formValues objectForKey:@"username"]] autorelease];
		
		OARequestParameter *password = [[[OARequestParameter alloc] initWithName:@"x_auth_password"
                                                                           value:[formValues objectForKey:@"password"]] autorelease];
		
		OARequestParameter *mode = [[[OARequestParameter alloc] initWithName:@"x_auth_mode"
                                                                       value:@"client_auth"] autorelease];
		
		[oRequest setParameters:[NSArray arrayWithObjects:username, password, mode, nil]];
	}
    else
    {
        if (pendingAction == SHKPendingRefreshToken)
        {
            if (accessToken.sessionHandle != nil)
                [oRequest setOAuthParameterName:@"oauth_session_handle" withValue:accessToken.sessionHandle];	
        }
        
        else
            [oRequest setOAuthParameterName:@"oauth_verifier" withValue:[authorizeResponseQueryVars objectForKey:@"oauth_verifier"]];
    }
}

- (void)tokenAccessTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data 
{
	if (xAuth) 
	{
		if (ticket.didSucceed)
		{
			[item setCustomValue:[[pendingForm formValues] objectForKey:@"followMe"] forKey:@"followMe"];
			[pendingForm close];
		}
		
		else
		{
			NSString *response = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
			
			SHKLog(@"tokenAccessTicket Response Body: %@", response);
			
			[self tokenAccessTicket:ticket didFailWithError:[SHK error:response]];
			return;
		}
	}
    
	[super tokenAccessTicket:ticket didFinishWithData:data];		
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
		[self showSinaWeiboForm];
	}
	
	else if (item.shareType == SHKShareTypeText)
	{
		[item setCustomValue:item.text forKey:@"status"];
		[self showSinaWeiboForm];
	}
}

- (void)showSinaWeiboForm
{
	SHKSinaWeiboForm *rootView = [[SHKSinaWeiboForm alloc] initWithNibName:nil bundle:nil];	
	rootView.delegate = self;
	
	// force view to load so we can set textView text
	[rootView view];
	
	rootView.textView.text = [item customValueForKey:@"status"];
	rootView.hasAttachment = item.image != nil;
	
	[self pushViewController:rootView animated:NO];
	
	[[SHK currentHelper] showViewController:self];	
}

- (void)sendForm:(SHKSinaWeiboForm *)form
{	
	[item setCustomValue:form.textView.text forKey:@"status"];
	[self tryToSend];
}

#pragma mark -

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
	// Check if we should send follow request too
	if (xAuth && [item customBoolForSwitchKey:@"followMe"])
		[self followMe];	
	
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

- (void)sendStatus
{
	OAMutableURLRequest *oRequest = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/statuses/update.json", API_DOMAIN]]
                                                                    consumer:consumer
                                                                       token:accessToken
                                                                       realm:nil
                                                           signatureProvider:nil];
	
	[oRequest setHTTPMethod:@"POST"];
	
	OARequestParameter *statusParam = [[OARequestParameter alloc] initWithName:@"status"
																		 value:[item customValueForKey:@"status"]];
	NSArray *params = [NSArray arrayWithObjects:statusParam, nil];
	[oRequest setParameters:params];
	[statusParam release];
	
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
    
	if (ticket.didSucceed) 
		[self sendDidFinish];
	
	else
	{		
		if (SHKDebugShowLogs)
        {
            SHKLog(@"Sina Weibo Send Status Error: %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
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
		if ([errorMessage isEqualToString:@"Invalid / used nonce"])
		{
			[self sendDidFailShouldRelogin];
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

- (void)sendImage {
	
	NSURL *serviceURL = nil;
	if([item customValueForKey:@"profile_update"]){
		serviceURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/account/update_profile_image.json", API_DOMAIN]];
	} else {
		serviceURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/statuses/upload.json", API_DOMAIN]];
	}
	
	OAMutableURLRequest *oRequest = [[OAMutableURLRequest alloc] initWithURL:serviceURL
																	consumer:consumer
																	   token:accessToken
																	   realm:API_DOMAIN
														   signatureProvider:signatureProvider];
	
	if( ! [item customValueForKey:@"profile_update"]){
        [oRequest setOAuthBaseStringParameterName:@"status" withValue:[item customValueForKey:@"status"]];
	}
    
    [oRequest setHTTPMethod:@"POST"];
    [oRequest prepare];
    
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
    
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[dispKey dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[@"Content-Type: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:imageData];
	[body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	
	if([item customValueForKey:@"profile_update"]){
		// no ops
	} else {
		[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"status\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[item customValueForKey:@"status"] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];	
	}
	
	[body appendData:[[NSString stringWithFormat:@"--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// setting the body of the post to the reqeust
	[oRequest setHTTPBody:body];
    
	// Notify delegate
	[self sendDidStart];
    
	// Start the request
	OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oRequest
																						  delegate:self
																				 didFinishSelector:@selector(sendImageTicket:didFinishWithData:)
																				   didFailSelector:@selector(sendImageTicket:didFailWithError:)];	
	
	[fetcher start];
	
	
	[oRequest release];
}

- (void)sendImageTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	// TODO better error handling here
    SHKLog(@"%@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
    
	// NSLog([[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
	
	if (ticket.didSucceed) {
		[self sendDidFinish];
		// Finished uploading Image, now need to posh the message and url in sina weibo
		NSString *dataString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
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


- (void)followMe
{
	// remove it so in case of other failures this doesn't get hit again
	[item setCustomValue:nil forKey:@"followMe"];
    
	OAMutableURLRequest *oRequest = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/friendships/create/%@.json", API_DOMAIN, SHKSinaWeiboUserID]]
																	consumer:consumer
																	   token:accessToken
																	   realm:nil
														   signatureProvider:nil];
	
	[oRequest setHTTPMethod:@"POST"];
    
	OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oRequest
                                                                                          delegate:nil // Currently not doing any error handling here.  If it fails, it's probably best not to bug the user to follow you again.
                                                                                 didFinishSelector:nil
                                                                                   didFailSelector:nil];	
	
	[fetcher start];
	[oRequest release];
}

@end
