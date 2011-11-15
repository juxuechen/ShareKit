//
//  RenrenSDKDemo
//
//  Created by  on 11-8-31.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import "GetFriendsInfoViewController.h"

@implementation GetFriendsInfoViewController
@synthesize page = _page;
@synthesize count = _count;
@synthesize fields = _fields;
@synthesize textView = _textView;
@synthesize indicatorView = _indicatorView;
@synthesize coverView = _coverView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = @"好友信息列表";	
	self.coverView.hidden = YES;
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(IBAction)requestGetFriends:(id)sender
{
    [self.fields resignFirstResponder];
	[self.page resignFirstResponder];
	[self.count resignFirstResponder];
	ROGetFriendsInfoRequestParam *requestParam = [[[ROGetFriendsInfoRequestParam alloc] init] autorelease];
	requestParam.page = self.page.text;
	requestParam.count = self.count.text;
    requestParam.fields = self.fields.text;
	
	[self.renren getFriendsInfo:requestParam andDelegate:self];
	
	[self.indicatorView startAnimating];
	self.coverView.hidden = NO;
}

-(IBAction)backgroundClicked:(id)sender
{
    [self.fields resignFirstResponder];
	[self.page resignFirstResponder];
	[self.count resignFirstResponder];
}

/**
 * 接口请求成功，第三方开发者实现这个方法
 */
- (void)renren:(Renren *)renren requestDidReturnResponse:(ROResponse*)response
{
	NSArray *friendsInfo = (NSArray *)(response.rootObject);
	NSString *outText = [NSString stringWithFormat:@""];
	NSArray *fieldsArray = [self.fields.text componentsSeparatedByString:@","];
	
	for (ROFriendResponseItem *item in friendsInfo) {
		NSDictionary *dictionary = [item responseDictionary];
		for (NSString *key in fieldsArray) {
			outText = [outText stringByAppendingFormat:@"%@:%@\n",key,[dictionary objectForKey:key]];
		}
		outText = [outText stringByAppendingFormat:@"\n"];
	}
	
	self.textView.text = outText;
	[self.indicatorView stopAnimating];
	self.coverView.hidden = YES;
}

/**
 * 接口请求失败，第三方开发者实现这个方法
 */
- (void)renren:(Renren *)renren requestFailWithError:(ROError*)error
{
	[self.indicatorView stopAnimating];
	self.coverView.hidden = YES;
	NSString *title = [NSString stringWithFormat:@"Error code:%d", [error code]];
	NSString *description = [NSString stringWithFormat:@"%@", [error.userInfo objectForKey:@"error_msg"]];
	UIAlertView *alertView =[[[UIAlertView alloc] initWithTitle:title message:description delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease];
	[alertView show];
}


- (void)dealloc {
	self.page = nil;
	self.count = nil;
    self.fields = nil;
	self.textView = nil;
	self.indicatorView = nil;
	self.coverView = nil;
    [super dealloc];
}

@end
