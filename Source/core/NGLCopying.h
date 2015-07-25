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

#import "NGLRuntime.h"

/*!
 *					The NGLCopying is an extension of Cocoa protocol NSCopying.
 *
 *					It defines two basic copying modes to NinevehGL objects:
 *
 *						- Copy: Makes a new clone, copying all the used memory.
 *						- Copy Instance: Makes a new clone, but clonning just the superficial memory.
 *
 *					All the copying method clone the current state of the object, this include the
 *					object's transformations, properties and everything inside the object. However,
 *					just like the professional 3D softwares, NinevehGL gives you a choice to save your
 *					work and your application's memory.
 *
 *					<strong>Copy</strong>
 *					All the used memory is copied and every new change made in one of both object will
 *					not affect the other one.
 *
 *					<strong>Copy Instance</strong>
 *					Just the superficial memory is copied, the deep memory, the hard one, is now shared
 *					by both object. So changes in the superficial structure are separated, but a change
 *					in a deep property will be reflected on the other one.
 *
 *					Each object defines what are its "superficial structure" and its "deep structure". For
 *					example, the #NGLMaterial# class defines its "superficial structure" is composed by all
 *					the scalar values (alpha, ambientColor, diffuseColor, emissiveColor, ...) and its
 *					"deep structure" is composed by the textures (alphaMap, ambientMap, diffuseMap, ...).
 *					Similarly, the #NGLMesh# defines its "superficial structure" as all transformations
 *					(position, rotation, scale, ...) and its "deep structure" as its mesh's structure
 *					(vertex normals, texcoords, tangent space, ...).
 *
 *					So, when you change the deep structure in one of both objects (original or copy) that
 *					the change will be reflected in the other one as well. This is very usefull for example
 *					when you need to clone a mesh changing its transformations but preserving its mesh's
 *					structure (like cloning an asteroid mesh to create a galaxy, or clonning a drop to
 *					create a rain).
 *
 *					This is the diagram of NGLCopying protocol:
 *
 *					<pre>
 *					                                    _________________
 *					                                   |                 |
 *					                                   |    NGLCopying   |
 *					                                   |_________________|
 *					                                            |
 *					      |-------------------------------------|------------------------------|
 *					      |                  |                  |               |              |
 *					  NGLMaterial        NGLShaders        NGLSurface      NGLObject3D     NGLTexture
 *					      |                  |                  |               | 
 *					      |                  |                  |               |
 *					NGLMaterialMulti  NGLShadersMulti   NGLSurfaceMulti     NGLCamera
 *					                                                            |
 *					                                                         NGLMesh
 *
 *					</pre>
 *
 *					This is the full table of all "superficial" and "deep" structures:
 *
 *					<pre>
 *					 _______________________________________________________________________________
 *					|                      |                               |                        |
 *					|                      |      Superficial Structure    |     Deep Structure     |
 *					|----------------------|-------------------------------|------------------------|
 *					|                      |          • Identifier         |                        |
 *					|      NGLMaterial     |       • All scalar values     |  • All texture maps    |
 *					|                      |                               |                        |
 *					|----------------------|-------------------------------|------------------------|
 *					|                      |                               |                        |
 *					|   NGLMaterialMulti   |               -               |  • List of Materials   |
 *					|                      |                               |                        |
 *					|----------------------|-------------------------------|------------------------|
 *					|                      |                               |    • Vertex Shader     |
 *					|      NGLShaders      |          • Identifier         |   • Fragment Shader    |
 *					|                      |                               |      • Variables       |
 *					|----------------------|-------------------------------|------------------------|
 *					|                      |                               |                        |
 *					|    NGLShadersMulti   |               -               |   • List of Shaders    |
 *					|                      |                               |                        |
 *					|----------------------|-------------------------------|------------------------|
 *					|                      |          • Identifier         |                        |
 *					|      NGLSurface      |          • Start data         |            -           |
 *					|                      |          • Length data        |                        |
 *					|----------------------|-------------------------------|------------------------|
 *					|                      |                               |                        |
 *					|    NGLSurfaceMulti   |               -               |   • List of Surfaces   |
 *					|                      |                               |                        |
 *					|----------------------|-------------------------------|------------------------|
 *					|                      |      • Transformations        |                        |
 *					|      NGLObject3D     | • Pivot, bounding box, target |            -           |
 *					|                      |   • Rotation Order and Space  |                        |
 *					|----------------------|-------------------------------|------------------------|
 *					|                      |         • Projection          |                        |
 *					|       NGLCamera      |           • Lenses            |            -           |
 *					|                      |           • Meshes            |                        |
 *					|----------------------|-------------------------------|------------------------|
 *					|                      |                               | • Materials, Surfaces  |
 *					|        NGLMesh       |  • Visibility + NGLObject 3D  |       and Shaders      |
 *					|                      |                               |    • Mesh's arrays     |
 *					|----------------------|-------------------------------|------------------------|
 *					|                      |      • File path and Type     |                        |
 *					|      NGLTexture      |  • Quality, Repeat, Optimize  |       • UIImage        |
 *					|______________________|_______________________________|________________________|
 *
 *					</pre>
 *
 *	@see			NGLMaterial
 *	@see			NGLMaterialMulti
 *	@see			NGLShaders
 *	@see			NGLShadersMulti
 *	@see			NGLSurface
 *	@see			NGLSurfaceMulti
 *	@see			NGLObject3D
 *	@see			NGLCamera
 *	@see			NGLMesh
 *	@see			NGLTexture
 */
@protocol NGLCopying <NSCopying>

@required

/*!
 *					Makes a clone from an object.
 *
 *					The memory is fully copied and both instances are completely independent from each
 *					other. Changes on one instance don't affect the other one.
 *
 *	@result			A new copied instance.
 */
- (id) copy;

/*!
 *					Makes a clone from an object.
 *
 *					The memory is partially copied. The "superficial structure" is completely independent
 *					from each other, but the "deep structure" is shared by both instances. Changes on the
 *					"deep structure" affect the other one.
 *
 *					The "superficial" and "deep" structures is defined by each class. Consult the
 *					NGLCopying documentation to check what is defined by each class.
 *
 *	@result			A new copied instance sharing the deep structure with the original one.
 */
- (id) copyInstance;

/*!
 *					Copies the properties from the current instance to a new one.
 *
 *					This method is responsible for creating the clones and managing the shared memories.
 *					Only the "deep structure" can be shared.
 *
 *	@param			aCopy
 *					The new instance which will receive the copied properties.
 *
 *	@param			isShared
 *					Indicates if the copy can shared the "deep structure" with the original one.
 */
- (void) defineCopyTo:(id)aCopy shared:(BOOL)isShared;

@end