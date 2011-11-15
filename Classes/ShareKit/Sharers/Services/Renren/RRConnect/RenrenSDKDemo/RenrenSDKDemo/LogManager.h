//
//  LogManager.h
//  RenrenSDKDemo
//
//  Created by renren-inc on 11-8-22.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//

#import <Foundation/Foundation.h>

@protocol RORequestDebugDelegate;

@interface LogManager : NSObject<RORequestDebugDelegate> {
    NSMutableString *_log;
}
@property (nonatomic, retain)NSMutableString *log;

+ (LogManager *)getInstance;

- (BOOL)clearLog;

@end
