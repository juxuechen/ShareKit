//
//  SHKRenRen.h
//  ShareKit
//
//  Created by icyleaf on 11-11-15.
//  Copyright (c) 2011 icyleaf.com. All rights reserved.
//

#import "SHKSharer.h"
#import "Renren.h"


@interface SHKRenRen : SHKSharer <RenrenDelegate>
{
    Renren *renren;
}

@property (retain) Renren *renren;

@end
