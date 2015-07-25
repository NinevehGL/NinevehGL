/*
 *	NGLCoreEngine.h
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

#import "NGLRuntime.h"
#import "NGLDataType.h"
#import "NGLGlobal.h"
#import "NGLVector.h"

@class NGLView;

/*!
 *					The NGLCoreEngine protocol defines the basic methods for a engine in NinevehGL.
 *
 *					A NinevehGL engine is responsible for anything related to the render process
 *					with a specif OpenGL version. It creates and manages the necessary buffers, the
 *					render filters and the viewport.
 */
@protocol NGLCoreEngine <NSObject>

@required

/*!
 *					Indicates if the core engine has the minimum necessary to receive a render call.
 *					While it's not ready no render calls should be made.
 */
@property (nonatomic, readonly) BOOL isReady;

/*!
 *					Indicates the number of samples at each pixel to create the anti-alias filter.
 *					The NGLAntialiasNone value represents that no filter will be used.
 *
 *					The default value is equal to the global antialias.
 */
@property (nonatomic) NGLAntialias antialias;

/*!
 *					Indicates whether the render engine will use or not the Depth Render Buffer.
 *
 *					The default value is NO.
 */
@property (nonatomic) BOOL useDepthBuffer;

/*!
 *					Indicates whether the render engine will use or not the Stencil Render Buffer.
 *
 *					The default value is YES.
 */
@property (nonatomic) BOOL useStencilBuffer;

/*!
 *					The NGLView used by this instance.
 */
@property (nonatomic, assign) NGLView *layer;

/*!
 *					Returns the pointer to the last generated offscreen render.
 *
 *					Renders to offscreen surfaces are produced by calling #offscreenRender#. Calling
 *					this property doesn't generate any new offscreen render.
 *
 *	@see			offscreenRender
 */
@property (nonatomic, readonly) unsigned char *offscreenData;

/*!
 *					Gets the current OpenGL framebuffer for this engine.
 */
@property (nonatomic, readonly) unsigned int framebuffer;

/*!
 *					Gets the current OpenGL renderbuffer (color) for this engine.
 */
@property (nonatomic, readonly) unsigned int renderbuffer;

/*!
 *					Gets the current OpenGL framebuffer size. It's size depends on the layer's content
 *					scale factor.
 */
@property (nonatomic, readonly) CGSize size;

/*!
 *					Initiates the NGLCoreEngine class with a NGLView.
 *
 *					This method initializes a NGLCoreEngine instance and set its layer.
 *
 *	@param			layer
 *					A NGLView instance. All the following render settings will be made based on this
 *					layer and the render will be shown on it.
 *
 *	@result			A new instance of NGLCoreEngine.
 */
- (id) initWithLayer:(NGLView *)layer;

/*!
 *					Constructs the Frame and Render Buffers. Must be called to start the OpenGL buffers.
 *
 *					This method constructs the bridge between OpenGL render and device's window system.
 *					The window system is responsible for drawing the image on the device's screen.
 *
 *					This method should be called every time the layer change its properties, like
 *					size, position or color.
 */
- (void) defineBuffers;

/*!
 *					Clean up all the buffers (Frame and Render Buffers). Must be called to delete the
 *					OpenGL buffers.
 *
 *					This method erases all the buffers in this engine and make it empty again.
 *
 *					This method should be called by the NGLCoreEngine owner before release it.
 */
- (void) clearBuffers;

/*!
 *					The first method to be called at each render cycle.
 *
 *					This method should be called to make a clean up and reset any necessary variable
 *					to start a new render cycle.
 */
- (void) preRender;

/*!
 *					The last method to be called at each render cycle.
 *
 *					This method will deal with the Frame and Render Buffers, with the filters and
 *					any other necessary process to produce the final image. Then it will output the
 *					render's image to the desired surface previously defined.
 */
- (void) render;

/*!
 *					Makes a render data to an offscreen surface, storing the data. The data can be
 *					retrieved with #offscreenData#.
 *
 *					This method doesn't make new renders, it just retrieve the image from the last
 *					rendered frame. The data is stored in the memory, that memory can be freed by:
 *						- Calling this method again. The last memory will replaced by the new one;
 *						- Deallocking this instance;
 *						- Calling #offscreenRenderFree# method.
 *
 *					The pixel data are in OpenGL format, which means the first pixel is in the lower left
 *					corner of the image, reading line by line, the last pixel is in the upper right corner.
 *
 *	@see			offscreenRenderFree
 */
- (void) offscreenRender;

/*!
 *					Frees the allocated memory from #offscreenRender# method.
 *
 *					This method will automatically be called when the current instance is deallocated.
 *
 *	@see			offscreenRender
 */
- (void) offscreenRenderFree;

/*!
 *					Gets the pixel color into a specific point in the current frame buffer.
 *
 *					The pixel color will be retrieved in the current state, that means no new render
 *					will be produced.
 *
 *	@param			point
 *					A CGPoint structure.
 *
 *	@result			A NGLivec4 representing the four components of the color: RGBA.
 */
- (NGLivec4) pixelColorAtPoint:(CGPoint)point;

@end