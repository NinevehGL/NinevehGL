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

#import "NGLObject3D.h"

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

@interface NGLObject3D()

- (void) commitRotation;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLObject3D

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize tag = _tag, name = _name, rotationSpace = _rotationSpace, rotationOrder = _rotationOrder,
			pivot = _pivot, lookAtTarget = _lookAtTarget, group = _group;

@dynamic x, y, z, scaleX, scaleY, scaleZ, rotateX, rotateY, rotateZ, boundingBox, cachePointer,
		 position, scale, rotation, matrix, matrixOrtho;

- (float) x { return _position.x; }
- (void) setX:(float)value
{
	if (_position.x != value)
	{
		_position.x = value;
		_oCache = NO;
	}
}

- (float) y { return _position.y; }
- (void) setY:(float)value
{
	if (_position.y != value)
	{
		_position.y = value;
		_oCache = NO;
	}
}

- (float) z { return _position.z; }
- (void) setZ:(float)value
{
	if (_position.z != value)
	{
		_position.z = value;
		_oCache = NO;
	}
}

- (float) scaleX { return _scale.x; }
- (void) setScaleX:(float)value
{
	if (_scale.x != value)
	{
		_scale.x = value;
		_oCache = NO;
	}
}

- (float) scaleY { return _scale.y; }
- (void) setScaleY:(float)value
{
	if (_scale.y != value)
	{
		_scale.y = value;
		_oCache = NO;
	}
}

- (float) scaleZ { return _scale.z; }
- (void) setScaleZ:(float)value
{
	if (_scale.z != value)
	{
		_scale.z = value;
		_oCache = NO;
	}
}

- (float) rotateX { return _rotation.x; }
- (void) setRotateX:(float)value
{
	if (_rotation.x != value)
	{
		_rotation.x = value;
		_oCache = _rCache = NO;
	}
}

- (float) rotateY { return _rotation.y; }
- (void) setRotateY:(float)value
{
	if (_rotation.y != value)
	{
		_rotation.y = value;
		_oCache = _rCache = NO;
	}
}

- (float) rotateZ { return _rotation.z; }
- (void) setRotateZ:(float)value
{
	if (_rotation.z != value)
	{
		_rotation.z = value;
		_oCache = _rCache = NO;
	}
}

- (NGLBoundingBox) boundingBox
{
	// TODO make a bounding box cache.
	nglBoundingBoxAABB(&_boundingBox, *self.matrix);
	
	return _boundingBox;
}

- (BOOL *) cachePointer { return &_oCache; }

- (NGLvec3 *) position { return &_position; }

- (NGLvec3 *) scale { return &_scale; }

- (NGLvec3 *) rotation { return &_rotation; }

