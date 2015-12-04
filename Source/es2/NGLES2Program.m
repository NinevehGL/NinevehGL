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

#import "NGLES2Program.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

static NSString *const PRG_ERROR_CONTEXT = @"Incorrect usage.\n\
No OpenGL context was created. You should initialize a NGLView before any other NinevehGL's object.";

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

// Global program cache.
static GLuint _currentProgram;

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NGLES2Program()

// Compiles a shader based on a type (Vertex or Fragment) and a NSString.
- (void) compileShader:(GLuint *)shader type:(GLenum)type data:(NSString *)data;

// Deletes the current program.
- (void) clearProgram;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLES2Program

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        _name = 0;
    }
    return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) compileShader:(GLuint *)shader type:(GLenum)type data:(NSString *)data
{
	const GLchar *source = [data UTF8String];
	
	// Creates the shader name/index.
    *shader = glCreateShader(type);
	
	if (*shader == 0)
	{
		[NGLError errorInstantlyWithHeader:@"Error while processing NGLES2Program."
								andMessage:PRG_ERROR_CONTEXT];
	}
	
	// Loads the shader source.
    glShaderSource(*shader, 1, &source, NULL);
	
	// Compiles the loaded source.
    glCompileShader(*shader);
	
#ifdef NGL_DEBUG
	// Prints a possible error on the console.
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
		[NGLError errorInstantlyWithHeader:@"Error while processing NGLES2Program."
								andMessage:[NSString stringWithFormat:@"Shader compile error.\n%s", log]];
        nglFree(log);
		
		glDeleteShader(*shader);
    }
#endif
}

- (void) clearProgram
{
	// If the current program has a valid name/id, deletes it.
	if(_name)
	{
		if (_currentProgram == _name)
		{
			_currentProgram = 0;
			glUseProgram(0);
		}
		
		glDeleteProgram(_name);
	}
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) setVertexString:(NSString *)vertex fragmentString:(NSString *)fragment
{
	// Deletes the current program, if needed.
	[self clearProgram];
	
	GLuint vsh;
	GLuint fsh;
	
	// Compiles the pair of shaders.
	[self compileShader:&vsh type:GL_VERTEX_SHADER data:vertex];
	[self compileShader:&fsh type:GL_FRAGMENT_SHADER data:fragment];
	
	// Creates the program name/index.
	_name = glCreateProgram();
	
	// Attaches the fragment and vertex shaders to current program.
	glAttachShader(_name, vsh);
	glAttachShader(_name, fsh);
	
	// Links the program into OpenGL's core.
	glLinkProgram(_name);
	
#ifdef NGL_DEBUG
	// Prints a possible error on the console.
	GLint logLength;
	glGetProgramiv(_name, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0)
	{
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(_name, logLength, &logLength, log);
		[NGLError errorInstantlyWithHeader:@"Error while processing NGLES2Program."
								andMessage:[NSString stringWithFormat:@"Program link error.\n%s", log]];
		nglFree(log);
	}
#endif
	
	// Clears the bound shaders.
	glDeleteShader(vsh);
	glDeleteShader(fsh);
}

- (void) setVertexFile:(NSString *)vertexPath fragmentFile:(NSString *)fragmentPath
{
	[self setVertexString:nglSourceFromFile(vertexPath) fragmentString:nglSourceFromFile(fragmentPath)];
}

- (void) setVertexShader:(NGLSLSource *)vertexShader fragmentShader:(NGLSLSource *)fragmentShader
{
	[self setVertexString:vertexShader.shaderData fragmentString:fragmentShader.shaderData];
}

- (GLint) attributeLocation:(NSString *)nameInShader
{
	return glGetAttribLocation(_name, [nameInShader UTF8String]);
}

- (GLint) uniformLocation:(NSString *)nameInShader
{
	return glGetUniformLocation(_name, [nameInShader UTF8String]);
}

- (void) use
{
	if (_currentProgram != _name)
	{
		_currentProgram = _name;
		glUseProgram(_currentProgram);
	}
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	[self clearProgram];
	
	[super dealloc];
}

@end
