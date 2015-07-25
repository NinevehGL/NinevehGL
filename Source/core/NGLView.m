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

#import "NGLView.h"
#import "NGLTimer.h"
#import "NGLThread.h"
#import "NGLArray.h"

// Parsers
#import "NGLParserImage.h"

// OpenGL ES 2.x
#import "NGLES2Engine.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

static NSString *const VIEW_ERROR_HEADER = @"Error while processing NGLView.";

static NSString *const VIEW_ERROR_DELEGATE = @"The instance %@ can't be declared as a delegate instance \
because it doesn't implement the NGLViewDelegate protocol correctly. \n\
It should implements the drawView() method.";

//static NSString *const VIEW_ERROR_SIZE = @"This NGLView can't create an OpenGL Engine without a size.\n\
You must define the \"frame\" or \"bounds\" property with a valid size before proceed.";

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

// Global pointer library to the views.
static NGLArray *_views;

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NGLView()

// Initializes a new instance.
- (void) initialize;

// Recreates the core engine.
- (void) updateCoreEngine;

// Deletes the current core engine.
- (void) deleteCoreEngine;

@end

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

// Recreates the buffers. This method sends a synchronous task to the core mesh thread.
static void fillCoreEngine(id <NGLCoreEngine> coreEngine, BOOL background)
{
	if (coreEngine != nil)
	{
		CGSize size = coreEngine.layer.bounds.size;
		
		// Avoids NGLView without a valid size.
		if (size.width == 0.0f || size.height == 0.0f)
		{
			//[NGLError errorInstantlyWithHeader:VIEW_ERROR_HEADER
			//						andMessage:VIEW_ERROR_SIZE];
			return;
		}
		
		// Every time the application changes the layout of this view,
		// reports the changes to the current NinevehGL engine.
		if (background)
		{
			nglThreadPerformAsync(kNGLThreadRender, @selector(defineBuffers), coreEngine);
			//nglThreadPerformSync(kNGLThreadRender, @selector(defineBuffers), coreEngine);
		}
		else
		{
			[coreEngine defineBuffers];
		}
	}
}

// Clears all the buffers from core mesh. This method sends a synchronous task to the core mesh thread.
static void emptyCoreEngine(id <NGLCoreEngine> coreEngine, BOOL background)
{
	if (coreEngine != nil)
	{
		// Before releasing the core engine, it's important to clear its buffers.
		if (background)
		{
			nglThreadPerformSync(kNGLThreadRender, @selector(clearBuffers), coreEngine);
		}
		else
		{
			[coreEngine clearBuffers];
		}
		
	}
}

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLView

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@dynamic paused, offscreen, delegate, antialias, useDepthBuffer, useStencilBuffer,
		 framebuffer, renderbuffer, colorPointer;

- (BOOL) isPaused { return _paused; }
- (void) setPaused:(BOOL)value
{
	_paused = value;
	
	// This view will enter in the run loop only if it's not paused and the offscreen is set to NO.
	if (!_paused && !_offscreen)
	{
		[[NGLTimer defaultTimer] addItem:self];
	}
	else
	{
		[[NGLTimer defaultTimer] removeItem:self];
	}
}

- (BOOL) isOffscreen { return _offscreen; }
- (void) setOffscreen:(BOOL)value
{
	_offscreen = value;
	
	// Updates the paused status.
	self.paused = _paused;
	
	// Setting a view to offscreen doesn't change the engine, however the buffers must be recreated
	// to conform with the view needs.
	fillCoreEngine(_engine, !_offscreen);
}

- (NGLAntialias) antialias { return _antialias; }
- (void) setAntialias:(NGLAntialias)value;
{
	if (value != _antialias)
	{
		_antialias = value;
		
		// Every change in the engine entails in reconstructing the engine buffers.
		_engine.antialias = _antialias;
		fillCoreEngine(_engine, !_offscreen);
	}
}

- (BOOL) useDepthBuffer { return _useDepthBuffer; }
- (void) setUseDepthBuffer:(BOOL)value
{
	if (value != _useDepthBuffer)
	{
		_useDepthBuffer = value;
		
		// Every change in the engine entails in reconstructing the engine buffers.
		_engine.useDepthBuffer = _useDepthBuffer;
		fillCoreEngine(_engine, !_offscreen);
	}
}

- (BOOL) useStencilBuffer { return _useStencilBuffer; }
- (void) setUseStencilBuffer:(BOOL)value
{
	if (value != _useStencilBuffer)
	{
		_useStencilBuffer = value;
		
		// Every change in the engine entails in reconstructing the engine buffers.
		_engine.useStencilBuffer = _useStencilBuffer;
		fillCoreEngine(_engine, !_offscreen);
	}
}

