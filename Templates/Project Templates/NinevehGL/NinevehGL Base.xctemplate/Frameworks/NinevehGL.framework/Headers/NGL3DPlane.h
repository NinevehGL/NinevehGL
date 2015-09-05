/*
 *	NGL3DPlane.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *	Created by Diney Bomfim on 11/18/11.
 *	Copyright (c) 2010 DB-Interactively. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import "NGLMesh.h"

// Cube
// Sphere
// Cylinder
// Cone
// Teapot
// Torus

@interface NGL3DPlane : NGLMesh
{
@private
	/*
	unsigned int			*_indices;
	float					*_structures;
	unsigned int			_iCount;
	unsigned int			_sCount;
	NGLMeshElements			*_meshElements;
	NGLbox					_boundingBox;
	*/
}
/*
@property (nonatomic, readonly) unsigned int indicesCount;
@property (nonatomic, readonly) unsigned int structuresCount;
@property (nonatomic, readonly) unsigned int *indices;
@property (nonatomic, readonly) float *structures;
@property (nonatomic, readonly) NGLMeshElements *meshElements;
@property (nonatomic, readonly) NGLbox boundingBox;
*/
- (id) initWithPlane:(NGLvec3)size segments:(NGLivec2)segments;

@end