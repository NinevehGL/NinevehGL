/*
 *  NGLES2Buffers.m
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
