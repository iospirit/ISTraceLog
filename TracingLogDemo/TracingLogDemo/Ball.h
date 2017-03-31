//
//  Ball.h
//  TracingLogDemo
//
//  Created by Felix Schwarz on 31.03.17.
//  Copyright © 2017 IOSPIRIT GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Ball : NSObject
{
	NSInteger hits;
}

@property(assign) NSInteger hits;

- (void)hit;

@end
