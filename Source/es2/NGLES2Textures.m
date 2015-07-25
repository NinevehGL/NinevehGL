/*
 *  NGLES2Textures.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *  Created by Diney Bomfim on 10/30/10.
 *  Copyright (c) 2010 DB-Interactively. All rights reserved.
 */

#import "NGLES2Textures.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

static NSString *const IMG_ERROR_HEADER = @"Error while processing NGLES2Textures.";

static NSString *const IMG_NOT_FOUND = @"Image with name \"%@\" was not loaded.\n\
Check the file path and image name. For more informations, consult the NGLTexture documentation.";

static NSString *const IMG_MAX_TEXTURES = @"Maximum textures was reached.\n\
This implementation of OpenGL supports up to %i textures per shader file and this limit was reached.";

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

// This static variable will store the OpenGL ES 2 texture names/ids linked with the files' names.
static NSMutableDictionary *_tCache;
static NSMutableDictionary *_tCacheMMC;

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static void nglAddTextureToCache(GLuint value)
{
	// Updates the current reference count to this newTexture.
	NSNumber *key = [NSNumber numberWithUnsignedInt:value];
	
	// Increments the retain count to the texture of value.
	unsigned int number = [[_tCacheMMC objectForKey:key] unsignedIntValue];
	[_tCacheMMC setObject:[NSNumber numberWithUnsignedInt:number + 1] forKey:key];
}

// Reduces the reference count for a cached texture.
// This function changes the count and the array that will be passed to OpenGL to delete the textures.
static void nglRemoveTexturesFromCache(int *count, GLuint *values)
{
	NSNumber *key;
	NSNumber *number;
	GLuint *copy;
	unsigned int value;
	unsigned int newCount = 0;
	unsigned int size = sizeof(GLuint) * *count;
	
	// Copies the memories
	copy = malloc(size);
	memcpy(copy, values, size);
	
	unsigned int i;
	unsigned int length = *count;
	for (i = 0; i < length; ++i)
	{
		// Retrieves the cache.
		key = [NSNumber numberWithUnsignedInt:copy[i]];
		number = [_tCacheMMC objectForKey:key];
		
		// Continues if there is no cache for the current texture.
		if (number == nil)
		{
			continue;
		}
		
		// Subtracts one in the reference count for the current texture.
		value = [number unsignedIntValue] - 1;
		
		// If it reaches 0, removes the texture and stores the removed texture.
		if (value == 0)
		{
			[_tCacheMMC removeObjectForKey:key];
			values = realloc(values, sizeof(GLuint) * (newCount + 1));
			values[newCount] = copy[i];
			++newCount;
		}
		// Proceeds with the subtraction.
		else
		{
			[_tCacheMMC setObject:[NSNumber numberWithUnsignedInt:value] forKey:key];
		}
	}
	
	nglFree(copy);
	
	// Stores the new count.
	*count = newCount;
}

// Translates the NGLTextureQuality to OpenGL ES 2 filter parameter.
static void nglDefineFilter(NGLTextureQuality quality, GLint *mag, GLint *min)
{
	// Checks if a global configuration is enabled.
	quality = (nglDefaultTextureQuality == NGL_NULL) ? quality : nglDefaultTextureQuality;
	
	// Transcribes the quality property to OpenGL ES 2 filter.
	switch (quality)
	{
		case NGLTextureQualityTrilinear:
			*mag = GL_LINEAR;
			*min = GL_LINEAR_MIPMAP_LINEAR;
			break;
		case NGLTextureQualityBilinear:
			*mag = GL_LINEAR;
			*min = GL_LINEAR_MIPMAP_NEAREST;
			break;
		case NGLTextureQualityNearest:
		default:
			*mag = GL_NEAREST;
			*min = GL_NEAREST_MIPMAP_NEAREST;
			break;
	}
}