- (NGLmat4 *) matrix
{
	// Defines the matrix to rebase feature.
	// If there is a group, the used matrix will be that one changed by the group.
	NGLmat4 *toRebase = (_group != nil) ? &_matrixModel : &_oMatrix;
	
	// Processes the lookAt routine, if exist.
	if (_lookAtTarget != nil)
	{
		[self lookAtObject:_lookAtTarget];
	}
	
	if(!_oCache)
	{
		// Commit the final rotation to the quaternion.
		[self commitRotation];
		
		// Get the final rotation matrix from Quaternion.
		nglMatrixCopy(*_quat.matrix, _oMatrix);
		
		// The translation is added directly to produce the same effect as a Pre-Multiplication
		// of Translation Matrix by the Rotation Matrix. That means, the rotations will always
		// be calculated before start the object translation.
		
		// Fourth Column
		_oMatrix[12] = _position.x;
		_oMatrix[13] = _position.y;
		_oMatrix[14] = _position.z;
		
		// Calculates the pivot if necessary.
		if (!nglVec3IsZero(_pivot))
		{
			// The pivot concept is something which affects all the transformations
			// (rotations, scales and translations). So it should be the first transformations
			// in the transformations chain (which is Scales -> Rotations -> Translations).
			// However, the pivot just affect the Translation column, so recalculates the final
			// position of the object.
			
			_oMatrix[12] -= _oMatrix[0] * _pivot.x + _oMatrix[4] * _pivot.y + _oMatrix[8] * _pivot.z;
			_oMatrix[13] -= _oMatrix[1] * _pivot.x + _oMatrix[5] * _pivot.y + _oMatrix[9] * _pivot.z;
			_oMatrix[14] -= _oMatrix[2] * _pivot.x + _oMatrix[6] * _pivot.y + _oMatrix[10] * _pivot.z;
		}
		
		// At this point, the object matrix and the orthogonal matrix (rotation + translation) are equals.
		nglMatrixCopy(_oMatrix, _rtMatrix);
		
		// The scale is multiplied by each column to achieve the same effect as a Pre-Multiplication
		// of the Scale Matrix by the actual Object Matrix. This produces a local scale, independently
		// of other transformations. Besides, the rotation and translation coordinate system will not
		// be affected by the scale factor, they remain in world space.
		
		// Fisrt Column
		_oMatrix[0] *= _scale.x;
		_oMatrix[1] *= _scale.x;
		_oMatrix[2] *= _scale.x;
		
		// Second Column
		_oMatrix[4] *= _scale.y;
		_oMatrix[5] *= _scale.y;
		_oMatrix[6] *= _scale.y;
		
		// Third Column
		_oMatrix[8] *= _scale.z;
		_oMatrix[9] *= _scale.z;
		_oMatrix[10] *= _scale.z;
		
		// Defines the two final matrices: MODEL Matrix and MODEL Orthogonal Matrix.
		nglMatrixCopy(_oMatrix, _matrixModel);
		nglMatrixCopy(_rtMatrix, _matrixOrtho);
		
		_oCache = YES;
	}
	
	//TODO make the lookAt within groups (!!!)
	/*
	 if (_lookAtTarget != nil)
	 {
	 NGLvec3 posZ = nglVec3Normalize(*_lookAtTarget.position);
	 NGLvec3 posX = nglVec3Normalize(nglVec3Cross((NGLvec3){0.0,1.0,0.0}, posZ));
	 NGLvec3 posY = nglVec3Cross(posZ, posX);
	 NGLmat4 mat4 = {posX.x,posX.y,posX.z,0.0,
	 posY.x,posY.y,posY.z,0.0,
	 posZ.x,posZ.y,posZ.z,0.0,
	 0.0,0.0,0.0,1.0};
	 
	 nglMatrixMultiply(_oMatrix, mat4, _grMatrix);
	 return &_grMatrix;
	 }
	 //*/
	//*
	// Processing group instructions.
	if (_group != nil)
	{
		nglMatrixMultiply(*_group.matrix, _oMatrix, _matrixModel);
	}
	//*/
	
	// Processing rebase instructions.
	if (_isRebasing)
	{
		nglMatrixMultiply(_rebaseMatrix, *toRebase, _matrixModel);
	}
	
	return &_matrixModel;
}

