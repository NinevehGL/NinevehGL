/*
 *	NGLES2Mesh.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *	Created by Diney Bomfim on 12/15/10.
 *	Copyright (c) 2010 DB-Interactively. All rights reserved.
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