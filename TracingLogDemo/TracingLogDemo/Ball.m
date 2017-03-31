//
//  Ball.m
//  TracingLogDemo
//
//  Created by Felix Schwarz on 31.03.17.
//  Copyright © 2017 IOSPIRIT GmbH. All rights reserved.
//

#import "Ball.h"
#import "ISTraceLog.h"

@implementation Ball

@synthesize hits;

- (instancetype)init
{
	if (self = [super init])
	{
		ISTRACELOG_ENTER_O(self);
		ISTRACELOG_O(self, @"Ball initialized");
		ISTRACELOG_LEAVE_O(self);
	}

	return(self);
}

- (void)hit
{
	ISTRACELOG_ENTER_O(self);

	hits++;

	ISTRACELOG_O(self, @"Ball hit, hits=%d", hits);
	ISTRACELOG_LEAVE_O(self);
}

@end
