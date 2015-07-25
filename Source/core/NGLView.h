/*
 *	NGLView.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *  Created by Diney Bomfim on 9/2/10.
 *  Copyright (c) 2010 DB-Interactively. All rights reserved.
 */

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "NGLRuntime.h"
#import "NGLDataType.h"
#import "NGLError.h"
#import "NGLCoreTimer.h"
#import "NGLCoreEngine.h"
#import "NGLTexture.h"

@class NGLView;

/*!
 *					The delegate protocol to NGLView.
 *
 *					This protocol defines the necessary methods for a delegation instance of
 *					NGLView. As many Cocoa classes, the delegation is a concept that let other classes
 *					control some actions and receive the callback rather than the original class.
 *					All that the other classes need to do is conforms to the delegate protocol.
 *
 *					In this case, the NGLViewDelegate delegates the drawing routine. By doing so, you can
 *					make your drawing changes from another class, like an <code>UIViewController</code>,
 *					for example.
 *
 *	@see			NGLView
 */
@protocol NGLViewDelegate <NSObject>

@required

/*!
 *					Method called at each render cycle.
 *
 *					Place all your drawing commands inside this method. NinevehGL drawing is done by using
 *					cameras. For each camera you want to draw, call its <code>#drawView#</code> method.
 *					Each camera called inside this method will produce its resulting image into the
 *					correspondent NGLView.
 */
- (void) drawView;

@end

/*!
 *					The NinevehGL view to work with OpenGL. This class must be the first to be initialized
 *					when working with NinevehGL.
 *
 *					NGLView is the first class to introduce you in the NinevehGL Engine's API. It's
 *					reponsible for constructing and managing a view based on UIView class. When you want
 *					to use NinevehGL you must create a NGLView instance rather than an UIView. As a
 *					subclass of UIView You can use NGLView to build your layout with Interface
 *					Builder Tool.
 *
 *					The NGLView class is responsible for creating and managing the OpenGL buffers.
 *					At runtime, it is responsible for the render looping and drawing the content on it.
 *
 *					Usually you will create a subclass of NGLView and override its draw method to create
 *					your own render. Just as some Cocoa Classes, NGLView offers a <code>#delegate#</code>
 *					API to you work with the way that is most comfortable to you, so you could create an
 *					UIViewController conforming with #NGLViewDelegate# protocol and set the delegate.
 *
 *					Despite NinevehGL was created to work with OpenGL programmable pipeline, it is OpenGL
 *					version free, so every new OpenGL release does not change your implementation of
 *					NinevehGL. Although by default, NinevehGL starts using the lastest OpenGL version, you
 *					can choose what OpenGL version you want and NGLView will make all the necessary
 *					changes on its core. You make this change by calling a NinevehGL Global function.
 *
 *	@see			NGLCamera
 *	@see			nglGlobalEngine
 */
@interface NGLView : UIView <NGLViewDelegate, NGLCoreTimer>
{
@private
	// States.
	BOOL					_paused;
	BOOL					_offscreen;
	id <NGLViewDelegate>	_delegate;
	
	// Engine.
	id <NGLCoreEngine>		_engine;
	NGLAntialias			_antialias;
	BOOL					_useDepthBuffer;
	BOOL					_useStencilBuffer;
	
	// Helpers.
	CGSize					_size;
	NGLvec4					_color;
}

/*!
 *					Pauses or resumes the render loop.
 *
 *					Set this property to YES if you want to pause the animation temporary. Set it to NO
 *					again to resume the render loop.
 *
 *					While this property is set to YES, no calls to drawView method will happen.
 *
 *					Its default value is NO.
 */
@property (nonatomic, getter = isPaused) BOOL paused;

/*!
 *					Defines if this view will be used to offscreen render.
 *
 *					When a view is set to offscreen it'll not enter in the render cycle, that means.
 *
 *					Its default value is NO.
 */
@property (nonatomic, getter = isOffscreen) BOOL offscreen;

/*!
 *					Indicates the delegation target.
 *					The target must implement the <code>#NGLViewDelegate#</code> protocol. If the target
 *					is nil or not implement the protocol, this instance of NGLView will be set as the
 *					delegate target.
 *
 *					If you are using Interface Builder tool, you can set the delegate as an Outlet to
 *					the view.
 *
 *	@see			NGLViewDelegate
 */
@property(nonatomic, assign) IBOutlet id <NGLViewDelegate> delegate;

/*!
 *					Specifies if this View will use the Multisample Filter provided by Apple.
 *					This filter produces more smooth images. The NGLAntialiasNone means no anti-aliasing
 *					filter will be placed in. NGLAntialias4X indicates the OpenGL buffer will be recreated
 *					and using 4 samples per pixel.
 *
 *					The default value is NGLAntialiasNone.
 */
