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
#import "NGLMatrix.h"
#import "NGLMesh.h"
#import "NGLTexture.h"
#import "NGLMaterial.h"
#import "NGLShaders.h"

#import "NGLES2Program.h"
#import "NGLES2Textures.h"
#import "NGLES2Functions.h"

#import "NGLSLVariables.h"
#import "NGLSLConstructor.h"

/*!
 *					<strong>(Internal only)</strong> Responsible for managing each mesh's polygon.
 *
 *					NGLES2Polygon is one of the most important classes for OpenGL ES 2. It's reponsible
 *					for coordinating the creation of shaders, variables and also the drawing process. Also
 *					it manages the Shader Program and the Textures. All its job is based on #NGLMaterial#,
 *					NGLShaders and #NGLSurface# information from a #NGLES2Mesh# (the version dependents
 *					core of a #NGLMesh#).
 *
 *					A single #NGLMesh# (#NGLES2Mesh#) can implement many NGLES2Polygon. Each
 *					NGLES2Polygon represents a part of the mesh's surface which uses a specific Shader
 *					Program. If the entire mesh needs only one kind of Shader Program, it will use only one
 *					NGLES2Polygon, probably. Actually, the number of NGLES2Polygon is defined by the
 *					number of #NGLSurface# instances defined to a #NGLMesh#.
 *
 *					The NGLES2Polygon is the last place of processing during the render's drawing phase.
 *					In this reason, NGLES2Polygon is extremely fast, dealing only with pointers to make
 *					all the drawing commands.
 *
 *	@see			NGLMesh
 *	@see			NGLMaterial
 *	@see			NGLShaders
 *	@see			NGLSurface
 *	@see			NGLES2Program
 *	@see			NGLES2Textures
 */
@interface NGLES2Polygon : NSObject
{
@private
	// Drawing Length
	void					*_start;
	GLsizei					_length;
	GLenum					_dataType;
	GLenum					_dataTypeSize;
	
	NGLES2Program			*_program;
	NGLES2Textures			*_textures;
	NGLSLVariables			*_variables;
	
	NGLvec4					_telemetry;
}

/*!
 *					Compiles this polygon with the current information.
 *
 *					This method must be called once after set the parent, material, shaders and surface.
 *
 *	@param			mesh
 *					The NGLMesh that will holds this polygon.
 *
 *	@param			location
 *					The location in the shader to bind the Texture Object.
 */
- (void) compilePolygon:(NGLMesh *)mesh
			   material:(NGLMaterial *)material
				shaders:(NGLShaders *)shaders
				surface:(NGLSurface *)surface;

/*!
 *					Draw this polygon to the OpenGL ES 2 core.
 *
 *					This method should be called once at every render cycle to update the image in the
 *					current frame buffer.
 */
- (void) drawPolygon;

- (void) drawPolygonTelemetry:(NGLvec4)color;

@end