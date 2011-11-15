//
//  RenrenSDKDemo
//
//  Created by Tora on 11-8-26.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import <UIKit/UIKit.h>
#import "RequestBaseViewController.h"

@interface PhotoUploadViewController : RequestBaseViewController <RenrenDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIButton *_postButton;
    UIButton *_chooseButton;
    UITextView *_statusTextView;
    UITextView *_resultTextView;
    UIImageView *_previewImageView;
}

@property (nonatomic, retain) IBOutlet UIButton *postButton;
@property (nonatomic, retain) IBOutlet UIButton *chooseButton;
@property (nonatomic, retain) IBOutlet UITextView *statusTextView;
@property (nonatomic, retain) IBOutlet UITextView *resultTextView;
@property (nonatomic, retain) IBOutlet UIImageView *previewImageView;

- (IBAction)upload:(id)sender;
- (IBAction)choosePhoto:(id)sender;

@end