- (NGLmat4 *) matrixOrtho
{
	// Defines the matrix to rebase feature.
	// If there is a group, the used matrix will be that one changed by the group.
	NGLmat4 *toRebase = (_group != nil) ? &_matrixOrtho : &_rtMatrix;
	
	if(!_oCache)
	{
		[self matrix];
	}
	
	// Processing group instructions.
	if (_group != nil)
	{
		nglMatrixMultiply(*_group.matrixOrtho, _rtMatrix, _matrixOrtho);
	}
	
	// Processing rebase instructions.
	if (_isRebasing)
	{
		nglMatrixMultiply(_rebaseMatrix, *toRebase, _matrixOrtho);
	}
	
	return &_matrixOrtho;
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
		// Initiates the quaternion class.
		_quat = [[NGLQuaternion alloc] init];
		
		// Sets the initial scale, rotation mode and rotation order.
		_pivot = kNGLvec3Zero;
		_scale.x = _scale.y = _scale.z = 1.0f;
		_rotationSpace = NGLRotationSpaceLocal;
		_rotationOrder = NGLRotationOrderXZY;
		
		// Loads the Identity Matrix in the object matrix.
		nglMatrixIdentity(_oMatrix);
		
		// Basic setting for bounding box.
		nglBoundingBoxDefine(&_boundingBox, kNGLboundsZero);
		
		// Defines no lookAt target.
		_lookAtTarget = nil;
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) commitRotation
{
	NGLRotationOrder order;
	NGLRotationSpace space;
	NGLAddMode addMode;
	
	if (!_rCache)
	{
		order = (nglDefaultRotationOrder == NGL_NULL) ? _rotationOrder : nglDefaultRotationOrder;
		space = (nglDefaultRotationSpace == NGL_NULL) ? _rotationSpace : nglDefaultRotationSpace;
		addMode = (space == NGLRotationSpaceLocal) ? NGLAddModePrepend : NGLAddModeAppend;
		
		/*
		// Resets the rotation to perform absolute rotations.
		[_quat identity];
		
		// Using binaries, gets Rotation Order previously defined.
		int bit[3] = {order >> 16 & 0xFF, order >> 8 & 0xFF, order & 0xFF};
		float angle[3] = {_rotation.x, _rotation.y, _rotation.z};
		
		// By using binary operations, the "if then else" conditionals can be avoided.
		[_quat rotateByAxis:kNGLAxis[bit[0]] angle:angle[bit[0]] mode:addMode];
		[_quat rotateByAxis:kNGLAxis[bit[1]] angle:angle[bit[1]] mode:addMode];
		[_quat rotateByAxis:kNGLAxis[bit[2]] angle:angle[bit[2]] mode:addMode];
		/*/
		[_quat identity];
		[_quat rotateByAxesOrdered:order angles:_rotation mode:addMode];
		//*/
		
		// Caches the last rotation.
		_rCache = YES;
	}
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (id) copyInstance
{
	id copy = [[[self class] allocWithZone:nil] init];
	
	// Copying properties.
	[self defineCopyTo:copy shared:YES];
	
	return copy;
}

- (id) copyWithZone:(NSZone *)zone
{
	id copy = [[[self class] allocWithZone:zone] init];
	
	// Copying properties.
	[self defineCopyTo:copy shared:NO];
	
	return copy;
}

- (void) defineCopyTo:(id)aCopy shared:(BOOL)isShared;
{
	NGLObject3D *copy = aCopy;
	
	// Copying properties.
	copy.tag = _tag;
	copy.name = _name;
	copy.pivot = _pivot;
	copy.lookAtTarget = _lookAtTarget;
	copy.rotationOrder = _rotationOrder;
	copy.rotationSpace = _rotationSpace;
	[copy translateToX:_position.x toY:_position.y toZ:_position.z];
	[copy rotateToX:_rotation.x toY:_rotation.y toZ:_rotation.z];
	[copy scaleToX:_scale.x toY:_scale.y toZ:_scale.z];
}

- (void) moveRelativeTo:(NGLMove)axis distance:(float)distance
{
	// Extracts the move vector from the binary constants.
	// The move vector accepts only the values -1.0, 0.0 or 1.0.
	float vx = (axis >> 16 & 0xFF) - 2.0f;
	float vy = (axis >> 8 & 0xFF) - 2.0f;
	float vz = (axis & 0xFF) - 2.0f;
	
	[self translateRelativeToX:vx * distance toY:vy * distance toZ:vz * distance];
}

- (void) translateRelativeToX:(float)xNum toY:(float)yNum toZ:(float)zNum
{
	NGLmat4 rotation;
	
	// Commits the last rotations.
	[self commitRotation];
	
	// Takes the rotation matrix without scales.
	nglMatrixCopy(*_quat.matrix, rotation);
	
	// Using the last rotation vectors (Right, Up and Look, respectively in rows 1,2 and 3)
	// multiplies by the specified distance parameters, and the result will be added to the
	// global object's position.
	self.x += xNum * rotation[0] + yNum * rotation[4] + zNum * rotation[8];
	self.y += xNum * rotation[1] + yNum * rotation[5] + zNum * rotation[9];
	self.z += xNum * rotation[2] + yNum * rotation[6] + zNum * rotation[10];
}

- (void) scaleRelativeToX:(float)xNum toY:(float)yNum toZ:(float)zNum
{
	self.scaleX += xNum;
	self.scaleY += yNum;
	self.scaleZ += zNum;
}

- (void) rotateRelativeToX:(float)xNum toY:(float)yNum toZ:(float)zNum
{
	// Commits the last rotations.
	[self commitRotation];
	
	NGLRotationOrder order;
	NGLRotationSpace space;
	NGLAddMode addMode;
	order = (nglDefaultRotationOrder == NGL_NULL) ? _rotationOrder : nglDefaultRotationOrder;
	space = (nglDefaultRotationSpace == NGL_NULL) ? _rotationSpace : nglDefaultRotationSpace;
	addMode = (space == NGLRotationSpaceLocal) ? NGLAddModePrepend : NGLAddModeAppend;
	/*
	// Using binaries, gets Rotation Order previously defined.
	int bit[3] = {order >> 16 & 0xFF, order >> 8 & 0xFF, order & 0xFF};
	float angle[3] = {xNum, yNum, zNum};
	
	// By using binary operations, the "if then else" conditionals can be avoided.
	[_quat rotateByAxis:kNGLAxis[bit[0]] angle:angle[bit[0]] mode:addMode];
	[_quat rotateByAxis:kNGLAxis[bit[1]] angle:angle[bit[1]] mode:addMode];
	[_quat rotateByAxis:kNGLAxis[bit[2]] angle:angle[bit[2]] mode:addMode];
	/*/
	[_quat rotateByAxesOrdered:order angles:(NGLvec3){xNum, yNum, zNum} mode:addMode];
	//*/
	
	//TODO update the absolute rotation, just like the other relatives.
	
	// It's not a good choice change the absolute rotation based on the current rotation order and space.
	// It can change before the render.
	
	// The problem lies on the order. When using the unique default quaternion rotation order (XZY)
	// everything works fine.
	_oCache = NO;
}

- (void) rotateRelativeWithMatrix:(NGLmat4)matrix
{
	NGLmat4 rotation;
	NGLvec3 euler;
	
	nglMatrixIsolateRotation(matrix, rotation);
	euler = nglVec3FromMatrix(rotation);
	
	[self rotateRelativeToX:euler.x toY:euler.y toZ:euler.z];
}

- (void) rotateRelativeWithQuaternion:(NGLQuaternion *)quaternion
{
	NGLvec3 euler = quaternion.euler;
	
	[self rotateRelativeToX:euler.x toY:euler.y toZ:euler.z];
}

- (void) translateToX:(float)xNum toY:(float)yNum toZ:(float)zNum
{
	self.x = xNum;
	self.y = yNum;
	self.z = zNum;
}

- (void) scaleToX:(float)xNum toY:(float)yNum toZ:(float)zNum
{
	self.scaleX = xNum;
	self.scaleY = yNum;
	self.scaleZ = zNum;
}

- (void) rotateToX:(float)xNum toY:(float)yNum toZ:(float)zNum
{
	self.rotateX = xNum;
	self.rotateY = yNum;
	self.rotateZ = zNum;
}

- (void) rotateWithMatrix:(NGLmat4)matrix
{
	NGLmat4 rotation;
	NGLvec3 euler;
	
	nglMatrixIsolateRotation(matrix, rotation);
	euler = nglVec3FromMatrix(rotation);
	
	self.x = euler.x;
	self.y = euler.y;
	self.z = euler.z;
}

- (void) rotateWithQuaternion:(NGLQuaternion *)quaternion
{
	NGLvec3 euler = quaternion.euler;
	
	self.x = euler.x;
	self.y = euler.y;
	self.z = euler.z;
}

- (void) lookAtObject:(NGLObject3D *)object
{
	// Calculates the distances between objects's pivots.
	NGLvec3 distance = (NGLvec3){object.x - self.x, object.y - self.y, object.z - self.z};
	
	[self lookAtVector:distance];
}

- (void) lookAtPointX:(float)xNum toY:(float)yNum toZ:(float)zNum
{
	// Calculates the distances between points.
	NGLvec3 distance = (NGLvec3){xNum - self.x, yNum - self.y, zNum - self.z};
	
	[self lookAtVector:distance];
}

- (void) lookAtVector:(NGLvec3)vector
{
	// This approach saves the Z rotation and can be used rather than the matrix formed
	// with the Front, Up and Side vector
	
	// Using Pythagoras Theorem, finds the projection magnitude on the plane XZ.
	// This will represent the adjacent side to X rotation (also known as roll or bank).
	float mag = sqrtf(vector.x * vector.x + vector.z * vector.z);
	
	// Applies the simple SOH-CAH-TOA formulas to find the angles in a triangle.
	// Here in both cases, use the Opposite and Adjacent sides.
	// The atan2f is better because can work in the four quadrants, not only 2 like atanf.
	float rotateX = nglRadiansToDegrees(atan2f(-vector.y, mag));
	float rotateY = nglRadiansToDegrees(atan2f(vector.x, vector.z));
	
	// Adds the rotation into the quaternion.
	[_quat rotateByEuler:(NGLvec3){rotateX, rotateY, _rotation.z} mode:NGLAddModeSet];
	
	_rCache = YES;
	_oCache = NO;
}

- (void) rebaseWithMatrix:(NGLmat4)matrix scale:(float)scale compatibility:(NGLRebase)rebase
{
	_isRebasing = YES;
	
	// Reduces the position by size to fit the NinevehGL/OpenGL sytem [0.0, 1.0].
	// By default, the rebase assumes the rotation matrix is already in the NinevehGL format/orientation.
	NGLvec3 position = (NGLvec3) {matrix[12] / scale, matrix[13] / scale, matrix[14] / scale};
	NGLQuaternion *quat = [[NGLQuaternion alloc] init];
	[quat rotateByMatrix:matrix mode:NGLAddModeSet];
	
	switch (rebase)
	{
		case NGLRebaseNone:
			
			break;
		case NGLRebaseQualcommAR:
			// Qualcomm has the camera UP vector inverted in relation to NinevehGL.
			[quat rotateByAxis:(NGLvec3){1.0f, 0.0f, 0.0f} angle:180.0f mode:NGLAddModeAppend];
			nglMatrixCopy(*quat.matrix, _rebaseMatrix);
			
			// Correcting the Qualcomm's Right Hand orientation.
			_rebaseMatrix[12] = position.x;
			_rebaseMatrix[13] -= position.y;
			_rebaseMatrix[14] -= position.z - 1.0f;
			break;
		default:
			
			break;
	}
	
	nglRelease(quat);
}

- (void) rebaseReset
{
	_isRebasing = NO;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	nglRelease(_name);
	nglRelease(_quat);
	
	[super dealloc];
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end