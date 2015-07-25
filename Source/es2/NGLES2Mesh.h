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
#import "NGLVector.h"
#import "NGLMesh.h"
#import "NGLCoreMesh.h"
#import "NGLArray.h"

#import "NGLES2Functions.h"
#import "NGLES2Buffers.h"
#import "NGLES2Polygon.h"

@class NGLES2Polygon;

/*!
 *					<strong>(Internal only)</strong> It's the bridge between #NGLMesh# and the
 *					OpenGL ES 2 API.
 *
 *					NGLES2Mesh is like an extension of the #NGLMesh#'s job. This class is responsible for
 *					creating and designating each mesh's polygon. A polygon is defined by the #NGLSurface#
 *					and is usually associated with a specific usage of a Shader Program.
 *
 *					Besides, this class is responsible for sending the array of structure and array of
 *					indices to appropriated buffers. The buffers are given by OpenGL ES 2 API and stores the
 *					mesh data in an optimized format to the GPU.
 *
 *	@see			NGLMesh
 *	@see			NGLSurface
 *	@see			NGLES2Buffers
 *	@see			NGLES2Polygon
 */
@interface NGLES2Mesh : NSObject <NGLCoreMesh>
{
@private
	NGLMesh					*_parent;
	NGLES2Buffers			*_buffers;
	NGLArray				*_polygons;
	
	// Monitor
	double					_loadedData;
	double					_totalData;
}

@end