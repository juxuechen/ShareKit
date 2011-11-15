//
//  RenrenSDKDemo
//
//  Created by Tora on 11-8-24.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import <UIKit/UIKit.h>
#import "RequestBaseViewController.h"

@interface StatusPostViewController : RequestBaseViewController <RenrenDelegate> {
    UIButton *_postButton;
    UITextView *_statusTextView;
    UITextView *_resultTextView;
}

@property (nonatomic, retain) IBOutlet UIButton *postButton;
@property (nonatomic, retain) IBOutlet UITextView *statusTextView;
@property (nonatomic, retain) IBOutlet UITextView *resultTextView;

- (IBAction)postStatus:(id)sender;

@end