@property (nonatomic) NGLAntialias antialias;

/*!
 *					Specifies if this View will use the Depth Render Buffer.
 *					Depth Render Buffer is used to store depth information and it's necessary to make
 *					3D graphics. The depth buffer is necessary to place the objects in front of each other.
 *
 *					The default value is YES.
 */
@property (nonatomic) BOOL useDepthBuffer;

/*!
 *					Specifies if this View will use the Stencil Render Buffer.
 *					Stencil Render Buffer is used to store information about how and when a pixel will be
 *					updated or not. In simple words, it's like a mask to defining which pixels can
 *					be displayed.
 *
 *					The default value is NO.
 */
@property (nonatomic) BOOL useStencilBuffer;

/*!
 *					Gets the current OpenGL framebuffer for this NGLView. It's useful to work with third
 *					party libraries that ask you for the framebuffer reference.
 */
@property (nonatomic, readonly) unsigned int framebuffer;

/*!
 *					Gets the current OpenGL renderbuffer (color) for this NGLView. It's useful to work with
 *					third party libraries that ask you for the renderbuffer reference.
 */
@property (nonatomic, readonly) unsigned int renderbuffer;

/*!
 *					A pointer to the background color. This color is a NinevehGL color (NGLvec4).
 */
@property (nonatomic, readonly) NGLvec4 *colorPointer;

- (id) initWithOffscreenFrame:(CGRect)frame;

- (void) drawOffscreen;

/*!
 *					Compiles the final engine and constructs the OpenGL's buffers. This method is called
 *					automatically when the NGLView is initialized.
 *
 *					This method should be called only after a change in the properties that affect the
 *					view's size, color or layer.
 *
 *					Calling this method will fire the render cycle, that means, if this NGLView was
 *					paused, it will be resumed.
 */
- (void) compileCoreEngine;

/*!
 *					<strong>(Internal only)</strong> You should not call this one manually.
 *
 *					This method affects all NGLView in the memory. It'll update all core engines.
 */
+ (void) updateAllViews;

/*!
 *					<strong>(Internal only)</strong> You should not call this one manually.
 *
 *					This method affects all NGLView in the memory. It'll clean up all core engines.
 */
+ (void) emptyAllViews;

/*!
 *					<strong>(Internal only)</strong> You should not set this property manually.
 *
 *					Gets all the views currently in the application's memory.
 *
 *	@result			A NSArray containing all the views.
 */
+ (NSArray *) allViews;

@end

/*!
 *					A category deals with iOS interactions.
 *
 *					This category implements methods to deal with any kind of interaction between NinevehGL
 *					structure and Cocoa Touch Framework. It includes things like: device's orientation,
 *					touches, accelerometer and any kind of input specific to iOS devices.
 */
@interface NGLView(NGLViewInteractive)

/*!
 *					Render to an off-screen surface.
 *
 *					This method works like a screen-shot or snapshot. It doesn't produce new renders,
 *					it just draw the last rendered frame with this NGLView and converts it to an UIImage.
 *
 *					So, if you have made changes until the last call to drawView method, those changes will
 *					not appear in the output of this method.
 *
 *	@result			An autoreleased instance of UIImage.
 */
- (UIImage *) drawToImage;

/*!
 *					Render to an off-screen surface.
 *
 *					This method works like a screen-shot or snapshot. It doesn't produce new renders,
 *					it just draw the last rendered frame with this NGLView and converts it to a
 *					#NGLTexture#.
 *
 *					So, if you have made changes until the last call to drawView method, those changes will
 *					not appear in the output of this method.
 *
 *	@result			An autoreleased instance of #NGLTexture#.
 */
- (NGLTexture *) drawToTexture;

/*!
 *					Render to an off-screen surface.
 *
 *					This method works like a screen-shot or snapshot. It doesn't produce new renders,
 *					it just draw the last rendered frame with this NGLView and converts it to a NSData.
 *					The data inside NSData can be:
 *
 *						- JPG formated bytes;
 *						- PNG formated bytes.
 *
 *					To create and save an image file locally you can call writeToFile:atomically: method
 *					from the returned NSData.
 *
 *					So, if you have made changes until the last call to drawView method, those changes will
 *					not appear in the output of this method.
 *
 *	@param			type
 *					The type of binary format (NGLImageFileTypeJPG or NGLImageFileTypePNG).
 *
 *	@result			An autoreleased instance of NSData.
 */
- (NSData *) drawToData:(NGLImageFileType)type;

- (NGLivec4) pixelColorAtPoint:(CGPoint)point;

@end