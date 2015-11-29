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
#import "NGLFunctions.h"
#import "NGLDataType.h"
#import "NGLError.h"
#import "NGLVector.h"
#import "NGLMeshElements.h"
#import "NGLMaterialMulti.h"
#import "NGLSurfaceMulti.h"

@class NGLMeshElements, NGLMaterialMulti, NGLSurfaceMulti;

/*!
 *					<strong>(Internal only)</strong> The core of NinevehGL Parse API.
 *					It's the superclass for all mesh parsing classes.
 *
 *					NGLParserMesh is an abstract class. It makes adjusts and calculates some elements
 *					based on an importing result. This class makes:
 *
 *						- Calculates the Tangent Space (Normals, Tangent and Bitangent);
 *						- Rescale the entire mesh to fit into a new range, like fit to the screen;
 *						- Centralize the mesh if it is far from the world origin (0.0, 0.0, 0.0);
 *						- Calculates the bouding box to the mesh;
 *						- Transform brute 3D data into OpenGL friendly format (array of structures and
 *							array of indices).
 *
 *					This class needs some information like array of vertices and array of faces. Other
 *					information like array of texcoords and array of normals are optionals. These are
 *					the necessary array formats:
 *
 *						- Array of Vertices: vx1, vy1, vz1, vw1, vx2, vy2, vz2, vw2, ...
 *						- Array of Texcoords: ts1, tt1, ts2, tt2, ...
 *						- Array of Normals: nx1, ny1, nz1, nx2, ny2, nz2, ...
 *						- Array of Faces: iv1, it1, in1, iv2, it2, in2, ...
 *
 *					Each index in the array of faces doesn't reffer directly to an index in the desired
 *					array, but instead, it points to an element index. For example:
 *
 *					<pre>
 *
 *					vx1, vy1, vz1, vw1, vx2, vy2, vz2, vw2, vx3, vy3, vz3, vw3, ...
 *					|__________________|__________________|____________________|
 *					         0                   1                   2
 *					  _______|       ____________|  _________________|
 *					 |              |              |
 *					iv1, it1, in1, iv2, it2, in2, iv3, it3, in3, ...
 *
 *					</pre>
 *
 *					The same is true to the array of indices. Each value doesn't point directly to
 *					an index in the array of structures, but instead, it points to a block of structures:
 *
 *					<pre>
 *
 *					vx1, vy1, vz1, vw1, ts1, tt1, nx1, ny1, nz1, vx2, vy2, vz2, ...
 *					|___________________________________________|
 *					                        0
 *					  ______________________|
 *					 |
 *					i1, i2, i3, i4, i5, i6, i7, i8, i9, ...
 *
 *					</pre>
 *
 *					NGLParserMesh is responsible by the most expensive part of the parsing process, each
 *					feature has a cost directly connected with the mesh structure. Complex meshes take
 *					long processing time. The less work this class makes, faster will be the parsing.
 *					Try to follow few simple tips:
 *
 *						- Export your mesh with the desired size and position to avoid auto normalize
 *							and auto centralize process.
 *						- Export your mesh with normals to avoid new calculations.
 */
@interface NGLParserMesh : NSObject
{
@protected
	// Structure Components
	UInt32                  _vCount;
	UInt32                  _tCount;
	UInt32                  _nCount;
	UInt32                  _taCount;
	UInt32                  _biCount;
	float					*_vertices;
	float					*_texcoords;
	float					*_normals;
	float					*_tangents;
	float					*_bitangents;
	
	// Faces
	UInt32                  _facesCount;
	UInt32                  _facesStride;
	UInt32                  *_faces;
	
	// Data
	UInt32                  _iCount;
	UInt32                  _sCount;
	UInt32                  _stride;
	UInt32                  *_indices;
	float					*_structures;
	
	// Mesh Structure
	NGLMeshElements			*_meshElements;
	
	// Materials
	NGLMaterialMulti		*_material;
	NGLSurfaceMulti			*_surface;
	
	// Monitor
	double					_loadedData;
	double					_totalData;
	double					_parsedData;
	double					_totalParsedData;
	BOOL					_canceled;
	
	// Error API
	NGLError				*_error;
	
@private
	// Helpers
	float					*_adjusted;
	BOOL					_aCache;
	
	// Adjusts
	BOOL					_autoCentralize;
	float					_autoNormalize;
	NGLvec3					_vMin;
	NGLvec3					_vMax;
	NGLvec3					_vCen;
}

