//
//  SHKSinaWeibo
//  ShareKit
//
//  Created by icyleaf on 11-03-31.
//  Copyright 2011 icyleaf.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SHKSinaWeiboForm : UIViewController <UITextViewDelegate>
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