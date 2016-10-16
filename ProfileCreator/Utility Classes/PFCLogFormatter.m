//
//  PFCLogFormatter.m
//  ProfileCreator
//
//  Created by Erik Berglund.
//  Copyright (c) 2016 ProfileCreator. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "PFCLogFormatter.h"

@implementation PFCLogFormatter

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)init {
    if ((self = [super init])) {
        _threadUnsafeDateFormatter = [[NSDateFormatter alloc] init];
        NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"yyyy/MM/dd HH:mm:ss:SSS" options:0 locale:[NSLocale currentLocale]];
        [_threadUnsafeDateFormatter setDateFormat:formatString];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark LogFormatter Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {

    // -------------------------------------------------------------------------
    //  Create a custom log format: yyyy/MM/dd HH:mm:ss:SSS [LogLevel] <Message>
    // -------------------------------------------------------------------------
    NSString *logLevel;
    switch (logMessage->_flag) {
    case DDLogFlagError:
        logLevel = @"ERROR";
        break;
    case DDLogFlagWarning:
        logLevel = @"WARNING";
        break;
    case DDLogFlagInfo:
        logLevel = @"";
        break;
    case DDLogFlagDebug:
        logLevel = @"DEBUG";
        break;
    default:
        logLevel = @"VERBOSE";
        break;
    }

    NSString *dateAndTime = [_threadUnsafeDateFormatter stringFromDate:(logMessage->_timestamp)];
    NSString *logMsg = logMessage->_message;

    if (logMessage->_flag == DDLogFlagInfo) {
        return [NSString stringWithFormat:@"%@ %@", dateAndTime, logMsg];
    } else {
        return [NSString stringWithFormat:@"%@ [%@] %@", dateAndTime, logLevel, logMsg];
    }
}

- (void)didAddToLogger:(id<DDLogger>)logger {
    _loggerCount++;
    NSAssert(_loggerCount <= 1, @"This logger isn't thread-safe");
}

- (void)willRemoveFromLogger:(id<DDLogger>)logger {
    _loggerCount--;
}

@end
