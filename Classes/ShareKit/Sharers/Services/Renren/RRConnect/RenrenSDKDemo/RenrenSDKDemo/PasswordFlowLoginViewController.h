//
//  RenrenSDKDemo
//
//  Created by xiawenhai on 11-8-22.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import <UIKit/UIKit.h>
#import "ROConnect.h"


@interface PasswordFlowLoginViewController : UIViewController <RenrenDelegate>{
	UITextField *_userName;
	UITextField *_passWord;
	UIView *_coverView;
	UIActivityIndicatorView *_indicatorView;
	Renren *_renren;
}

@property (retain,nonatomic)IBOutlet UITextField *userName;
@property (retain,nonatomic)IBOutlet UITextField *password;
@property (retain,nonatomic)IBOutlet UIView *coverView;
@property (retain,nonatomic)IBOutlet UIActivityIndicatorView *indicatorView;
@property (retain,nonatomic)Renren *renren;

/**
 * 用户名密码登录授权
 */
- (IBAction)loginButtonClick:(id)sender;

@end
