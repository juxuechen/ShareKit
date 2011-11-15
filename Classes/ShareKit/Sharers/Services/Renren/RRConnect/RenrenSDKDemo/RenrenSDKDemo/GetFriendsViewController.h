//
//  RenrenSDKDemo
//
//  Created by xiawenhai on 11-8-25.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import <UIKit/UIKit.h>
#import "RequestBaseViewController.h"


@interface GetFriendsViewController : RequestBaseViewController{
	UITextField *_page;
	UITextField *_count;
	UITextView *_textView;
	UIActivityIndicatorView *_indicatorView;
	UIView *_coverView;
}

@property (retain, nonatomic)IBOutlet UITextField *page;
@property (retain, nonatomic)IBOutlet UITextField *count;
@property (retain, nonatomic)IBOutlet UITextView *textView;
@property (retain,nonatomic)IBOutlet UIActivityIndicatorView *indicatorView;
@property (retain,nonatomic)IBOutlet UIView *coverView;

-(IBAction)requestGetFriends:(id)sender;
-(IBAction)backgroundClicked:(id)sender;

@end
