//
//  SHKSharerDelegate.m
//  ShareKit
//
//  Created by Vilem Kurz on 2.1.2012.
//  Copyright (c) 2012 Cocoa Miners. All rights reserved.
//

#import "SHKSharerDelegate.h"

@implementation SHKSharerDelegate

#pragma mark -
#pragma mark SHKSharerDelegate protocol methods

// These are used if you do not provide your own custom UI and delegate

- (void)sharerStartedSending:(SHKSharer *)sharer
{
	if (!sharer.quiet) {
//		[[SHKActivityIndicator currentIndicator] displayActivity:SHKLocalizedString(@"Saving to %@", [[sharer class] sharerTitle])];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"jx-sharerStartedSending"
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    NSStringFromClass([sharer class]),@"sharer",nil]];
    }
}

- (void)sharerFinishedSending:(SHKSharer *)sharer
{
	if (!sharer.quiet) {
//		[[SHKActivityIndicator currentIndicator] displayCompleted:SHKLocalizedString(@"Saved!")];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"jx-sharerFinishedSending"
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    NSStringFromClass([sharer class]),@"sharer",nil]];
    }
}

- (void)sharer:(SHKSharer *)sharer failedWithError:(NSError *)error shouldRelogin:(BOOL)shouldRelogin
{
    
//    [[SHKActivityIndicator currentIndicator] hide];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"jx-sharerfailed"
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                NSStringFromClass([sharer class]),@"sharer",
                                                                [NSNumber numberWithBool:shouldRelogin],@"shouldRelogin",
                                                                error,@"error",
                                                                nil]];

    //if user sent the item already but needs to relogin we do not show alert
    
    //去掉后面的业务逻辑处理，把所有状况都返回给vc。
//    if (!sharer.quiet && sharer.pendingAction != SHKPendingShare && sharer.pendingAction != SHKPendingSend)
//	{				
//		[[[[UIAlertView alloc] initWithTitle:SHKLocalizedString(@"Error")
//									 message:sharer.lastError!=nil?[sharer.lastError localizedDescription]:SHKLocalizedString(@"There was an error while sharing")
//									delegate:nil
//						   cancelButtonTitle:SHKLocalizedString(@"Close")
//						   otherButtonTitles:nil] autorelease] show];
//    }		
//    if (shouldRelogin) {        
//        [sharer promptAuthorization];
//	}
}

- (void)sharerCancelledSending:(SHKSharer *)sharer
{

}

- (void)sharerAuthDidFinish:(SHKSharer *)sharer success:(BOOL)success
{

}

- (void)sharerShowBadCredentialsAlert:(SHKSharer *)sharer
{    
    NSString *errorMessage = SHKLocalizedString(@"Sorry, %@ did not accept your credentials. Please try again.", [[sharer class] sharerTitle]);
       
    [[[[UIAlertView alloc] initWithTitle:SHKLocalizedString(@"Login Error")
                                 message:errorMessage
                                delegate:nil
                       cancelButtonTitle:SHKLocalizedString(@"Close")
                       otherButtonTitles:nil] autorelease] show];
}

- (void)sharerShowOtherAuthorizationErrorAlert:(SHKSharer *)sharer
{    
    NSString *errorMessage = SHKLocalizedString(@"Sorry, %@ encountered an error. Please try again.", [[sharer class] sharerTitle]);
    
    [[[[UIAlertView alloc] initWithTitle:SHKLocalizedString(@"Login Error")
                                 message:errorMessage
                                delegate:nil
                       cancelButtonTitle:SHKLocalizedString(@"Close")
                       otherButtonTitles:nil] autorelease] show];
}


@end
