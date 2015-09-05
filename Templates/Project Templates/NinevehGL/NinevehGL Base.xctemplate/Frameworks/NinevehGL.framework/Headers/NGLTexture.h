/*
 *	NGLTexture.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *	
 *	Created by Diney Bomfim on 3/17/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLRuntime.h"
#import "NGLError.h"
#import "NGLGlobal.h"
#import "NGLCopying.h"
#import "NGLCoreTexture.h"
#import "NGLArray.h"

@class NGLTexture;

/*!
 *					Defines the type of the texture map.
 *
 *					Each texture map has its own behavior and needs its own texture coordinate values.
 *					Texture coordinates can have 2, 3 or 4 elements depending on this texture type.
 *
 *	@see			NGLTexture::type
 *	
 *	@var			NGLTextureType2D
 *					Represents 2D texture map.
 *	
 *	@var			NGLTextureTypeCube
 *					Represents a cube map.
 */
typedef enum
{
	NGLTextureType2D			= NGL_SAMPLER_2D,
	NGLTextureTypeCube			= NGL_SAMPLER_CUBE,
} NGLTextureType;

/*!
 *					The NinevehGL texture class.
 *
 *					The NGLTexture holds all necessary information to construct a texture map with any
 *					OpenGL version. The image can be extracted from a file path, using the NinevehGL's
 *					Path API, or from an UIImage instance.
 *
 *					If both are set, the image for texture will be extracted preferentially from the
 *					UIImage instance.
 *
 *					NinevehGL accepts non-POT sizes, that means, non Power of Two. You can use any texture
 *					size you want, like 2000 x 1000, 754 x 421 or any other. However, as OpenGL just accept
 *					POT sizes, your image will be stretched to the nearest POT value. For example, 
 *					754 x 421 will become 1024 x 512. The maximum texture size is 2048.
 *
 *					All the texture files must follow these rules:
 *
 *						- 8 bits per channel.
 *
 *					The supported image file formats and extensions are:
 *
 *						- Tagged Image File Format (.tiff, .tif);
 *						- Joint Photographic Experts Group (.jpg, .jpeg);
 *						- Graphic Interchange Format (.gif);
 *						- Portable Network Graphic (.png);
 *						- Windows Bitmap Format (.bmp, .bmpf);
 *						- Windows Icon Format (.ico);
 *						- Windows Cursor (.cur);
 *						- XWindow bitmap (.xbm).
 */
@interface NGLTexture : NSObject <NGLCopying>
{
@private
	NGLTextureType			_type;
	NGLTextureQuality		_quality;
	NGLTextureRepeat		_repeat;
	NGLTextureOptimize		_optimize;
	
	// Structure
	CGRect					_rect;
	unsigned int			_unit;
	
	// Importing
	id <NGLCoreTexture>		_coreTexture;
	id						_lastSource;
	BOOL					_isLoading;
}

/*!
 *					Gets the current unit for this texture object. This is an identifier, it can be
 *					shared by instances when you make a copy instance or even change during the
 *					application lifetime.
 *
 *					If no more textures is using the identifier value, it can be used again by another one.
 */
@property (nonatomic, readonly) unsigned int *unit;

/*!
 *					The texture type.
 *
 *	@see			NGLTextureType
 */
@property (nonatomic) NGLTextureType type;

/*!
 *					The final texture quality.
 *
 *					This property has a correlated global property. As any other NinevehGL Global Property,
 *					the final value will be taken from here only if the global property is NGL_NULL,
 *					otherwise the global value will be used.
 *
 *					The default value is NGLTextureQualityLow.
 *
 *	@see			NGLTextureQuality
 *	@see			nglGlobalTextureQuality
 */
@property (nonatomic) NGLTextureQuality quality;

/*!
 *					The repeat filter which will be applied to the texture.
 *
 *					This property has a correlated global property. As any other NinevehGL Global Property,
 *					the final value will be taken from here only if the global property is NGL_NULL,
 *					otherwise the global value will be used.
 *
 *					The default is NGLTextureRepeatNormal.
 *
 *	@see			NGLTextureRepeat
 *	@see			nglGlobalTextureRepeat
 */
@property (nonatomic) NGLTextureRepeat repeat;

/*!
 *					The situations in which this texture can be optimized.
 *
 *					This property has a correlated global property. As any other NinevehGL Global Property,
 *					the final value will be taken from here only if the global property is NGL_NULL,
 *					otherwise the global value will be used.
 *
 *					The default is NGLTextureOptimizeAlways.
 *
 *	@see			NGLTextureOptimize
 *	@see			nglGlobalTextureOptimize
 */
@property (nonatomic) NGLTextureOptimize optimize;

/*!
 *					Represents the last working source for this texture. The source can be many things,
 *					like a NSString with the file's name/path, UIImage or NSArray with many images and
 *					file's names/paths.
 *
 *					If you directly update the pixels of this texture, the source will not change, it
 *					will keep pointing to the last loaded source through the #loadSource:# method.
 *					It means a copied NGLTexture will not have the #lastSource# because it was not
 *					created via loading process, it'll be nil.
 */
@property (nonatomic, readonly) id lastSource;

/*!
 *					Initializes a new instance of NGLTexture loading a source. The source can be the
 *					file's name/path, UIImage or NSArray containing those formats.
 *
 *	@param			source
 *					The source can be various kind of data. It can be a file's name/path, UIImage or
 *					NSArray. The array is taken as a 3D texture, that means, a cube texture, which contains
 *					6 images.
 *
 *	@result			A new NGLTexture instance.
 *
 *	@see			lastSource
 */
- (id) initWithSource:(id)source;

/*!
 *					Starts a loading process with a source. If there is another loading process in
 *					progress this call will be silently ignored. The loading process is an async process
 *					and it will run on the NinevehGL auxiliar Helper Thread.
 *
 *	@param			source
 *					The source can be various kind of data. It can be a file's name/path, UIImage or
 *					NSArray. The array is taken as a 3D texture, that means, a cube texture, which contains
 *					6 images.
 *
 *	@see			lastSource
 */
- (void) loadSource:(id)source;

/*!
 *					Immediately updates the texture data. This process is an synchronous one. The loading
 *					process finishes calling this method.
 *
 *					ATTENTION: It's very important to make sure the pixels data (also called as texels)
 *					must be in 32bits format. The internal process will take care of optimizing the
 *					data if necessary according to the #optimize# property.
 *
 *	@param			pixels
 *					The pixel data. It must be in 32bits format. The pixels order must also be from
 *					UP/LEFT to DOWN/RIGHT in row major format, that means, line by line.
 *
 *	@param			rect
 *					Defines the rect in wich this texture will be updated. Remember that the "size"
 *					parameter must be the same of the size of the pixels data.
 */
- (void) update2DWithData:(void *)pixels rect:(CGRect)rect;

/*!
 *					Returns an autoreleased instance of NGLTexture loading a source. The source can be the
 *					file's name/path, UIImage or NSArray containing those formats.
 *
 *	@param			source
 *					The source can be various kind of data. It can be a file's name/path, UIImage or
 *					NSArray. The array is taken as a 3D texture, that means, a cube texture, which contains
 *					6 images.
 *
 *	@result			A new NGLTexture autoreleased instance.
 */
+ (id) textureWithSource:(id)source;

@end