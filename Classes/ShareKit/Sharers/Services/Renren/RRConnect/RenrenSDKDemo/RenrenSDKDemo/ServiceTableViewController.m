//
//  RenrenSDKDemo
//
//  Created by renren-inc on 11-8-19.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//
#import "ServiceTableViewController.h"
#import "CheckLogViewController.h"
#import "CurrentUserInfoViewController.h"
#import "OtherUsersInfoViewController.h"
#import "AlbumInfoViewController.h"
#import "StatusPostViewController.h"
#import "CreateAlbumViewController.h"
#import "GetFriendsViewController.h"
#import "RequestBaseViewController.h"
#import "PhotoUploadViewController.h"
#import "GetFriendsInfoViewController.h"



@implementation ServiceTableViewController
@synthesize sectionHeaders = _sectionHeaders;
@synthesize cellText = _cellText;
@synthesize cellDetailText = _cellDetailText;
@synthesize renren = _renren;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.sectionHeaders = [NSArray arrayWithObjects:@"用户信息", @"好友", @"相册", @"发布内容", @"一键发布", @"Widget Dialog", nil];
        self.cellText = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"当前用户信息", @"指定用户信息", nil], [NSArray arrayWithObjects:@"好友ID列表",@"好友信息列表",nil], [NSArray arrayWithObjects:@"相册列表", @"新建相册", nil], [NSArray arrayWithObjects:@"上传照片", @"发布状态", nil], [NSArray arrayWithObject:@"一键上传照片"], [NSArray arrayWithObjects:@"Feed Dialog", @"Like Dialog", nil], nil];
        self.cellDetailText = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"getUsersInfo",@"getUsersInfo", nil], [NSArray arrayWithObjects:@"getFriends",@"getFriendsInfo", nil], [NSArray arrayWithObjects:@"getAlbums", @"createAlbum", nil], [NSArray arrayWithObjects:@"publishPhoto", @"postStatus", nil], [NSArray arrayWithObjects:@"publishPhotoSimply", nil], [NSArray arrayWithObjects:@"feedDialog", @"likeDialog", nil], nil];
    }
    return self;
}

- (void)dealloc
{
    [_sectionHeaders release];
    [_cellText release];
    [_cellDetailText release];
	self.renren = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)respondToNotification{
    self.navigationItem.title = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_UserId"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //[self.navigationController.navigationBar pushNavigationItem:self.navigationItem animated:YES];
    if ([self.renren isSessionValid]) {
        NSString *userSessionId = nil;
        userSessionId = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_UserId"];
        if (nil == userSessionId) {
            self.navigationItem.title = userSessionId;
        }else{
            self.navigationItem.title = [NSString stringWithFormat:@"已授权"];
        }
    } else {
        self.navigationItem.title = [NSString stringWithFormat:@"未授权"];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UITableView *myTableView = [self.view.subviews objectAtIndex:0];
    [myTableView deselectRowAtIndexPath:[myTableView indexPathForSelectedRow] animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToNotification) name:@"kNotificationDidGetLoggedInUserId" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDatasource protocol methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *FirstLevelCell= @"ServiceTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FirstLevelCell];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:FirstLevelCell] autorelease];
    }
    
    // Configure the cell
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [[self.cellText objectAtIndex:section] objectAtIndex:row];
    cell.detailTextLabel.text = [[self.cellDetailText objectAtIndex:section] objectAtIndex:row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.cellText objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.sectionHeaders count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.sectionHeaders objectAtIndex:section];
}

#pragma mark - UITableViewDelegate protocol methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	RequestBaseViewController *viewController = nil;
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			viewController = [[CurrentUserInfoViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
		} 
        
        else if (indexPath.row == 1){
			viewController = [[OtherUsersInfoViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
		}
	} 
    
    else if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			viewController = [[GetFriendsViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
		}
        
        else if (indexPath.row == 1){
			viewController = [[GetFriendsInfoViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
		}
	} 
    
    else if (indexPath.section == 2) {
		if (indexPath.row == 0) {
			viewController = [[AlbumInfoViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
		} 
        
        else if (indexPath.row == 1) {
			viewController = [[CreateAlbumViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
		}

	}
    
    else if (indexPath.section == 3) {
		if (indexPath.row == 0) {
			viewController = [[PhotoUploadViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
		} 
        
        else if (indexPath.row == 1) {
			viewController = [[StatusPostViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
		}
    }
    
    else if(indexPath.section == 4){
        if (indexPath.row == 0) {
            UIImage *image = [UIImage imageNamed:@"renren_logo.png"];
            NSString *caption = @"这是一张由人人网SDK一键上传功能发布的照片";
            [self.renren publishPhotoSimplyWithImage:image caption:caption];
        }
        
	}
    
    else if(indexPath.section == 5) {
        if (indexPath.row == 0) {
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
        
        else if (indexPath.row == 1) {
            NSMutableDictionary *params=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         @"http://hecao.info/like.html",@"like_url",
                                         nil];
            [self.renren dialog:@"like" andParams:params andDelegate:self];
        } 
    }
	if (viewController) {
        viewController.renren = self.renren;
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];
    }
}

#pragma mark - IBAction methods

- (IBAction)logoutButtonClick:(id)sender{
    //[self.navigationController.navigationBar popNavigationItemAnimated:YES];
	[self.renren logout:self];
}
- (IBAction)checkLogButtonClick:(id)sender{
    CheckLogViewController *checkLogViewController = [[CheckLogViewController alloc]initWithNibName:nil bundle:[NSBundle mainBundle]];
    [self presentModalViewController:checkLogViewController animated:YES];
    [checkLogViewController release];
}

#pragma mark -

-(void)showAlert:(NSString*)message{
	UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Widget Dialog" 
                                                   message:message delegate:nil
                                         cancelButtonTitle:@"ok" otherButtonTitles:nil];
	[alert show];
    [alert release];
}

#pragma mark - RenrenDelegate methods

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
    ///////////////////////////////////////////////////////////////////////////////
    UITableView *myTableView = [self.view.subviews objectAtIndex:0];
    [myTableView deselectRowAtIndexPath:[myTableView indexPathForSelectedRow] animated:YES];
    
}

- (void)renren:(Renren *)renren requestFailWithError:(ROError*)error{
	//Demo Test
    NSString* errorCode = [NSString stringWithFormat:@"Error:%d",error.code];
    NSString* errorMsg = [error localizedDescription];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:errorCode message:errorMsg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)renrenDidLogout:(Renren *)renren
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)renrenDialogDidCancel:(Renren *)renren
{
    NSLog(@"取消Dialog");
}
#pragma mark - DialogDelegate methods

@end
