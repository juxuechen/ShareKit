//
//  SHKEvernote
//  ShareKit Evernote Additions
//
//  Created by Atsushi Nagase on 8/28/10.
//  Copyright 2010 LittleApps Inc. All rights reserved.
//

#import "SHKEvernote.h"
#import "THTTPClient.h"
#import "TBinaryProtocol.h"
#import "SHKEvernoteFormController.h"
#import "SHKItem+EDAMNote.h"

#import "Types.h"
#import "UserStore.h"
#import "NoteStore.h"


@implementation SHKEvernoteItem
@synthesize note;

- (void)dealloc {
	[note release];
	[super dealloc];	
}


@end

@interface SHKEvernote(private)

- (void)authFinished:(BOOL)success;
- (void)sendFinished:(BOOL)success;
- (void)_show;
- (void)_send;

- (EDAMAuthenticationResult *)getAuthenticationResultForUsername:(NSString *)username password:(NSString *)password;

@end


@implementation SHKEvernote


#pragma mark -
#pragma mark Configuration : Service Defination

+ (NSString *)sharerTitle { return @"Evernote"; }
+ (BOOL)canShareURL   { return YES; }
+ (BOOL)canShareImage { return YES; }
+ (BOOL)canShareText  { return YES; }
+ (BOOL)canShareFile  { return YES; }
+ (BOOL)requiresAuthentication { return YES; }


#pragma mark -
#pragma mark Configuration : Dynamic Enable

+ (BOOL)canShare {	return YES; }

#pragma mark -
#pragma mark Authentication

// Return the form fields required to authenticate the user with the service
+ (NSArray *)authorizationFormFields 
{
	return [NSArray arrayWithObjects:
			[SHKFormFieldSettings label:@"Username" key:@"username" type:SHKFormFieldTypeText start:nil],
			[SHKFormFieldSettings label:@"Password" key:@"password" type:SHKFormFieldTypePassword start:nil],			
			nil];
}

+ (NSString *)authorizationFormCaption 
{
	return SHKLocalizedString(@"Create a free account at %@", @"Evernote.com");
}

- (void)authorizationFormValidate:(SHKFormController *)form 
{
	// Display an activity indicator
	if (!quiet)
		[[SHKActivityIndicator currentIndicator] displayActivity:SHKLocalizedString(@"Logging In...")];
	
	// Authorize the user through the server
	self.pendingForm = form;
	[NSThread detachNewThreadSelector:@selector(_authorizationFormValidate:) toTarget:self withObject:[form formValues]];
}

- (void)_authorizationFormValidate:(NSDictionary *)args 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	BOOL success = NO;
	@try {
		EDAMAuthenticationResult *authResult = [self getAuthenticationResultForUsername:[args valueForKey:@"username"] password:[args valueForKey:@"password"]];
		success = authResult&&[authResult userIsSet]&&[authResult authenticationTokenIsSet];
	}
	@catch (NSException * e) {
		SHKLog(@"Caught %@: %@ %@", [e name], [e reason],e);
	}	
	[self performSelectorOnMainThread:@selector(_authFinished:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:success?@"1":@"0",@"success",nil] waitUntilDone:YES];
    [pool release];
}

- (EDAMAuthenticationResult *)getAuthenticationResultForUsername:(NSString *)username password:(NSString *)password 
{
	THTTPClient *userStoreHTTPClient = [[[THTTPClient alloc] initWithURL:[NSURL URLWithString:SHKEvernoteUserStoreURL]] autorelease];
	TBinaryProtocol *userStoreProtocol = [[[TBinaryProtocol alloc] initWithTransport:userStoreHTTPClient] autorelease];
	EDAMUserStoreClient *userStore = [[[EDAMUserStoreClient alloc] initWithProtocol:userStoreProtocol] autorelease];

	BOOL versionOK = [userStore checkVersion:@"ShrareKit EDAM" :[EDAMUserStoreConstants EDAM_VERSION_MAJOR] :[EDAMUserStoreConstants EDAM_VERSION_MINOR]];
	if(!versionOK) 
	{
		[[[[UIAlertView alloc] initWithTitle:SHKLocalizedString(@"EDAM Error")
									 message:SHKLocalizedString(@"EDAM Version is too old.")
									delegate:nil 
						   cancelButtonTitle:SHKLocalizedString(@"Close")
						   otherButtonTitles:nil] autorelease] show];
		return nil;
	}
	return [userStore authenticate :username :password :SHKEvernoteConsumerKey :SHKEvernoteSecretKey];
}

- (void)_authFinished:(NSDictionary *)args 
{
	[self authFinished:[[args valueForKey:@"success"] isEqualToString:@"1"]];
}

- (void)authFinished:(BOOL)success 
{
	[[SHKActivityIndicator currentIndicator] hide];
	if(!success)
	{
		[[[[UIAlertView alloc] initWithTitle:SHKLocalizedString(@"Login Error") message:SHKLocalizedString(@"Your username and password did not match") delegate:nil cancelButtonTitle:SHKLocalizedString(@"Close") otherButtonTitles:nil] autorelease] show];
		return;
	}
	else
		[pendingForm saveForm];
}

