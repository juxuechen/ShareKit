//
//  ShareTogethorViewController.m
//  ShareKit
//
//  Created by ChenYang on 12-10-25.
//
//

#import "ShareTogethorViewController.h"
#import "SHKSharer.h"
#import "SHKDouban.h"
#import "SHKSinaWeiboV2.h"
#import "SHKTencentWeibo.h"

@interface ShareTogethorViewController ()

@end

@implementation ShareTogethorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"SHKAuthDidFinish"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note){
                                                      NSLog(@"绑定完成   userinfo %@",note.userInfo);
                                                      if ([[note.userInfo objectForKey:@"sharer"] isEqualToString:@"SHKDouban"]) {
                                                          BOOL success = [[note.userInfo objectForKey:@"success"] boolValue];
                                                          self.doubanFX = success;
                                                      }
                                                      if ([[note.userInfo objectForKey:@"sharer"] isEqualToString:@"SHKSinaWeibo"]) {
                                                          BOOL success = [[note.userInfo objectForKey:@"success"] boolValue];
                                                          self.sinaFX = success;
                                                      }
                                                  }];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Public

- (void)setDoubanFX:(BOOL)s {
    _doubanFX = s;
    NSString *imageName = s ? @"doubanS" : @"doubanNS";
    [self.doubanButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self.doubanButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
}


- (void)setSinaFX:(BOOL)s {
    _sinaFX = s;
    NSString *imageName = s ? @"sinaS" : @"sinaNS";
    [self.sinaButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self.sinaButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
}


- (void)setQqFX:(BOOL)qqFX {
    _qqFX = qqFX;
    NSString *imageName = qqFX ? @"qqS" : @"qqNS";
    [self.qqButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self.qqButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
}

#pragma mark -
#pragma mark Share

- (IBAction)buttonAction:(UIButton *)btn {
    switch (btn.tag) {
        case 0:
        {
            self.doubanFX = !self.doubanFX;
            
            if (self.doubanFX) {
                self.doubanSharer = [[[SHKDouban alloc] init] autorelease];
                SHKItem *item = [SHKItem text:self.textView.text];
                [self.doubanSharer loadItem:item];
                [SHK setRootViewController:self];
                if (![self.doubanSharer restoreAccessToken]) {//未绑定
                    [self.doubanSharer share];
                }
            }
        }
            break;
        case 1:
        {
            self.sinaFX = !self.sinaFX;
            
            if (self.sinaFX) {
                self.sinaSharer = [[[SHKSinaWeibo alloc] init] autorelease];
                SHKItem *item = [SHKItem text:self.textView.text];
                [self.sinaSharer loadItem:item];
                [SHK setRootViewController:self];
                if (![self.sinaSharer restoreAccessToken]) {//未绑定
                    [self.sinaSharer share];
                }
            }

        }
            break;
        case 2:
        {
            self.qqFX = !self.qqFX;
            
            if (self.qqFX) {
                self.qqSharer = [[[SHKTencentWeibo alloc] init] autorelease];
                SHKItem *item = [SHKItem text:self.textView.text];
                [self.qqSharer loadItem:item];
                [SHK setRootViewController:self];
                if (![self.qqSharer restoreAccessToken]) {//未绑定
                    [self.qqSharer share];
                }
            }
        }
            break;
        default:
            break;
    }
    
    
}



- (IBAction)share:(id)sender {
    [self.textView resignFirstResponder];
    if (self.doubanFX) {
        [self.doubanSharer share];
    }
    if (self.sinaFX) {
        [self.sinaSharer share];
    }
    if (self.qqFX) {
        [self.qqSharer share];
    }
}



@end
