//
//  SHKSMS.m
//  ShareKit
//
//  Created by DEJOware on 7/28/10.

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

#import "SHKSMS.h"


@implementation MFMessageComposeViewController (SHK)

- (void)SHKviewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	// Remove the SHK view wrapper from the window
	[[SHK currentHelper] viewWasDismissed];
}

@end



@implementation SHKSMS


#pragma mark -
#pragma mark Configuration : Service Definition

+ (NSString *)sharerTitle
{
	return @"SMS";
}

+ (BOOL)canShareText
{
	return YES;
}

+ (BOOL)canShareURL
{
	return YES;
}

+ (BOOL)shareRequiresInternetConnection
{
	return NO;
}

+ (BOOL)requiresAuthentication
{
	return NO;
}

#pragma mark -
#pragma mark Configuration : Dynamic Enable

+ (BOOL)canShare
{
	return [MFMessageComposeViewController canSendText];
}

- (BOOL)shouldAutoShare
{
	return YES;
}



#pragma mark -
#pragma mark Share API Methods

- (BOOL)send
{	
	if (![self validateItem])
		return NO;
	
	return [self sendSMS]; // Put the actual sending action in another method to make subclassing SHKSMS easier
}

- (BOOL)sendSMS
{	
	MFMessageComposeViewController *messageController = [[[MFMessageComposeViewController alloc] init] autorelease];
	messageController.messageComposeDelegate = self;
	
	NSString *body = [item customValueForKey:@"body"];
	
	if (body == nil)
	{
		if (item.text != nil)
			body = item.text;
		
		
		if (item.URL != nil)
		{	
			NSString *urlStr = [item.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			
			if (body != nil)
				body = [body stringByAppendingFormat:@" - %@", urlStr];
			
			else
				body = urlStr;
		}

		// fallback
		if (body == nil)
			body = @"";
		
		// sig
		body = [body stringByAppendingFormat:@" [Sent from %@]", SHKMyAppName];
		
		// save changes to body
		[item setCustomValue:body forKey:@"body"];
	}
	
	[messageController setBody:body];
	
	[[SHK currentHelper] showViewController:messageController];
	
	return YES;
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	switch (result) {
		case MessageComposeResultCancelled:
			//NSLog(@"Cancelled");
			break;
		case MessageComposeResultFailed: {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SHKMyAppName
															message:@"Message Compose Failed"
														   delegate:self
												  cancelButtonTitle:@"OK"
												  otherButtonTitles: nil];
			[alert show];
			[alert release];
		}
			break;
		case MessageComposeResultSent:
			break;
		default:
			break;
	}
	
	[[SHK currentHelper] hideCurrentViewControllerAnimated:YES];
}

@end
