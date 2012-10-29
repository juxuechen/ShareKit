//
//  ShareTogethorViewController.h
//  ShareKit
//
//  Created by ChenYang on 12-10-25.
//
//

#import <UIKit/UIKit.h>


@class SHKDouban;
@class SHKSinaWeibo;
@class SHKTencentWeibo;
@class SHKRenRen;

@interface ShareTogethorViewController : UIViewController 

@property (strong, nonatomic)  IBOutlet UITextView *textView;

@property (strong, nonatomic)  SHKDouban *doubanSharer;
@property (strong, nonatomic)  IBOutlet UIButton *doubanButton;
@property (nonatomic)  BOOL doubanFX;

@property (strong, nonatomic)  SHKSinaWeibo *sinaSharer;
@property (strong, nonatomic)  IBOutlet UIButton *sinaButton;
@property (nonatomic)  BOOL sinaFX;

@property (strong, nonatomic)  SHKTencentWeibo *qqSharer;
@property (strong, nonatomic)  IBOutlet UIButton *qqButton;
@property (nonatomic)  BOOL qqFX;

@property (strong, nonatomic)  SHKRenRen *renrenSharer;
@property (strong, nonatomic)  IBOutlet UIButton *renrenButton;
@property (nonatomic)  BOOL renrenFX;

@property (strong, nonatomic)  IBOutlet UIImageView *imageView;

- (IBAction)buttonAction:(id)sender;

- (IBAction)share:(id)sender;

@end
