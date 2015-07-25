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

#import "NGLSLVariables.h"

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
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLSLVariables

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
		//_collection = [[NGLArray alloc] initWithPointerSize:sizeof(NGLSLVariable)];
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

- (void) addVariable:(NGLSLVariable)variable
{
	// A copy from the original variable was created and allocated.
	_variables = realloc(_variables, sizeof(NGLSLVariable) * (_vCount + 1));
	
	// Saves the copy.
	_variables[_vCount] = variable;
	
	// Retains the Obj-C string.
	[variable.name retain];
	
	++_vCount;
}

- (void) addFromVariables:(NGLSLVariables *)variables
{
	NGLSLVariable *variable;
	
	// Uses fast enumeration method for retrieve all the elements.
	while ((variable = [variables nextIterator]))
	{
		[self addVariable:*variable];
	}
}

- (NGLSLVariable *) variableAtIndex:(int)index
{
	return (index < _vCount && index >= 0) ? &_variables[index] : NULL;
}

- (NGLSLVariable *) variableWithName:(NSString *)name
{
	unsigned int i;
	unsigned int length = _vCount;
	for (i = 0; i < length; i++)
	{
		if ([name isEqualToString:_variables[i].name])
		{
			return &_variables[i];
		}
	}
	
	return NULL;
}

- (void) removeVariableWithName:(NSString *)name
{
	NGLSLVariable variable;
	NGLSLVariable *variables = _variables;
	
	unsigned int i;
	unsigned int length = _vCount;
	for (i = 0; i < length; i++)
	{
		variable = _variables[i];
		
		if ([name isEqualToString:variable.name])
		{
			// Releases the Obj-C string.
			nglRelease(variable.name);
			
			--_vCount;
			continue;
		}
		
		*variables++ = variable;
	}
	
	_variables = realloc(_variables, sizeof(NGLSLVariable) * (_vCount));
}

- (void) removeAll
{
	NGLSLVariable variable;
	
	unsigned int i;
	unsigned int length = _vCount;
	for (i = 0; i < length; i++)
	{
		variable = _variables[i];
		
		// Releases the Obj-C string.
		nglRelease(variable.name);
	}
	
	_vCount = 0;
	
	nglFree(_variables);
}

- (unsigned int) count
{
	return _vCount;
}

- (void *) nextIterator
{
	// Loops iterator until it reach the variables count.
	if (_iterator < _vCount)
	{
		return &_variables[_iterator++];
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

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (NSString *) description
{
	NSMutableString *string = [[NSMutableString alloc] initWithString:[super description]];
	NGLSLVariable *variable;
	
	while ((variable = [self nextIterator]))
	{
		[string appendFormat:@"\n\n\
		 Name: %@\n\
		 Dynamic: %@",
		 (*variable).name,
		 ((*variable).isDynamic) ? @"YES" : @"NO"];
	}
	
	return [string autorelease];
}

- (void) dealloc
{
	[self removeAll];
	
	nglRelease(_collection);
	
	[super dealloc];
}

@end