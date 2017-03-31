# ISTraceLog
A class for building a trace log to follow an object's journey as it travels through your app.

*by [@felix_schwarz](https://twitter.com/felix_schwarz/)*

## Inspiration
Working on an NSCollectionViewLayout subclass, I ran into a problem that could only be reproduced during rapid scrolling and spanned across five classes. With the only link between them being the NSIndexPath of the displayed items.

After spending a day with futile attempts to identifiy the root cause of the issue, I wrote this class to get a detailed, hierarchic and chronologic view of what was happening inside these classes. Using it, I could identify and fix the edge case responsible for the issue within a couple of minutes.

## Usage
To follow an object around your app, you need to add a few macros to the methods that manipulate or work with it. 

```objc
#import "ISTraceLog.h"


@implementation MyObjectCache
…

- (void)cacheHeightFromObject:(MyObject *)object
{
	ISTRACELOG_ENTER_O(object); // Log the entrance into this method with ISTraceLog 

	ISTRACELOG_MSG_O(object, @"Caching height=%f", object.height); // Log the value that was taken from MyObject
	cachedHeight = object.height;

	…

	ISTRACELOG_LEAVE_O(object); // Log the end of this method with ISTraceLog 
}

…
@end

@implementation MyObject

- (void)setHeight:(CGFloat)height
{
	ISTRACELOG_ENTER_O(self); // Log the entrance into this method with ISTraceLog 

	ISTRACELOG_MSG_O(self, @"Height changed. height=%f", height); // Log the change
	_height = height;

	ISTRACELOG_LEAVE_O(self); // Log the entrance into this method with ISTraceLog 
}

@end

```

Then, if anything goes wrong later and you'd like to know what operations were performed with and on the object, you can retrieve and log a formatted log using

```objc
NSLog(@"%@", [[ISTraceLog sharedTraceLog] formattedLogForIdentifier:ISTRACELOG_IDENTIFIER_O(myObjectInstance) options:kISTraceLogOptionsDefault notOlderThan:0]);
```

ISTraceLog provides three flavors of its logging macros:
* one for objects that comply to NSCopying (like f.ex. NSString, NSNumber, NSIndexPath, ..):
	* ISTRACELOG_ENTER(identifier)
	* ISTRACELOG(identifier, fmt, ..)
	* ISTRACELOG_LEAVE(identifier)

* one for raw pointers (void *):
	* ISTRACELOG_ENTER_P(pointer)
	* ISTRACELOG_P(pointer, fmt, ..)
	* ISTRACELOG_LEAVE_P(pointer)

* one for object instances:
	* ISTRACELOG_ENTER_O(pointer)
	* ISTRACELOG_O(pointer, fmt, ..)
	* ISTRACELOG_LEAVE_O(pointer)

## Features
* Show log entry time
	* relative to the first ISTraceLog call
	* relative to the first log entry generated for an object
	* relative to current time (T minus style)
	* as date
* Can return only log entries from within X seconds before requesting a formatted log
* Fast: offloads as much work as possible to a background queue, postpones the bulk of formatting until a formatted log is requested
* Lock-free (except for the formatted log generation)

## Example output
Here's the example output from the included demo:
```text
0.0001 [---> Entered -[Ball init]
0.0004         [MSG] Ball initialized [Ball.m:21]
0.0004 --->] Leaving -[Ball init]
0.0004 [---> Entered -[Racket hitBall:]
0.0004         [---> Entered -[Ball hit]
0.0005                 [MSG] Ball hit, hits=1 [Ball.m:34]
0.0005         --->] Leaving -[Ball hit]
0.0006         [MSG] Ping (-[Racket hitBall:] [Racket.m:24])
0.0006 --->] Leaving -[Racket hitBall:]
0.0006 [---> Entered -[Racket hitBall:]
0.0006         [---> Entered -[Ball hit]
0.0006                 [MSG] Ball hit, hits=2 [Ball.m:34]
0.0006         --->] Leaving -[Ball hit]
0.0007         [---> Entered -[Racket doubleCheckPong:]
0.0007                 [MSG] Pong [Racket.m:42]
0.0007         --->] Leaving -[Racket doubleCheckPong:]
0.0007 --->] Leaving -[Racket hitBall:]
0.0007 [---> Entered -[Racket hitBall:]
0.0008         [---> Entered -[Ball hit]
0.0008                 [MSG] Ball hit, hits=3 [Ball.m:34]
0.0008         --->] Leaving -[Ball hit]
0.0008         [MSG] Ping (-[Racket hitBall:] [Racket.m:24])
0.0008 --->] Leaving -[Racket hitBall:]
0.0008 [---> Entered -[Racket hitBall:]
0.0008         [---> Entered -[Ball hit]
0.0009                 [MSG] Ball hit, hits=4 [Ball.m:34]
0.0009         --->] Leaving -[Ball hit]
0.0009         [---> Entered -[Racket doubleCheckPong:]
0.0009                 [MSG] Pong [Racket.m:42]
0.0009         --->] Leaving -[Racket doubleCheckPong:]
0.0009 --->] Leaving -[Racket hitBall:]
0.0009 [---> Entered -[Racket hitBall:]
0.0009         [---> Entered -[Ball hit]
0.0010                 [MSG] Ball hit, hits=5 [Ball.m:34]
0.0010         --->] Leaving -[Ball hit]
0.0010         [MSG] Ping (-[Racket hitBall:] [Racket.m:24])
0.0010 --->] Leaving -[Racket hitBall:]
0.0010 [---> Entered -[Racket hitBall:]
0.0010         [---> Entered -[Ball hit]
0.0010                 [MSG] Ball hit, hits=6 [Ball.m:34]
0.0010         --->] Leaving -[Ball hit]
0.0011         [---> Entered -[Racket doubleCheckPong:]
0.0011                 [MSG] Pong [Racket.m:42]
0.0011         --->] Leaving -[Racket doubleCheckPong:]
0.0011 --->] Leaving -[Racket hitBall:]
0.0011 [---> Entered -[Racket hitBall:]
0.0011         [---> Entered -[Ball hit]
0.0012                 [MSG] Ball hit, hits=7 [Ball.m:34]
0.0012         --->] Leaving -[Ball hit]
0.0012         [MSG] Ping (-[Racket hitBall:] [Racket.m:24])
0.0012 --->] Leaving -[Racket hitBall:]
0.0012 [---> Entered -[Racket hitBall:]
0.0012         [---> Entered -[Ball hit]
0.0012                 [MSG] Ball hit, hits=8 [Ball.m:34]
0.0012         --->] Leaving -[Ball hit]
0.0013         [---> Entered -[Racket doubleCheckPong:]
0.0013                 [MSG] Pong [Racket.m:42]
0.0013         --->] Leaving -[Racket doubleCheckPong:]
0.0013 --->] Leaving -[Racket hitBall:]
0.0013 [---> Entered -[Racket hitBall:]
0.0013         [---> Entered -[Ball hit]
0.0013                 [MSG] Ball hit, hits=9 [Ball.m:34]
0.0014         --->] Leaving -[Ball hit]
0.0014         [MSG] Ping (-[Racket hitBall:] [Racket.m:24])
0.0014 --->] Leaving -[Racket hitBall:]
0.0014 [---> Entered -[Racket hitBall:]
0.0014         [---> Entered -[Ball hit]
0.0014                 [MSG] Ball hit, hits=10 [Ball.m:34]
0.0014         --->] Leaving -[Ball hit]
0.0015         [---> Entered -[Racket doubleCheckPong:]
0.0015                 [MSG] Pong [Racket.m:42]
0.0015                 [---> Entered -[Racket stealthHit:]
0.0015                         [MSG] Manipulated hitCount, so the pong goes unnoticed, hits=9 [Racket.m:61]
0.0015                 --->] Leaving -[Racket stealthHit:]
0.0016         --->] Leaving -[Racket doubleCheckPong:]
0.0016 --->] Leaving -[Racket hitBall:]
0.0016 [---> Entered -[Racket hitBall:]
0.0016         [---> Entered -[Ball hit]
0.0016                 [MSG] Ball hit, hits=10 [Ball.m:34]
0.0016         --->] Leaving -[Ball hit]
0.0016         [---> Entered -[Racket doubleCheckPong:]
0.0017                 [MSG] Pong [Racket.m:42]
0.0017         --->] Leaving -[Racket doubleCheckPong:]
0.0017 --->] Leaving -[Racket hitBall:]
```

## License
MIT License

Copyright (c) 2017 IOSPIRIT GmbH

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

