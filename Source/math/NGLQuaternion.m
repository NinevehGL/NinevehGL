/*
 *	NGLQuaternion.m
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *	Created by Diney Bomfim on 11/7/10.
 *	Copyright (c) 2010 DB-Interactively. All rights reserved.
 */

#import "NGLQuaternion.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

// Basic vector to the axis X, Y and Z.
static const NGLvec3 kNGLAxis[3] = {{1.0f, 0.0f, 0.0f},{0.0f, 1.0f, 0.0f},{0.0f, 0.0f, 1.0f}};

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static NGLvec4 nglQuaternionMultiply(NGLvec4 qA, NGLvec4 qB)
{
	NGLvec4 q;
	
	// Quaternions multiplication's formula.
	q.w = qA.w * qB.w - qA.x * qB.x - qA.y * qB.y - qA.z * qB.z;
	q.x = qA.w * qB.x + qA.x * qB.w + qA.y * qB.z - qA.z * qB.y;
	q.y = qA.w * qB.y - qA.x * qB.z + qA.y * qB.w + qA.z * qB.x;
	q.z = qA.w * qB.z + qA.x * qB.y - qA.y * qB.x + qA.z * qB.w;
	
	return q;
}

static NGLvec4 nglQuaternionAdd(NGLvec4 qOriginal, NGLvec4 qNew, NGLAddMode mode)
{
	NGLvec4 q;
	
	switch (mode)
	{
			// Assumes the value of the new Quaternion.
		case NGLAddModeSet:
			q = qNew;
			break;
			// Multiplies the original Quaternion by the new one.
		case NGLAddModePrepend:
			q = nglQuaternionMultiply(qOriginal, qNew);
			break;
			// Multiplies the new Quaternion by the original one.
		case NGLAddModeAppend:
			q = nglQuaternionMultiply(qNew, qOriginal);
			break;
	}
	
	// Quaternions must be normalized.
	q = nglVec4Normalize(q);
	
	return q;
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLQuaternion

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@dynamic angle, axis, euler, matrix;

- (float) angle
{
	// Angles in Quaternion are in radians, so convert they to degrees.
	return nglRadiansToDegrees(acosf(_q.w) * 2.0f);
}

- (NGLvec3) axis
{
	NGLvec3 vec;
	float t = sqrtf(1.0f - _q.w * _q.w);
	
	// Avoids a division by 0.
	if (t != 0.0f)
	{
		vec.x = _q.x / t;
		vec.y = _q.y / t;
		vec.z = _q.z / t;
	}
	
	return vec;
}

- (NGLvec3) euler
{
	NGLvec3 euler;
	float pole = _q.x * _q.y + _q.z * _q.w;
	
	// Z coordinate is independent of the pole.
	euler.z = asinf(2.0f * roundf(pole * 100.0f) / 100.0f);
	
	// North pole.
	if (pole > 0.49f)
	{
		euler.y = 2.0f * atan2f(_q.x, _q.w);
		euler.x = 0.0f;
	}
	// South pole.
	else if (pole < -0.49f)
	{
		euler.y = -2.0f * atan2f(_q.x, _q.w);
		euler.x = 0.0f;
	}
	// Outside the poles.
	else
	{
		euler.y = atan2f(2.0f * (_q.y * _q.w - _q.x * _q.z), 1.0f - 2.0f * (_q.y * _q.y + _q.z * _q.z));
		euler.x = atan2f(2.0f * (_q.x * _q.w - _q.y * _q.z), 1.0f - 2.0f * (_q.x * _q.x + _q.z * _q.z));
	}
	
	// Values are in radians, converts them into degrees.
	euler.y = nglRadiansToDegrees(euler.y);
	euler.z = nglRadiansToDegrees(euler.z);
	euler.x = nglRadiansToDegrees(euler.x);
	
	return euler;
}

- (NGLmat4 *) matrix
{
	if(!_qCache)
	{
		// Fisrt Column
		_qMatrix[0] = 1.0f - 2.0f * (_q.y * _q.y + _q.z * _q.z);
		_qMatrix[1] = 2.0f * (_q.x * _q.y + _q.z * _q.w);
		_qMatrix[2] = 2.0f * (_q.x * _q.z - _q.y * _q.w);
		_qMatrix[3] = 0.0f;
		
		// Second Column
		_qMatrix[4] = 2.0f * (_q.x * _q.y - _q.z * _q.w);
		_qMatrix[5] = 1.0f - 2.0f * (_q.x * _q.x + _q.z * _q.z);
		_qMatrix[6] = 2.0f * (_q.z * _q.y + _q.x * _q.w);
		_qMatrix[7] = 0.0f;
		
		// Third Column
		_qMatrix[8] = 2.0f * (_q.x * _q.z + _q.y * _q.w);
		_qMatrix[9] = 2.0f * (_q.y * _q.z - _q.x * _q.w);
		_qMatrix[10] = 1.0f - 2.0f * (_q.x * _q.x + _q.y * _q.y);
		_qMatrix[11] = 0.0f;
		
		// Fourth Column
		_qMatrix[12] = 0.0f;
		_qMatrix[13] = 0.0f;
		_qMatrix[14] = 0.0f;
		_qMatrix[15] = 1.0f;
		
		_qCache = YES;
	}
	
	return &_qMatrix;
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
		[self identity];
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************


#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) identity
{
	_q.w = 1.0f;
	_q.x = 0.0f;
	_q.y = 0.0f;
	_q.z = 0.0f;
	
	_qCache = NO;
}

- (void) invert
{
	// Conjugate
	_q.x *= -1.0f;
	_q.y *= -1.0f;
	_q.z *= -1.0f;
	
	_q = nglVec4Normalize(_q);
	
	_qCache = NO;
}

- (void) rotateByAxis:(NGLvec3)vec angle:(float)degrees mode:(NGLAddMode)mode
{
	NGLvec4 q;
	
	// Converts the degrees angle to radians.
	float radians = nglDegreesToRadians(degrees);
	
	// Finds the Sin and Cosin for the half angle.
	float sin = sinf(radians * 0.5f);
	float cos = cosf(radians * 0.5f);
	
	// Multiplication formula to construct a Quaternion by axis.
	q.w = cos;
	q.x = vec.x * sin;
	q.y = vec.y * sin;
	q.z = vec.z * sin;
	
	// Adds the new quaternion to this quaternion instance with a specific mode.
	_q = nglQuaternionAdd(_q, q, mode);
	
	_qCache = NO;
}

- (void) rotateByEuler:(NGLvec3)vec mode:(NGLAddMode)mode
{
	NGLvec4 q;
	
	// Converts all degrees angles to radians.
	vec.y = nglDegreesToRadians(vec.y);
	vec.z = nglDegreesToRadians(vec.z);
	vec.x = nglDegreesToRadians(vec.x);
	
	// Finds the Sin and Cosin for each half angles.
	float sY = sinf(vec.y * 0.5f);
	float cY = cosf(vec.y * 0.5f);
	float sZ = sinf(vec.z * 0.5f);
	float cZ = cosf(vec.z * 0.5f);
	float sX = sinf(vec.x * 0.5f);
	float cX = cosf(vec.x * 0.5f);
	
	// Multiplication formula to construct a Quaternion by eulers.
	q.w = cY * cZ * cX - sY * sZ * sX;
	q.x = sY * sZ * cX + cY * cZ * sX;
	q.y = sY * cZ * cX + cY * sZ * sX;
	q.z = cY * sZ * cX - sY * cZ * sX;
	
	// Adds the new quaternion to this quaternion instance with a specific mode.
	_q = nglQuaternionAdd(_q, q, mode);
	
	_qCache = NO;
}

- (void) rotateByMatrix:(NGLmat4)mat mode:(NGLAddMode)mode
{
	NGLvec4 q;
	float trace = mat[0] + mat[5] + mat[10];
	float s4;
	
	if (trace > 0)
	{
		// The following line results in s4 = 4 * w.
		s4 = sqrtf(trace+ 1.0f) * 2.0f;
		q.w = 0.25f * s4;
		q.x = (mat[6] - mat[9]) / s4;
		q.y = (mat[8] - mat[2]) / s4;
		q.z = (mat[1] - mat[4]) / s4;
	}
	else if (mat[0] > mat[5] && mat[0] > mat[10])
	{
		// The following line results in s4 = 4 * qx.
		s4 = sqrtf(1.0f + mat[0] - mat[5] - mat[10]) * 2.0f;
		q.w = (mat[6] - mat[9]) / s4;
		q.x = 0.25f * s4;
		q.y = (mat[4] + mat[1]) / s4; 
		q.z = (mat[8] + mat[2]) / s4; 
	}
	else if (mat[5] > mat[10])
	{
		// The following line results in s4 = 4 * qy.
		s4 = sqrtf(1.0f + mat[5] - mat[0] - mat[10]) * 2.0f;
		q.w = (mat[8] - mat[2]) / s4;
		q.x = (mat[4] + mat[1]) / s4;
		q.y = 0.25f * s4;
		q.z = (mat[9] + mat[6]) / s4;
	}
	else
	{
		// The following line results in s4 = 4 * qz.
		s4 = sqrtf(1.0f + mat[5] - mat[0] - mat[10]) * 2.0f;
		q.w = (mat[1] - mat[4]) / s4;
		q.x = (mat[8] + mat[2]) / s4;
		q.y = (mat[9] + mat[6]) / s4;
		q.z = 0.25f * s4;
	}
	
	_q = nglQuaternionAdd(_q, q, mode);
	
	_qCache = NO;
}

- (void) rotateByQuaternionVector:(NGLvec4)quaternion mode:(NGLAddMode)mode
{
	_q = nglQuaternionAdd(_q, quaternion, mode);
	
	_qCache = NO;
}

- (void) rotateByAxesOrdered:(NGLRotationOrder)order angles:(NGLvec3)vec mode:(NGLAddMode)mode
{
	NGLvec4 q;
	NGLvec3 axis;
	float sin, cos, radians;
	
	// Using binaries, gets Rotation Order previously defined.
	int bit[3] = {order >> 16 & 0xFF, order >> 8 & 0xFF, order & 0xFF};
	float angle[3] = {vec.x, vec.y, vec.z};
	
	unsigned int i;
	unsigned int length = 3;
	for (i = 0; i < length; ++i)
	{
		axis = kNGLAxis[bit[i]];
		radians = nglDegreesToRadians(angle[bit[i]]);
		
		sin = sinf(radians * 0.5f);
		cos = cosf(radians * 0.5f);
		
		// Multiplication formula to construct a Quaternion by axis.
		q.w = cos;
		q.x = axis.x * sin;
		q.y = axis.y * sin;
		q.z = axis.z * sin;
		
		// Adds the new quaternion to this quaternion instance with a specific mode.
		_q = nglQuaternionAdd(_q, q, mode);
	}
	
	_qCache = NO;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (NSString *) description
{
	return [NSString stringWithFormat:@"NGLQuaternion :: {w:%f x:%f y:%f z:%f}", _q.w, _q.x, _q.y, _q.z];
}

@end