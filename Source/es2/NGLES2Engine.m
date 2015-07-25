/*
 *  NGLES2Engine.m
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

#import "NGLES2Engine.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

static NSString *const ENG_ERROR_HEADER = @"Error while processing NGLES2Engine.";

static NSString *const ENG_ERROR_BUFFER = @"Incomplete FrameBuffer.\n\
The FrameBuffers or RenderBuffers was not properly configured and OpenGL generated the error %x.";

static NSString *const ENG_ERROR_LAYER = @"CAEAGLLayer is missing.\n\
You must set a valid CAEAGLLayer before update the engine.";

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

static NGLES2Engine				*_lastEngine;

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

// Parses the values from NinevehGL Globals to OpenGL ES format, sending them to NGLES2Functions.
static void updateStates()
{
	//*************************
	//	General
	//*************************
	ngles2Default();
	
	//*************************
	//	Pixel Blend
	//*************************
	ngles2BlendAlpha((nglDefaultColorFormat == NGLColorFormatRGBA));
	
	//*************************
	//	Front and Cull Face
	//*************************
	GLenum front, cull;
	
	switch (nglDefaultFrontFace)
	{
		case NGLFrontFaceCCW:
			front = GL_CCW;
			break;
		case NGLFrontFaceCW:
			front = GL_CW;
			break;
	}
	
	switch (nglDefaultCullFace)
	{
		case NGLCullFaceBack:
			cull = GL_BACK;
			break;
		case NGLCullFaceFront:
			cull = GL_FRONT;
			break;
		case NGLCullFaceNone:
			cull = NGL_NULL;
			break;
	}
	
	ngles2FrontCullFace(front, cull);
	
	// Commiting changes on OpenGL resources.
	glFlush();
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NGLES2Engine()

// Initializes a new instance.
- (void) initialize;

// Creates a new discard based on an attachment.
- (void) createDiscardsTo:(GLenum)attachment;

// Deletes all discards.
- (void) deleteDiscards;

// Creates Frame and Render buffers.
- (void) createBuffers;

// Creates Apple Multisampling buffers.
- (void) createMultisampleBuffers;

// Deletes all buffer on this engine.
- (void) destroyBuffers;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLES2Engine

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize isReady = _isReady, useDepthBuffer = _useDepthBuffer, useStencilBuffer = _useStencilBuffer,
			layer = _layer, offscreenData = _offscreenData;

@dynamic antialias, framebuffer, renderbuffer, size;

- (NGLAntialias) antialias { return _antialias; }
- (void) setAntialias:(NGLAntialias)value
{
	_antialias = (nglDefaultAntialias == NGL_NULL) ? value : nglDefaultAntialias;
}

- (unsigned int) framebuffer { return _frameBuffer; }

- (unsigned int) renderbuffer { return _colorBuffer; }

- (CGSize) size { return (CGSize){ _width, _height }; }

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
    if ((self = [super init]))
	{
		[self initialize];
	}
	
    return self;
}

- (id) initWithLayer:(NGLView *)layer
{
    if ((self = [super init]))
	{
		[self initialize];
		
		_layer = layer;
	}
	
    return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initialize
{
	// Initializes a EAGLContext at the current thread. This one will be the first to create a
	// EAGLContext, which will share its sharegroup with all other contexts in NinevehGL.
	// Usually this thread is the main thread.
	nglContextEAGL();
	
	// Settings.
	_isReady = NO;
	
	// Initialize error API.
	_error = [[NGLError alloc] init];
	_error.header = ENG_ERROR_HEADER;
}

- (void) createDiscardsTo:(GLenum)attachment
{
	_discards = realloc(_discards, sizeof(GLenum) * (_discardCount + 1));
	_discards[_discardCount] = attachment;
	_discardCount++;
}

- (void) deleteDiscards
{
	_discardCount = 0;
	nglFree(_discards);
}

- (void) createBuffers
{
	// Clears previously Buffer Objects.
	[self destroyBuffers];
	
    // Frame Buffer.
	glGenFramebuffers(1, &_frameBuffer);
	ngles2BindBuffer(GL_FRAMEBUFFER, _frameBuffer, YES);
	
	// Color Render Buffer.
	glGenRenderbuffers(1, &_colorBuffer);
	ngles2BindBuffer(GL_RENDERBUFFER, _colorBuffer, YES);
	[_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)_layer.layer];
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorBuffer);
	_clearBuffer = GL_COLOR_BUFFER_BIT;
	
	// Depth Render Buffer.
	if (_useDepthBuffer)
	{
		glGenRenderbuffers(1, &_depthBuffer);
		ngles2BindBuffer(GL_RENDERBUFFER, _depthBuffer, YES);
		glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _width, _height);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);
		_clearBuffer = _clearBuffer | GL_DEPTH_BUFFER_BIT;
		
		// Updates discards.
		[self createDiscardsTo:GL_DEPTH_ATTACHMENT];
		
		// Enables the state for depth test once.
		ngles2State(GL_DEPTH_TEST, YES);
	}
	
	// Stencil Render Buffer.
	if (_useStencilBuffer)
	{
		glGenRenderbuffers(1, &_stencilBuffer);
		ngles2BindBuffer(GL_RENDERBUFFER, _stencilBuffer, YES);
		glRenderbufferStorage(GL_RENDERBUFFER, GL_STENCIL_INDEX8, _width, _height);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _stencilBuffer);
		_clearBuffer = _clearBuffer | GL_STENCIL_BUFFER_BIT;
		
		// Updates discards.
		[self createDiscardsTo:GL_STENCIL_ATTACHMENT];
		
		// Enables the state for stencil test once.
		ngles2State(GL_STENCIL_TEST, YES);
	}
	
	// Anti-Aliasing Filter (Apple Multisample).
	if (_antialias >= NGLAntialias4X)
	{
		[self createMultisampleBuffers];
	}
}

- (void) createMultisampleBuffers
{
	GLenum color = (nglDefaultColorFormat == NGLColorFormatRGB) ? GL_RGB8_OES : GL_RGBA8_OES;
	
	glGenFramebuffers(1, &_msaaFrameBuffer);
	ngles2BindBuffer(GL_FRAMEBUFFER, _msaaFrameBuffer, NO);
	
	// Color Render Buffer
	glGenRenderbuffers(1, &_msaaColorBuffer);
	ngles2BindBuffer(GL_RENDERBUFFER, _msaaColorBuffer, NO);
	glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, _antialias, color, _width, _height);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _msaaColorBuffer);
	
	// Depth Render Buffer
	if (_useDepthBuffer)
	{
		glGenRenderbuffers(1, &_msaaDepthBuffer);
		ngles2BindBuffer(GL_RENDERBUFFER, _msaaDepthBuffer, NO);
		glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, _antialias, GL_DEPTH_COMPONENT16,
											  _width, _height);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _msaaDepthBuffer);
	}
	
	// Updates discards.
	[self createDiscardsTo:GL_COLOR_ATTACHMENT0];
}

- (void) destroyBuffers
{
	// Deletes all discards.
	[self deleteDiscards];
	
	// Resets the current buffers.
	[_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:nil];
	ngles2BindBuffer(GL_RENDERBUFFER, 0, YES);
	ngles2BindBuffer(GL_FRAMEBUFFER, 0, YES);
	
	// Deletes the RenderBuffers
    if (_colorBuffer != 0)
	{
        glDeleteRenderbuffers(1, &_colorBuffer);
        _colorBuffer = 0;
	}
	
    if (_depthBuffer != 0)
	{
        glDeleteRenderbuffers(1, &_depthBuffer);
        _depthBuffer = 0;
	}
	
	if (_stencilBuffer != 0)
	{
        glDeleteRenderbuffers(1, &_stencilBuffer);
        _stencilBuffer = 0;
	}
	
	// Deletes the Multisample RenderBuffers
    if (_msaaColorBuffer != 0)
	{
        glDeleteRenderbuffers(1, &_msaaColorBuffer);
        _msaaColorBuffer = 0;
	}
	
    if (_msaaDepthBuffer != 0)
	{
        glDeleteRenderbuffers(1, &_msaaDepthBuffer);
        _msaaDepthBuffer = 0;
	}
	
	// Deletes the FrameBuffer
    if (_frameBuffer != 0)
	{
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
	}
	
	// Deletes the Multisample FrameBuffer
    if (_msaaFrameBuffer != 0)
	{
        glDeleteFramebuffers(1, &_msaaFrameBuffer);
        _msaaFrameBuffer = 0;
	}
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) defineBuffers
{
	// Prevents nil layer.
	if (!_layer)
	{
		_error.message = ENG_ERROR_LAYER;
		[_error showError];
		return;
	}
	
	// Gets the current context for the current thread.
	_context = nglContextEAGL();
	
	// Sets the current layer size.
	CGSize size = _layer.bounds.size;
	_width = (GLsizei)(size.width * _layer.contentScaleFactor);
	_height = (GLsizei)(size.height * _layer.contentScaleFactor);
	
	// Creates the necessary buffers.
	[self createBuffers];
	
	// Resents the last engine.
	_lastEngine = nil;
	
	// Prints a possible error on the console.
	if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
	{
		GLenum log = glCheckFramebufferStatus(GL_FRAMEBUFFER);
		_error.message = [NSString stringWithFormat:ENG_ERROR_BUFFER, log];
		[_error showError];
	}
	
	// Updates all the necessary OpenGL ES states.
	updateStates();
	
	// Now this engine is ready for render.
	_isReady = YES;
}

- (void) clearBuffers
{
	// Avoids redundant calls.
	if (!_isReady)
	{
		return;
	}
	
	// This engine is not ready any more.
	_isReady = NO;
	
	// Gets the current context for the current thread.
	_context = nglContextEAGL();
	
	// Clears the buffers.
	[self destroyBuffers];
	[self offscreenRenderFree];
}

- (void) preRender
{
	// If there is multiple engines currently running, each one must rebind its buffers.
	// This check is a optimization for applications with a single NGLView (95% of all).
	if (_lastEngine != self)
	{
		//NGLvec4 color = nglColorFromUIColor(_layer.backgroundColor);
		NGLvec4 color = *_layer.colorPointer;
		
		_lastEngine = self;
		ngles2BindBuffer(GL_FRAMEBUFFER, _frameBuffer, YES);
		ngles2BindBuffer(GL_RENDERBUFFER, _colorBuffer, YES);
		ngles2Viewport(0, 0, _width, _height);
		ngles2Color(color.r, color.g, color.b, color.a);
	}
	
	if (_antialias  >= NGLAntialias4X)
	{
		ngles2BindBuffer(GL_FRAMEBUFFER, _msaaFrameBuffer, NO);
	}
	
	// Clears previously attachments in the current Frame Buffer.
	glClear(_clearBuffer);
}

- (void) render
{
	if (_antialias  >= NGLAntialias4X)
	{
		ngles2BindBuffer(GL_DRAW_FRAMEBUFFER_APPLE, _frameBuffer, NO);
		ngles2BindBuffer(GL_READ_FRAMEBUFFER_APPLE, _msaaFrameBuffer, NO);
		glResolveMultisampleFramebufferAPPLE();
	}
	
	// Apple (and the khronos group as well) encourages to discard
	// unneded render buffer contents whenever is possible.
	glDiscardFramebufferEXT(GL_FRAMEBUFFER, _discardCount, _discards);
	
	// Presents the bound render buffer. In deep, it will swap the back and front buffer.
	[_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void) offscreenRender
{
	// Sets the correct buffers.
	ngles2BindBuffer(GL_FRAMEBUFFER, _frameBuffer, YES);
	ngles2BindBuffer(GL_RENDERBUFFER, _colorBuffer, YES);
	
	// Prepares to receive new data.
	nglFree(_offscreenData);
	_offscreenData = malloc(_width * _height * NGL_SIZE_UINT);// size of uint = byte * 4
	
	// Makes sure the data is aligned in 4 bytes and retrieves the data.
	glReadPixels(0, 0, _width, _height, GL_RGBA, GL_UNSIGNED_BYTE, _offscreenData);
}

- (void) offscreenRenderFree
{
	nglFree(_offscreenData);
}

- (NGLivec4) pixelColorAtPoint:(CGPoint)point
{
	unsigned char pixelData[4];
	glReadPixels(point.x, _height - point.y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, &pixelData);
	
	return (NGLivec4){ pixelData[0], pixelData[1], pixelData[2], pixelData[3] };
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	// IMPORTANT: clearBuffers must be called by the owner before in the same thread as defineBuffers was.
	
	nglRelease(_error);
	
    [super dealloc];
}

@end