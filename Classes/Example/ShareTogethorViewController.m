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
                                                      NSLog(@"绑定成功 %@",note);
                                                      NSLog(@"绑定完成   userinfo %@",note.userInfo);
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

- (void)setDoubanShare:(BOOL)s {
    _doubanShare = s;
    NSString *imageName = s ? @"doubanS" : @"doubanNS";
    [self.doubanButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self.doubanButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
}


- (void)setSinaShare:(BOOL)s {
    _sinaShare = s;
    NSString *imageName = s ? @"sinaS" : @"sinaNS";
    [self.sinaButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self.sinaButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
}


#pragma mark -
#pragma mark Share

- (IBAction)douban:(id)sender {
    self.doubanShare = !self.doubanShare;
    
    if (self.doubanShare) {
        self.doubanSharer = [[[SHKDouban alloc] init] autorelease];
        SHKItem *item = [SHKItem text:@"1234569999000"];
        [self.doubanSharer loadItem:item];
        [SHK setRootViewController:self];
        if (![self.doubanSharer restoreAccessToken]) {//未绑定
            [self.doubanSharer share];
        }
    }
}


- (IBAction)sina:(id)sender {
    self.sinaShare = !self.sinaShare;
    
    if (self.sinaShare) {
        self.sinaSharer = [[[SHKSinaWeibo alloc] init] autorelease];
        SHKItem *item = [SHKItem text:@"1234569999000"];
        [self.sinaSharer loadItem:item];
        [SHK setRootViewController:self];
        if (![self.sinaSharer restoreAccessToken]) {//未绑定
            [self.sinaSharer share];
        }
    }
}


- (IBAction)share:(id)sender {
    if (self.doubanShare) {
        [self.doubanSharer share];
    }
    if (self.sinaShare) {
        [self.sinaSharer share];
    }
}



@end
