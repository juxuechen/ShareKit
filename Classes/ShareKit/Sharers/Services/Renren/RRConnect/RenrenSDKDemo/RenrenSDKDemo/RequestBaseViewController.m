//
//  RenrenSDKDemo
//
//  Created by xiawenhai on 11-8-25.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//

#import "RequestBaseViewController.h"
#import "CheckLogViewController.h"


@implementation RequestBaseViewController
@synthesize renren = _renren;

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIBarButtonItem *leftbarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backForward:)];
	self.navigationItem.leftBarButtonItem = leftbarButtonItem;
	[leftbarButtonItem release];
    
    UIBarButtonItem *rightbarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"查看Log" style:UIBarButtonItemStylePlain target:self action:@selector(checkLogInfo:)];
	self.navigationItem.rightBarButtonItem = rightbarButtonItem;
	[rightbarButtonItem release];
}

#pragma mark following 5 methods to implement soft keyboard auto hiding.

- (void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [super viewDidDisappear:animated];
}


- (void)keyboardWillShow:(NSNotification *)notification
{
    _isKeyboardHidden = NO;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    _isKeyboardHidden = YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    /*
     * 此方法必须由子类覆盖掉，由于基类无法获取textView的frame，所以这里什么也不做(do nothing here!)。
     */
    return;
}

#pragma mark --
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

- (void)backForward:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)checkLogInfo:(id)sender
{
	CheckLogViewController *checkLogViewController = [[CheckLogViewController alloc]initWithNibName:nil bundle:[NSBundle mainBundle]];
    [self presentModalViewController:checkLogViewController animated:YES];
    [checkLogViewController release];
}

- (void)dealloc {
    self.renren.renrenDelegate = nil;
	self.renren = nil;
    [super dealloc];
}


@end
