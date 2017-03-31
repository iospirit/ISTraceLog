//
//  ISTraceLog.m
//  ISKit
//
//  Created by Felix Schwarz on 31.03.17.
//  Copyright © 2017 IOSPIRIT GmbH. All rights reserved.
//

#import "ARCMacros.h"
#import "ISTraceLog.h"

#ifndef ISTRACELOG_DISABLED
@implementation ISTraceLogEntry

@synthesize type;
@synthesize timestamp;
@synthesize functionName;
@synthesize file;
@synthesize line;
@synthesize logMessage;

#pragma mark - Init & Dealloc
- (instancetype)init
{
	if ((self = [super init]) != nil)
	{
		timestamp = [NSDate timeIntervalSinceReferenceDate];
	}
	
	return(self);
}

- (void)dealloc
{
	ISReleaseNil(functionName);
	ISReleaseNil(file);
	ISReleaseNil(logMessage);
	
	ISSuperDealloc();
}

@end

@implementation ISTraceLog

+ (instancetype)sharedTraceLog
{
	static dispatch_once_t onceToken;
	static ISTraceLog *sharedTraceLog;
	
	dispatch_once(&onceToken, ^{
		sharedTraceLog = [ISTraceLog new];
	});
	
	return (sharedTraceLog);
}

#pragma mark - Init & Dealloc
- (instancetype)init
{
	if ((self = [super init]) != nil)
	{
		baseTimestamp = [NSDate timeIntervalSinceReferenceDate];
		logEntriesByIdentifier = [NSMutableDictionary new];
		serialQueue = dispatch_queue_create("ISTraceLog Serial Queue", DISPATCH_QUEUE_SERIAL);
	}
	
	return(self);
}

- (void)dealloc
{
	ISReleaseNil(serialQueue);
	ISReleaseNil(logEntriesByIdentifier);

	ISSuperDealloc();
}

- (void)addLogEntryForIdentifier:(id <NSCopying>)identifier type:(ISTraceLogEntryType)type functionName:(NSString *)functionName file:(NSString *)file line:(NSUInteger)line message:(NSString *)logMessage
{
	NSTimeInterval timestamp = [NSDate timeIntervalSinceReferenceDate];
	
	if (identifier == nil)
	{
		NSLog(@"ISTraceLog: not logging new entry with NIL identifier: type=%lu functionName:%@ message:%@", (unsigned long)type, functionName, logMessage);
		return;
	}

	dispatch_async(serialQueue, ^{
		ISTraceLogEntry *logEntry;
		
		if ((logEntry = [ISTraceLogEntry new]) != nil)
		{
			logEntry.timestamp = timestamp;
			logEntry.type = type;
			logEntry.functionName = functionName;
			logEntry.logMessage = logMessage;
			logEntry.file = [file lastPathComponent];
			logEntry.line = line;
			
			[self _addLogEntry:logEntry forIdentifier:identifier];
			
			ISRelease(logEntry);
		}
	});
}

- (void)addLogEntry:(ISTraceLogEntry *)logEntry forIdentifier:(id <NSCopying>)identifier
{
	if (identifier == nil)
	{
		NSLog(@"ISTraceLog: not logging new entry with NIL identifier: %@", logEntry);
		return;
	}

	dispatch_async(serialQueue, ^{
		[self _addLogEntry:logEntry forIdentifier:identifier];
	});
}

- (void)_addLogEntry:(ISTraceLogEntry *)logEntry forIdentifier:(id <NSCopying>)identifier
{
	NSMutableArray <ISTraceLogEntry *> *logEntries;
	
	if ((logEntries = logEntriesByIdentifier[identifier]) == nil)
	{
		logEntries = [NSMutableArray new];
		logEntriesByIdentifier[identifier] = logEntries;
		ISRelease(logEntries);
	}
	
	if (logEntries != nil)
	{
		[logEntries addObject:logEntry];
	}
}

- (void)enterIdentifier:(id <NSCopying>)identifier functionName:(NSString *)functionName file:(NSString *)file line:(NSUInteger)line
{
	[self addLogEntryForIdentifier:identifier type:kISTraceLogEntryTypeEnterFunction functionName:functionName file:file line:line message:nil];
}

- (void)logIdentifier:(id <NSCopying>)identifier functionName:(NSString *)functionName file:(NSString *)file line:(NSUInteger)line format:(NSString *)logFormat, ...;
{
	if (logFormat != nil)
	{
		va_list argumentList;

		va_start(argumentList, logFormat);
		[self addLogEntryForIdentifier:identifier type:kISTraceLogEntryTypeLogMessage functionName:functionName file:file line:line message:ISAutoReleased([[NSString alloc] initWithFormat:logFormat arguments:argumentList])];
		va_end(argumentList);
	}
}

