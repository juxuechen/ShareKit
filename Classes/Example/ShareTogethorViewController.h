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

@interface ShareTogethorViewController : UIViewController 

@property (strong, nonatomic)  SHKDouban *doubanSharer;
@property (strong, nonatomic)  IBOutlet UIButton *doubanButton;
@property (nonatomic)  BOOL doubanShare;

@property (strong, nonatomic)  SHKSinaWeibo *sinaSharer;
@property (strong, nonatomic)  IBOutlet UIButton *sinaButton;
@property (nonatomic)  BOOL sinaShare;

- (IBAction)douban:(id)sender;
- (IBAction)sina:(id)sender;

- (IBAction)share:(id)sender;

@end
