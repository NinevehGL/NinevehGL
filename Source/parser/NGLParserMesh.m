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

#import "NGLParserMesh.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

// By default, crease angle is ~ 80.
#define kCreaseAngle		0.2

static NSString *const MSH_MAX_UINT = @"Exceeded the maximum number of unique faces.\n\
NinevehGL supports up to 4.294.967.295 unique faces, almost 4.3 billions.\n\
The number of unique faces in your file should not exceed it.";

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


#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

// Checks the crease angle for the normal calculations.
// This function creates and divides the normals to a vertex recursively.
static UInt32 creaseAngle(UInt32 index,
								NGLvec3 vector,
								NGLvec3 **buffer,
								UInt32 *count,
								NSMutableDictionary *list)
{
	NSNumber *newIndex, *oldIndex;
	
	// Eliminates the NaN points.
	(*buffer)[index] = nglVec3Cleared((*buffer)[index]);
	
	// Checks if the informed normal vector is not zero.
	if (!nglVec3IsZero((*buffer)[index]))
	{
		// Calculates the cosine of the angle between the current normal vector and the
		// averaged normal in the buffer.
		float cos = nglVec3Dot(nglVec3Normalize(vector), nglVec3Normalize((*buffer)[index]));
		
		// If the cosine is greater than the crease angle, that means the current normal vector
		// forms an acceptable angle witht the averaged normal in the buffer. Otherwise, proceeds and
		// creates a new normal vector to the current triangle face.
		if (cos <= kCreaseAngle)
		{
			// Tries to retrieve an already buffered normal with the same bend.
			oldIndex = [NSNumber numberWithInt:index];
			newIndex = [list objectForKey:oldIndex];
			
			// If no buffer was found, create a new register to the current normal vector.
			if (newIndex == nil)
			{
				// Retrieves the new index and stores its value as a linked list to the old one.
				newIndex = [NSNumber numberWithInt:*count];
				[list setObject:newIndex forKey:oldIndex];
				index = [newIndex intValue];
				
				// Reallocates the buffer and set the new buffer value to zero, avoiding NaN.
				*buffer = realloc(*buffer, NGL_SIZE_VEC3 * ++*count);
				(*buffer)[index] = kNGLvec3Zero;
			}
			// Otherwise, repeat the process with the buffered value to check for new crease angles.
			else
			{
				index = creaseAngle([newIndex intValue], vector, buffer, count, list);
			}
		}
	}
	
	return index;
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NGLParserMesh()

// Initializes a new instance.
- (void) initialize;

// Per-Vertex post adjusts like: centralize, rescale and bouding box.
- (void) perVertexAdjusts;

// Defines the tangent space. Tangent Space includes the normals, which will be generated automatically
// if there is no normals on the file. Then tangents and bitangents will be generated if the mesh
// contains texture coordinates. The creation of Tangent Space is one of the most hard and expensive tasks.
- (void) defineTangentSpace;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLParserMesh

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize indicesCount = _iCount, structuresCount = _sCount, stride = _stride,
			indices = _indices, meshElements = _meshElements, material = _material, surface = _surface;

@dynamic loadedData, hasError, structures, autoCentralize, autoNormalize;

- (float) loadedData
{
	double data = (_loadedData / _totalData * 0.8) + (_parsedData / _totalParsedData * 0.2);
	return (float)data;
}

- (BOOL) hasError
{
	return _error.hadError || _canceled;
}

- (float *) structures
{
	if (!_aCache)
	{
		[self perVertexAdjusts];
	}
	
	return _adjusted;
}

- (BOOL) autoCentralize { return _autoCentralize; }
- (void) setAutoCentralize:(BOOL)value
{
	_autoCentralize = value;
	_aCache = NO;
}

- (float) autoNormalize { return _autoNormalize; }
- (void) setAutoNormalize:(float)value
{
	_autoNormalize = value;
	_aCache = NO;
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

- (id) initWithFile:(NSString *)named
{
	if ((self = [super init]))
	{
		[self initialize];
		
		[self loadFile:named];
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
	_meshElements = [[NGLMeshElements alloc] init];
	
	// If no material or surface, they will remain empty libraries.
	_material = [[NGLMaterialMulti alloc] init];
	_surface = [[NGLSurfaceMulti alloc] init];
	
	// Initialize the error API.
	_error = [[NGLError alloc] init];
	
	// Reseting.
	_indices = NULL;
	_structures = NULL;
	_adjusted = NULL;
	_canceled = NO;
	_aCache = NO;
	_autoCentralize = NO;
	_autoNormalize = 0.0f;
	_loadedData = _parsedData = 0;
	_totalData = _totalParsedData = 1;
}

- (void) perVertexAdjusts
{
	if (_adjusted == NULL)
	{
		// Prepares the adjusted array.
		// This duplication is necessary to optimize and keep flexible the post-adjusts on the structure.
		_adjusted = malloc(_sCount * NGL_SIZE_FLOAT);
		memcpy(_adjusted, _structures, _sCount * NGL_SIZE_FLOAT);
	}
	
	if (_autoCentralize || _autoNormalize > 0.0f)
	{
		int i, n;
		int stride = (_stride == 0) ? 1 : _stride;
		int length = _sCount;
		float vx, vy, vz;
		float scale;
		int startV = (*[_meshElements elementWithComponent:NGLComponentVertex]).start;
		NGLvec3 center;
		
		// Resets all the adjusts.
		vx = _structures[startV];
		vy = _structures[startV + 1];
		vz = _structures[startV + 2];
		_vMin = (NGLvec3){vx, vy, vz};
		_vMax = (NGLvec3){vx, vy, vz};
		
		for (i = 0; i < length; i += stride)
		{
			n = i + startV;
			
			vx = _structures[n];
			vy = _structures[n + 1];
			vz = _structures[n + 2];
			
			// Stores the minimum value for vertices coordinates.
			_vMin.x = (_vMin.x > vx) ? vx : _vMin.x;
			_vMin.y = (_vMin.y > vy) ? vy : _vMin.y;
			_vMin.z = (_vMin.z > vz) ? vz : _vMin.z;
			
			// Stores the maximum value for vertices coordinates.
			_vMax.x = (_vMax.x < vx) ? vx : _vMax.x;
			_vMax.y = (_vMax.y < vy) ? vy : _vMax.y;
			_vMax.z = (_vMax.z < vz) ? vz : _vMax.z;
		}
		
		// Calculates the object's center.
		_vCen.x = (_vMax.x + _vMin.x) * 0.5f;
		_vCen.y = (_vMax.y + _vMin.y) * 0.5f;
		_vCen.z = (_vMax.z + _vMin.z) * 0.5f;
		
		// Sets the scale factor based on the largest axis range, if needed.
		scale = _autoNormalize / MAX(MAX((_vMax.x - _vMin.x),(_vMax.y - _vMin.y)),(_vMax.z - _vMin.z));
		scale = (_autoNormalize > 0.0f) ? scale : 1.0f;
		
		// Sets the object's center, if needed.
		center = (_autoCentralize) ? _vCen : kNGLvec3Zero;
		
		//*************************
		//	Auto Adjusts
		//*************************
		for (i = 0; i < length; i += stride)
		{
			n = i + startV;
			
			_adjusted[n] = (_structures[n] - center.x) * scale;
			_adjusted[n + 1] = (_structures[n + 1] - center.y) * scale;
			_adjusted[n + 2] = (_structures[n + 2] - center.z) * scale;
		}
	}
	
	_aCache = YES;
}

- (void) defineTangentSpace
{
	UInt32 i, length;
	UInt32 j, lengthJ;
	
	UInt32 *newFaces, *outFaces;
	UInt32 oldFaceStride = _facesStride;
	
	int i1, i2, i3;
	int vi1, vi2, vi3;
	int ti1, ti2, ti3;
	
	NGLvec3 vA, vB, vC;
	NGLvec2 tA, tB, tC;
	NGLvec3 distBA, distCA;
	NGLvec2 tdistBA, tdistCA;
	
	NGLvec3 normal;
	NGLvec3 tangent;
	NGLvec3 bitangent;
	
	NGLvec3 *normalBuffer;
	NGLvec3 *tangentBuffer;
	NGLvec3 *bitangentBuffer;
	
	NSMutableDictionary *multiples;
	
	NGLElement *element;
	int vLength, vOffset;
	int nLength, nOffset;
	int tLength, tOffset;
	
	float area, delta;
	float *outValue;
	
	// Checks if the parsed mesh has Normals and Texture Coordinates.
	BOOL hasNormals = ([_meshElements elementWithComponent:NGLComponentNormal] != NULL);
	BOOL hasTextures = ([_meshElements elementWithComponent:NGLComponentTexcoord] != NULL);
	
	// Gets the vertex element.
	element = [_meshElements elementWithComponent:NGLComponentVertex];
	vLength = (*element).length;
	vOffset = (*element).offsetInFace;
	
	// If the normal element doesn't exist yet, creates a new one.
	// Reserve an unique slot for normals.
	if (!hasNormals)
	{
		[_meshElements addElement:(NGLElement){NGLComponentNormal, _stride, 3, _facesStride++}];
		_stride += 3;
	}
	
	// Gets the normal element.
	element = [_meshElements elementWithComponent:NGLComponentNormal];
	nLength = (*element).length;
	nOffset = (*element).offsetInFace;
	
	// If the texture coordinate element exist, gets it and create tangent and bitangent element.
	// Reserve an unique slots for tangent and bitangent.
	if (hasTextures)
	{
		element = [_meshElements elementWithComponent:NGLComponentTexcoord];
		tLength = (*element).length;
		tOffset = (*element).offsetInFace;
		
		[_meshElements addElement:(NGLElement){NGLComponentTangent, _stride, 3, _facesStride++}];
		_stride += 3;
		
		[_meshElements addElement:(NGLElement){NGLComponentBitangent, _stride, 3, _facesStride++}];
		_stride += 3;
	}
	
	// Allocates memory to the new faces.
	newFaces = malloc(NGL_SIZE_INT * (_facesCount * _facesStride));
	
	// A priori, assumes that for each vertex exists only one normal.
	_nCount = _taCount = _biCount = _vCount;
	
	// Initializes the buffers for the tangent space elements.
	// Must use calloc to generate 0 (zero) values, otherwise NaN values can be generated.
	normalBuffer = calloc(_nCount, NGL_SIZE_VEC3);
	tangentBuffer = calloc(_taCount, NGL_SIZE_VEC3);
	bitangentBuffer = calloc(_biCount, NGL_SIZE_VEC3);
	
	// Initializes the dictionaries to deal with vertices with multiple normals.
	multiples = [[NSMutableDictionary alloc] init];
	
	// Loop through each triangle.
	length = _facesCount;
	for (i = 0; i < length; i += 3, _parsedData += 3)
	{
		// Canceled status.
		if (_canceled)
		{
			break;
		}
		
		// Triangle Vertices. At this moment _faces is an ordered list of elements' indices:
		// iv1, it1, in1, iv2, in2, it2, iv3, it3, in3...
		//  |			   |			  |
		//  V			   V			  V
		// iv1,			  iv2,			 iv3
		// So the following lines will extract the indices of vertices that form a triangle.
		i1 = _faces[i * oldFaceStride + vOffset];
		i2 = _faces[(i + 1) * oldFaceStride + vOffset];
		i3 = _faces[(i + 2) * oldFaceStride + vOffset];
		
		// Calculates the vertex indices in the array of vertices.
		vi1 = i1 * vLength;
		vi2 = i2 * vLength;
		vi3 = i3 * vLength;
		
		// Retrieves 3 vertices from the array of vertices.
		vA = (NGLvec3){_vertices[vi1], _vertices[vi1 + 1], _vertices[vi1 + 2]};
		vB = (NGLvec3){_vertices[vi2], _vertices[vi2 + 1], _vertices[vi2 + 2]};
		vC = (NGLvec3){_vertices[vi3], _vertices[vi3 + 1], _vertices[vi3 + 2]};
		
		// Calculates the vector of the edges, the distance between the vertices.
		distBA = nglVec3Subtract(vB, vA);
		distCA = nglVec3Subtract(vC, vA);
		
		//*************************
		//	Normals
		//*************************
		if (!hasNormals)
		{
			// Calculates the face normal to the current triangle.
			normal = nglVec3Cross(distBA, distCA);
			
			// Searches for crease angles considering the adjacent triangles.
			// This function also initialize new blocks of memory to the buffer, setting them to 0 (zero).
			i1 = creaseAngle(i1, normal, &normalBuffer, &_nCount, multiples);
			i2 = creaseAngle(i2, normal, &normalBuffer, &_nCount, multiples);
			i3 = creaseAngle(i3, normal, &normalBuffer, &_nCount, multiples);
			
			// Averages the new normal vector with the oldest buffered.
			normalBuffer[i1] = nglVec3Add(normal, normalBuffer[i1]);
			normalBuffer[i2] = nglVec3Add(normal, normalBuffer[i2]);
			normalBuffer[i3] = nglVec3Add(normal, normalBuffer[i3]);
		}
		else
		{
			// If the parsed file has normals in it, retrieves their indices in the array of normals.
			vi1 = _faces[i * oldFaceStride + nOffset] * nLength;
			vi2 = _faces[(i + 1) * oldFaceStride + nOffset] * nLength;
			vi3 = _faces[(i + 2) * oldFaceStride + nOffset] * nLength;
			
			// Retrieves the normals.
			vA = (NGLvec3){_normals[vi1], _normals[vi1 + 1], _normals[vi1 + 2]};
			vB = (NGLvec3){_normals[vi2], _normals[vi2 + 1], _normals[vi2 + 2]};
			vC = (NGLvec3){_normals[vi3], _normals[vi3 + 1], _normals[vi3 + 2]};
			
			// Calculates the face normal to the current triangle.
			normal = nglVec3Add(nglVec3Add(vA, vB), vC);
		}
		
		//*************************
		//	Tangent Space
		//*************************
		if (hasTextures)
		{
			// The crease angle process produces splits on the per-vertex normals, as the tangent space
			// must be orthogonalized, the tangent and bitanget follow those splits.
			if (_nCount > _taCount)
			{
				// Normals, Tangents and Bitangents buffers will always have the same number of elements.
				tangentBuffer = realloc(tangentBuffer, NGL_SIZE_VEC3 * _nCount);
				bitangentBuffer = realloc(bitangentBuffer, NGL_SIZE_VEC3 * _nCount);
				
				// Setting the brand new buffers to 0 (zero).
				lengthJ = _nCount;
				for (j = _taCount - 1; j < lengthJ; ++j)
				{
					tangentBuffer[j] = kNGLvec3Zero;
					bitangentBuffer[j] = kNGLvec3Zero;
				}
				
				_taCount = _biCount = _nCount;
			}
			
			// Retrieves texture coordinate indices.
			ti1 = _faces[i * oldFaceStride + tOffset] * tLength;
			ti2 = _faces[(i + 1) * oldFaceStride + tOffset] * tLength;
			ti3 = _faces[(i + 2) * oldFaceStride + tOffset] * tLength;
			
			// Retrieves the texture coordinates.
			tA = (NGLvec2){_texcoords[ti1], _texcoords[ti1 + 1]};
			tB = (NGLvec2){_texcoords[ti2], _texcoords[ti2 + 1]};
			tC = (NGLvec2){_texcoords[ti3], _texcoords[ti3 + 1]};
			
			// Calculates the vector of the texture coordinates edges, the distance between them.
			tdistBA = nglVec2Subtract(tB, tA);
			tdistCA = nglVec2Subtract(tC, tA);
			
			// Calculates the triangle's area.
			area = tdistBA.x * tdistCA.y - tdistBA.y * tdistCA.x;
			
			//*************************
			//	Tangent
			//*************************
			if (area == 0.0f)
			{
				tangent = kNGLvec3Zero;
			}
			else
			{
				delta = 1.0f / area;
				
				// Calculates the face tangent to the current triangle.
				tangent.x = delta * ((distBA.x * tdistCA.y) + (distCA.x * -tdistBA.y));
				tangent.y = delta * ((distBA.y * tdistCA.y) + (distCA.y * -tdistBA.y));
				tangent.z = delta * ((distBA.z * tdistCA.y) + (distCA.z * -tdistBA.y));
			}
			
			// Averages the new tagent vector with the oldest buffered.
			tangentBuffer[i1] = nglVec3Add(tangent, tangentBuffer[i1]);
			tangentBuffer[i2] = nglVec3Add(tangent, tangentBuffer[i2]);
			tangentBuffer[i3] = nglVec3Add(tangent, tangentBuffer[i3]);
			
			//*************************
			//	Bitangent
			//*************************
			// Calculates the face bitangent to the current triangle,
			// completing the orthogonalized tangent space.
			bitangent = nglVec3Cross(normal, tangent);
			
			// Averages the new bitangent vector with the oldest buffered.
			bitangentBuffer[i1] = nglVec3Add(bitangent, bitangentBuffer[i1]);
			bitangentBuffer[i2] = nglVec3Add(bitangent, bitangentBuffer[i2]);
			bitangentBuffer[i3] = nglVec3Add(bitangent, bitangentBuffer[i3]);
		}
		
		// Copies the oldest face indices and inserts the new created indices.
		outFaces = newFaces + (i * _facesStride);
		lengthJ = _facesStride;
		for (j = 0; j < lengthJ; ++j)
		{
			*outFaces++ = (j < oldFaceStride) ? _faces[i * oldFaceStride + j] : i1;
		}
		
		outFaces = newFaces + ((i + 1) * _facesStride);
		for (j = 0; j < lengthJ; ++j)
		{
			*outFaces++ = (j < oldFaceStride) ? _faces[(i + 1) * oldFaceStride + j] : i2;
		}
		
		outFaces = newFaces + ((i + 2) * _facesStride);
		for (j = 0; j < lengthJ; ++j)
		{
			*outFaces++ = (j < oldFaceStride) ? _faces[(i + 2) * oldFaceStride + j] : i3;
		}
	}
	
	// Commits the changes for the original array of faces. At this time, it could looks like:
	// iv1, it1, in1, ita1, ibt1, iv2, it2, in2, ita2, ibt2,...
	_faces = realloc(_faces, NGL_SIZE_INT * (_facesCount * _facesStride));
	memcpy(_faces, newFaces, NGL_SIZE_INT * (_facesCount * _facesStride));
	
	// Reallocates the memory for the array of normals, if needed. 
	if (!hasNormals)
	{
		_normals = realloc(_normals, NGL_SIZE_VEC3 * _nCount);
	}
	
	// Reallocates the memory for the array of tangents and array of bitangents, if needed.
	if (hasTextures)
	{
		_tangents = realloc(_tangents, NGL_SIZE_VEC3 * _taCount);
		_bitangents = realloc(_bitangents, NGL_SIZE_VEC3 * _biCount);
	}
	
	// Loops through all new values of the tangent space, normalizing all the averaged vectors.
	length = _nCount;
	for (i = 0; i < length; i++)
	{
		// Puts the new normals, if needed.
		if (!hasNormals)
		{
			normal = nglVec3Normalize(normalBuffer[i]);
			outValue = _normals + (i * 3);
			*outValue++ = normal.x;
			*outValue++ = normal.y;
			*outValue = normal.z;
		}
		
		// Puts the new tangent and bitangent, if needed.
		// Isn't necessary here the Gram–Schmidt Orthogonalization process, because all the vectors
		// of the tangent space are already orthogonalized in reason of the crease angle approach.
		if (hasTextures)
		{
			tangent = nglVec3Normalize(tangentBuffer[i]);
			bitangent = nglVec3Normalize(bitangentBuffer[i]);
			
			outValue = _tangents + (i * 3);
			*outValue++ = tangent.x;
			*outValue++ = tangent.y;
			*outValue = tangent.z;
			
			outValue = _bitangents + (i * 3);
			*outValue++ = bitangent.x;
			*outValue++ = bitangent.y;
			*outValue = bitangent.z;
		}
	}
	
	// Frees the memories.
	nglFree(newFaces);
	nglFree(normalBuffer);
	nglFree(tangentBuffer);
	nglFree(bitangentBuffer);
	
	nglRelease(multiples);
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) loadFile:(NSString *)named
{
	// Does nothing here, just to override.
}

- (void) defineStructure
{
	UInt32 i, lengthI;
	UInt32 j, lengthJ;
	UInt32 index, faceIndex;
	
	NGLElement *element;
	UInt32 eIndex, eStart;
	float *eValue;
	
	float *outStructure;
	UInt32 *outIndex;
	
	char *faceData;
	char *faceCString;
	NSNumber *indexNum;
	NSString *faceString;
	NSMutableDictionary *faceProcessed;
	
	// Parsing data will loop through the faces twice:
	// when defining the tangent space and when creating the structure.
	// Both loops increase the parsed data in your loop routines.
	_parsedData = 0;
	_totalParsedData = _facesCount * 2;
	
	// Calculates the tangent space.
	[self defineTangentSpace];
	
	// Allocates the necessary memory to deal with unique faces.
	faceData = malloc(NGL_SIZE_CHAR * 64);
	faceCString = malloc(NGL_SIZE_CHAR * 64);
	faceProcessed = [[NSMutableDictionary alloc] init];
	
	// The final size of the array of structures can't be calculated now,
	// but the array of indices has the same length of mesh's vertices.
	_sCount = 0;
	_iCount = _facesCount;
	
	// Reallocates the array of indices.
	_indices = realloc(_indices, _iCount * NGL_SIZE_UINT);
	outIndex = _indices;
	
	// Loops through each mesh's vertex.
	lengthI = _facesCount;
	for (i = 0; i < lengthI; ++i, ++_parsedData)
	{
		// Canceled status.
		if (_canceled)
		{
			break;
		}
		
		faceIndex = i * _facesStride;
		memset(faceCString, 0, NGL_SIZE_POINTER);
		
		// Creates a string representing the face using only the valid elements to avoid faces with 
		// unreferenced elements. Nevertheless, the string could have coincidences like 11 1 and 1 11.
		// To avoid that, it's necessary to add a slash: 11/1 and 1/11 is now different.
		while ((element = [_meshElements nextIterator]))
		{
			sprintf(faceData, "%i/", (unsigned int)_faces[faceIndex + (*element).offsetInFace]);
			strcat(faceCString, faceData);
		}
		
		//TODO find a faster way to check the faces. VERY EXPENSIVE
		// Looking for the same face string in the processed list.
		faceString = [NSString stringWithCString:faceCString encoding:NSUTF8StringEncoding];
		indexNum = [faceProcessed objectForKey:faceString];
		
		// Processes new faces.
		if (indexNum == nil)
		{
			// Adds the new face string.
			index = (UInt32)[faceProcessed count];
			[faceProcessed setObject:[NSNumber numberWithUnsignedInt:index] forKey:faceString];
			
			// Reallocates the array of structures and sets a pointer to the following process.
			_structures = realloc(_structures, (_sCount + _stride) * NGL_SIZE_FLOAT);
			outStructure = _structures + _sCount;
			
			while ((element = [_meshElements nextIterator]))
			{
				// Retrieves the element index in the array of faces.
				eIndex = _faces[faceIndex + (*element).offsetInFace];
				eStart = (*element).start;
				
				// Sets the pointer to correct original array.
				switch ((*element).component)
				{
					case NGLComponentVertex:
						eValue = _vertices + (eIndex * (*element).length);
						break;
					case NGLComponentTexcoord:
						eValue = _texcoords + (eIndex * (*element).length);
						break;
					case NGLComponentNormal:
						eValue = _normals + (eIndex * (*element).length);
						break;
					case NGLComponentTangent:
						eValue = _tangents + (eIndex * (*element).length);
						break;
					case NGLComponentBitangent:
						eValue = _bitangents + (eIndex * (*element).length);
						break;
				}
				
				// Copies the values from original array to the array of structure.
				lengthJ = (*element).length;
				for (j = 0; j < lengthJ; ++j)
				{
					outStructure[eStart + j] = *eValue++;
					++_sCount;
				}
			}
		}
		// If the face was already processed, skips it.
		else
		{
			index = [indexNum unsignedIntValue];
		}
		
		// Copies the array of structure's index to the array of indices.
		*outIndex++ = index;
	}
	
	// Checks for the maximum unique faces.
	if ([faceProcessed count] > NGL_MAX_32)
	{
		_error.message = MSH_MAX_UINT;
	}
	 
	[_error showError];
	
	// Frees the memories
	nglFree(faceCString);
	nglFree(faceData);
	
	nglRelease(faceProcessed);
}

- (void) cancelLoading
{
	_canceled = YES;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	nglFree(_indices);
	nglFree(_structures);
	nglFree(_adjusted);
	
	nglFree(_tangents);
	nglFree(_bitangents);
	
	nglRelease(_meshElements);
	nglRelease(_material);
	nglRelease(_surface);
	nglRelease(_error);
	
	[super dealloc];
}

@end