// Translates the NGLTextureRepeat to OpenGL ES 2 wrap parameter.
static void nglDefineWrap(NGLTextureRepeat repeat, GLint *wrap)
{
	// Checks if a global configuration is enabled.
	repeat = (nglDefaultTextureRepeat == NGL_NULL) ? repeat : nglDefaultTextureRepeat;
	
	// Transcribes the repeat property to OpenGL ES 2 wrap.
	switch (repeat)
	{
		case NGLTextureRepeatNormal:
			*wrap = GL_REPEAT;
			break;
		case NGLTextureRepeatMirrored:
			*wrap = GL_MIRRORED_REPEAT;
			break;
		case NGLTextureRepeatNone:
		default:
			*wrap = GL_CLAMP_TO_EDGE;
			break;
	}
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NGLES2Textures ()

// Update this core with a new texture.
- (void) updateTexturesWith:(GLuint)newTexture;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLES2Textures

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super init]))
	{
		// Initializes once.
		if (_tCache == nil)
		{
			_tCache = [[NSMutableDictionary alloc] init];
			_tCacheMMC = [[NSMutableDictionary alloc] init];
		}
		
		// Initializes the file name's collections to this class
		_fileNames = [[NSMutableArray alloc] init];
		
		// Initializes the error API.
		_error = [[NGLError alloc] init];
		_error.header = IMG_ERROR_HEADER;
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) updateTexturesWith:(GLuint)newTexture
{
	if (_tCount >= [NGLES2Textures maxTextures])
	{
		_error.message = [NSString stringWithFormat:IMG_MAX_TEXTURES, [NGLES2Textures maxTextures]];
		[_error showError];
		
		return;
	}
	
	// Updates the texture reference count.
	nglAddTextureToCache(newTexture);
	
	// Reallocates the necessary memory.
	_textures = realloc(_textures, sizeof(GLuint) * (_tCount + 1));
	
	// Adds the new texture name/id to the array of textures.
	_textures[_tCount] = newTexture;
	
	// Sums one texture to the texture count.
	++_tCount;
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) addTexture:(NGLTexture *)texture
{
	NSNumber *cached;
	GLint color, type;
	GLsizei width, height;
	GLenum format;
	NGLParserImage *parser;
	NSString *filePath = texture.filePath;
	UIImage *image = texture.image;
	BOOL isPVRTC = (filePath != nil && [filePath rangeOfString:@".pvr"].length > 0);
	
	//*************************
	//	Cache
	//*************************
	// Looking for an identical image previously uploaded.
	if ((cached = [_tCache objectForKey:filePath]))
	{
		GLint oldMagFilter, oldMinFilter, oldWrap;
		GLint magFilter, minFilter, wrap;
		
		nglDefineFilter(texture.quality, &magFilter, &minFilter);
		nglDefineWrap(texture.repeat, &wrap);
		
		// Binds the already created texture and retrieve its parameters.
		glBindTexture(GL_TEXTURE_2D, [cached unsignedIntValue]);
		glGetTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, &oldMagFilter);
		glGetTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, &oldMinFilter);
		glGetTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, &oldWrap);
		
		// Checks if the new attemption has the same parameters as the cached texture.
		// If the parameters are the same, reuses the previous texture.
		if (magFilter == oldMagFilter && minFilter == oldMinFilter && wrap == oldWrap)
		{
			// Reuses the previously cached texture.
			[self updateTexturesWith:[cached unsignedIntValue]];
			
			// Ignores all subsequent processing.
			return;
		}
	}
	
	//*************************
	//	Parsing
	//*************************
	// If the file extension contains "pvr", treat it as a PVRTC compressed image file.
	if (isPVRTC)
	{
		// Shows error if the file not found.
		NSData *data = nglDataFromFile(filePath);
		
		if ([data length] == 0)
		{
			_error.message = [NSString stringWithFormat:IMG_NOT_FOUND, filePath];
			[_error showError];
			
			return;
		}
		
		// Constructs NGLParserImage to extract pixel data and use it as texels in OpenGL.
		parser = [[NGLParserImage alloc] initWithPVRTC:data];
		
		// Chooses the right compression format.
		if (nglDefaultColorFormat == NGLColorFormatRGB)
		{
			format = (parser.optimized == NGLImageCompressionPVRTC4) ?
			GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG :
			GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG;
		}
		else
		{
			format = (parser.optimized == NGLImageCompressionPVRTC4) ?
			GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG :
			GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG;
		}
	}
	// All other files will be treat as uncompressed image file.
	else
	{
		// Prefers the image if it was set on NGLTexture.
		UIImage *uiImage = (image != nil) ? image : [UIImage imageWithContentsOfFile:nglMakePath(filePath)];
		
		// Shows error if the file was not found.
		if (uiImage == nil)
		{
			_error.message = [NSString stringWithFormat:IMG_NOT_FOUND, filePath];
			[_error showError];
			
			return;
		}
		
		// Checks if a global property is enabled.
		NGLTextureOptimize option;
		option = (nglDefaultTextureOptimize == NGL_NULL) ? texture.optimize : nglDefaultTextureOptimize;
		
		// Chooses if the texture will be optimized or not.
		BOOL optimize;
		if (nglDefaultColorFormat == NGLColorFormatRGB)
		{
			optimize = (option == NGLTextureOptimizeAlways || option == NGLTextureOptimizeRGB);
		}
		else
		{
			optimize = (option == NGLTextureOptimizeAlways || option == NGLTextureOptimizeRGBA);
		}
		
		// Constructs NGLParserImage to extract pixel data and use it as texels in OpenGL.
		// By default, all textures will be parsed with optimized formats.
		parser = [[NGLParserImage alloc] initWithImage:uiImage optimize:optimize];
		
		// Chooses the appropriate color and data type based on color information.
		// Always try to optimize the image data.
		switch (parser.optimized)
		{
			case NGLImageCompressionRGB565:
				type = GL_UNSIGNED_SHORT_5_6_5;
				color = GL_RGB;
				break;
			case NGLImageCompressionRGBA4444:
				type = GL_UNSIGNED_SHORT_4_4_4_4;
				color = GL_RGBA;
				break;
			default:
				type = GL_UNSIGNED_BYTE;
				color = GL_RGBA;
				break;
		}
	}
	
	width = parser.width;
	height = parser.height;
	
	//*************************
	//	Uploading
	//*************************
	// Creates and bind a new texture object.
	GLuint newTexture;
	GLint magFilter, minFilter, wrap;
	
	nglDefineFilter(texture.quality, &magFilter, &minFilter);
	nglDefineWrap(texture.repeat, &wrap);
	
	// Generates the texture name/id.
	glGenTextures(1, &newTexture);
	
	// Makes this texture the current texture to perform changes.
	glBindTexture(GL_TEXTURE_2D, newTexture);
	
	// Sets the filters to this texture.
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrap);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrap);
	
	// Uploads image data.
	if (isPVRTC)
	{
		glCompressedTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, parser.length, parser.data);
	}
	else
	{
		glTexImage2D(GL_TEXTURE_2D, 0, color, width, height, 0, color, type, parser.data);
	}
	//glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, color, type, const GLvoid* pixels)
	// Automatic generates mipmap levels until 1x1.
	glGenerateMipmap(GL_TEXTURE_2D);
	
	// Updates the array of textures and the array of texture units.
	[self updateTexturesWith:newTexture];
	
	// Releases.
	nglRelease(parser);
	
	// Registers the file path into the cache to optimize next usage of the same image file.
	if (filePath != nil)
	{
		[_tCache setObject:[NSNumber numberWithUnsignedInt:_textures[_tCount - 1]] forKey:filePath];
		[_fileNames addObject:filePath];
	}
}

