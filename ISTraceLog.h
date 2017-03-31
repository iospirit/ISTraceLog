//
//  ISTraceLog.h
//  ISKit
//
//  Created by Felix Schwarz on 31.03.17.
//  Copyright © 2017 IOSPIRIT GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef ISTRACELOG_DISABLED
typedef NS_ENUM(NSUInteger, ISTraceLogEntryType)
{
	kISTraceLogEntryTypeEnterFunction,
	kISTraceLogEntryTypeLeaveFunction,
	kISTraceLogEntryTypeLogMessage
};

@interface ISTraceLogEntry : NSObject
{
	ISTraceLogEntryType type;
	NSTimeInterval timestamp;
	NSString *functionName;
	NSString *file;
	NSUInteger line;
	NSString *logMessage;
}

@property(assign) ISTraceLogEntryType type;
@property(assign) NSTimeInterval timestamp;
@property(strong) NSString *functionName;
@property(strong) NSString *file;
@property(assign) NSUInteger line;
@property(strong) NSString *logMessage;

@end

typedef NS_ENUM(NSUInteger, ISTraceLogOptions)
{
	kISTraceLogOptionsIndent		= (1L << 0L),	//!< Indent the log entries
	kISTraceLogOptionsClearLog		= (1L << 1L),	//!< Clear the log after compiling the formatted log
	kISTraceLogOptionsUseLogBaseTime	= (1L << 2L),	//!< Print time stamps relative to the baseTimestamp of the ISTraceLog object
	kISTraceLogOptionsTimeRelativeToNow	= (1L << 3L),	//!< Print time stamps relative to the time the log is formatted ("T-minus" style)
	kISTraceLogOptionsTimeAsDate		= (1L << 4L),	//!< Print time as actual date
	
	kISTraceLogOptionsDefault = (kISTraceLogOptionsIndent|kISTraceLogOptionsUseLogBaseTime)
};

@interface ISTraceLog : NSObject
{
	NSTimeInterval baseTimestamp;

	NSMutableDictionary <id <NSCopying>, NSMutableArray <ISTraceLogEntry *> *> *logEntriesByIdentifier;
	dispatch_queue_t serialQueue;
}

+ (instancetype)sharedTraceLog;

- (void)enterIdentifier:(id <NSCopying>)identifier functionName:(NSString *)functionName file:(NSString *)file line:(NSUInteger)line;
- (void)logIdentifier:(id <NSCopying>)identifier   functionName:(NSString *)functionName file:(NSString *)file line:(NSUInteger)line format:(NSString *)logFormat, ...;
- (void)leaveIdentifier:(id <NSCopying>)identifier functionName:(NSString *)functionName file:(NSString *)file line:(NSUInteger)line;

- (NSString *)formattedLogForIdentifier:(id <NSCopying>)identifier options:(ISTraceLogOptions)options notOlderThan:(NSTimeInterval)secondsAgo;

@end
#endif /* ISTRACELOG_DISABLED */

#ifdef ISTRACELOG_DISABLED
	#define ISTRACELOG_ENTER(identifier)
	#define ISTRACELOG(identifier,fmt,...)
	#define ISTRACELOG_LEAVE(identifier)

	#define ISTRACELOG_ENTER_P(pointer)
	#define ISTRACELOG_P(pointer,fmt,...)
	#define ISTRACELOG_LEAVE_P(pointer)

	#define ISTRACELOG_ENTER_O(object)
	#define ISTRACELOG_O(object,fmt,...)
	#define ISTRACELOG_LEAVE_O(object)
#else
	#define ISTRACELOG_ENTER(identifier)	[[ISTraceLog sharedTraceLog] enterIdentifier:identifier functionName:@(__PRETTY_FUNCTION__) file:@(__FILE__) line:__LINE__]
	#define ISTRACELOG(identifier,fmt,...)	[[ISTraceLog sharedTraceLog] logIdentifier:identifier   functionName:@(__PRETTY_FUNCTION__) file:@(__FILE__) line:__LINE__ format:fmt, ##__VA_ARGS__]
	#define ISTRACELOG_LEAVE(identifier)	[[ISTraceLog sharedTraceLog] leaveIdentifier:identifier functionName:@(__PRETTY_FUNCTION__) file:@(__FILE__) line:__LINE__]

	// Use a pointer as the identifier
	#define ISTRACELOG_ENTER_P(pointer)	[[ISTraceLog sharedTraceLog] enterIdentifier:[NSValue valueWithPointer:(__bridge void *)pointer] functionName:@(__PRETTY_FUNCTION__) file:@(__FILE__) line:__LINE__]
	#define ISTRACELOG_P(pointer,fmt,...)	[[ISTraceLog sharedTraceLog] logIdentifier:[NSValue valueWithPointer:(__bridge void *)pointer]   functionName:@(__PRETTY_FUNCTION__) file:@(__FILE__) line:__LINE__ format:fmt, ##__VA_ARGS__]
	#define ISTRACELOG_LEAVE_P(pointer)	[[ISTraceLog sharedTraceLog] leaveIdentifier:[NSValue valueWithPointer:(__bridge void *)pointer] functionName:@(__PRETTY_FUNCTION__) file:@(__FILE__) line:__LINE__]

	// Use any object as an identifier
	#define ISTRACELOG_ENTER_O(object)	[[ISTraceLog sharedTraceLog] enterIdentifier:[NSString stringWithFormat:@"<%@ 0x%p>", [object className], (__bridge void *)object] functionName:@(__PRETTY_FUNCTION__) file:@(__FILE__) line:__LINE__]
	#define ISTRACELOG_O(object,fmt,...)	[[ISTraceLog sharedTraceLog] logIdentifier:[NSString stringWithFormat:@"<%@ 0x%p>", [object className], (__bridge void *)object]   functionName:@(__PRETTY_FUNCTION__) file:@(__FILE__) line:__LINE__ format:fmt, ##__VA_ARGS__]
	#define ISTRACELOG_LEAVE_O(object)	[[ISTraceLog sharedTraceLog] leaveIdentifier:[NSString stringWithFormat:@"<%@ 0x%p>", [object className], (__bridge void *)object] functionName:@(__PRETTY_FUNCTION__) file:@(__FILE__) line:__LINE__]
	
#endif /* ISTRACELOG_DISABLED */

// Conversion macros for use with -[ISTraceLog formattedLogForIdentifier:options:notOlderThan:]
#define ISTRACELOG_IDENTIFIER(identifier) identifier
#define ISTRACELOG_IDENTIFIER_P(object)	  [NSValue valueWithPointer:(__bridge void *)pointer]
#define ISTRACELOG_IDENTIFIER_O(object)	  [NSString stringWithFormat:@"<%@ 0x%p>", [object className], (__bridge void *)object]
