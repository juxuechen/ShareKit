//
//  SHKSinaWeibo
//  ShareKit
//
//  Created by «FULLUSERNAME» on «DATE».
//  Copyright «YEAR» «ORGANIZATIONNAME». All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHK.h"
#import "SHKOAuthSharer.h"
#import "SHKSinaWeiboForm.h"


@interface SHKSinaWeibo : SHKOAuthSharer {
    BOOL xAuth;		
}
    
@property BOOL xAuth;
    
    
#pragma mark -
#pragma mark UI Implementation
    
- (void)showSinaWeiboForm;
    
#pragma mark -
#pragma mark Share API Methods
    
- (void)sendForm:(SHKSinaWeiboForm *)form;
    
- (void)sendStatus;
- (void)sendStatusTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)sendStatusTicket:(OAServiceTicket *)ticket didFailWithError:(NSError*)error;

- (void)sendImage;
- (void)sendImageTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)sendImageTicket:(OAServiceTicket *)ticket didFailWithError:(NSError*)error;
    
- (void)followMe;

@end
