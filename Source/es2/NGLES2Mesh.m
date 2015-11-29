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

#import "NGLES2Mesh.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************


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

@interface NGLES2Mesh()

// Creates the buffer objects to the array of indices and array of structures.
- (void) createBuffers;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLES2Mesh

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize parent = _parent;

@dynamic isReady, loadedData;

- (BOOL) isReady { return _loadedData > 0.0; }

- (float) loadedData
{
	double data = _loadedData / _totalData;
	return (float)data;
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) initWithParent:(NGLMesh *)mesh
{
	if ((self = [super init]))
	{
		// Initialize a EAGLContext at the current thread. This one will be the first to create a
		// EAGLContext, which will share its sharegroup with all other contexts in NinevehGL.
		nglContextEAGL();
		
		// Settings.
		self.parent = mesh;
		_loadedData = 0.0;
		_totalData = 1.0;
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) createBuffers
{
	// TODO remove all this shit when iOS 6 comes out.
	//*
	void *indices;
	UInt32 dataSize;
	UInt16 *newData = NULL;
	
	if (nglDeviceSystemVersion() < NGL_IOS_5_0)
	{
		UInt32 *data = _parent.indices;
		UInt32 count = _parent.indicesCount;
		
		if (count > NGL_MAX_16)
		{
			count = NGL_MAX_16;
			NSLog(@"Exceeded max data type for iOS 4.");
			[NGLError errorInstantlyWithHeader:@"Error while processing NGLES2Mesh."
									andMessage:@"Exceeded the max data for iOS 4.x. (~120.000 faces).\
			 The iOS 5.x supports up to 4 billions faces."];
		}
		
		newData = malloc(count * NGL_SIZE_USHORT);
		
		UInt32 i;
		UInt32 length = count;
		for (i = 0; i < length; ++i)
		{
			newData[i] = (UInt16)data[i];
		}
		
		indices = newData;
		dataSize = NGL_SIZE_USHORT;
	}
	else
	{
		indices = _parent.indices;
		dataSize = NGL_SIZE_UINT;
	}
	
	// Creates a new IBO.
	[_buffers loadData:indices
				  size:_parent.indicesCount * dataSize
				  type:NGLES2BuffersTypeIndex
				 usage:NGLES2BuffersUsageStatic];
	
	// Creates a new VBO.
	[_buffers loadData:_parent.structures
				  size:_parent.structuresCount * NGL_SIZE_FLOAT
				  type:NGLES2BuffersTypeStructure
				 usage:NGLES2BuffersUsageStatic];
	
	nglFree(newData);
	/*/
	// Creates a new IBO.
	[_buffers loadData:_parent.indices
				  size:_parent.indicesCount * NGL_SIZE_UINT//UINT POINT
				  type:NGLES2BuffersTypeIndex
				 usage:NGLES2BuffersUsageStatic];
	
	// Creates a new VBO.
	[_buffers loadData:_parent.structures
				  size:_parent.structuresCount * NGL_SIZE_FLOAT
				  type:NGLES2BuffersTypeStructure
				 usage:NGLES2BuffersUsageStatic];
	//*/
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) defineBuffers
{
	nglContextEAGL();
	
	// Clears the old polygons.
	nglRelease(_polygons);
	_polygons = [[NGLArray alloc] initWithRetainOption];
	
	// Clears the old buffer objects.
	nglRelease(_buffers);
	_buffers = [[NGLES2Buffers alloc] init];
	
	// Creates the Buffer Objects.
	[self createBuffers];
	
	NGLMaterialMulti *mtlLib;
	NGLShadersMulti *shdLib;
	NGLSurfaceMulti *sufLib;
	
	NGLSurface *surface;
	UInt16 sufId;
	BOOL multiMtl = [_parent.material isKindOfClass:[NGLMaterialMulti class]];
	BOOL multiShd = [_parent.shaders isKindOfClass:[NGLShadersMulti class]];
	
	NGLES2Polygon *polygon;
	
	// First checks for Multi/Sub Libraries.
	mtlLib = (multiMtl) ? [[NGLMaterialMulti alloc] initWithMaterialKind:_parent.material] : nil;
	shdLib = (multiShd) ? [[NGLShadersMulti alloc] initWithShadersKind:_parent.shaders] : nil;
	sufLib = [[NGLSurfaceMulti alloc] initWithSurfaceKind:_parent.surface];
	
	// Avoiding empty multi-surface.
	if ([sufLib count] == 0)
	{
		[sufLib addSurface:[NGLSurface surface]];
	}
	
	// Monitoring uploading.
	_loadedData = 0.0;
	_totalData = (double)[sufLib count];
	
	// Takes the Multi/Sub Surface count, otherwise this mesh will work with only one polygon.
	for (surface in sufLib)
	{
		// Define the data length for the current surface, it can't be large than the mesh's data.
		surface.lengthData = MIN(surface.lengthData, _parent.indicesCount - surface.startData);
		
		// Get the current identifier, if the doesn't have a surface set the identifier to the default.
		sufId = surface.identifier;
		
		// Constructs a polygon and set its properties.
		// Except by the "parent", these properties could be nil at this point.
		polygon = [[NGLES2Polygon alloc] init];
		
		// Compiles the current polygon.
		[polygon compilePolygon:_parent
					   material:(multiMtl) ? [mtlLib materialWithIdentifier:sufId] : _parent.material
						shaders:(multiShd) ? [shdLib shadersWithIdentifier:sufId] : _parent.shaders
						surface:surface];
		
		// Commiting changes to the OpenGL server.
		// This single instruction will update the render core,
		// then the NinevehGL render thread will be able to make render, even without finish the parser.
		glFlush();
		
		// Puts the polygon into the array of polygons.
		[_polygons addPointer:polygon];
		nglRelease(polygon);
		
		// Updates the loaded data.
		++_loadedData;
	}
	
	// Frees the memory.
	nglRelease(mtlLib);
	nglRelease(shdLib);
	nglRelease(sufLib);
}

- (void) clearBuffers
{
	_loadedData = 0;
	_totalData = 1;
	
	// Makes sure the current context is valid.
	nglContextEAGL();
	
	// Releases the buffers.
	nglRelease(_buffers);
	nglRelease(_polygons);
}

- (void) drawCoreMesh
{
	// Binds the ABO and IBO for this mesh.
	[_buffers bind];
	
	NGLES2Polygon *polygon;
    nglFor (polygon, _polygons)
	{
		[polygon drawPolygon];
	}
	
	// Unbid all BOs.
	[_buffers unbind];
}

- (void) drawTelemetry:(UInt32)telemetry
{
	NGLvec4 color = nglTelemetryIDToColor(telemetry);
	
	// Binds the ABO and IBO for this mesh.
	[_buffers bind];
	
	NGLES2Polygon *polygon;
	nglFor (polygon, _polygons)
	{
		[polygon drawPolygonTelemetry:color];
		
		color.b += kNGL_COLOR_UNIT;
	}
	
	// Unbid all BOs.
	[_buffers unbind];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	// IMPORTANT: clearBuffers must be called by the owner before in the same thread as defineBuffers was.
	
	[super dealloc];
}

@end