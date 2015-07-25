/*
 *	NGLSLVariables.m
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *	Created by Diney Bomfim on 3/4/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
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