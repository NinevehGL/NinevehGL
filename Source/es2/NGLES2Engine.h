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

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "NGLRuntime.h"
#import "NGLDataType.h"
#import "NGLCoreEngine.h"
#import "NGLError.h"
#import "NGLView.h"

#import "NGLES2Functions.h"

/*!
 *					<strong>(Internal only)</strong> Manages Framebuffers, Renderbuffers, EAGLContext
 *					and Render Cycle.
 *
 *					#NGLES2Engine# is the greatest render core of NinevehGL using OpenGL ES 2. This class
 *					is responsible for creating, managing and deleting the Framebuffer, all the
 *					Renderbuffers, EAGLContext, Multisample filter, Viewport and everything directly
 *					related to the render cycle, like Cull Face and Front Face.
 *
 *					It's prepared to avoid any kind of redundant calls or sets. It also works with the
 *					NinevehGL Error API and can show any error related to the buffers or the render cycle.
 *
 *					#NGLES2Engine# is hold by a #NGLView#. Every change in that layer which implies into a
 *					redraw of the screen, like a change to the device orientation, produces a re-layout
 *					in the buffers. That means all the buffers will be deleted and recreated.
 *
 *					Besides, #NGLES2Engine# is the first and last class to be called in the NinevehGL's
 *					Render Chain. The Color Renderbuffer is mandatory, but the Depth Renderbuffer and
 *					Stencil Renderbuffer are optionals.
 */
@interface NGLES2Engine : NSObject <NGLCoreEngine>
{
@private
	EAGLContext				*_context;
	NGLView					*_layer;
	
	GLbitfield				_clearBuffer;
	GLenum					*_discards;
	GLsizei					_discardCount;
	GLsizei					_width;
	GLsizei					_height;
	
	// Normal Buffers
	GLuint					_frameBuffer;
	GLuint					_colorBuffer;
	GLuint					_depthBuffer;
	GLuint					_stencilBuffer;
	
	// Multisample Buffers
	GLuint					_msaaFrameBuffer;
	GLuint					_msaaColorBuffer;
	GLuint					_msaaDepthBuffer;
	
	// Helpers
	NGLAntialias			_antialias;
	BOOL					_useDepthBuffer;
	BOOL					_useStencilBuffer;
	BOOL					_isReady;
	
	// ReadPixels APIs
	unsigned char			*_offscreenData;
	
	// Error API
	NGLError				*_error;
}

@end