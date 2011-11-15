//
//  RenrenSDKDemo
//
//  Created by xiawenhai on 11-8-25.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import "GetFriendsViewController.h"


@implementation GetFriendsViewController
@synthesize page = _page;
@synthesize count = _count;
@synthesize textView = _textView;
@synthesize indicatorView = _indicatorView;
@synthesize coverView = _coverView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = @"好友ID列表";	
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
	[self.page resignFirstResponder];
	[self.count resignFirstResponder];
	ROGetFriendsRequestParam *requestParam = [[[ROGetFriendsRequestParam alloc] init] autorelease];
	requestParam.page = self.page.text;
	requestParam.count = self.count.text;
	
	[self.renren getFriends:requestParam andDelegate:self];
	
	[self.indicatorView startAnimating];
	self.coverView.hidden = NO;
}

-(IBAction)backgroundClicked:(id)sender
{
	[self.page resignFirstResponder];
	[self.count resignFirstResponder];
}

/**
 * 接口请求成功，第三方开发者实现这个方法
 */
- (void)renren:(Renren *)renren requestDidReturnResponse:(ROResponse*)response
{
	NSArray *friends = (NSArray *)(response.rootObject);
	NSString *outText = [NSString stringWithFormat:@""];
	
	for (NSString *item in friends) {
		outText = [outText stringByAppendingFormat:@"%@\n",item];
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
	self.textView = nil;
	self.indicatorView = nil;
	self.coverView = nil;
    [super dealloc];
}


@end
