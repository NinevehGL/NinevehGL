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