/*
 *	NGLBoundingBox.m
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

#import "NGLBoundingBox.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define kNGL_VERTEX_COUNT		3

typedef enum
{
	NGLRayAtLeft,
	NGLRayAtRight,
	NGLRayAtMiddle,
} NGLRayAt;

#pragma mark -
#pragma mark Fixed Functions
#pragma mark -
//**********************************************************************************************************
//
//  Fixed Functions
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Construction Functions
//**************************************************
//	Construction Functions
//**************************************************

void nglBoundingBoxDefine(NGLBoundingBox *box, NGLbounds bounds)
{
	NGLvec3 vMin = bounds.min, vMax = bounds.max;
	
	// The original Volume.
	(*box).volume[0] = (NGLvec3){ vMin.x, vMin.y, vMin.z };
	(*box).volume[1] = (NGLvec3){ vMin.x, vMax.y, vMin.z };
	(*box).volume[2] = (NGLvec3){ vMax.x, vMax.y, vMin.z };
	(*box).volume[3] = (NGLvec3){ vMax.x, vMin.y, vMin.z };
	(*box).volume[4] = (NGLvec3){ vMin.x, vMin.y, vMax.z };
	(*box).volume[5] = (NGLvec3){ vMin.x, vMax.y, vMax.z };
	(*box).volume[6] = (NGLvec3){ vMax.x, vMax.y, vMax.z };
	(*box).volume[7] = (NGLvec3){ vMax.x, vMin.y, vMax.z };
	
	// The current Bounds.
	(*box).aligned = bounds;
}

void nglBoundingBoxAABB(NGLBoundingBox *box, NGLmat4 matrix)
{
	NGLvec3 vMin, vMax, vertex;
	NGLbox boxStructure;
	
	unsigned short i;
	unsigned short length = 8;
	for (i = 0; i < length; ++i)
	{
		boxStructure[i] = nglVec3ByMatrix((*box).volume[i], matrix);
	}
	
	vertex = boxStructure[0];
	vMin = vertex;
	vMax = vertex;
	
	for (i = 1; i < length; ++i)
	{
		vertex = boxStructure[i];
		
		// Stores the minimum value for vertices coordinates.
		vMin.x = (vMin.x > vertex.x) ? vertex.x : vMin.x;
		vMin.y = (vMin.y > vertex.y) ? vertex.y : vMin.y;
		vMin.z = (vMin.z > vertex.z) ? vertex.z : vMin.z;
		
		// Stores the maximum value for vertices coordinates.
		vMax.x = (vMax.x < vertex.x) ? vertex.x : vMax.x;
		vMax.y = (vMax.y < vertex.y) ? vertex.y : vMax.y;
		vMax.z = (vMax.z < vertex.z) ? vertex.z : vMax.z;
	}
	
	(*box).aligned.min = vMin;
	(*box).aligned.max = vMax;
}

#pragma mark -
#pragma mark Intersection Functions
//**************************************************
//	Intersection Functions
//**************************************************

BOOL nglBoundingBoxCollision(NGLBoundingBox boxA, NGLBoundingBox boxB)
{
	BOOL isColliding = NO;
	NGLbounds boundsA = boxA.aligned, boundsB = boxB.aligned;
	
	if (boundsA.min.x < boundsB.max.x && boundsA.max.x > boundsB.min.x &&
		boundsA.min.y < boundsB.max.x && boundsA.max.y > boundsB.min.y &&
		boundsA.min.z < boundsB.max.y && boundsA.max.z > boundsB.min.z)
	{
		isColliding = YES;
	}
	
	return isColliding;
}

BOOL nglBoundingBoxCollisionWithRay(NGLBoundingBox box, NGLray ray)
{
	float aabbMin[kNGL_VERTEX_COUNT] = { box.aligned.min.x, box.aligned.min.y, box.aligned.min.z };
	float aabbMax[kNGL_VERTEX_COUNT] = { box.aligned.max.x, box.aligned.max.y, box.aligned.max.z };
	float rayOrigin[kNGL_VERTEX_COUNT] = { ray.origin.x, ray.origin.y, ray.origin.z };
	float rayDirection[kNGL_VERTEX_COUNT] = { ray.direction.x, ray.direction.y, ray.direction.z };
	
	float coord[kNGL_VERTEX_COUNT];
	
	BOOL isInside = YES;
	char quadrant[kNGL_VERTEX_COUNT];
	
	float maxT[kNGL_VERTEX_COUNT];
	float candidatePlane[kNGL_VERTEX_COUNT];
	
	unsigned int i;
	unsigned int whichPlane;
	
	// Chooses the candidate planes for the intersection.
	// This single step eliminates 3 faces of the bounding box.
	for (i = 0; i < kNGL_VERTEX_COUNT; ++i)
	{
		if(rayOrigin[i] < aabbMin[i])
		{
			quadrant[i] = NGLRayAtLeft;
			candidatePlane[i] = aabbMin[i];
			isInside = NO;
		}
		else if (rayOrigin[i] > aabbMax[i])
		{
			quadrant[i] = NGLRayAtRight;
			candidatePlane[i] = aabbMax[i];
			isInside = NO;
		}
		else
		{
			quadrant[i] = NGLRayAtMiddle;
		}
	}
	
	// Ray origin inside bounding box
	if(isInside)
	{
		coord[0] = rayOrigin[0];
		coord[1] = rayOrigin[1];
		coord[2] = rayOrigin[2];
		return YES;
	}
	
	// Calculate T distances to candidate planes
	for (i = 0; i < kNGL_VERTEX_COUNT; ++i)
	{
		if (quadrant[i] != NGLRayAtMiddle && rayDirection[i] != 0.0f)
		{
			maxT[i] = (candidatePlane[i] - rayOrigin[i]) / rayDirection[i];
		}
		else
		{
			maxT[i] = -1.0f;
		}
	}
	
	// Get largest of the maxT's for final choice of intersection
	whichPlane = 0;
	for (i = 1; i < kNGL_VERTEX_COUNT; ++i)
	{
		if (maxT[whichPlane] < maxT[i])
		{
			whichPlane = i;
		}
	}
	
	// Check final candidate actually inside box
	if (maxT[whichPlane] < 0.0f)
	{
		return NO;
	}
	
	for (i = 0; i < kNGL_VERTEX_COUNT; ++i)
	{
		if (whichPlane != i)
		{
			coord[i] = rayOrigin[i] + maxT[whichPlane] * rayDirection[i];
			
			if (coord[i] < aabbMin[i] || coord[i] > aabbMax[i])
			{
				return NO;
			}
		}
		else
		{
			coord[i] = candidatePlane[i];
		}
	}
	
	//NSLog(@"COORDS: %f %f %f",coord[0],coord[1],coord[2]);
	
	// ray hits box
	return YES;
}

#pragma mark -
#pragma mark Auxiliary Functions
//**************************************************
//	Auxiliary Functions
//**************************************************

void nglBoundingBoxDescribe(NGLBoundingBox box)
{
	NSString *describe = [NSString stringWithFormat:@"\n\
                                                              \n\
                             Volume                           \n\
                                                              \n\
                      1 +------------+ 2                      \n\
                       /|           /|                        \n\
                      / |          / |       0 = { %f,%f,%f } \n\
                     /  |         /  |       1 = { %f,%f,%f } \n\
                    /   |        /   |       2 = { %f,%f,%f } \n\
                 5 +------------+ 6  |       3 = { %f,%f,%f } \n\
                   |    |       |    |       4 = { %f,%f,%f } \n\
                   |  0 +-------|----+ 3     5 = { %f,%f,%f } \n\
                   |   /        |   /        6 = { %f,%f,%f } \n\
	   +y          |  /         |  /         7 = { %f,%f,%f } \n\
       |  -z       | /          | /                           \n\
       |  /      4 +/-----------+/ 7                          \n\
       | /                                                    \n\
-x ____|/_____ +x                                             \n\
       |              Aligned (AABB)                          \n\
      /|                                                      \n\
     / |            +---------------+                         \n\
    /  |           /|              /|       MIN:              \n\
   +z  -y         / |             / |        X = %f           \n\
                 /  |            /  |        y = %f           \n\
                /   |           /   |        z = %f           \n\
               +---------------+    |                         \n\
               |    |          |    |       MAX:              \n\
               |    +----------|----+        X = %f           \n\
               |   /           |   /         Y = %f           \n\
               |  /            |  /          Z = %f           \n\
               | /             | /                            \n\
               +/--------------+/                             \n\
															  \n",
						  box.volume[0].x,box.volume[0].y,box.volume[0].z,
						  box.volume[1].x,box.volume[1].y,box.volume[1].z,
						  box.volume[2].x,box.volume[2].y,box.volume[2].z,
						  box.volume[3].x,box.volume[3].y,box.volume[3].z,
						  box.volume[4].x,box.volume[4].y,box.volume[4].z,
						  box.volume[5].x,box.volume[5].y,box.volume[5].z,
						  box.volume[6].x,box.volume[6].y,box.volume[6].z,
						  box.volume[7].x,box.volume[7].y,box.volume[7].z,
						  box.aligned.min.x,
						  box.aligned.min.y,
						  box.aligned.min.z,
						  box.aligned.max.x,
						  box.aligned.max.y,
						  box.aligned.max.z];
	
	NSLog(@"Describe BoundingBox:%@", describe);
}