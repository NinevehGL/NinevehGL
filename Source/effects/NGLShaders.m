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

#import "NGLShaders.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

static NSString *const SHD_ERROR_HEADER = @"Error while processing NGLShader.";

static NSString *const SHD_ERROR_DATA = @"Invalid data type to the shader variable with name %@.\n\
The data type must be one of types specified in NGLDataType and should be accepted by the kind\n\
of variable you are trying to create (attributes or uniforms).";

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

@interface NGLShaders()

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

@implementation NGLShaders

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize identifier = _identifier, vertex = _vsh, fragment = _fsh, variables = _variables;

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

- (id) initWithSourcesVertex:(NSString *)vsh andFragment:(NSString *)fsh
{
	if ((self = [super init]))
	{
		[self initialize];
		
		if (vsh != nil)
		{
			[_vsh addFromString:vsh mode:NGLSLAddModeSet];
		}
		
		if (fsh != nil)
		{
			[_fsh addFromString:fsh mode:NGLSLAddModeSet];
		}
	}
	
	return self;
}

- (id) initWithFilesVertex:(NSString *)vshPath andFragment:(NSString *)fshPath
{
	if ((self = [super init]))
	{
		[self initialize];
		
		if (vshPath != nil)
		{
			[_vsh addFromFile:vshPath mode:NGLSLAddModeSet];
		}
		
		if (fshPath != nil)
		{
			[_fsh addFromFile:fshPath mode:NGLSLAddModeSet];
		}
	}
	
	return self;
}

+ (id) shadersWithSourcesVertex:(NSString *)vsh andFragment:(NSString *)fsh
{
	NGLShaders *shaders = [[NGLShaders alloc] initWithSourcesVertex:vsh andFragment:fsh];
	
	return [shaders autorelease];
}

+ (id) shadersWithFilesVertex:(NSString *)vshPath andFragment:(NSString *)fshPath
{
	NGLShaders *shaders = [[NGLShaders alloc] initWithFilesVertex:vshPath andFragment:fshPath];
	
	return [shaders autorelease];
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initialize
{
	_identifier = 0;
	
	nglRelease(_vsh);
	nglRelease(_fsh);
	nglRelease(_variables);
	
	_vsh = [[NGLSLSource alloc] init];
	_fsh = [[NGLSLSource alloc] init];
	_variables = [[NGLSLVariables alloc] init];
	
	// Initializes the error API.
	_error = [[NGLError alloc] initWithHeader:SHD_ERROR_HEADER];
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
	NGLShaders *copy = aCopy;
	
	// Copying properties.
	copy.identifier = _identifier;
	
	[copy.vertex addFromSource:_vsh mode:NGLSLAddModeSet];
	[copy.fragment addFromSource:_fsh mode:NGLSLAddModeSet];
	[copy.variables addFromVariables:_variables];
	
	if (isShared)
	{
		nglRelease(_vsh);
		nglRelease(_fsh);
		nglRelease(_variables);
		_vsh = [copy.vertex retain];
		_fsh = [copy.fragment retain];
		_variables = [copy.variables retain];
	}
}

- (void) bindAttribute:(NSString *)name stride:(int)stride dataType:(int)dataType data:(void *)data
{
	int count;
	
	// Checks against invalid data types.
	if (dataType > NGL_SAMPLER_CUBE)
	{
		_error.message = [NSString stringWithFormat:SHD_ERROR_DATA,name];
		[_error showError];
		return;
	}
	
	// Define the correct count based on a data type.
	switch (dataType)
	{
		case NGL_FLOAT:
			count = 1;
			break;
		case NGL_VEC2:
			count = 2;
			break;
		case NGL_VEC3:
			count = 3;
			break;
		case NGL_VEC4:
			count = 4;
			break;
		case NGL_MAT2:
			count = 4;
			break;
		case NGL_MAT3:
			count = 9;
			break;
		case NGL_MAT4:
			count = 16;
			break;
		default:
			count = 0;
			break;
	}
	
	// Create the variable using the internal NGLSLVariable structure.
	[_variables addVariable:(NGLSLVariable){YES, name, 0, count, dataType, stride, data}];
}

- (void) bindUniform:(NSString *)name count:(int)count dataType:(int)dataType data:(void *)data
{
	// Checks against invalid data types.
	if (dataType > NGL_SAMPLER_CUBE)
	{
		_error.message = [NSString stringWithFormat:SHD_ERROR_DATA,name];
		[_error showError];
		return;
	}
	
	// Create the variable using the internal NGLSLVariable structure.
	[_variables addVariable:(NGLSLVariable){NO, name, 0, count, dataType, 0, data}];
}

- (void) bindTexture:(NSString *)name texture:(NGLTexture *)texture
{
	// Create the variable using the internal NGLSLVariable structure.
	[_variables addVariable:(NGLSLVariable){NO, name, 0, 1, texture.type, 0, texture}];
}

- (void) removeVariableWithName:(NSString *)name
{
	[_variables removeVariableWithName:name];
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
			Vertex Shader:\n %@\n\
			Fragment Shader:\n %@\n\
			Variables:\n %@",
			[super description],
			self.identifier,
			self.vertex,
			self.fragment,
			self.variables];
}

- (void) dealloc
{
	nglRelease(_vsh);
	nglRelease(_fsh);
	nglRelease(_variables);
	nglRelease(_error);
	
	[super dealloc];
}

@end
