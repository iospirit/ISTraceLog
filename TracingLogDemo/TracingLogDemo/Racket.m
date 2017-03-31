//
//  Racket.m
//  TracingLogDemo
//
//  Created by Felix Schwarz on 31.03.17.
//  Copyright © 2017 IOSPIRIT GmbH. All rights reserved.
//

#import "Racket.h"
#import "ISTraceLog.h"

@implementation Racket

- (void)hitBall:(Ball *)ball
{
	ISTRACELOG_ENTER_O(ball);
	ISTRACELOG_ENTER_O(self);
	[ball hit];
	
	ISTRACELOG_O(self, @"Hitting ball %@", ball);
	
	if (ball.hits % 2)
	{
		ISTRACELOG_O(ball, @"Ping");
	}
	else
	{
		[self doubleCheckPong:ball];
	}

	ISTRACELOG_LEAVE_O(self);
	ISTRACELOG_LEAVE_O(ball);
}

- (void)doubleCheckPong:(Ball *)ball
{
	ISTRACELOG_ENTER_O(ball);
	ISTRACELOG_ENTER_O(self);
	
	if ((ball.hits % 2) == 0)
	{
		ISTRACELOG_O(ball, @"Pong");
	}
	
	if ((rand() % 5) == 0)
	{
		[self stealthHit:ball];
	}

	ISTRACELOG_LEAVE_O(self);
	ISTRACELOG_LEAVE_O(ball);
}

- (void)stealthHit:(Ball *)ball
{
	ISTRACELOG_ENTER_O(ball);
	ISTRACELOG_ENTER_O(self);

	ball.hits--;

	ISTRACELOG_O(ball, @"Manipulated hitCount, so the pong goes unnoticed, hits=%d", ball.hits);
	ISTRACELOG_O(self, @"Manipulated hitCount of %@, so the pong goes unnoticed, hits=%d", ball, ball.hits);

	ISTRACELOG_LEAVE_O(self);
	ISTRACELOG_LEAVE_O(ball);
}

@end
