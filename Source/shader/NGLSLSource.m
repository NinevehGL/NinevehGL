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

#import "NGLSLSource.h"

#import "NGLRegEx.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

static NSString *const SHD_ERROR_HEADER = @"Error while processing NGLSLSource.";

static NSString *const SHD_NOT_FOUND = @"Shader file \"%@\" was not found in the specified path.\n\
The path to a file must reflect its real location, \
if only the file's name was specified, the search will happen in the Global Path.\n\
For more information check the nglGlobalFilePath() function.";

static NSString *const SHD_MALFORMED = @"Shader file is malformed.\n\
The shader files need to follow GLSL ES 1.0 specifications.\n\
Probably a problem with the \"void main()\" function syntax.\n\
For more information check: http://www.khronos.org/files/opengles_shading_language.pdf";

//static NSString *const SHD_FINAL = @"%@\nvoid main()\n{\n%@\n}";

static NSString *const REG_CLEARING = @"(\\/\\*.*?\\*\\/)|(\\/\\/.*?[\\n|\\r|\\t])";

static NSString *const REG_DIVIDING = @"(.*)?void\\W+main\\W*\\(.*?\\)\\W*\\{(.*)\\}";

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

@interface NGLSLSource()

// Initializes a new instance.
- (void) initialize;

// Puts a block of code into the shader.
- (void) setPart:(NSMutableString *)part withString:(NSString *)string mode:(NGLSLAddMode)mode;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLSLSource

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize headerData = _header, bodyData = _body;

@dynamic shaderData;

- (NSString *) shaderData
{
	// If the header and body was properly set, returns the final shader string.
	if ([_header length] > 0 && [_body length] > 0)
	{
		return [NSString stringWithFormat:@"%@\nvoid main()\n{\n%@\n}",_header,_body];
	}
	
	return nil;
}

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

- (id) initWithFile:(NSString *)filePath
{
	if ((self = [super init]))
	{
		[self initialize];
		
		[self addFromFile:filePath mode:NGLSLAddModeSet];
	}
	
	return self;
}

- (id) initWithString:(NSString *)string
{
	if ((self = [super init]))
	{
		[self initialize];
		
		[self addFromString:string mode:NGLSLAddModeSet];
	}
	
	return self;
}

- (id) initWithSource:(NGLSLSource *)shader
{
	if ((self = [super init]))
	{
		[self initialize];
		
		[self addFromSource:shader mode:NGLSLAddModeSet];
	}
	
	return self;
}

- (id) initWithHeader:(NSString *)header andBody:(NSString *)body
{
	if ((self = [super init]))
	{
		[self initialize];
		
		[self setPart:_header withString:header mode:NGLSLAddModeSet];
		[self setPart:_body withString:body mode:NGLSLAddModeSet];
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initialize
{
	_header = [[NSMutableString alloc] init];
	_body = [[NSMutableString alloc] init];
	
	// Initiates error API.
	_error = [[NGLError alloc] init];
	_error.header = SHD_ERROR_HEADER;
}

- (void) setPart:(NSMutableString *)part withString:(NSString *)string mode:(NGLSLAddMode)mode
{
	// If the string if valid, add it to the desired part using the specified mode.
	if (string != nil)
	{
		switch (mode)
		{
			case NGLSLAddModeSet:
				[part setString:string];
				break;
			case NGLSLAddModePrepend:
				[part insertString:string atIndex:0];
				break;
			case NGLSLAddModeAppend:
				[part appendString:string];
				break;
		}
	}
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) addHeader:(NSString *)header mode:(NGLSLAddMode)mode
{
	[self setPart:_header withString:header mode:mode];
}

- (void) addBody:(NSString *)body mode:(NGLSLAddMode)mode
{
	[self setPart:_body withString:body mode:mode];
}

- (void) addFromFile:(NSString *)filePath mode:(NGLSLAddMode)mode
{
	// Load the Shader source.
	NSString *source = nglSourceFromFile(filePath);
	
	// Checks if the file exist.
	if (source == nil)
	{
		_error.message = [NSString stringWithFormat:SHD_NOT_FOUND, filePath];
		[_error showError];
	}
	// Proceeds if the source was successfully loaded.
	else
	{
		[self addFromString:source mode:mode];
	}
}

- (void) addFromString:(NSString *)string mode:(NGLSLAddMode)mode
{
	// Check if the source was load.
	if (string != nil)
	{
		string = nglRegExReplace(string, REG_CLEARING, @"", NGLRegExFlagGDM);
		string = nglRegExReplace(string, REG_DIVIDING, @"$1#@NGLCUT@#$2", NGLRegExFlagGDM);
		
		// Cut into a NSArray is fast than run RegExp twice, one for header and one for body.
		NSArray *cuted = [string componentsSeparatedByString:@"#@NGLCUT@#"];
		
		if ([cuted count] != 2)
		{
			_error.message = SHD_MALFORMED;
			[_error showError];
		}
		else
		{
			// Add each part of the content to their right places.
			[self setPart:_header withString:[cuted objectAtIndex:0] mode:mode];
			[self setPart:_body withString:[cuted objectAtIndex:1] mode:mode];
		}
	}
}

- (void) addFromSource:(NGLSLSource *)shader mode:(NGLSLAddMode)mode
{
	[self setPart:_header withString:shader.headerData mode:mode];
	[self setPart:_body withString:shader.bodyData mode:mode];
}

- (BOOL) hasHeader:(NSString *)pattern
{
	return nglRegExMatch(_header, pattern, NGLRegExFlagGDM);
}

- (BOOL) hasBody:(NSString *)pattern
{
	return nglRegExMatch(_body, pattern, NGLRegExFlagGDM);
}

- (BOOL) hasPattern:(NSString *)pattern
{
	return ([self hasHeader:pattern] || [self hasBody:pattern]);
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (NSString *) description
{
	return [NSString stringWithFormat:@"\n%@\n%@", [super description], self.shaderData];
}

- (void) dealloc
{
	nglRelease(_header);
	nglRelease(_body);
	nglRelease(_error);
	
	[super dealloc];
}

@end