/*
 *	NGLES2Engine.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *  Created by Diney Bomfim on 9/3/10.
 *  Copyright (c) 2010 DB-Interactively. All rights reserved.
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