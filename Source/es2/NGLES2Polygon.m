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

#import "NGLES2Polygon.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

//static NSString *const PLG_ERROR_HEADER = @"Error while processing NGLES2Polygon.";

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

// Pointers to Function to set uniforms of all kinds.
typedef void (*nglUniformVector)(GLint location, GLsizei count, const void *v);
typedef void (*nglUniformMatrix)(GLint location, GLsizei count, GLboolean transpose, const void *value);

static NGLSLVariables *telemetryVariables(void)
{
	static NGLSLVariables *_telemetryVariables;
	
	// Allocates once with Grand Central Dispatch (GCD) routine. Thread safe.
	static dispatch_once_t safer;
	dispatch_once(&safer, ^(void)
	{
		_telemetryVariables = [[NGLSLVariables alloc] init];
	});
	
	return _telemetryVariables;
}

static NGLES2Program *telemetryProgram()
{
	static NGLES2Program *_telemetryProgram;
	
	// Allocates once with Grand Central Dispatch (GCD) routine. Thread safe.
	static dispatch_once_t safer;
	dispatch_once(&safer, ^(void)
	{
		_telemetryProgram = [[NGLES2Program alloc] init];
		
		NGLShaders *telemetryShd = [[NGLShaders alloc] init];
		nglConstructTelemetryShaders(telemetryShd);
		
		[_telemetryProgram setVertexShader:telemetryShd.vertex fragmentShader:telemetryShd.fragment];
		
		NGLSLVariable *variable;
		NGLSLVariables *variables = telemetryVariables();
		[variables addFromVariables:telemetryShd.variables];
		
		// Gets all variables' location.
		while ((variable = [variables nextIterator]))
		{
			// Gets the location to the current variable.
			(*variable).location = ((*variable).isDynamic) ?
			[_telemetryProgram attributeLocation:(*variable).name] :
			[_telemetryProgram uniformLocation:(*variable).name];
		}
		
		nglRelease(telemetryShd);
	});
	
	return _telemetryProgram;
}

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

// Turns ON or OFF the dynamic vertices for a NGLSLVariables library.
static void setDynamicVariables(NGLSLVariables *variables, BOOL activate)
{
	NGLSLVariable *variable;
	
	while ((variable = [variables nextIterator]))
	{
		if ((*variable).isDynamic)
		{
			if(activate)
			{
				glEnableVertexAttribArray((*variable).location);
			}
			else
			{
				glDisableVertexAttribArray((*variable).location);
			}
		}
	}
}

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLES2Polygon

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
		_program = [[NGLES2Program alloc] init];
		_textures = [[NGLES2Textures alloc] init];
		_variables = [[NGLSLVariables alloc] init];
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

- (void) compilePolygon:(NGLMesh *)mesh
			   material:(NGLMaterial *)material
				shaders:(NGLShaders *)shaders
				surface:(NGLSurface *)surface
{
	// TODO remove all this shit when iOS 6 comes out.
	//*
	if (nglDeviceSystemVersion() < NGL_IOS_5_0)
	{
		_dataType = GL_UNSIGNED_SHORT;
		_dataTypeSize = NGL_SIZE_USHORT;
	}
	else
	{
		_dataType = GL_UNSIGNED_INT;
		_dataTypeSize = NGL_SIZE_UINT;
	}
	/*/
	_dataType = GL_UNSIGNED_INT;
	_dataTypeSize = NGL_SIZE_UINT;//UINT POINT
	//*/
	
	// Adjusts the surface.
	_start = (void *)(UInt64)(surface.startData * _dataTypeSize); // FIXME: What is going on with this address calculation??
	_length = surface.lengthData;
	
	// Sets the default material.
	if (material == nil)
	{
		material = [NGLMaterial material];
	}
	
	NGLShaders *nglShaders = [[NGLShaders alloc] init];
	
	// Sets custom shaders if exist.
	if (shaders != nil)
	{
		[nglShaders.variables addFromVariables:shaders.variables];
		[nglShaders.vertex addFromSource:shaders.vertex mode:NGLSLAddModeSet];
		[nglShaders.fragment addFromSource:shaders.fragment mode:NGLSLAddModeSet];
	}
	
	// Constructs the shaders based on a NGLMaterial and NGLMesh.
	// The mesh is needed to get the data pointers.
	nglConstructShaders(nglShaders, material, mesh);
	
	// Prepares the shader variables with the telemetry variables.
	// The telemetry will not 
	nglPrepareTelemetryShaders(nglShaders, &_telemetry);
	
	// Creates the shader program object fo this polygon sets the variables for this polygon.
	// After the program creation, the shader is no longer necessary.
	[_program setVertexShader:nglShaders.vertex fragmentShader:nglShaders.fragment];
	
	[_variables removeAll];
	[_variables addFromVariables:nglShaders.variables];
	
	nglRelease(nglShaders);
	
	// Gets all variables' location.
	NGLSLVariable *variable;
	while ((variable = [_variables nextIterator]))
	{
		// The dynamic variables only use one OpenGL function, so they don't need Function Pointer.
		if ((*variable).isDynamic)
		{
			// Gets the location to the current variable.
			(*variable).location = [_program attributeLocation:(*variable).name];
		}
		else
		{
			// Gets the location to the current variable.
			(*variable).location = [_program uniformLocation:(*variable).name];
			
			// Selects the appropriate OpenGL ES 2 function.
			switch ((*variable).dataType)
			{
				case NGL_MAT4:
					(*variable).glFunction = &glUniformMatrix4fv;
					break;
				case NGL_MAT3:
					(*variable).glFunction = &glUniformMatrix3fv;
					break;
				case NGL_MAT2:
					(*variable).glFunction = &glUniformMatrix2fv;
					break;
				case NGL_VEC4:
					(*variable).glFunction = &glUniform4fv;
					break;
				case NGL_VEC3:
					(*variable).glFunction = &glUniform3fv;
					break;
				case NGL_VEC2:
					(*variable).glFunction = &glUniform2fv;
					break;
				case NGL_FLOAT:
					(*variable).glFunction = &glUniform1fv;
					break;
				case NGL_IVEC4:
				case NGL_BVEC4:
					(*variable).glFunction = &glUniform4iv;
					break;
				case NGL_IVEC3:
				case NGL_BVEC3:
					(*variable).glFunction = &glUniform3iv;
					break;
				case NGL_IVEC2:
				case NGL_BVEC2:
					(*variable).glFunction = &glUniform2iv;
					break;
				case NGL_INT:
				case NGL_BOOL:
					(*variable).glFunction = &glUniform1iv;
					break;
				case NGL_SAMPLER_2D:
				case NGL_SAMPLER_CUBE:
					// Creates a texture object based on a reference of NGLTexture in the data.
					[_textures addTexture:(NGLTexture *)(*variable).data];
					
					// Replaces the NGLTexture reference by the final texture unit to this texture object.
					(*variable).data = (void *)(UInt64)[_textures getLastUnit];
					break;
			}
		}
	}
}

