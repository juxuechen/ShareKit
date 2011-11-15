//
//  LogManager.m
//  RenrenSDKDemo
//
//  Created by renren-inc on 11-8-22.
//  Copyright 2011年 Renren Inc. All rights reserved.
//  - Powered by Team Pegasus. -
//

#import "RORequest.h"
#import "LogManager.h"


static LogManager *logManager = nil;

@implementation LogManager
@synthesize log = _log;

- (void)dealloc{
    logManager.log = nil;
    [super dealloc];
}

+ (LogManager *)getInstance{
    @synchronized(self){
        if (nil == logManager) {
            logManager = [[LogManager alloc] init];
            logManager.log = [NSMutableString string];
        }
    }
    
    return logManager;
}

- (BOOL)clearLog{
    self.log = nil;
    self.log = [NSMutableString string];
    return YES;
}

#pragma mark - RORequestDebugDelegate methods
- (void)requestToServer:(NSString *)requestParam forMethod:(NSString *)methodName{
    [self.log appendFormat:@"%@\nmethod: %@\nrequest:\n%@\n", [[NSDate date] description], methodName, requestParam];
}
- (void)responseFormServer:(NSString *)response forMethod:(NSString *)methodName{
    [self.log appendFormat:@"%@\nmethod: %@\nresponse:\n%@\n", [[NSDate date] description], methodName, response];
}
- (void)otherErrors:(NSString *)errorDescription forMethod:(NSString *)methodName{
    [self.log appendFormat:@"%@\nmethod: %@\nresponse:\n%@\n", [[NSDate date] description], methodName, errorDescription];
}

@end
