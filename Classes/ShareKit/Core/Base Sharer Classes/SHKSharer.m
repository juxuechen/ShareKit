    //
//  SHKSharer.m
//  ShareKit
//
//  Created by Nathan Weiner on 6/8/10.

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

#import "SHKSharer.h"
#import "SHKActivityIndicator.h"
#import "SHKConfiguration.h"
#import "SHKSharerDelegate.h"



@implementation SHKSharer

@synthesize shareDelegate;
@synthesize item, request;
@synthesize lastError;
@synthesize quiet, pendingAction;

- (void)dealloc
{
	[item release];
    [shareDelegate release];
	[request release];
	[lastError release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Configuration : Service Defination

// Each service should subclass these and return YES/NO to indicate what type of sharing they support.
// Superclass defaults to NO so that subclasses only need to add methods for types they support

+ (NSString *)sharerTitle
{
	return @"";
}

- (NSString *)sharerTitle
{
	return [[self class] sharerTitle];
}

+ (NSString *)sharerId
{
	return NSStringFromClass([self class]);
}

- (NSString *)sharerId
{
	return [[self class] sharerId];	
}

+ (BOOL)canShareText
{
	return NO;
}

+ (BOOL)canShareURL
{
	return NO;
}

+ (BOOL)canShareImage
{
	return NO;
}

+ (BOOL)canShareFile
{
	return NO;
}

+ (BOOL)canGetUserInfo
{
    return NO;
}

+ (BOOL)shareRequiresInternetConnection
{
	return YES;
}

+ (BOOL)canShareOffline
{
	return YES;
}

+ (BOOL)requiresAuthentication
{
	return YES;
}

+ (BOOL)canShareType:(SHKShareType)type
{
	switch (type) 
	{
		case SHKShareTypeURL:
			return [self canShareURL];
			
		case SHKShareTypeImage:
			return [self canShareImage];
			
		case SHKShareTypeText:
			return [self canShareText];
			
		case SHKShareTypeFile:
			return [self canShareFile];
            
        case SHKShareTypeUserInfo:
			return [self canGetUserInfo];
			
		default: 
			break;
	}
	return NO;
}

+ (BOOL)canAutoShare
{
	return YES;
}



#pragma mark -
#pragma mark Configuration : Dynamic Enable

// Allows a subclass to programically disable/enable services depending on the current environment

+ (BOOL)canShare
{
	return YES;
}

- (BOOL)shouldAutoShare
{	
	return [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@_shouldAutoShare", [self sharerId]]];
}


#pragma mark -
#pragma mark Initialization

- (id)init
{
	if (self = [super initWithNibName:nil bundle:nil])
	{
		self.shareDelegate = [[[SHKSharerDelegate alloc] init] autorelease];
		self.item = [[[SHKItem alloc] init] autorelease];
				
		if ([self respondsToSelector:@selector(modalPresentationStyle)])
			self.modalPresentationStyle = [SHK modalPresentationStyle];
		
		if ([self respondsToSelector:@selector(modalTransitionStyle)])
			self.modalTransitionStyle = [SHK modalTransitionStyle];
	}
	return self;
}


#pragma mark -
#pragma mark Share Item Loading Convenience Methods

+ (id)shareItem:(SHKItem *)i
{
	[SHK pushOnFavorites:[self sharerId] forType:i.shareType];
	
	// Create controller and set share options
	SHKSharer *controller = [[self alloc] init];
	controller.item = i;
	
	// share and/or show UI
	[controller share];
	
	return [controller autorelease];
}

- (void)loadItem:(SHKItem *)i
{
	[SHK pushOnFavorites:[self sharerId] forType:i.shareType];
	
	// Create controller set share options
	self.item = i;
}

+ (id)shareURL:(NSURL *)url
{
	return [self shareURL:url title:nil];
}

+ (id)shareURL:(NSURL *)url title:(NSString *)title
{
	// Create controller and set share options
	SHKSharer *controller = [[self alloc] init];
	controller.item.shareType = SHKShareTypeURL;
	controller.item.URL = url;
	controller.item.title = title;

	// share and/or show UI
	[controller share];

	return [controller autorelease];
}

+ (id)shareImage:(UIImage *)image title:(NSString *)title
{
	// Create controller and set share options
	SHKSharer *controller = [[self alloc] init];
	controller.item.shareType = SHKShareTypeImage;
	controller.item.image = image;
	controller.item.title = title;
	
	// share and/or show UI
	[controller share];
	
	return [controller autorelease];
}

+ (id)shareText:(NSString *)text
{
	// Create controller and set share options
	SHKSharer *controller = [[self alloc] init];
	controller.item.shareType = SHKShareTypeText;
	controller.item.text = text;
	
	// share and/or show UI
	[controller share];
	
	return [controller autorelease];
}

+ (id)shareFile:(NSData *)file filename:(NSString *)filename mimeType:(NSString *)mimeType title:(NSString *)title
{
	// Create controller and set share options
	SHKSharer *controller = [[self alloc] init];
	controller.item.shareType = SHKShareTypeFile;
	controller.item.data = file;
	controller.item.filename = filename;
	controller.item.mimeType = mimeType;
	controller.item.title = title;
	
	// share and/or show UI
	[controller share];
	
	return [controller autorelease];
}

+ (id)getUserInfo
{
    // Create controller and set share options
	SHKSharer *controller = [[self alloc] init];
	controller.item.shareType = SHKShareTypeUserInfo;
    
	// share and/or show UI
	[controller share];
    
    return [controller autorelease];
}

#pragma mark -
#pragma mark Commit Share

- (void)share
{
	// isAuthorized - If service requires login and details have not been saved, present login dialog	
	if (![self authorize]) {
//		self.pendingAction = SHKPendingShare;
    }

	// A. First check if auto share is set and isn't nobbled off
	// B. If it is, try to send
	// If either A or B fail, display the UI
	else if ([SHKCONFIG(allowAutoShare) boolValue] == FALSE ||	// this calls show and would skip try to send... but for sharers with no UI, try to send gets called in show
			 ![self shouldAutoShare] || 
			 ![self tryToSend])
		[self show];
}


#pragma mark -
#pragma mark Authentication

- (BOOL)isAuthorized
{	
	//子类实现
    return NO;
}

- (BOOL)authorize
{
	if ([self isAuthorized])
		return YES;
	
	else 
		[self promptAuthorization];
	
	return NO;
}

- (void)promptAuthorization
{
	//子类已经都有实现，此处代码不会执行。要删除SHKFormController相关部分，本地写入账号密码授权。
}

- (NSString *)getAuthValueForKey:(NSString *)key
{
	return [SHK getAuthValueForKey:key forSharer:[self sharerId]];
}

- (void)setShouldAutoShare:(BOOL)b
{
	[[NSUserDefaults standardUserDefaults] setBool:b forKey:[NSString stringWithFormat:@"%@_shouldAutoShare", [self sharerId]]];
}


+ (void)logout
{
	//子类实现
}

// Credit: GreatWiz
+ (BOOL)isServiceAuthorized 
{	
	SHKSharer *controller = [[self alloc] init];
	BOOL isAuthorized = [controller isAuthorized];
	[controller release];
	
	return isAuthorized;	
}




#pragma mark -
#pragma mark UI Implementation

- (void)show
{
	//子类实现
}

#pragma mark -
#pragma mark API Implementation

- (BOOL)validateItem
{
	switch (item.shareType) 
	{
		case SHKShareTypeURL:
			return (item.URL != nil);
			
		case SHKShareTypeImage:
			return (item.image != nil);
			
		case SHKShareTypeText:
			return (item.text != nil);
			
		case SHKShareTypeFile:
			return (item.data != nil);
            
        case SHKShareTypeUserInfo:
        {    
            BOOL result = [[self class] canGetUserInfo];
            return result; 
        }   
		default:
			break;
	}
	
	return NO;
}

- (BOOL)tryToSend
{
	if (![[self class] shareRequiresInternetConnection] || [SHK connected])
		return [self send];
	
	else if ([SHKCONFIG(allowOffline) boolValue] == TRUE && [[self class] canShareOffline])
		return [SHK addToOfflineQueue:item forSharer:[self sharerId]];
	
	else if (!quiet)
	{
		[[[[UIAlertView alloc] initWithTitle:SHKLocalizedString(@"Offline")
									 message:SHKLocalizedString(@"You must be online in order to share with %@", [self sharerTitle])
									delegate:nil
						   cancelButtonTitle:SHKLocalizedString(@"Close")
						   otherButtonTitles:nil] autorelease] show];
		
		return YES;
	}
	
	
	return NO;
}

- (BOOL)send
{	
	// Does not actually send anything.
	// Your subclass should implement the sending logic.
	// There is no reason to call [super send] in your subclass
	
	// You should never call [XXX send] directly, you should use [XXX tryToSend].  TryToSend will perform an online check before trying to send.
	return NO;
}

#pragma mark -
#pragma mark Pending Actions

- (void)tryPendingAction
{
	switch (pendingAction) 
	{
		case SHKPendingRefreshToken:
        case SHKPendingSend:    
			
            //resend silently
            [self tryToSend];
            
            //to show alert if reshare finishes with error (see SHKSharerDelegate)
            self.pendingAction = SHKPendingNone;            
            break;        
//        case SHKPendingShare:
                    
            //show UI or autoshare
//			[self share];
            
            //to show alert if reshare finishes with error (see SHKSharerDelegate)
//            self.pendingAction = SHKPendingNone;
//			break;
		default:
			break;
	}
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	// Remove the SHK view wrapper from the window
	[[SHK currentHelper] viewWasDismissed];
}


#pragma mark -
#pragma mark Delegate Notifications

- (void)sendDidStart
{		
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SHKSendDidStartNotification" object:self];
    
	if ([self.shareDelegate respondsToSelector:@selector(sharerStartedSending:)])
		[self.shareDelegate performSelector:@selector(sharerStartedSending:) withObject:self];	
}

- (void)sendDidFinish
{	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHKSendDidFinish" object:self];

    if ([self.shareDelegate respondsToSelector:@selector(sharerFinishedSending:)])
		[self.shareDelegate performSelector:@selector(sharerFinishedSending:) withObject:self];
	}

- (void)shouldReloginWithPendingAction:(SHKSharerPendingAction)action
{
    self.pendingAction = action;
	[self sendDidFailWithError:[SHK error:SHKLocalizedString(@"Could not authenticate you. Please relogin.")] shouldRelogin:YES];
}

- (void)sendDidFailWithError:(NSError *)error
{
	[self sendDidFailWithError:error shouldRelogin:NO];	
}

- (void)sendDidFailWithError:(NSError *)error shouldRelogin:(BOOL)shouldRelogin
{
	self.lastError = error;
	SHKLog(@"%@", [self.request description]);
    
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHKSendDidFailWithError" object:self];
    
	if ([self.shareDelegate respondsToSelector:@selector(sharer:failedWithError:shouldRelogin:)])
		[self.shareDelegate sharer:self failedWithError:error shouldRelogin:shouldRelogin];
}

- (void)sendDidCancel
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHKSendDidCancel" object:self];
    
    if ([self.shareDelegate respondsToSelector:@selector(sharerCancelledSending:)])
		[self.shareDelegate performSelector:@selector(sharerCancelledSending:) withObject:self];	
}

- (void)authDidFinish:(BOOL)success	
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"jx-SHKAuthDidFinish"
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [NSNumber numberWithBool:success],@"success",
                                                                NSStringFromClass([self class]),@"sharer",nil]];
    
    if ([self.shareDelegate respondsToSelector:@selector(sharerAuthDidFinish:success:)]) {
        [self.shareDelegate sharerAuthDidFinish:self success:success];
    }
}

- (void)authShowBadCredentialsAlert {
    
    SHKLog(@"%@", [self.request description]);
    if ([self.shareDelegate respondsToSelector:@selector(sharerShowBadCredentialsAlert:)]) {		
        [self.shareDelegate sharerShowBadCredentialsAlert:self];
    }
}

- (void)authShowOtherAuthorizationErrorAlert {
    
    SHKLog(@"%@", [self.request description]);
    if ([self.shareDelegate respondsToSelector:@selector(sharerShowOtherAuthorizationErrorAlert:)]) {
        [self.shareDelegate sharerShowOtherAuthorizationErrorAlert:self];
    }
}

- (void)sendShowSimpleErrorAlert {
    
    [self sendDidFailWithError:[SHK error:SHKLocalizedString(@"There was a problem saving to %@", [[self class] sharerTitle])]];
}

@end
