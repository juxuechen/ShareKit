//
//  RenrenSDKDemo
//
//  Created by renren-inc on 11-8-19.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//

#import "CheckLogViewController.h"
#import "LogManager.h"


@implementation CheckLogViewController
@synthesize logTextView = _logTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_logTextView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //self.navigationItem.title = @"gaidong";
    
	
    //NSLog(@"%@", self.navigationItem);
    //NSLog(@"%@", self.navigationController);
    
    NSLog(@"This is log:\n%@", [LogManager getInstance].log);
    self.logTextView.text = [LogManager getInstance].log;
    [self.logTextView scrollRangeToVisible:NSMakeRange([self.logTextView.text length], 0)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)clearLog{
    if (![[LogManager getInstance] clearLog]) {
        NSLog(@"Log couldn't be clear, some error might occured!!");
    }
    self.logTextView.text = [LogManager getInstance].log; // update this textView's content.
}

- (IBAction)cancel{
    [self dismissModalViewControllerAnimated:YES];
}

@end