- (void)leaveIdentifier:(id <NSCopying>)identifier functionName:(NSString *)functionName file:(NSString *)file line:(NSUInteger)line
{
	[self addLogEntryForIdentifier:identifier type:kISTraceLogEntryTypeLeaveFunction functionName:functionName file:file line:line message:nil];
}

- (NSString *)formattedLogForIdentifier:(id <NSCopying>)identifier options:(ISTraceLogOptions)options notOlderThan:(NSTimeInterval)secondsAgo
{
	NSMutableString *formattedLog = [NSMutableString string];

	dispatch_sync(serialQueue, ^{
		NSMutableArray <ISTraceLogEntry *> *logEntries;
		
		if ((logEntries = logEntriesByIdentifier[identifier]) != nil)
		{
			NSTimeInterval referenceTimestamp = ((options & kISTraceLogOptionsUseLogBaseTime) != 0) ? baseTimestamp : 0;
			NSTimeInterval nowTimestamp = [NSDate timeIntervalSinceReferenceDate];
			NSInteger indentLevel=0;
			NSString *indentChar = [NSString stringWithFormat:@" "];
			NSString *lastFunctionName = nil;
		
			for (ISTraceLogEntry *logEntry in logEntries)
			{
				if ((secondsAgo == 0) || ((nowTimestamp-logEntry.timestamp) < secondsAgo))
				{
					if (referenceTimestamp == 0)
					{
						referenceTimestamp = logEntry.timestamp;
					}
					
					// Timestamp
					if ((options & kISTraceLogOptionsTimeRelativeToNow) != 0)
					{
						// Time relative to now (T minus ..)
						[formattedLog appendFormat:@"%03.04f", logEntry.timestamp - nowTimestamp];
					}
					else if ((options & kISTraceLogOptionsTimeAsDate) != 0)
					{
						// Time as date
						[formattedLog appendFormat:@"%@", [NSDate dateWithTimeIntervalSinceReferenceDate:logEntry.timestamp]];
					}
					else
					{
						// Time relative to reference timestamp
						[formattedLog appendFormat:@"%3.04f", logEntry.timestamp - referenceTimestamp];
					}
				
					// Indent
					if (logEntry.type == kISTraceLogEntryTypeLeaveFunction)
					{
						indentLevel--;
					}

					if (options & kISTraceLogOptionsIndent)
					{
						[formattedLog appendString:[@"" stringByPaddingToLength:((indentLevel > 0) ? (indentLevel*8) : 0) withString:indentChar startingAtIndex:0]];
					}

					// Type
					switch (logEntry.type)
					{
						case kISTraceLogEntryTypeLogMessage:
							[formattedLog appendString:@" [MSG]"];
						break;

						case kISTraceLogEntryTypeEnterFunction:
							[formattedLog appendString:@" [--->"];
							indentLevel++;
						break;

						case kISTraceLogEntryTypeLeaveFunction:
							[formattedLog appendString:@" --->]"];
						break;
					}
					
					// Message
					switch (logEntry.type)
					{
						case kISTraceLogEntryTypeLogMessage:
							[formattedLog appendFormat:@" %@", logEntry.logMessage];
							
							if ((lastFunctionName==nil) || ((lastFunctionName!=nil) && (![logEntry.functionName isEqualToString:lastFunctionName])))
							{
								[formattedLog appendFormat:@" (%@ [%@:%ld])", logEntry.functionName, logEntry.file, logEntry.line];
							}
							else
							{
								[formattedLog appendFormat:@" [%@:%ld]", logEntry.file, logEntry.line];
							}
						break;

						case kISTraceLogEntryTypeEnterFunction:
							[formattedLog appendFormat:@" Entered %@", logEntry.functionName];
						break;

						case kISTraceLogEntryTypeLeaveFunction:
							[formattedLog appendFormat:@" Leaving %@", logEntry.functionName];
						break;
					}
					
					lastFunctionName = logEntry.functionName;
					
					// New line
					[formattedLog appendFormat:@"\n"];
				}
			}
			
			// Clear
			if ((options & kISTraceLogOptionsClearLog) != 0)
			{
				[logEntries removeAllObjects];
			}
		}
	});
	
	return (formattedLog);
}

@end
#endif /* ISTRACELOG_DISABLED */
