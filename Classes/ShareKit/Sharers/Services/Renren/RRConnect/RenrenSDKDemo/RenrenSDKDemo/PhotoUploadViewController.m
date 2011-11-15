//
//  RenrenSDKDemo
//
//  Created by Tora on 11-8-26.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//

#import "PhotoUploadViewController.h"
#import "ROPublishPhotoRequestParam.h"
#import "ROPublishPhotoResponseItem.h"

@implementation PhotoUploadViewController

@synthesize postButton = _postButton;
@synthesize statusTextView = _statusTextView;
@synthesize resultTextView = _resultTextView;
@synthesize previewImageView = _previewImageView;
@synthesize chooseButton = _chooseButton;

- (void) dealloc {
    self.postButton = nil;
    self.statusTextView = nil;
    self.resultTextView = nil;
    self.previewImageView = nil;
    self.chooseButton = nil;
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

#pragma mark - View lifecycle - 

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([ROGlobalStyle isPad]) {
        self.chooseButton.hidden = YES;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.postButton = nil;
    self.statusTextView = nil;
    self.resultTextView = nil;
    self.previewImageView = nil;
    self.chooseButton = nil;
}


#pragma mark - RenrenDelegate -

/**
 * 接口请求成功，第三方开发者实现这个方法
 */
- (void)renren:(Renren *)renren requestDidReturnResponse:(ROResponse*)response {
    
    if ([response.rootObject isKindOfClass:[ROPublishPhotoResponseItem class]]) {
        ROPublishPhotoResponseItem *result = (ROPublishPhotoResponseItem *)response.rootObject;
        self.resultTextView.text = [NSString stringWithFormat:@"Photo upload success!\n user id = %@\n album id = %@\n photo id = %@\n caption = %@\n small url = %@\n normal url = %@\n big url = %@", result.userId, result.albumId, result.photoId, result.caption, result.srcSmallUrl, result.srcUrl, result.srcBigUrl];
    }
}

/**
 * 接口请求失败，第三方开发者实现这个方法
 */
- (void)renren:(Renren *)renren requestFailWithError:(ROError*)error {
    self.resultTextView.text = [error localizedDescription];
}

#pragma mark - IBAction -
- (IBAction)choosePhoto:(id)sender
{
    UIImagePickerController *imagePicker = [[[UIImagePickerController alloc] init] autorelease];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentModalViewController:imagePicker animated:YES];
    
}
- (IBAction)upload:(id)sender {
    ROPublishPhotoRequestParam *param = [[ROPublishPhotoRequestParam alloc] init];
    param.imageFile = self.previewImageView.image;
    param.caption = self.statusTextView.text;
    [self.renren publishPhoto:param andDelegate:self];
    [param release];
    
    [self.statusTextView resignFirstResponder];
}

#pragma mark - UIImagePickerControllerDelegate Methods - 

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    self.previewImageView.image = image;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UINavigationControllerDelegate Methods - 

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    return;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    return;
}

@end