- (int) getLastUnit
{
	return (_tCount > 0) ? _tCount - 1 : 0;
}

- (void) bindUnit:(GLint)unit toLocation:(GLint)location
{
	if (unit < _tCount)
	{
		// Based on a texture index, activates a texture unit, puts the desired texture in
		// and sets an uniform to work with this texture unit.
		glActiveTexture(GL_TEXTURE0 + unit);
		glBindTexture(GL_TEXTURE_2D, _textures[unit]);
		glUniform1i(location, unit);
	}
}

+ (void) unbindAll
{
	// Unbind any actual texture.
	glBindTexture(GL_TEXTURE_2D, 0);
}

+ (int) maxTextures
{
	static int maxImages = 0;
	
	if (maxImages == 0)
	{
		// Retrieves the maximum texture units supported by this OpenGL ES 2 implementation.
		glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, &maxImages);
	}
	
	return maxImages;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	// Takes only the necessary textures to delete. Reused textures will still in cache.
	nglRemoveTexturesFromCache(&_tCount, _textures);
	
	// Deletes the texture from OpenGL ES 2 core.
	glDeleteTextures(_tCount, _textures);
	nglFree(_textures);
	
	// Removes the necessary textures from the cache collection.
	[_tCache removeObjectsForKeys:_fileNames];
	
	// Releases the collection if it becomes empty.
	if ([_tCache count] == 0)
	{
		nglRelease(_tCache);
		nglRelease(_tCacheMMC);
	}
	
	nglRelease(_fileNames);
	nglRelease(_error);
	
	[super dealloc];
}

@end