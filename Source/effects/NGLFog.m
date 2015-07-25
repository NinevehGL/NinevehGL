/*
 *	NGLFog.m
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *	
 *	Created by Diney Bomfim on 5/22/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLFog.h"

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

@interface NGLFog()

- (void) calculateFactor;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLFog

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@dynamic type, color, start, end, values;

- (NGLFogType) type { return _values.type; }
- (void) setType:(NGLFogType)value
{
	_values.type = value;
}

- (NGLvec4) color { return _values.color; }
- (void) setColor:(NGLvec4)value
{
	_values.color = value;
}

- (float) start { return _values.start; }
- (void) setStart:(float)value
{
	_values.start = value;
	[self calculateFactor];
}

- (float) end { return _values.end; }
- (void) setEnd:(float)value
{
	_values.end = value;
	[self calculateFactor];
}

- (NGLFogValues *) values { return &_values; }

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super init]))
	{
		self.start = 75.0f;
		self.end = 100.0f;
		self.type = NGLFogTypeNone;
		self.color = nglDefaultColor;
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) calculateFactor
{
	_values.factor = _values.end - _values.start;
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

+ (NGLFog *) defaultFog
{
	// Persistent instance.
	static NGLFog *_default = nil;
	
	// Allocates once with Grand Central Dispatch (GCD) routine. Thread safe.
	static dispatch_once_t safer;
	dispatch_once(&safer, ^(void)
	{
		_default = [[NGLFog alloc] init];
	});
	
	return _default;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (id) retain
{
	return self;
}

- (oneway void) release
{
	// Does nothing here.
}

- (id) autorelease
{
	return self;
}

- (NSUInteger) retainCount
{
    return NGL_MAX_32;
}

- (void) dealloc
{
	[super dealloc];
}

@end
