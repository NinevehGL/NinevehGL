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

#import "NGLES2Buffers.h"

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
#pragma mark Private Definitions
//**************************************************
//	Private Definitions
//**************************************************

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLES2Buffers

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

- (void) loadData:(const void *)data
			 size:(int)size
			 type:(NGLES2BuffersType)type
			usage:(NGLES2BuffersUsage)usage;
{
	// Chooses the type of the buffer.
	GLuint *name = (type == NGLES2BuffersTypeIndex) ? &_ibo : &_vbo;
	
	// Creates a Buffer Object's.
	glGenBuffers(1, name);
	
	// Makes this Buffer the current Buffer for its type.
	// This step will really create the Buffer Object.
	glBindBuffer(type, *name);
	
	// Sets the buffer's data
	glBufferData(type, size, data, usage);
	
	// Unbids this buffer.
	glBindBuffer(type, 0);
}

- (void) bind
{
	// Binds the buffers.
	glBindBuffer(NGLES2BuffersTypeIndex, _ibo);
	glBindBuffer(NGLES2BuffersTypeStructure, _vbo);
}

- (void) unbind
{
	// Unbinds both buffers.
	glBindBuffer(NGLES2BuffersTypeIndex, 0);
	glBindBuffer(NGLES2BuffersTypeStructure, 0);
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	// Unbinds the buffers.
	[self unbind];
	
	// Deletes the buffers.
	glDeleteBuffers(1, &_vbo);
	glDeleteBuffers(1, &_ibo);
	
	[super dealloc];
}

@end
