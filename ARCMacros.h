//
//  ARCMacros.h
//  ISKit
//
//  Created by Felix Schwarz on 31.03.17.
//  Copyright © 2017 IOSPIRIT GmbH. All rights reserved.
//

#ifndef ARCMacros_h
#define ARCMacros_h

#if !__has_feature(objc_arc)
	#define ISRetain(obj)				[obj retain]
	#define ISRetained(obj)				[obj retain]
	#define ISRelease(obj)				[obj release]
	#define ISAutoRelease(obj)			[obj autorelease]
	#define ISAutoReleased(obj)			[obj autorelease]
	#define ISReleaseNil(obj)			[obj release]; obj=nil
	#define ISSuperDealloc()			[super dealloc]
	#define ISSetValueRetained(instVar,newValue)	[newValue retain]; [instVar release]; instVar = newValue
	
	#define IS_WEAK					__unsafe_unretained
	
	#define ISDispatchRelease(dispatchObj)		dispatch_release(dispatchObj)
#else
	#define ISRetain(obj)				
	#define ISRetained(obj)				obj
	#define ISRelease(obj)				
	#define ISAutoRelease(obj)			
	#define ISAutoReleased(obj)			obj
	#define ISReleaseNil(obj)			obj=nil
	#define ISSuperDealloc()			
	#define ISSetValueRetained(instVar,newValue)	instVar = newValue

	#define IS_WEAK					__weak

	#define ISDispatchRelease(dispatchObj)		dispatchObj = NULL
#endif

#endif /* ARCMacros_h */
