/*
 *	NGLCoreTexture.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *	
 *	Created by Diney Bomfim on 7/8/12.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLRuntime.h"
#import "NGLGlobal.h"

@class NGLTexture;

/*!
 *					The NGLCoreTexture protocol defines the basic methods for a texture in NinevehGL.
 *
 *					This protocol defines routines that is shared by any OpenGL Graphics Pipeline.
 *					So it can be used through all OpenGL versions.
 *
 *	@see			NGLTexture
 */
@protocol NGLCoreTexture <NSObject>

@required

/*!
 *					A pointer to the #NGLTexture# instance that holds this core instance.
 *
 *	@see			NGLMesh
 */
@property (nonatomic, assign) NGLTexture *parent;

/*!
 *					Gets the current unit for this texture object. This is an unique identifier defined
 *					at the initialization. Only this texture object will use it.
 *
 *					After deleting this texture, the same identifier can be used again by another one.
 */
@property (nonatomic, readonly) unsigned int unit;

/*!
 *					Initiates the core texture instance setting a parent #NGLTexture#.
 *
 *					This method initializes a core texture and sets its #parent# property.
 *
 *	@param			mesh
 *					The #NGLMesh# instance that holds this core instance.
 *
 *	@result			A new initialized instance.
 */
- (id) initWithParent:(NGLTexture *)texture;

/*!
 *					Updates the texture quality and repeating mode.
 *
 *	@see			NGLTextureQuality
 *	@see			NGLTextureRepeat
 */
- (void) setQuality:(NGLTextureQuality)quality repeatingMode:(NGLTextureRepeat)repeat;

/*!
 *					Updates the core texture with a new data.
 *
 *					This method will immediately update the texture object. This call doesn't change the
 *					texture unit.
 *
 *	@param			compress
 *					A NGLImageCompression indicating the pixel compression format.
 *
 *	@param			rect
 *					The pixel area to be updated.
 *
 *	@param			length
 *					The length of the data that will be passed.
 *
 *	@param			data
 *					The pixel data should be already in the OpenGL format.
 */
- (void) update:(NGLImageCompression)compress rect:(CGRect)rect length:(int)length data:(void *)data;

@end