/*
 *	NGLCoreTimer.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *	
 *	Created by Diney Bomfim on 7/1/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLRuntime.h"
#import "NGLGlobal.h"

/*!
 *					This protocol defines the callback functions to every instance which makes use of the
 *					NinevehGL Timer API.
 *
 *					The default callback interval is defined by the constant NGL_MAX_FPS,
 *					which means the callback function will be called NGL_MAX_FPS times per second.
 */
@protocol NGLCoreTimer <NSObject>

@required

/*!
 *					This method is automatically called when an object, which implements NGLCoreTimer
 *					protocol, enters in the NinevehGL timer cycle. This method is called in the render
 *					thread, if the multithreading is enabled.
 */
- (void) timerCallBack;

@end