- (void) drawPolygon
{
	// Starts using the program to this polygon.
	[_program use];
	
	// Enables dynamic locations.
	setDynamicVariables(_variables, YES);
	
	// Sets the shaders' variables.
	NGLSLVariable *variable;
	while ((variable = [_variables nextIterator]))
	{
		NGLSLVariable var = *variable;
		
		if (var.isDynamic)
		{
			glVertexAttribPointer(var.location, var.count, GL_FLOAT, GL_FALSE, var.stride, var.data);
		}
		else
		{
			// Selects the right Pointer to Function.
			switch (var.dataType)
			{
				case NGL_MAT4:
				case NGL_MAT3:
				case NGL_MAT2:
					((nglUniformMatrix)var.glFunction)(var.location, var.count, GL_FALSE, var.data);
					break;
				case NGL_SAMPLER_2D:
				case NGL_SAMPLER_CUBE:
					[_textures bindUnit:(int)var.data toLocation:var.location];
					break;
				default:
					((nglUniformVector)var.glFunction)(var.location, var.count, var.data);
					break;
			}
		}
	}
	
	// Draws the primitives.
	glDrawElements(GL_TRIANGLES, _length, _dataType, _start);
	
	// Disables the dynamic locations.
	setDynamicVariables(_variables, NO);
}

- (void) drawPolygonTelemetry:(NGLvec4)color
{
	NGLES2Program *telemetry = telemetryProgram();
	
	NGLSLVariable telVar;
	NGLSLVariables *telVars = telemetryVariables();
	
	NGLSLVariable selfVar;
	NGLSLVariables *selfVars = _variables;
	
	// Using the telemetry program.
	[telemetry use];
	
	// Updating the telemetry color.
	_telemetry = color;
	
	// Enables dynamic locations.
	setDynamicVariables(telVars, YES);
	
	telVar = *[telVars variableWithName:@"a_nglPosition"];
	selfVar = *[selfVars variableWithName:@"a_nglPosition"];
	glVertexAttribPointer(telVar.location, selfVar.count, GL_FLOAT, GL_FALSE, selfVar.stride, selfVar.data);
	
	telVar = *[telVars variableWithName:@"u_nglMVPMatrix"];
	selfVar = *[selfVars variableWithName:@"u_nglMVPMatrix"];
	glUniformMatrix4fv(telVar.location, selfVar.count, GL_FALSE, selfVar.data);
	
	telVar = *[telVars variableWithName:@"u_nglTelemetry"];
	selfVar = *[selfVars variableWithName:@"u_nglTelemetry"];
	glUniform4fv(telVar.location, selfVar.count, selfVar.data);
	
	// Draws the primitives.
	glDrawElements(GL_TRIANGLES, _length, _dataType, _start);
	
	// Disables the dynamic locations.
	setDynamicVariables(telVars, NO);
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	nglRelease(_program);
	nglRelease(_textures);
	nglRelease(_variables);
	
	[super dealloc];
}

@end