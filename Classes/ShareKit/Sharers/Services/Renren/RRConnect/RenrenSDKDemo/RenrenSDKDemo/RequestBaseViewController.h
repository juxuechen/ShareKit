//
//  RenrenSDKDemo
//
//  Created by xiawenhai on 11-8-25.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//

#import <UIKit/UIKit.h>
#import "ROConnect.h"

@interface RequestBaseViewController : UIViewController <RenrenDelegate> {
	Renren *_renren;
    
    BOOL _isKeyboardHidden;
}

@property (retain,nonatomic)Renren *renren;

@end
