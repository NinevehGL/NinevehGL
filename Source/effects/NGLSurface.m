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

#import "NGLSurface.h"

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

@interface NGLSurface()

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

@implementation NGLSurface

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize identifier = _identifier, startData = _startData, lengthData = _lengthData;

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

- (id) initWithStart:(UInt32)start length:(UInt32)length identifier:(UInt32)newId
{
	if ((self = [super init]))
	{
		[self initialize];
		
		_identifier = newId;
		_startData = start;
		_lengthData = length;
	}
	
	return self;
}

+ (id) surface
{
	NGLSurface *newSurface = [[NGLSurface alloc] init];
	
	return [newSurface autorelease];
}

+ (id) surfacetWithStart:(UInt32)start length:(UInt32)length identifier:(UInt32)newId
{
	NGLSurface *newSurface = [[NGLSurface alloc] initWithStart:start length:length identifier:newId];
	
	return [newSurface autorelease];
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initialize
{
	_identifier = 0;
	_startData = 0;
	_lengthData = NGL_MAX_32;
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
	NGLSurface *copy = aCopy;
	
	// Copying properties.
	copy.identifier = _identifier;
	copy.startData = _startData;
	copy.lengthData = _lengthData;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (NSString *) description
{
	return [NSString stringWithFormat:@"\n%@\n\
			ID: %i\n\
			Start: %i\n\
			Length: %i\n",
			[super description],
			(unsigned int)self.identifier,
			(unsigned int)self.startData,
			(unsigned int)self.lengthData];
}

@end