- (id <NGLViewDelegate>) delegate { return (_delegate == self) ? nil : _delegate; }
- (void) setDelegate:(id <NGLViewDelegate>)value
{
	if (value != nil && ![value respondsToSelector:@selector(drawView)])
	{
		_delegate = self;
		[NGLError errorInstantlyWithHeader:VIEW_ERROR_HEADER
								andMessage:[NSString stringWithFormat:VIEW_ERROR_DELEGATE, value]];
	}
	else
	{
		_delegate = (value != nil) ? value : self;
	}
}

- (unsigned int) framebuffer { return _engine.framebuffer; }

- (unsigned int) renderbuffer { return _engine.renderbuffer; }

- (NGLvec4 *) colorPointer { return &_color; }

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

- (id) initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self initialize];
	}
	
    return self;
}

- (id) initWithCoder:(NSCoder *)decoder
{
	if ((self = [super initWithCoder:decoder]))
	{
		[self initialize];
	}
	
    return self;
}

- (id) initWithOffscreenFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		_offscreen = YES;
		
		[self initialize];
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
	// Allocates once.
	if (_views == nil)
	{
		_views = [[NGLArray alloc] init];
	}
	
	// Adds the current view if it was not already in there.
	[_views addPointerOnce:self];
	
	// Settings.
	_antialias = NGLAntialiasNone;
	_useDepthBuffer = YES;
	_useStencilBuffer = NO;
	_color = nglDefaultColor;
	self.delegate = _delegate;
	
	// Constructs the core engine but not initialize the buffers nor the timer.
	[self updateCoreEngine];
}

