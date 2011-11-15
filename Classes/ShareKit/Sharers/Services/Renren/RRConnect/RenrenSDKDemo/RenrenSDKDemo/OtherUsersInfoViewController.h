//
//  RenrenSDKDemo
//
//  Created by xiawenhai on 11-8-24.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import <UIKit/UIKit.h>
#import "RequestBaseViewController.h"

@interface OtherUsersInfoViewController : RequestBaseViewController{
	UITextView *_textView;
	UITextField *_uidTextField;
	UITextField *_fieldTextField;
	UIActivityIndicatorView *_indicatorView;
	UIView *_coverView;
}

@property (retain,nonatomic)IBOutlet UITextView *textView;
@property (retain,nonatomic)IBOutlet UITextField *uidTextField;
@property (retain,nonatomic)IBOutlet UITextField *fieldTextField;
@property (retain,nonatomic)IBOutlet UIActivityIndicatorView *indicatorView;
@property (retain,nonatomic)IBOutlet UIView *coverView;

-(IBAction)requestUsersInfo:(id)sender;
-(IBAction)backgroundClicked:(id)sender;

@end
