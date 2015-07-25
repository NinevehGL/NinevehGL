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