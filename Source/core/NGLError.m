/*
 *	NGLError.m
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *	Created by Diney Bomfim on 1/5/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLError.h"

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

@implementation NGLError

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize hasError = _hasError, hadError = _hadError, header = _header;

@dynamic message;

- (NSString *) message { return _message; }
- (void) setMessage:(NSString *)string
{
	// Copies the message string if it is valid.
	if (_message != string)
	{
		nglRelease(_message);
		_message = [string copy];
		
		// Every changes to the error message is taken as a valid error.
		_hasError = YES;
		_hadError = YES;
	}
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) initWithHeader:(NSString *)header
{
	if ((self = [super init]))
	{
		self.header = header;
	}
	
	return self;
}

+ (id) error
{
	return [[[NGLError alloc] init] autorelease];
}

+ (id) errorWithHeader:(NSString *)headerString
{
	NGLError *error = [[NGLError alloc] init];
	
	// Sets just the header. This is not taken as a valid error.
	error.header = headerString;
	
	return [error autorelease];
}

+ (id) errorWithHeader:(NSString *)headerString andMessage:(NSString *)messageString
{
	NGLError *error = [[NGLError alloc] init];
	
	// Sets the header and message. This is a valid error.
	error.header = headerString;
	error.message = messageString;
	
	return [error autorelease];
}

+ (void) errorInstantlyWithHeader:(NSString *)headerString andMessage:(NSString *)messageString
{
	NGLError *error = [[NGLError alloc] init];
	
	// Sets the header and message and immediatly shows the error.
	error.header = headerString;
	error.message = messageString;
	[error showError];
	
	nglRelease(error);
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) showError
{
	// Shows the error if it exist, that means, if there is an error not presented.
	if (_hasError)
	{
		_hasError = NO;
#ifdef NGL_DEBUG
		NSLog(@"\n***** NGLError *****\n%@\n%@\n********************", self.header, self.message);
#endif
	}
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	nglRelease(_header);
	nglRelease(_message);
	
	[super dealloc];
}

@end