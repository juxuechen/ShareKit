//
//  RenrenSDKDemo
//
//  Created by renren-inc on 11-8-19.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import "ServiceTableViewController.h"
#import "PasswordFlowLoginViewController.h"
#import "CheckLogViewController.h"
#import "LoginViewController.h"


@implementation LoginViewController
@synthesize renren = _renren;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc{
	self.renren = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad{
    [super viewDidLoad];
	
    self.renren = [Renren sharedRenren];
} 

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        
        button1.frame = CGRectMake(148, 129, 175, 37);
        button2.frame = CGRectMake(34, 180, 175, 37);
        button3.frame = CGRectMake(285, 180, 175, 37);
        label1.frame = CGRectMake(158, 83, 154, 38);
        label2.frame =CGRectMake(161, 235, 148, 21);
        logoImageView.frame =CGRectMake(104, 10, 263, 83);
    }
    else
    {
        button1.frame = CGRectMake(65, 193, 175, 37);
        button2.frame = CGRectMake(65, 252, 175, 37);
        button3.frame = CGRectMake(65, 311, 175, 37);
        label1.frame = CGRectMake(83, 147, 154, 38);
        label2.frame =CGRectMake(75, 375, 148, 21);
        logoImageView.frame =CGRectMake(20, 39, 263, 83);
        
        
    }
}

#pragma mark - IBAction methods

- (IBAction)unloginPublishNewFeed:(id)sender{
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 @"http://dev.renren.com/",@"url",
                                 @"人人网开放平台",@"name",
                                 @"访问我们",@"action_name",
                                 @"http://dev.renren.com/",@"action_link",
                                 @"来自人人网iOS SDK",@"description",
                                 @"欢迎使用人人网SDK！",@"caption",
                                 @"http://hdn.xnimg.cn/photos/hdn421/20090923/1935/head_1Wmz_19242g019116.jpg",@"image",
                                 nil];
    [self.renren dialog:@"feed" andParams:params andDelegate:self];
}

- (IBAction)authPageButtonClick:(id)sender{
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray* graphCookies = [cookies cookiesForURL:
                             [NSURL URLWithString:@"http://graph.renren.com"]];
	
	for (NSHTTPCookie* cookie in graphCookies) {
		[cookies deleteCookie:cookie];
	}
	NSArray* widgetCookies = [cookies cookiesForURL:[NSURL URLWithString:@"http://widget.renren.com"]];
	
	for (NSHTTPCookie* cookie in widgetCookies) {
		[cookies deleteCookie:cookie];
	}
	if (![self.renren isSessionValid]){
		[self.renren authorizationWithPermisson:nil andDelegate:self];
	} else {
		ServiceTableViewController *serviceTableViewController = [[ServiceTableViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
		serviceTableViewController.renren = self.renren;
		[self.navigationController pushViewController:serviceTableViewController animated:YES];
		[serviceTableViewController release];
	}
}

- (IBAction)authPageWithPrivilegeButtonClick:(id)sender{
	if (![self.renren isSessionValid]) {
		NSArray *permissions = [NSArray arrayWithObjects:@"read_user_album",@"status_update",@"photo_upload",@"publish_feed",@"create_album",@"operate_like",nil];
		[self.renren authorizationWithPermisson:permissions andDelegate:self];
	} else {
		ServiceTableViewController *serviceTableViewController = [[ServiceTableViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
		serviceTableViewController.renren = self.renren;
		[self.navigationController pushViewController:serviceTableViewController animated:YES];
		[serviceTableViewController release];
	}
}

- (IBAction)userPwdButtonClick:(id)sender{
	if (![self.renren isSessionValid]) {
		PasswordFlowLoginViewController *passwordFlowLoginViewController = [[PasswordFlowLoginViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
		passwordFlowLoginViewController.renren = self.renren;
		[self.navigationController pushViewController:passwordFlowLoginViewController animated:YES];
		[passwordFlowLoginViewController release];
	} else {
		ServiceTableViewController *serviceTableViewController = [[ServiceTableViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
		serviceTableViewController.renren = self.renren;
		[self.navigationController pushViewController:serviceTableViewController animated:YES];
		[serviceTableViewController release];
	}
}

- (IBAction)checkLogButtonClick:(id)sender{
    [self presentModalViewController:[[[CheckLogViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]] autorelease] animated:YES];
}

-(void)showAlert:(NSString*)message{
	UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Widget Dialog" 
                                                   message:message delegate:nil
                                         cancelButtonTitle:@"ok" otherButtonTitles:nil];
	[alert show];
    [alert release];
}

#pragma mark - RenrenDelegate methods

-(void)renrenDidLogin:(Renren *)renren{
	ServiceTableViewController *serviceTableViewController = [[ServiceTableViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
    serviceTableViewController.renren = self.renren;
	[self.navigationController pushViewController:serviceTableViewController animated:YES];
	[serviceTableViewController release];
}

- (void)renren:(Renren *)renren loginFailWithError:(ROError*)error{
	NSString *title = [NSString stringWithFormat:@"Error code:%d", [error code]];
	NSString *description = [NSString stringWithFormat:@"%@", [error localizedDescription]];
	UIAlertView *alertView =[[[UIAlertView alloc] initWithTitle:title message:description delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease];
	[alertView show];
}

- (void)renren:(Renren *)renren requestDidReturnResponse:(ROResponse*)response{
	NSDictionary* params = (NSDictionary *)response.rootObject;
    if (params!=nil) {
        NSString *msg=nil;
        NSMutableString *result = [[NSMutableString alloc] initWithString:@""];
        for (id key in params)
		{
			msg = [NSString stringWithFormat:@"key: %@ value: %@    ",key,[params objectForKey:key]];
		    [result appendString:msg];
		}
		[self showAlert:result];
        [result release];
	}

    
}

- (void)renren:(Renren *)renren requestFailWithError:(ROError*)error{
	//Demo Test
    NSString* errorCode = [NSString stringWithFormat:@"Error:%d",error.code];
    NSString* errorMsg = [error localizedDescription];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:errorCode message:errorMsg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

@end
