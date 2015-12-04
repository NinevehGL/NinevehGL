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

#import "NGLSurfaceMulti.h"

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

@interface NGLSurfaceMulti()

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

@implementation NGLSurfaceMulti

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
		[self initialize];
	}
	
	return self;
}

- (id) initWithSurfaces:(NGLSurface *)first, ...
{
	if ((self = [super init]))
	{
		[self initialize];
		
		va_list list;
		NGLSurface * surface;
		
		// Executes all elements of the list until get nil.
		va_start(list, first);
		for (surface = first; surface != nil; surface = va_arg(list, NGLSurface *))
		{
			[self addSurface:surface];
		}
		va_end(list);
	}
	
	return self;
}

- (id) initWithSurfaceKind:(id<NGLSurface>)surface
{
	if ((self = [super init]))
	{
		[self initialize];
		
		if ([surface isKindOfClass:[self class]])
		{
			[self addNGLSurfaceMulti:(NGLSurfaceMulti *)surface copyItems:NO];
		}
		else
		{
			[self addSurface:(NGLSurface *)surface];
		}
	}
	
	return self;
}

+ (id) surfaceMultiWithSurface:(NGLSurface *)first
{
	NGLSurfaceMulti *surfaceMulti = [[NGLSurfaceMulti alloc] initWithSurfaces:first, nil];
	
	return [surfaceMulti autorelease];
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initialize
{
	_collection = [[NGLArray alloc] initWithRetainOption];
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
	NGLSurfaceMulti *copy = aCopy;
	
	// Copying properties.
	if (isShared)
	{
		[copy addNGLSurfaceMulti:self copyItems:NO];
	}
	else
	{
		[copy addNGLSurfaceMulti:self copyItems:YES];
	}
}

- (void) addSurface:(NGLSurface *)item
{
	// Adds the target once.
	if (![_collection hasPointer:item])
	{
		[_collection addPointer:item];
		
		// Sets the identifier automatically, if no one was specified.
		if (item.identifier == 0)
		{
			item.identifier = [_collection count];
		}
	}
}

- (void) addNGLSurfaceMulti:(NGLSurfaceMulti *)multi copyItems:(BOOL)flag
{
	NGLSurface *item, *copy;
	
	for (item in multi)
	{
		if (flag)
		{
			copy = [item copy];
			[self addSurface:copy];
			nglRelease(copy);
		}
		else
		{
			[self addSurface:item];
		}
	}
}

- (BOOL) hasSurface:(NGLSurface *)item
{
	return [_collection hasPointer:item];
}

- (void) removeAll
{
	[_collection removeAll];
}

- (NGLSurface *) surfaceWithIdentifier:(UInt32)identifier
{
	NGLSurface *item = nil;
	
	for (item in _collection)
	{
		if (item.identifier == identifier)
		{
			break;
		}
	}
	
	return item;
}

- (NGLSurface *) surfaceAtIndex:(UInt32)index
{
	return [_collection pointerAtIndex:index];
}

- (UInt32) count
{
	return [_collection count];
}

- (void *) nextIterator
{
	return [_collection nextIterator];
}

- (void) resetIterator
{
	[_collection resetIterator];
}

- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state
								   objects:(NGL_ARC_ASSIGN id *)stackbuf
									 count:(NSUInteger)len
{
	UInt32 count = [_collection count];
	
    if ((*state).state >= count)
    {
        return 0;
    }
	
	// Runs once. Points mutationPtr to self to avoid error when array changes while looping.
	(*state).itemsPtr = _collection.itemsPointer;
	(*state).state = count;
	(*state).mutationsPtr = _collection.mutationsPointer;
	
    return count;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (NSString *) description
{
	NSMutableString *string = [[NSMutableString alloc] initWithString:[super description]];
	NGLSurface *surface;
	
	// Describes each element in this library.
	for (surface in _collection)
	{
		[string appendString:[surface description]];
	}
	
	return [string autorelease];
}

- (void) dealloc
{
	nglRelease(_collection);
	
	[super dealloc];
}

@end