//
//  main.m
//  TracingLogDemo
//
//  Created by Felix Schwarz on 31.03.17.
//  Copyright © 2017 IOSPIRIT GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

// #define ISTRACELOG_DISABLED 1 // Disable tracing for this source file (or set it as a preprocessor flag to disable it globally (f.ex. in Release builds)
#import "ISTraceLog.h"

#import "Ball.h"
#import "Racket.h"

int main(int argc, const char * argv[])
{
	@autoreleasepool
	{
		Ball *ball = [Ball new];
		Racket *racketOne=[Racket new], *racketTwo=[Racket new];
		NSInteger alternateRacket = 0;
		
		while (ball.hits < 10)
		{
			alternateRacket = 1 - alternateRacket;
		
			if (alternateRacket)
			{
				[racketOne hitBall:ball];
			}
			else
			{
				[racketTwo hitBall:ball];
			}
		};
		
		NSLog(@"Trace log of ball:\n%@\n================================================================", [[ISTraceLog sharedTraceLog] formattedLogForIdentifier:ISTRACELOG_IDENTIFIER_O(ball) options:kISTraceLogOptionsDefault notOlderThan:0]);

		// Uncomment for additional trace logs for each of the rackets

		// NSLog(@"Trace log of racketOne:\n%@\n================================================================", [[ISTraceLog sharedTraceLog] formattedLogForIdentifier:ISTRACELOG_IDENTIFIER_O(racketOne) options:kISTraceLogOptionsDefault notOlderThan:0]);

		// NSLog(@"Trace log of racketTwo:\n%@\n================================================================", [[ISTraceLog sharedTraceLog] formattedLogForIdentifier:ISTRACELOG_IDENTIFIER_O(racketTwo) options:kISTraceLogOptionsDefault notOlderThan:0]);

	}
	return 0;
}
