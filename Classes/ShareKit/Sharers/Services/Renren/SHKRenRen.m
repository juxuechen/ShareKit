//
//  SHKRenRen.m
//  ShareKit
//
//  Created by icyleaf on 11-11-15.
//  Copyright (c) 2011 icyleaf.com. All rights reserved.
//

#import "SHKRenRen.h"

@implementation SHKRenRen

@synthesize renren;


- (id)init
{
	if ((self = [super init]))
	{		
        self.renren = [Renren sharedRenren];
	}
    
	return self;
}


#pragma mark -
#pragma mark Configuration : Service Defination

+ (NSString *)sharerTitle
{
	return @"人人网";
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
	return YES; // RRConnect presents its own dialog
}


#pragma mark -
#pragma mark Authentication

- (BOOL)isAuthorized
{	
	return [self.renren isSessionValid];
}

- (void)promptAuthorization
{
    NSArray *permissions = [NSArray arrayWithObjects:@"status_update", @"photo_upload", nil];
    [self.renren authorizationWithPermisson:permissions andDelegate:self];
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
		[self showRenRenPublishPhotoDialog];
	}
	
	else if (item.shareType == SHKShareTypeText)
	{
		[item setCustomValue:item.text forKey:@"status"];
		[self showRenRenForm];
	}
}

- (void)showRenRenForm
{
    
}

- (void)showRenRenPublishPhotoDialog
{
    [self.renren publishPhotoSimplyWithImage:item.image  
                                     caption:item.title];
}


#pragma mark - RenrenDelegate methods

-(void)showAlert:(NSString*)message{
	UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Widget Dialog" 
                                                   message:message delegate:nil
                                         cancelButtonTitle:@"ok" otherButtonTitles:nil];
	[alert show];
    [alert release];
}

-(void)renrenDidLogin:(Renren *)renren{
    NSLog(@"renrenDidLogin");
//	ServiceTableViewController *serviceTableViewController = [[ServiceTableViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
//    serviceTableViewController.renren = self.renren;
//	[self.navigationController pushViewController:serviceTableViewController animated:YES];
//	[serviceTableViewController release];
}

- (void)renren:(Renren *)renren loginFailWithError:(ROError*)error{
	NSString *title = [NSString stringWithFormat:@"Error code:%d", [error code]];
	NSString *description = [NSString stringWithFormat:@"%@", [error localizedDescription]];
	UIAlertView *alertView =[[[UIAlertView alloc] initWithTitle:title message:description delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease];
	[alertView show];
}

- (void)renren:(Renren *)renren requestDidReturnResponse:(ROResponse*)response{
	NSDictionary* params = (NSDictionary *)response.rootObject;
    if (params!=nil) {
        NSString *msg=nil;
        NSMutableString *result = [[NSMutableString alloc] initWithString:@""];
        for (id key in params)
		{
			msg = [NSString stringWithFormat:@"key: %@ value: %@    ",key,[params objectForKey:key]];
		    [result appendString:msg];
		}
		[self showAlert:result];
        [result release];
	}
    
    
}

- (void)renren:(Renren *)renren requestFailWithError:(ROError*)error{
	//Demo Test
    NSString* errorCode = [NSString stringWithFormat:@"Error:%d", error];
    NSString* errorMsg = [error localizedDescription];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:errorCode message:errorMsg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

@end
