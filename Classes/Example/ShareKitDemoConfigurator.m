//
//  ShareKitDemoConfigurator.m
//  ShareKit
//
//  Created by Vilem Kurz on 12.11.2011.
//  Copyright (c) 2011 Cocoa Miners. All rights reserved.
//

#import "ShareKitDemoConfigurator.h"

@implementation ShareKitDemoConfigurator

/* 
 App Description 
 ---------------
 These values are used by any service that shows 'shared from XYZ'
 */
- (NSString*)appName {
	return @"Share Kit Demo App";
}

- (NSString*)appURL {
	return @"https://github.com/juxuechen";
}

/*
 API Keys
 --------
 This is the longest step to getting set up, it involves filling in API keys for the supported services.
 It should be pretty painless though and should hopefully take no more than a few minutes.
 
 Each key below as a link to a page where you can generate an api key.  Fill in the key for each service below.
 
 A note on services you don't need:
 If, for example, your app only shares URLs then you probably won't need image services like Flickr.
 In these cases it is safe to leave an API key blank.
 
 However, it is STRONGLY recommended that you do your best to support all services for the types of sharing you support.
 The core principle behind ShareKit is to leave the service choices up to the user.  Thus, you should not remove any services,
 leaving that decision up to the user.
 */

// Sina Weibo 
- (NSString*)sinaWeiboConsumerKey {
	return @"2388700821";
}

- (NSString*)sinaWeiboConsumerSecret {
	return @"0f630a52cb06174df190d4981fb6d515";
}

// You need to set this if using OAuth (MUST be set, it could be any words)
- (NSString*)sinaWeiboCallbackUrl {
	return @"http://www.etao.com";
}

// To use xAuth, set to 1
- (NSNumber*)sinaWeiboUseXAuth {
	return [NSNumber numberWithInt:0];
}

// Enter your sina weibo screen name (Only for xAuth)
- (NSString*)sinaWeiboScreenname {
	return @"Taobao";
}

//Enter your app's sina weibo account if you'd like to ask the user to follow it when logging in. (Only for xAuth)
- (NSString*)sinaWeiboUserID {
	return @"4127260343";
}


// Tencent Weibo
- (NSString*)tencentWeiboConsumerKey
{
    return @"801259774";
}

- (NSString*)tencentWeiboConsumerSecret
{
    return @"969cf2b756f44a470b36cb36188a53a1";
}

- (NSString*)tencentWeiboCallbackUrl
{
    return @"null";
}


// Douban
- (NSString*)doubanConsumerKey {
	return @"061cb3ff24ce7f1e12561bfd6e6b7d5a";
}

- (NSString*)doubanConsumerSecret {
	return @"232973bf980ce2d8";
}

// You need to set this if using OAuth (MUST be set, it could be any words)
- (NSString*)doubanCallbackUrl {
	return @"http://www.taobao.com";
}



@end
