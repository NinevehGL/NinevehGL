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

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "NGLRuntime.h"
#import "NGLError.h"
#import "NGLShaders.h"

#import "NGLSLSource.h"
#import "NGLSLConstructor.h"

/*!
 *					<strong>(Internal only)</strong> Creates and makes use of OpenGL ES 2 Shader Programs.
 *
 *					NGLES2Program is a class which compiles shaders programs based on NSString, local
 *					files containing the shaders strings or on #NGLSLSource# instances. Shader Programs are
 *					always compiled in pairs: Vertex Shader and Fragment Shader, so the both shaders sources
 *					must be informed together.
 *
 *					Besides, it uses the NinevehGL Error API to show any possible error in the shaders'
 *					compilation. The error will be shown in the console panel.
 *
 *					Once the both shader sources are compileds, you can retrieve any attribute or uniform
 *					location from the compiled Shader Program. Those locations will be used later at the
 *					drawing phase.
 *
 *					NGLES2Program is also responsible by set its own program to be used by OpenGL's core.
 */
@interface NGLES2Program : NSObject
{
@private
	GLuint					_name;
}

/*!
 *					Compiles a new Shader Program based on a Vertex and a Fragment Shaders.
 *
 *					If there is any compiled Shader Program previously, the new shaders will completely
 *					replace the oldest.
 *
 *					This method compiles the new Shader Program imediately. If there is any error, it will
 *					be shown instantly. If the Shader Program was successfully compiled, it's sure that
 *					everything is OK with the syntax inside its source code.
 *
 *					Once the Shader Program was compiled, you can retrieve the variables locations from it,
 *					by using the <code>#attributeLocation:#</code> or <code>#uniformLocation:#</code>
 *					methods.
 *
 *	@param			vertex
 *					The NSString containing the source code to the Vertex Shader.
 *
 *	@param			fragment
 *					The NSString containing the source code to the Vertex Shader.
 *
 *	@see			attributeLocation:
 *	@see			uniformLocation:
 */
- (void) setVertexString:(NSString *)vertex fragmentString:(NSString *)fragment;

/*!
 *					Compiles a new Shader Program based on a Vertex and a Fragment Shaders.
 *
 *					If there is any compiled Shader Program previously, the new shaders will completely
 *					replace the oldest.
 *
 *					This method compiles the new Shader Program imediately. If there is any error, it will
 *					be shown instantly. If the Shader Program was successfully compiled, it's sure that
 *					everything is OK with the syntax inside its source code.
 *
 *					Once the Shader Program was compiled, you can retrieve the variables locations from it,
 *					by using the <code>#attributeLocation:#</code> or <code>#uniformLocation:#</code>
 *					methods.
 *
 *	@param			vertexPath
 *					The NSString containing the file path to the Vertex Shader file.
 *
 *	@param			fragmentPath
 *					The NSString containing the file path to the Fragment Shader file.
 *
 *	@see			attributeLocation:
 *	@see			uniformLocation:
 */
- (void) setVertexFile:(NSString *)vertexPath fragmentFile:(NSString *)fragmentPath;

/*!
 *					Compiles a new Shader Program based on a Vertex and a Fragment Shaders.
 *
 *					If there is any compiled Shader Program previously, the new shaders will completely
 *					replace the oldest.
 *
 *					This method compiles the new Shader Program imediately. If there is any error, it will
 *					be shown instantly. If the Shader Program was successfully compiled, it's sure that
 *					everything is OK with the syntax inside its source code.
 *
 *					Once the Shader Program was compiled, you can retrieve the variables locations from it,
 *					by using the <code>#attributeLocation:#</code> or <code>#uniformLocation:#</code>
 *					methods.
 *
 *	@param			vertexShader
 *					The #NGLSLSource# containing the Vertex Shader.
 *
 *	@param			fragmentShader
 *					The #NGLSLSource# containing the Vertex Shader.
 *
 *	@see			attributeLocation:
 *	@see			uniformLocation:
 */
- (void) setVertexShader:(NGLSLSource *)vertexShader fragmentShader:(NGLSLSource *)fragmentShader;

/*!
 *					Returns the locations of an attribute.
 *
 *					This method must be called after the Shader Program be compiled, that means, after call
 *					one of the methods <code>setVertex*</code>. If there is no compiled Shader Program, 0
 *					will be returned.
 *
 *	@param			nameInShader
 *					A NSString representing the attributes's name inside the shaders.
 *
 *	@result			An int data type with the location of the informed shader variable.
 *
 *	@see			setVertexString:fragmentString:
 *	@see			setVertexFile:fragmentFile:
 *	@see			setVertexShader:fragmentShader:
 */
- (GLint) attributeLocation:(NSString *)nameInShader;

/*!
 *					Returns the locations of an uniform.
 *
 *					This method must be called after the Shader Program be compiled, that means, after call
 *					one of the methods <code>setVertex*</code>. If there is no compiled Shader Program, 0
 *					will be returned.
 *
 *	@param			nameInShader
 *					A NSString representing the uniform's name inside the shaders.
 *
 *	@result			An int data type with the location of the informed shader variable.
 *
 *	@see			setVertexString:fragmentString:
 *	@see			setVertexFile:fragmentFile:
 *	@see			setVertexShader:fragmentShader:
 */
- (GLint) uniformLocation:(NSString *)nameInShader;

/*!
 *					Makes use of its own compiled Shader Program.
 *
 *					This method instructs OpenGL's core to start using the current program. It should be
 *					called once at the drawing phase before starting the drawing to this Shader Program.
 */
- (void) use;

@end
