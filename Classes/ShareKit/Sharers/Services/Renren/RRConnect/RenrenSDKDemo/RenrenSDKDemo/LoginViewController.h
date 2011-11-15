//
//  RenrenSDKDemo
//
//  Created by renren-inc on 11-8-19.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import <UIKit/UIKit.h>


@interface LoginViewController : UIViewController <RenrenDelegate> {
    Renren *_renren;
    IBOutlet UIButton* button1;
    IBOutlet UIButton* button2;
    IBOutlet UIButton* button3;
    IBOutlet UIImageView* logoImageView;
    IBOutlet UILabel* label1;
    IBOutlet UILabel* label2;
}

@property (retain,nonatomic)Renren *renren;

/**
 * 授权页面方式
 */
- (IBAction)authPageButtonClick:(id)sender;

/**
 * 带权限的授权页面方式
 */
- (IBAction)authPageWithPrivilegeButtonClick:(id)sender;

/**
 * 用户名密码授权方式
 */
- (IBAction)userPwdButtonClick:(id)sender;

/**
 * 查看log
 */
- (IBAction)checkLogButtonClick:(id)sender;

- (IBAction)unloginPublishNewFeed:(id)sender;
@end
