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
    [[NSNotificationCenter defaultCenter] addObserverForName:@"tokenAccessTicket"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note){
                                                      NSLog(@"绑定成功 %@",note);
                                                      NSString *className = [note.userInfo objectForKey:@"class"];
                                                      if ([className isEqualToString:@"SHKSinaWeibo"]) {
                                                          [self.doubanButton setTitle:@"新浪绑定成功" forState:UIControlStateNormal];
                                                      }
                                                      if ([className isEqualToString:@"SHKDouban"]) {
                                                          [self.doubanButton setTitle:@"豆瓣绑定成功" forState:UIControlStateNormal];
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


- (IBAction)douban:(id)sender {
    self.doubanSharer = [[[SHKDouban alloc] init] autorelease];
    SHKItem *item = [SHKItem text:@"1234569999000"];
    [self.doubanSharer loadItem:item];
    [SHK setRootViewController:self];
    if (![self.doubanSharer authorize]) {//未绑定
        [self.doubanSharer share];
    }
    else {
        [self.doubanButton setTitle:@"不分享到豆瓣" forState:UIControlStateNormal];
    }
}


- (IBAction)sina:(id)sender {
    self.sinaSharer = [[[SHKSinaWeibo alloc] init] autorelease];
    SHKItem *item = [SHKItem text:@"1234569999000"];
    [self.sinaSharer loadItem:item];
    [SHK setRootViewController:self];
    if (![self.sinaSharer authorize]) {//未绑定
        [self.sinaSharer share];
    }
    else {
        [self.sinaButton setTitle:@"不分享到新浪" forState:UIControlStateNormal];
    }
}


- (IBAction)share:(id)sender {
    [self.doubanSharer share];
    [self.sinaSharer share];
}



@end
