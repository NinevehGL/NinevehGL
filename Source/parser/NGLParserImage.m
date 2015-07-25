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

#import "NGLParserImage.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

// Defines the Minimum and Maximum POT sizes.
#define kNGL_MIN_POT		8
#define kNGL_MAX_POT		1024

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

// PVRTC header data.
typedef struct
{
	unsigned int headerLength;
	unsigned int height;
	unsigned int width;
	unsigned int numMipmaps;
	unsigned int flags;
	unsigned int dataLength;
	unsigned int bpp;
	unsigned int bitmaskRed;
	unsigned int bitmaskGreen;
	unsigned int bitmaskBlue;
	unsigned int bitmaskAlpha;
	unsigned int pvrTag;
	unsigned int numSurfs;
} NGLParserImageHeader;

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static unsigned int makePOTSize(unsigned int size)
{
	unsigned int pot = kNGL_MIN_POT;
	while (pot < size)
	{
		pot *= 2;
	}
	
	pot = (pot < kNGL_MAX_POT) ? pot : kNGL_MAX_POT;
	
	return pot;
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NGLParserImage()

// Converts the current pixel data to one of the optimized 2bpp formats.
- (void) optimizeData;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

UIImage *nglImageFromData(CGSize size, float scale, unsigned char *data)
{
	int width = size.width * scale;
	int height = size.height * scale;
	float widthF = (float)width / scale, heightF = (float)height / scale;
	
	UIImage *image;
	CGColorSpaceRef color;
	CGDataProviderRef provider;
	CGImageRef cgImage;
	CGBitmapInfo info = kCGBitmapByteOrder32Big;
	CGColorRenderingIntent intent = kCGRenderingIntentDefault;
	
	// Defines if has alpha or not.
	if (nglDefaultColorFormat == NGLColorFormatRGB)
	{
		info |= kCGImageAlphaNoneSkipLast;
	}
	else
	{
		info |= kCGImageAlphaPremultipliedLast;
	}
	
	// Creates a CGImage from the pixel data.
	color = CGColorSpaceCreateDeviceRGB();
	provider = CGDataProviderCreateWithData(NULL, data, width * height * 4, NULL);
	cgImage = CGImageCreate(width, height, 8, 32, width * 4, color, info, provider, NULL, YES, intent);
	
	// Draws the current graphics context into an UIImage.
	CGRect rect = CGRectMake(0.0f, 0.0f, widthF, heightF);
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale);
	CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, cgImage);
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	// Frees the datas.
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(color);
	CGImageRelease(cgImage);
	
    return image;
}

@implementation NGLParserImage

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize width = _width, height = _height, length = _length, data = _data, optimized = _optimized;

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) initWithImage:(UIImage *)uiImage optimize:(BOOL)optimize
{
	if ((self = [super init]))
	{
		[self parseImage:uiImage optimize:optimize];
	}
	
	return self;
}

- (id) initWithPVRTC:(NSData *)data
{
	if ((self = [super init]))
	{
		[self parsePVRTC:data];
	}
	
	return self;
}


#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) optimizeData
{
	unsigned int i;
	unsigned int length = _length;
	
	void *newData;
	
	// Pointer to pixel information of 32 bits (R8 + G8 + B8 + A8).
	// 4 bytes per pixel.
	unsigned int *inPixel32;
	
	// Pointer to new pixel information of 16 bits (R5 + G6 + B5) or (R4 + G4 + B4 + A4).
	// 2 bytes per pixel.
	unsigned short *outPixel16;
	
	newData = malloc(_length * NGL_SIZE_USHORT);
	inPixel32 = (unsigned int *)_data;
	outPixel16 = (unsigned short *)newData;
	
	// If the global color format is RGB, optimizes the pixel data to RGB565.
	if (nglDefaultColorFormat == NGLColorFormatRGB)
	{
		_optimized = NGLImageCompressionRGB565;
		
		// Using pointer arithmetic, move the pointer over the original data.
		for(i = 0; i < length; ++i, ++inPixel32)
		{
			// Makes the convertion, ignoring the alpha channel, as following:
			// 1 -	Isolates the Red channel, discards 3 bits (8 - 3), then pushes to the final position.
			// 2 -	Isolates the Green channel, discards 2 bits (8 - 2), then pushes to the final position.
			// 3 -	Isolates the Blue channel, discards 3 bits (8 - 3), then pushes to the final position.
			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) |
							((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) |
							((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
		}
	}
	// If the global color format is RGBA, optimizes the pixel data to RGBA4444.
	else
	{
		_optimized = NGLImageCompressionRGBA4444;
		
		// Using pointer arithmetic, move the pointer over the original data.
		for(i = 0; i < length; ++i, ++inPixel32)
		{
			// Makes the convertion, as following:
			// 1 -	Isolates the Red channel, discards 4 bits (8 - 4), then pushes to the final position.
			// 2 -	Isolates the Green channel, discards 4 bits (8 - 4), then pushes to the final position.
			// 3 -	Isolates the Blue channel, discards 4 bits (8 - 4), then pushes to the final position.
			// 4 -	Isolates the Alpha channel, discards 4 bits (8 - 4), then pushes to the final position.
			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 4) << 12) |
							((((*inPixel32 >> 8) & 0xFF) >> 4) << 8) |
							((((*inPixel32 >> 16) & 0xFF) >> 4) << 4) |
							((((*inPixel32 >> 24) & 0xFF) >> 4) << 0);
		}
	}
	
	nglFree(_data);
	
	_data = newData;
}


