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

#import "NGLMeshElements.h"

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
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static NSString *stringFromElement(NGLComponent component)
{
	NSString *string;
	
	switch (component)
	{
		case NGLComponentVertex:
			string = @"Vertex";
			break;
		case NGLComponentTexcoord:
			string = @"Texture Coordinate";
			break;
		case NGLComponentNormal:
			string = @"Normal";
			break;
		case NGLComponentTangent:
			string = @"Tangent";
			break;
		case NGLComponentBitangent:
			string = @"Bitangent";
			break;
	}
	
	return string;
}

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLMeshElements

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
		// Clears any previous element.
		[self removeAll];
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************



#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) addElement:(NGLElement)element
{
	NGLElement *oldElement = [self elementWithComponent:element.component];
	
	if (oldElement != NULL)
	{
		(*oldElement).start = element.start;
		(*oldElement).length = element.length;
		(*oldElement).offsetInFace = element.offsetInFace;
	}
	else
	{
		// A copy from the original variable is created and allocated.
		_elements = realloc(_elements, sizeof(NGLElement) * (_pCount + 1));
		
		// Saves the copy.
		_elements[_pCount] = element;
		
		++_pCount;
	}
}

- (void) addFromElements:(NGLMeshElements *)elements
{
	NGLElement *element;
	
	[self removeAll];
	
	// Uses fast enumeration method to retrieve all the elements.
	while ((element = [elements nextIterator]))
	{
		[self addElement:*element];
	}
}

- (NGLElement *) elementWithComponent:(NGLComponent)component
{
	unsigned int i;
	unsigned int length = _pCount;
	for (i = 0; i < length; i++)
	{
		if (_elements[i].component == component)
		{
			return &_elements[i];
		}
	}
	
	return NULL;
}

- (void) removeElementWithComponent:(NGLComponent)component
{
	NGLElement *elements = _elements;
	NGLElement element;
	
	// Will be done pulling all the subsequent elements on
	// the position of the element that will be removed.
	unsigned int i;
	unsigned int length = _pCount;
	for (i = 0; i < length; i++)
	{
		element = _elements[i];
		
		// When the element to be removed is found,
		// skips it and continue replacing the other elements.
		if (_elements[i].component == component)
		{
			--_pCount;
			continue;
		}
		
		*elements++ = element;
	}
	
	_elements = realloc(_elements, sizeof(NGLElement) * (_pCount));
}

- (void) removeAll
{
	// Loops through all elements and free their memory.
	if (_pCount > 0)
	{
		nglFree(_elements);
		_pCount = 0;
	}
}

- (void *) nextIterator
{
	// Loops iterator until it reach the variables count.
	if (_iterator < _pCount)
	{
		return &_elements[_iterator++];
	}
	// When iterator reach the variables count, resets iterator.
	else
	{
		[self resetIterator];
	}
	
	return NULL;
}

- (void) resetIterator
{
	_iterator = 0;
}

- (int) count
{
	return _pCount;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (NSString *) description
{
	NSMutableString *string = [[NSMutableString alloc] initWithString:[super description]];
	NGLElement *element;
	
	// Uses fast enumeration method to retrieve all the elements.
	while ((element = [self nextIterator]))
	{
		[string appendString:[NSString stringWithFormat:@"\n\
							  Element: %@\n\
							  Start: %i\n\
							  Length: %i\n\
							  Offset: %i\n",
							  stringFromElement((*element).component),
							  (*element).start,
							  (*element).length,
							  (*element).offsetInFace]];
	}
	
	return [string autorelease];
}

- (void) dealloc
{
	[self removeAll];
	
	[super dealloc];
}

@end