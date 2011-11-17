//
//  SHKRenRen.h
//  ShareKit
//
//  Created by icyleaf on 11-11-15.
//  Copyright (c) 2011 icyleaf.com. All rights reserved.
//

#import "SHKSharer.h"
#import "SHKOAuthSharer.h"
#import "ROConnect.h"
#import "SHKRenRenForm.h"


@interface SHKRenRen : SHKOAuthSharer  <RenrenDelegate>
{
    Renren *renren;
}

@property (retain) Renren *renren;


#pragma mark -
#pragma mark UI Implementation

- (void)showRenRenForm;
- (void)showRenRenPublishPhotoDialog;


#pragma mark -
#pragma mark Share API Methods

- (void)sendForm:(SHKRenRenForm *)form;

- (void)sendStatus;

@end
