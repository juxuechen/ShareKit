//
//  RenrenSDKDemo
//
//  Created by renren-inc on 11-8-19.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//

#import <UIKit/UIKit.h>


@interface CheckLogViewController : UIViewController {
    IBOutlet UITextView *_logTextView; 
}

@property (nonatomic, retain) IBOutlet UITextView *logTextView;

- (IBAction)clearLog;
- (IBAction)cancel;

@end
