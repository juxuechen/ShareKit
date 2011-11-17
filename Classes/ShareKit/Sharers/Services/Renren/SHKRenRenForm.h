//
//  SHKRenRenForm.h
//  ShareKit
//
//  Created by icyleaf on 11-11-17.
//  Copyright (c) 2011年 icyleaf.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHKRenRenForm : UIViewController <UITextViewDelegate>
{
	id delegate;
	UITextView *textView;
	UILabel *counter;
	BOOL hasAttachment;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UILabel *counter;
@property BOOL hasAttachment;

- (void)layoutCounter;

@end
