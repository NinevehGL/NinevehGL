/*
 *	NGLContext.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *  Created by Diney Bomfim on 10/14/11.
 *  Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import <OpenGLES/EAGL.h>

#import "NGLRuntime.h"
#import "NGLGlobal.h"

/*!
 *					Defines a EAGLContext for the current running thread.
 *
 *					If the context was already created, just returns the pointer to it. The created
 *					instance will be internally retained.
 *
 *					You must call <code>nglContextDeleteCurrent()</code> to delete the created context.
 *
 *	@result			A pointer to the created EAGLContext.
 */
NGL_API EAGLContext *nglContextEAGL(void);

/*!
 *					Deletes the EAGLContext for the current running thread. This call must be called from
 *					the thread you want to delete contexts (EAGLContext and NGLContext). Both contexts
 *					work together, so they are also deleted together.
 */
NGL_API void nglContextDeleteCurrent(void);