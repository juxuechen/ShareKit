//
//  RenrenSDKDemo
//
//  Created by xiawenhai on 11-8-25.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//

#import <UIKit/UIKit.h>
#import "RequestBaseViewController.h"


@interface CreateAlbumViewController : RequestBaseViewController{
	UITextField *_albumName;
	UITextField *_location;
	UITextField *_description;
	UITextView *_textView;
	UIActivityIndicatorView *_indicatorView;
	UIView *_coverView;
}

@property (retain, nonatomic)IBOutlet UITextField *albumName;
@property (retain, nonatomic)IBOutlet UITextField *location;
@property (retain, nonatomic)IBOutlet UITextField *description;
@property (retain, nonatomic)IBOutlet UITextView *textView;
@property (retain,nonatomic)IBOutlet UIActivityIndicatorView *indicatorView;
@property (retain,nonatomic)IBOutlet UIView *coverView;

-(IBAction)requestCreateAlbum:(id)sender;
-(IBAction)backgroundClicked:(id)sender;

@end
