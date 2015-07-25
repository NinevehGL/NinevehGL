/*
 *	NGLBoundingBox.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *  Created by Diney Bomfim on 9/29/10.
 *  Copyright (c) 2010 DB-Interactively. All rights reserved.
 */

#import "NGLRuntime.h"
#import "NGLDataType.h"
#import "NGLVector.h"
#import "NGLMatrix.h"

/*!
 *					Fills the "volume" attribute of a bounding box structure as is advised by NGLbox.
 *
 *	@param			box
 *					The bounding box pointer. The pointed variable will receive the values.
 *
 *	@param			bounds
 *					The bounds that will delimiter the bounding box's volume.
 *
 *	@see			NGLBoundingBox
 *	@see			NGLbounds
 */
NGL_API void nglBoundingBoxDefine(NGLBoundingBox *box, NGLbounds bounds);

/*!
 *					Fills the "aligned" attribute of a bounding box structure.
 *
 *	@param			box
 *					The bounding box pointer. The pointed variable will receive the values.
 *
 *	@param			matrix
 *					A transformation matrix that will transform the original bounding box's volume.
 *
 *	@see			NGLBoundingBox
 *	@see			NGLmat4
 */
NGL_API void nglBoundingBoxAABB(NGLBoundingBox *box, NGLmat4 matrix);

/*!
 *					Checks if two bouding boxes are touching their selves.
 *
 *	@param			boxA
 *					The first bounding box.
 *
 *	@param			boxB
 *					The seconds bounding box.
 *
 *	@see			NGLBoundingBox
 */
NGL_API BOOL nglBoundingBoxCollision(NGLBoundingBox boxA, NGLBoundingBox boxB);

/*!
 *					Checks if a ray instersects a bounding box.
 *
 *	@param			box
 *					The bounding box.
 *
 *	@param			ray
 *					A NGLray representing the ray that tries to cross the box.
 *
 *	@see			NGLBoundingBox
 */
NGL_API BOOL nglBoundingBoxCollisionWithRay(NGLBoundingBox box, NGLray ray);

/*!
 *					Describes a bounding box.
 *
 *					A user friendly representation will be shown on console panel. The representation
 *					will be like this:
 *
 *					<pre>
 *					                             Volume
 *					
 *					                       1 +------------+ 2
 *					                        /|           /|
 *					                       / |          / |       0 =
 *					                      /  |         /  |       1 =
 *					                     /   |        /   |       2 =
 *					                  5 +------------+ 6  |       3 =
 *					                    |    |       |    |       4 =
 *					                    |  0 +-------|----+ 3     5 =
 *					                    |   /        |   /        6 =
 *					        +y          |  /         |  /         7 =
 *					        |  -z       | /          | /                
 *					        |  /      4 +/-----------+/ 7               
 *					        | /                                         
 *					 -x ____|/_____ +x                           
 *					        |              Aligned (AABB)               
 *					       /|                                          
 *					      / |            +---------------+            
 *					     /  |           /|              /|       MIN:
 *					    +z  -y         / |             / |        X =
 *					                  /  |            /  |        y =
 *					                 /   |           /   |        z =
 *					                +---------------+    |              
 *					                |    |          |    |       MAX:   
 *					                |    +----------|----+        X =
 *					                |   /           |   /         Y =
 *					                |  /            |  /          Z =
 *					                | /             | /
 *					                +/--------------+/
 *					</pre>
 *	
 *	@param			original
 *					The matrix to be described.
 */
NGL_API void nglBoundingBoxDescribe(NGLBoundingBox box);
