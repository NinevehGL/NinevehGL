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
#import "NGLGlobal.h"
#import "NGLTexture.h"
#import "NGLMaterial.h"
#import "NGLParserImage.h"

/*!
 *					<strong>(Internal only)</strong> Creates, manages and organizes textures to OpenGL ES 2.
 *
 *					This class holds all necessary information about textures to OpenGL ES 2.
 *					NGLES2Textures is also used in the render process to bind the texture units within
 *					the shaders programs. NGLES2Textures creates mipmaps automatically and set the filters
 *					to the textures.
 *
 *					As any other class bound with OpenGL specific version, you should never deal with
 *					NGLES2Textures directly, NinevehGL is responsible for that.
 *
 *	@see			NGLMaterial
 *	@see			NGLES2Mesh
 */
@interface NGLES2Textures : NSObject
{
@private
	// Textures
	NSMutableArray			*_fileNames;
	GLuint					*_textures;
	int						_tCount;
	
	// Error API
	NGLError				*_error;
}

/*!
 *					Loads, parses and constructs a texture map based on a #NGLTexture#.
 *
 *					This method creates an OpenGL ES 2 specific texture object.
 *
 *	@param			texture
 *					A #NGLTexture# intialized and parsed instance.
 *
 *	@see			NGLTexture
 */
- (void) addTexture:(NGLTexture *)texture;


/*!
 *					Gets the reserved texture unit to the last added texture.
 *
 *					This method returns a reserved unique texture unit to the last added texture.
 *					So this method should be called immediately after a new texture be added.
 *
 *	@result			The reserved texture unit to use later on.
 */
- (int) getLastUnit;

/*!
 *					Binds an OpenGL ES 2 texture to a location.
 *
 *					You must inform the texture unit and location in the shader only. This method doesn't
 *					need to know the texture object name/index because each texture unit is reserved
 *					to only one texture object in the current instance. For example:
 *
 *					<pre>
 *
 *					Texture Objects         Texture Unit                  bindUnit:toLocation: method
 *					       1        ------>      0       ------|
 *					       2        ------>      1             |
 *					       5        ------>      2             |------>       0 + location
 *					       8        ------>      3       ------------->       3 + location
 *					       9        ------>      4     
 *
 *					</pre>
 *
 *					In the example above, as each NGLES2Textures instance always reserves unique Texture
 *					Units for each Texture Objects, you don't need to know the Texture Object name/index.
 *					All that you need to know is its Texture Unit and inform the desired location in the
 *					shaders to bind the Texture Object.
 *
 *					The Texture Unit can be catched by calling <code>#getLastUnit#</code> method.
 *
 *					It's important to pay attention at the maximum number of textures supported by the
 *					current OpenGL ES 2 implementation.
 *
 *	@param			unit
 *					The Texture Unit to use.
 *
 *	@param			location
 *					The location in the shader to bind the Texture Object.
 *
 *	@see			getLastUnit
 *	@see			maxTextures
 *	@see			addTexture:
 */
- (void) bindUnit:(GLint)unit toLocation:(GLint)location;

/*!
 *					Unbinds all texture object.
 *
 *					This method uses the OpenGL reserved name/index 0.
 */
+ (void) unbindAll;

/*!
 *					Returns the maximum number of textures supported.
 *
 *					The maximum texture objects supported by the shaders is something that depends on the
 *					OpenGL's implementation. So, different implementations/platforms may support different
 *					number of textures.
 *
 *	@result			An int data type with the maximum supported textures in shaders.
 */
+ (int) maxTextures;

@end