//
//  RenrenSDKDemo
//
//  Created by xiawenhai on 11-8-24.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import <UIKit/UIKit.h>
#import "RequestBaseViewController.h"


@interface CurrentUserInfoViewController : RequestBaseViewController{
	UITextView *_textView;
	UIActivityIndicatorView *_indicatorView;
}

@property (retain, nonatomic)IBOutlet UITextView *textView;
@property (retain, nonatomic)IBOutlet UIActivityIndicatorView *indicatorView;

@end
