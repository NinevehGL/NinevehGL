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

#import "NGLRuntime.h"
#import "NGLGlobal.h"
#import "NGLCopying.h"

@class NSString;

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
	NGLTextureType2D		= NGL_SAMPLER_2D,
	NGLTextureTypeCube		= NGL_SAMPLER_CUBE,
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
 *					754 x 421 will become 1024 x 512. The maximum size is 1024 for commum displays or
 *					2048 for retina displays.
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
	NSString				*_filePath;
	UIImage					*_image;
	
	NGLTextureType			_type;
	NGLTextureQuality		_quality;
	NGLTextureRepeat		_repeat;
	NGLTextureOptimize		_optimize;
}

/*!
 *					The image file path. The paths in NinevehGL is managed by NinevehGL's Path API.
 *					The type of the image file should be supported by one of NinevehGL parsers.
 */
@property (nonatomic, copy) NSString *filePath;

/*!
 *					An UIImage instance. The image from texture will be extract, preferentially, from this
 *					UIImage instance.
 */
@property (nonatomic, retain) UIImage *image;

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
 *					The default value is NGLTextureQualityNearest.
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
 *					Initializes a new instance of NGLTexture.
 *
 *					This method also inserts a file path into the new instance.
 *
 *	@param			path
 *					The file system path for the image file. This method uses NinevehGL Path API.
 *
 *	@result			A new NGLTexture instance.
 */
- (id) init2DWithFile:(NSString *)path;

/*!
 *					Initializes a new instance of NGLTexture.
 *
 *					The NGLTexture returned by this method is initialized with an UIImage instance
 *					inside it.
 *
 *	@param			image
 *					The UIImage to create the texture.
 *
 *	@result			A NGLTexture autoreleased instance.
 */
- (id) init2DWithImage:(UIImage *)image;

/*!
 *					Returns an autoreleased instance of NGLTexture.
 *
 *					This method also inserts a file path into the new instance.
 *
 *	@param			path
 *					The file system path for the image file. This method uses NinevehGL Path API.
 *
 *	@result			A NGLTexture autoreleased instance.
 */
+ (id) texture2DWithFile:(NSString *)path;

/*!
 *					Returns an autoreleased instance of NGLTexture.
 *
 *					The NGLTexture returned by this method is initialized with an UIImage instance
 *					inside it.
 *
 *	@param			image
 *					The UIImage to create the texture.
 *
 *	@result			A NGLTexture autoreleased instance.
 */
+ (id) texture2DWithImage:(UIImage *)image;

@end