/*!
 *					The percentage of the loaded data within the range [0.0, 1.0].
 */
@property (nonatomic, readonly) float loadedData;

/*!
 *					Indicates if this parsing object has any error.
 */
@property (nonatomic, readonly) BOOL hasError;

/*!
 *					The number of elements in the array of indices.
 */
@property (nonatomic, readonly) UInt32 indicesCount;

/*!
 *					The number of elements in the array of structures.
 */
@property (nonatomic, readonly) UInt32 structuresCount;

/*!
 *					The stride of elements in the array of structures. This stride is given in elements.
 *					However, OpenGL needs stride in basic machine units (bytes). So this number must be
 *					converted later on, before be sent to OpenGL's core.
 */
@property (nonatomic, readonly) UInt32 stride;

/*!
 *					The array of indices. It's an UInt32 data type.
 */
@property (nonatomic, readonly) UInt32 *indices;

/*!
 *					The array of structures. It's composed by float data type because OpenGL
 *					is prepared to work on GPU, which was made to work preferably with floating points.
 */
@property (nonatomic, readonly) float *structures;

/*!
 *					The elements that forms the mesh structure.
 *
 *	@see			NGLMeshElements
 */
@property (nonatomic, readonly) NGLMeshElements *meshElements;

/*!
 *					The material library created from the 3D file.
 *
 *	@see			NGLMaterialMulti
 */
@property (nonatomic, readonly) NGLMaterialMulti *material;

/*!
 *					The surface library created from the 3D file.
 *
 *	@see			NGLSurfaceMulti
 */
@property (nonatomic, readonly) NGLSurfaceMulti *surface;

/*!
 *					This property indicates if the final mesh will be centralized to the position 0,0,0
 *					or not. This property doesn't interfere in the parse process. So you can change it
 *					a couple of times.
 *
 *					It's important to remember that by centralizing the mesh you will eventually lose the
 *					original pivot of the object and a new pivot will be created in the center of
 *					the object.
 *
 *					The default value is NO.
 */
@property (nonatomic) BOOL autoCentralize;

/*!
 *					This property indicates if the final mesh will have the vertices' values normalized
 *					to a specific range. This property doesn't interfere in the parse process. So you can
 *					change it many times. The value of this property defines the dimensions of a cube in
 *					which the final mesh will be bound.
 *
 *					For example, if you specify 1.0, the mesh will be bound into the center of a cube of
 *					dimensions 1.0 x 1.0 x 1.0.
 *					So the minimum and maximum value to X axis will be -0.5 and 0.5, respectively.
 *
 *					If 0.0 is set to this property, the normalization will not happen.
 *
 *					The default value is 0.0.
 */
@property (nonatomic) float autoNormalize;

/*!
 *					Initialize loading and parsing a new 3D file.
 *
 *					The file will be searched using the NinevehGL Path API.
 *
 *	@param			named
 *					In NinevehGL the "named" parameter is always related to the NinevehGL Path API, so you
 *					can inform the only the file's name or full path. The full path is related to the file
 *					system. If only the file's name is informed, NinevehGL will search for the file at the
 *					global path.
 *
 *	@result			A new initialized instance.
 */
- (id) initWithFile:(NSString *)named;

/*!
 *					Loads and parses a new 3D file.
 *
 *					The file will be searched using the NinevehGL Path API.
 *
 *	@param			named
 *					In NinevehGL the "named" parameter is always related to the NinevehGL Path API, so you
 *					can inform the only the file's name or full path. The full path is related to the file
 *					system. If only the file's name is informed, NinevehGL will search for the file at the
 *					global path.
 */
- (void) loadFile:(NSString *)named;

/*!
 *					Defines all the necessary structure, OpenGL friendly structure.
 *
 *					This method should be called by all parsing class which extends the superclass
 *					NGLParserMesh. Specifically, this call should happen after parsing the brute
 *					3D information from the file. Brute information are: vertices, texture coordinates,
 *					normals and faces.
 *
 *					This method will create all the arrays necessaries to OpenGL. Besides it calculates
 *					the tangent space.
 */
- (void) defineStructure;

/*!
 *					Stops the loading/parsing process. Cancelling the process is not immediately, it can
 *					take one more cycle (NGL_CYCLE) to release all the allocated memory.
 */
- (void) cancelLoading;

@end