/*
 *	Copyright (c) 2011-2015 NinevehGL. More information at: http://nineveh.gl
 *
 *	Permission is hereby granted, free of charge, to any person obtaining a copy
 *	of this software and associated documentation files (the "Software"), to deal
 *	in the Software without restriction, including without limitation the rights
 *	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *	copies of the Software, and to permit persons to whom the Software is
 *	furnished to do so, subject to the following conditions:
 *
 *	The above copyright notice and this permission notice shall be included in
 *	all copies or substantial portions of the Software.
 *
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *	THE SOFTWARE.
 */

#import "NGLContext.h"
#import <pthread.h>

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Definitions
//**************************************************
//	Private Definitions
//**************************************************

static EAGLSharegroup *_nglGroup = nil;
static pthread_mutex_t _nglContextMutex;

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

EAGLContext *nglContextEAGL(void)
{
    // Thread Safety: Protect the critical section of establishing the shared group.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_mutex_init(&_nglContextMutex, NULL );
    });
    
	EAGLContext *contextEAGL = [EAGLContext currentContext];
	if (contextEAGL == nil)
	{
        pthread_mutex_lock(&_nglContextMutex);
		
		// Choose the correct API.
        EAGLRenderingAPI api;
		switch (nglDefaultEngine)
		{
			case NGLEngineVersionES2:
			default:
				api = kEAGLRenderingAPIOpenGLES2;
				break;
		}
		
		// The first context created will generate the sharegroup (usually done in the main thread).
		// NinevehGL shares all resources between all contexts, useful when changing multithreading.
		contextEAGL = [[[EAGLContext alloc] initWithAPI:api sharegroup:_nglGroup] autorelease];
		_nglGroup = (_nglGroup) ? _nglGroup : contextEAGL.sharegroup;
		
		// Commit changes and set the new EAGLContext.
		[EAGLContext setCurrentContext:contextEAGL];
        
        pthread_mutex_unlock(&_nglContextMutex);
	}
	
	return contextEAGL;
}

void nglContextDeleteCurrent(void)
{
	// Commit changes and set the new EAGLContext.
	[EAGLContext setCurrentContext:nil];
}

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