- (void) updateCoreEngine
{
	//*************************
	//	EAGL Settings
	//*************************
	NSString *color;
	CAEAGLLayer *eaglLayer;
	NSDictionary *layperProperties;
	BOOL isOpaque = (nglDefaultColorFormat == NGLColorFormatRGB);
	
	// Chooses the right color format.
	color = isOpaque ? kEAGLColorFormatRGB565 : kEAGLColorFormatRGBA8;
	
	// Retains the last frame is not used by NinevehGL,
	// because the frame is reconstructed at every render cycle.
	layperProperties = [NSDictionary dictionaryWithObjectsAndKeys:
						[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
						color, kEAGLDrawablePropertyColorFormat,
						nil];
	
	// Sets the properties to CAEALLayer, the Apple's Layer to present OpenGL graphics.
	eaglLayer = (CAEAGLLayer *)[self layer];
	[eaglLayer setOpaque:isOpaque];
	[eaglLayer setDrawableProperties:layperProperties];
	
	// This view transparency follows the NinevehGL color format.
	[self setOpaque:isOpaque];
	
	//*************************
	//	Engine Settings
	//*************************
	//*
	// Clears the buffers and release the instance.
	emptyCoreEngine(_engine, !_offscreen);
	nglRelease(_engine);
	
	// Starts the new engine.
	switch (nglDefaultEngine)
	{
		case NGLEngineVersionES2:
		default:
			_engine = [[NGLES2Engine alloc] initWithLayer:self];
			break;
	}
	
	_engine.antialias = _antialias;
	_engine.useDepthBuffer = _useDepthBuffer;
	_engine.useStencilBuffer = _useStencilBuffer;
	
	// Fills the new core engine synchronously.
	fillCoreEngine(_engine, !_offscreen);
	/*/
	//TODO by changing the color format and this approach get error.
	id <NGLCoreEngine> newCore, oldCore = _engine;
	
	// Starts the new engine.
	switch (nglDefaultEngine)
	{
		case NGLEngineVersionES2:
		default:
			newCore = [[NGLES2Engine alloc] initWithLayer:eaglLayer];
			break;
	}
	
	newCore.antialias = _antialias;
	newCore.useDepthBuffer = _useDepthBuffer;
	newCore.useStencilBuffer = _useStencilBuffer;
	
	// Fills the new core engine synchronously.
	fillCoreEngine(newCore);
	
	// Now the new core engine is ready to render.
	// This view assumes it as the official core and gives up of the old core.
	_engine = newCore;
	
	// Clears the buffers and release the instance.
	emptyCoreEngine(oldCore);
	
	// Releases the old core engine.
	nglRelease(oldCore);
	//*/
}

- (void) deleteCoreEngine
{
	emptyCoreEngine(_engine, !_offscreen);
	
	// Releases the current core engine.
	nglRelease(_engine);
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) compileCoreEngine
{
	// Performs updates on the render thread.
	[self updateCoreEngine];
	
	// Restarts the render cycle.
	self.paused = NO;
}

- (void) timerCallBack
{
	// Prepares a new render.
	[_engine preRender];
	
	// Custom draws.
	[_delegate drawView];
	
	// Commits the new render.
	[_engine render];
}

- (void) drawView
{
	// Does nothing here, just override.
}

- (void) drawOffscreen
{
	// Prepares a new render.
	[_engine preRender];
}

+ (void) updateAllViews
{
	NGLView *view;
	
	//for (view in _views)
	nglFor (view, _views)
	{
		[view compileCoreEngine];
	}
}

+ (void) emptyAllViews
{
	NGLView *view;
	
	//for (view in _views)
	nglFor (view, _views)
	{
		[view deleteCoreEngine];
	}
}

+ (NSArray *) allViews
{
	return [_views allPointers];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) didMoveToSuperview
{
	[super didMoveToSuperview];
	
	// Starts the render cycle only when the view is visible.
	self.paused = NO;
}
/*
- (void) layoutSubviews
{
	CGSize engineSize = _engine.size;
	CGSize selfSize = self.bounds.size;
	float scale = self.contentScaleFactor;
	nglLog();
	// Avoids unecessary changes on the OpenGL buffers.
	if (selfSize.width * scale != engineSize.width || selfSize.height * scale != engineSize.height)
	{
		fillCoreEngine(_engine, !_offscreen);
	}
}
/*/
- (void) setBounds:(CGRect)value
{
	[super setBounds:value];
	
	// Avoids unecessary changes on the OpenGL buffers.
	if (_size.width != value.size.width || _size.height != value.size.height)
	{
		_size = value.size;
		fillCoreEngine(_engine, !_offscreen);
	}
}

- (void) setFrame:(CGRect)value
{
	[super setFrame:value];
	
	// Avoids unecessary changes on the OpenGL buffers.
	if (_size.width != value.size.width || _size.height != value.size.height)
	{
		_size = value.size;
		fillCoreEngine(_engine, !_offscreen);
	}
}
//*/

- (void) setContentScaleFactor:(CGFloat)value
{
	float scale = self.contentScaleFactor;
	
	[super setContentScaleFactor:value];
	
	// Avoids unecessary changes on the OpenGL buffers.
	if (value != scale && value != 0.0f)
	{
		fillCoreEngine(_engine, !_offscreen);
	}
}

- (UIColor *) backgroundColor { return nglColorToUIColor(_color); }
- (void) setBackgroundColor:(UIColor *)value
{
	// All the NGLView will have a nil UIKit background.
	// However its behavior is the same outside the class.
	
	NGLvec4 newColor = nglColorFromUIColor(value);
	
	// Avoids unecessary changes on the OpenGL buffers.
	if (!nglVec4IsEqual(_color, newColor))
	{
		_color = newColor;
		fillCoreEngine(_engine, !_offscreen);
	}
}

- (void) dealloc
{
	self.paused = YES;
	
	[self deleteCoreEngine];
	
	// Removes this NGLView from the views collection.
	[_views removePointer:self];
	
	// Releases the collection if it becomes empty.
	if ([_views count] == 0)
	{
		nglRelease(_views);
	}
	
    [super dealloc];
}

+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end

#pragma mark -
#pragma mark Categories
#pragma mark -
//**********************************************************************************************************
//
//	Categories
//
//**********************************************************************************************************

@implementation NGLView(NGLViewInteractive)

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

- (UIImage *) drawToImage
{
	UIImage *image = nil;
	
	// Gets the properties from this NGLView.
	CGSize size = self.bounds.size;
	float scale = self.contentScaleFactor;
	
	// Allocates the memory, performing task on the NinevehGL render thread.
	nglThreadPerformSync(kNGLThreadRender, @selector(offscreenRender), _engine);
	
	// Retrieves the date from the last rendered frame for this NGLView.
	unsigned char *pixels = _engine.offscreenData;
	
	// Extracts the UIImage from data.
	image = nglImageFromData(size, scale, pixels);
	
	// Frees the memory.
	[_engine offscreenRenderFree];
	
	return image;
}

- (NGLTexture *) drawToTexture
{
	return [NGLTexture texture2DWithImage:[self drawToImage]];
}

- (NSData *) drawToData:(NGLImageFileType)type
{
	NSData *data;
	
	// Defines the image type.
	switch (type)
	{
		case NGLImageFileTypeJPG:
			data = UIImageJPEGRepresentation([self drawToImage], 1.0f);
			break;
		case NGLImageFileTypePNG:
			data = UIImagePNGRepresentation([self drawToImage]);
			break;
		default:
			data = nil;
			break;
	}
	
	return data;
}

- (NGLivec4) pixelColorAtPoint:(CGPoint)point
{
	return [_engine pixelColorAtPoint:point];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end