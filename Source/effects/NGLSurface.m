/*
 *	NGLSurface.m
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *	Created by Diney Bomfim on 1/29/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
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

- (id) initWithStart:(unsigned int)start length:(unsigned int)length identifier:(unsigned int)newId
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

+ (id) surfacetWithStart:(unsigned int)start length:(unsigned int)length identifier:(unsigned int)newId
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
			self.identifier,
			self.startData,
			self.lengthData];
}

@end