#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) parseImage:(UIImage *)uiImage optimize:(BOOL)optimize
{
	CGImageRef cgImage;
	CGBitmapInfo bitmapInfo;
	CGContextRef context;
	CGColorSpaceRef	colorSpace;
	
	// Resets the variables.
	_length = 0;
	nglFree(_data);
	_optimized = NGLImageCompressionRGBA;
	
	// Sets the CoreGraphic Image to start work on it.
	cgImage = [uiImage CGImage];
	
	// Sets the size of image.
	_width = makePOTSize((unsigned int)CGImageGetWidth(cgImage));
	_height = makePOTSize((unsigned int)CGImageGetHeight(cgImage));
	
	// Defines the information about bitmaps.
	bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
	
	// Always parse the image as RGBA by default.
	// So it sets the length to 4 bytes per pixel (RGBA8888), this is the default not optimized format.
	_length = _width * _height;
	_data = malloc(_length * NGL_SIZE_UINT);
	colorSpace = CGColorSpaceCreateDeviceRGB();
	context = CGBitmapContextCreate(_data, _width, _height, 8, 4 * _width, colorSpace, bitmapInfo);
	CGColorSpaceRelease(colorSpace);
	
	// Adjusts position and invert the image.
	// The UIImage works renders upside-down compared to CGBitmapContext referential
	CGContextTranslateCTM(context, 0.0f, _height);
	CGContextScaleCTM(context, 1.0f, -1.0f);
	
	// Clears and Draws the image in the context to further use the pixel data inside it.
	CGContextClearRect(context, CGRectMake(0.0f, 0.0f, _width, _height));
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, _width, _height), cgImage);
	
	// Gets the optimized format, if requested.
	if (optimize)
	{
		[self optimizeData];
	}
	
	// Releases the context.
	CGContextRelease(context);
}

- (void) parsePVRTC:(NSData *)data
{
	unsigned char bpp;
	unsigned int width, height;
	unsigned int length;
	NSRange range;
	
	NGLParserImageHeader header;
	[data getBytes:&header length:52];
	
	// Checks for the new and older header size.
	if (header.headerLength == 52 || header.headerLength == 44)
	{
		// Retrieves file's information.
		bpp = header.bpp;
		width = header.width;
		height = header.height;
		length = width * height * bpp / 8;
		
		// Defines the range for the mipmap level 0 only.
		range = NSMakeRange(header.headerLength, length);
	}
	else
	{
		// This is a trick to work with PVRTC files without header or mipmaps created by Apple TextureTool.
		// The PVRTC files without header nor mipmaps has the data length in bytes equals to
		// "width * height * bpp / 8", that means, the "number of pixels" * "bits per pixel" / "8 (bits)"
		// As PVRTC must be squared we can use the formula "x = sqrtf((width * height) * 8 / bpp)"
		// to retrieve a possible data length.
		// Assuming a bpp of 4, we can test the retrieved size to check if it is divisible by 8,
		// the minimum POT(power of two) size of PVRTC. If it is divisible by 8, then the bpp is really 4,
		// otherwise the bpp should be 2.
		float size = sqrtf([data length] * 8 / 4);
		
		// Retrieves file's information.
		bpp = ((int)size % 8 == 0) ? 4 : 2;
		width = sqrtf([data length] * 8 / bpp);
		height = sqrtf([data length] * 8 / bpp);
		length = (unsigned int)[data length];
		
		// Defines the range for the mipmap level 0 only. In this special case, is the total file.
		range = NSMakeRange(0, length);
	}
	
	// Retrieves the bits per pixel information.
	_optimized = (bpp == 2) ? NGLImageCompressionPVRTC2 : NGLImageCompressionPVRTC4;
	
	// Sets the parser information.
	_width = width;
	_height = height;
	_length = length;
	
	// Copies the data for the mipmap level 0 only.
	_data = malloc(length);
	[data getBytes:_data range:range];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	nglFree(_data);
	
	[super dealloc];
}

@end