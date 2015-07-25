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
