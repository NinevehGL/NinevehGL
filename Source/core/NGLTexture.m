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

#import "NGLTexture.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************


#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NGLTexture()

// Initializes a new instance.
- (void) initialize;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLTexture

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize filePath = _filePath, image = _image;

@synthesize type = _type, quality = _quality, repeat = _repeat, optimize = _optimize;

- (NSString *) filePath { return _filePath; }
- (void) setFilePath:(NSString *)value
{
	if (_filePath != value)
	{
		nglRelease(_filePath);
		_filePath = [value copy];
		
		// Only one, filePath or image, can be actived at a time.
		self.image = nil;
	}
}

- (UIImage *) image { return _image; }
- (void) setImage:(UIImage *)value
{
	if (_image != value)
	{
		nglRelease(_image);
		_image = [value retain];
		
		// Only one, filePath or image, can be actived at a time.
		self.filePath = nil;
	}
}

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

- (id) init2DWithFile:(NSString *)path
{
	if ((self = [super init]))
	{
		[self initialize];
		
		self.filePath = path;
	}
	
	return self;
}

- (id) init2DWithImage:(UIImage *)image
{
	if ((self = [super init]))
	{
		[self initialize];
		
		self.image = image;
	}
	
	return self;
}

+ (id) texture2DWithFile:(NSString *)path
{
	NGLTexture *texture = [[NGLTexture alloc] init2DWithFile:path];
	
	return [texture autorelease];
}

+ (id) texture2DWithImage:(UIImage *)image
{
	NGLTexture *texture = [[NGLTexture alloc] init2DWithImage:image];
	
	return [texture autorelease];
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initialize
{
	_type = NGLTextureType2D;
	_quality = NGLTextureQualityNearest;
	_repeat = NGLTextureRepeatNormal;
	_optimize = NGLTextureOptimizeAlways;
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (id) copyInstance
{
	id copy = [[[self class] allocWithZone:nil] init];
	
	// Copying properties.
	[self defineCopyTo:copy shared:YES];
	
	return copy;
}

- (id) copyWithZone:(NSZone *)zone
{
	id copy = [[[self class] allocWithZone:zone] init];
	
	// Copying properties.
	[self defineCopyTo:copy shared:NO];
	
	return copy;
}

- (void) defineCopyTo:(id)aCopy shared:(BOOL)isShared
{
	NGLTexture *copy = aCopy;
	
	// Copying properties.
	copy.filePath = _filePath;
	copy.type = _type;
	copy.quality = _quality;
	copy.repeat = _repeat;
	copy.optimize = _optimize;
	
	if (isShared)
	{
		copy.image = (_image != nil) ? _image : nil;
	}
	else
	{
		copy.image = (_image != nil) ? [UIImage imageWithCGImage:[_image CGImage]] : nil;
	}
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (NSString *) description
{
	NSString *string = [NSString stringWithFormat:@"%@\n\
						File name: %@\n\
						Image: %@\n\
						Type: %i\n\
						Quality: %i\n\
						Repeat: %i\n\
						Optimize: %i\n",
						[super description],
						_filePath,
						_image,
						_type,
						_quality,
						_repeat,
						_optimize];
	
	return string;
}

- (void) dealloc
{
	nglRelease(_filePath);
	nglRelease(_image);
	
	[super dealloc];
}

@end