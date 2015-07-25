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

#pragma mark -
#pragma mark Fixed Functions
#pragma mark -
//**********************************************************************************************************
//
//	Fixed Functions
//
//**********************************************************************************************************

NSString *nglGetFile(NSString *named)
{
	NSRange range;
	
	// Prevent Microsoft Windows path file format.
	named = [named stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
	
	range = [named rangeOfString:@"/" options:NSBackwardsSearch];
	
	if (range.length > 0)
	{
		named = [named substringFromIndex:range.location + 1];
	}
	
	return named;
}

NSString *nglGetFileExtension(NSString *named)
{
	NSRange range;
	NSString *type = @"";
	
	// Isolates the file extension.
	range = [named rangeOfString:@"." options:NSBackwardsSearch];
	
	if (range.length > 0)
	{
		type = [named substringFromIndex:range.location + 1];
	}
	
	return type;
}

NSString *nglGetFileName(NSString *named)
{
	NSRange range;
	
	// Gets the file name + extension.
	named = nglGetFile(named);
	
	// Using range and substringToIndex: is around 70% faster than stringByDeletingPathExtension: method
	range = [named rangeOfString:@"." options:NSBackwardsSearch];
	
	if (range.length > 0)
	{
		named = [named substringToIndex:range.location];
	}
	
	return named;
}

NSString *nglGetPath(NSString *named)
{
	NSString *pathOnly = nil;
	NSRange range = [named rangeOfString:nglGetFile(named)];
	
	// Checks if the path contains a file at the end to extract it, if necessary.
	if (range.length > 0)
	{
		pathOnly = [named substringToIndex:range.location];
	}
	
	return pathOnly;
}

NSString *nglMakePath(NSString *named)
{
	NSString *fullPath;
	
	// Prevent Microsoft Windows path files.
	named = [named stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
	
	// Assuming the path already contains the file path, checks if the file exist,
	// in afirmative case use it, otherwise, uses the default file path.
	if ([[NSFileManager defaultManager] fileExistsAtPath:named])
	{
		fullPath = named;
	}
	else
	{
		// Initializes the default path once.
		if (nglDefaultPath == nil)
		{
			nglGlobalFilePath([[NSBundle mainBundle] bundlePath]);
		}
		
		fullPath = [nglDefaultPath stringByAppendingPathComponent:nglGetFile(named)];
	}
	
	return fullPath;
}

NSString *nglSourceFromFile(NSString *named)
{
	return [NSString stringWithContentsOfFile:nglMakePath(named) encoding:NSUTF8StringEncoding error:nil];
}

NSData *nglDataFromFile(NSString *named)
{
	return [NSData dataWithContentsOfFile:nglMakePath(named)];
}

NSRange nglRangeWithout(NSString *init, NSString *end, NSString *source)
{
	NSUInteger start;
	NSRange range;
	
	// Finds the start range.
	range = [source rangeOfString:init];
	start = range.location + range.length;
	source = [source substringFromIndex:start];
	
	// Creates the final range.
	range.location = start;
	range.length = [source rangeOfString:end].location;
	
	return range;
}

NSRange nglRangeWith(NSString *init, NSString *end, NSString *source)
{
	NSUInteger start;
	NSRange range, rangeEnd;
	
	// Finds the start range.
	range = [source rangeOfString:init];
	start = range.location + range.length;
	source = [source substringFromIndex:start];
	
	// Finds the end of the range.
	rangeEnd = [source rangeOfString:end];
	
	// Creates the final range.
	range.length += rangeEnd.location + rangeEnd.length;
	
	return range;
}

NSArray *nglGetArray(NSString *string)
{
	NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSMutableArray *array = [NSMutableArray arrayWithArray:
							 [string componentsSeparatedByCharactersInSet:charSet]];
	
	[array removeObject:@""];
	
	return array;
}

void nglCStringReplaceChar(char *string, char searchFor, char replaceFor)
{
	char *pointer;
	
	pointer = strchr(string,searchFor);
	while (pointer != NULL)
	{
		string[pointer - string] = replaceFor;
		pointer = strchr(pointer + 1, searchFor);
	}
}

BOOL nglDeviceOrientationIsValid(void)
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	return !(orientation == UIDeviceOrientationUnknown ||
			orientation == UIDeviceOrientationFaceUp ||
			orientation == UIDeviceOrientationFaceDown);
}

BOOL nglDeviceOrientationIsPortrait(void)
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	return (orientation == UIDeviceOrientationPortrait ||
			orientation == UIDeviceOrientationPortraitUpsideDown);
}

BOOL nglDeviceOrientationIsLandscape(void)
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	return (orientation == UIDeviceOrientationLandscapeLeft ||
			orientation == UIDeviceOrientationLandscapeRight);
}

float nglDeviceSystemVersion(void)
{
	static float osVersion = 0;
	
	if (osVersion == 0)
	{
		osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
	}
	
	return osVersion;
}