#pragma mark -
#pragma mark Share Form

- (NSArray *)shareFormFieldsForType:(SHKShareType)type 
{
	return [NSArray arrayWithObjects:
	 [SHKFormFieldSettings label:SHKLocalizedString(@"Title") key:@"title" type:SHKFormFieldTypeText start:item.title],
	 //[SHKFormFieldSettings label:SHKLocalizedString(@"Memo")  key:@"text" type:SHKFormFieldTypeText start:item.text],
	 [SHKFormFieldSettings label:SHKLocalizedString(@"Tags")  key:@"tags" type:SHKFormFieldTypeText start:item.tags],
	 nil];
}

- (void)shareFormValidate:(SHKCustomFormController *)form 
{	
	[form saveForm];
}


#pragma mark -
#pragma mark Implementation

- (BOOL)validateItem {  return [super validateItem]; }

- (BOOL)send {
	if (![self validateItem])
		return NO;
	[self sendDidStart];
	[NSThread detachNewThreadSelector:@selector(_send) toTarget:self withObject:nil];
	return YES;
}

- (void)_send {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	BOOL success = NO;
	NSString *authToken;
  NSURL *noteStoreURL;
	NSString *errorMessage = nil;
	BOOL shouldRelogin = NO;
	@try {
  	////////////////////////////////////////////////
  	// Authentication
  	////////////////////////////////////////////////
		EDAMAuthenticationResult *authResult = [self getAuthenticationResultForUsername:[self getAuthValueForKey:@"username"] password:[self getAuthValueForKey:@"password"]];
    EDAMUser *user = [authResult user];
    authToken    = [authResult authenticationToken];
    noteStoreURL = [NSURL URLWithString:[SHKEvernoteNetStoreURLBase stringByAppendingString:[user shardId]]];

  	////////////////////////////////////////////////
    // Make clients
  	////////////////////////////////////////////////
    THTTPClient *noteStoreHTTPClient = [[[THTTPClient alloc] initWithURL:noteStoreURL] autorelease];
    TBinaryProtocol *noteStoreProtocol = [[[TBinaryProtocol alloc] initWithTransport:noteStoreHTTPClient] autorelease];
    EDAMNoteStoreClient *noteStore = [[[EDAMNoteStoreClient alloc] initWithProtocol:noteStoreProtocol] autorelease];

  	////////////////////////////////////////////////
    // Make EDAMNote contents
  	////////////////////////////////////////////////
    
    EDAMNote *createdNote = [noteStore createNote:authToken :[item edamNoteForNotebook:[noteStore getDefaultNotebook:authToken]]];
    if (createdNote != NULL) {
      SHKLog(@"Created note: %@", [createdNote title]);
			success = YES;
    }
  }
  @catch (EDAMUserException * e) 
	{
		SHKLog(@"%@",e);
		
		NSString *errorName;		
		switch (e.errorCode) 
		{
			case EDAMErrorCode_BAD_DATA_FORMAT:
				errorName = @"Invalid format";
				break;
			case EDAMErrorCode_PERMISSION_DENIED:
				errorName = @"Permission Denied";
				break;
			case EDAMErrorCode_INTERNAL_ERROR:
				errorName = @"Internal Evernote Error";
				break;
			case EDAMErrorCode_DATA_REQUIRED:
				errorName = @"Data Required";
				break;
			case EDAMErrorCode_QUOTA_REACHED:
				errorName = @"Quota Reached";
				break;
			case EDAMErrorCode_INVALID_AUTH:
				errorName = @"Invalid Auth";
				shouldRelogin = YES;
				break;
			case EDAMErrorCode_AUTH_EXPIRED:
				errorName = @"Auth Expired";
				shouldRelogin = YES;
				break;
			case EDAMErrorCode_DATA_CONFLICT:
				errorName = @"Data Conflict";
				break;
			default:
				errorName = @"Unknown error from Evernote";
				break;
		}
		
		errorMessage = [NSString stringWithFormat:@"Evernote Error on %@: %@", e.parameter, errorName];
	}
	[self performSelectorOnMainThread:@selector(_sendFinished:)
						   withObject:[NSDictionary dictionaryWithObjectsAndKeys:
									   success?@"1":@"0",@"success",
									   errorMessage==nil?@"":errorMessage,@"errorMessage",
									   shouldRelogin?@"1":@"0",@"shouldRelogin",
									   nil] waitUntilDone:YES];
	[pool release];
}

- (void)_sendFinished:(NSDictionary *)args 
{
	if (![[args valueForKey:@"success"] isEqualToString:@"1"])
	{
		if ([[args valueForKey:@"shouldRelogin"] isEqualToString:@"1"])
		{
			[self sendDidFailShouldRelogin];
			return;
		}
		
		[self sendDidFailWithError:[SHK error:[args valueForKey:@"errorMessage"]]];
		return;
	}
	
	[self sendDidFinish];
}


- (void)sendFinished:(BOOL)success {	
	if (success) {
		[self sendDidFinish];
	} else {
		[self sendDidFailWithError:[SHK error:SHKLocalizedString(@"There was a problem sharing with Evernote")] shouldRelogin:NO];
	}
}

@end
