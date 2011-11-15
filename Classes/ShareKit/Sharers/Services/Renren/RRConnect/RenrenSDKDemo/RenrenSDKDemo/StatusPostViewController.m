//
//  RenrenSDKDemo
//
//  Created by Tora on 11-8-24.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//

#import "StatusPostViewController.h"

@implementation StatusPostViewController

@synthesize postButton = _postButton;
@synthesize statusTextView = _statusTextView;
@synthesize resultTextView = _resultTextView;

- (void) dealloc {
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if (!CGRectContainsPoint(self.statusTextView.frame,[touch locationInView:self.view])) {
        if (!_isKeyboardHidden) {
            [self.statusTextView resignFirstResponder];
        }
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.postButton = nil;
    self.statusTextView = nil;
    self.resultTextView = nil;
}

#pragma mark - RenrenDelegate -

/**
 * 接口请求成功，第三方开发者实现这个方法
 */
- (void)renren:(Renren *)renren requestDidReturnResponse:(ROResponse*)response {
    self.resultTextView.text = [NSString stringWithFormat:@"%@", response.rootObject];
}

/**
 * 接口请求失败，第三方开发者实现这个方法
 */
- (void)renren:(Renren *)renren requestFailWithError:(ROError*)error {
    self.resultTextView.text = [error localizedDescription];
}

#pragma mark - IBAction -

- (IBAction)postStatus:(id)sender {
    
    if ([self.statusTextView.text length] <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"状态不能为空！" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:@"status.set" forKey:@"method"];
    [params setObject:self.statusTextView.text forKey:@"status"];
    [self.renren requestWithParams:params andDelegate:self];
}

@end
