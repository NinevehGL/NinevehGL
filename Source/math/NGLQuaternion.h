/*
 *	NGLQuaternion.h
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

#import "NGLRuntime.h"
#import "NGLDataType.h"
#import "NGLMath.h"
#import "NGLVector.h"
#import "NGLGlobal.h"

/*!
 *					The mode which the new quaternion will be added in the current quaternion.
 *
 *					The modes will be used by methods which change the rotation's values in the quaternion.
 *
 *	@see			NGLQuaternion::rotateByAxis:angle:mode:
 *	@see			NGLQuaternion::rotateByEuler:mode:
 *	
 *	@var			NGLAddModeSet
 *					This mode represents a completely values replacement.
 *
 *	@var			NGLAddModePrepend
 *					This mode represents a multiplication of the current quaternion by the new one
 *					(current x new). This mode could be used to generate local rotations.
 *
 *	@var			NGLAddModeAppend
 *					This mode represents a multiplication of a new quaternion by the current quaternion
 *					(current x new). This mode could be used to generate global rotations.
 */
typedef enum
{
	NGLAddModeSet		= 0x01,
	NGLAddModePrepend	= 0x02,
	NGLAddModeAppend	= 0x03,
} NGLAddMode;

/*!
 *					Quaternion is a complex number used to make rotations in a 3D space avoiding
 *					the Gimbal Lock issue.
 *
 *					There is a great polemic around the quaternions and euler angles about 3D rotations.
 *					In the NinevehGL the quaternion is THE class of rotations, because here quaternions
 *					can does much more than just rotate a matrix.
 *
 *					NGLQuaternion is the first class in the NinevehGL's Render Chain to use cache.
 *					The cache concept in NinevehGL means that the render's performance will be boosted to
 *					compute each 3D change individually. By doing so, only some parts of the entire
 *					rendering will be updated and submitted to the core of OpenGL.
 *
 *					Besides, the NGLQuaternion can easily manage and convert global and local rotations.
 *					It even can work with Euler angles or vector as input to rotations.
 *					NGLQuaternion is fast and could be performed thousand, even millions times at each
 *					frame with no impacts to the frame rate.
 *	
 *					Set the quaternion using the a vector axis is better. But if you need to set
 *					3 times (one for each x,y,z coordinate) is advisable to use the euler angles,
 *					because the number of multiplications to construct the final quaternion will be less.
 */
@interface NGLQuaternion : NSObject
{
@private
	BOOL					_qCache;
	NGLmat4					_qMatrix;
	NGLvec4					_q;
}

/*!
 *					The the angle that compound this NGLQuaternion.
 */
@property (nonatomic, readonly) float angle;

/*!
 *					The vector value of this NGLQuaternion.
 */
@property (nonatomic, readonly) NGLvec3 axis;

/*!
 *					Returns the Euler representation of this NGLQuaternion.
 *					The returning values will be in degrees and with a range of -180º to 180º.
 */
@property (nonatomic, readonly) NGLvec3 euler;

/*!
 *					Returns a pointer to the equivalent matrix based on this quaternion object.
 *					The returning matrix is:
 *
 *						- Orthogonal matrix;
 *						- Right hand oriented;
 *						- Ordered by Euler Rotation order (Y,Z,X)
 *
 *					The full formula is:
 *
 *					<pre>
 *
 *						|w²+x²-y²-z²      2xy-2zw         2xz+2yw       0|
 *						| 2xy+2zw       w²-x²+y²-z²       2yz-2xw       0|
 *						| 2xz-2yw         2yz+2xw       w²-x²-y²+z²     0|
 *						|    0               0               0          1|
 *
 *					</pre>
 *
 *					As 3D rotation just need unit quaternions, the matrix could be optimized to:
 *
 *					<pre>
 *
 *						|1-2y²-2z²        2xy-2zw         2xz+2yw       0|
 *						| 2xy+2zw        1-2x²-2z²        2yz-2xw       0|
 *						| 2xz-2yw         2yz+2xw        1-2x²-2y²      0|
 *						|    0               0               0          1|
 *
 *					</pre>
 */
@property (nonatomic, readonly) NGLmat4 *matrix;

/*!
 *					Resets the current quaternion to the identity quaternion.
 *
 *					The identity quaternion means a rotation of 0 in three axis. The identity quaternion
 *					results generates identity matrix.
 */
- (void) identity;

/*!
 *					Inverts the current quaternion.
 *
 *					This operations is also known as "conjugate quaternion".
 */
- (void) invert;

/*!
 *					Adds a new rotation to the current quaternion according to the mode.
 *
 *					The new rotation is defined by a vector and an angle of rotation around its own pivot.
 *	   
 *	@param			vec
 *					A vector representing the rotation in 3D space. This axis is the direction of
 *					the rotation.
 *
 *	@param			degrees
 *					The angle to make the rotation in degrees.
 *
 *	@param			mode
 *					The mode in which the new rotation will be assigned.
 *
 *	@see			NGLAddMode
 */
- (void) rotateByAxis:(NGLvec3)vec angle:(float)degrees mode:(NGLAddMode)mode;

/*!
 *					rotateByEuler:mode:
 *
 *					Adds a new rotation to the current quaternion according to the mode.
 *
 *					The new rotation is defined by a vector representing the Euler Rotation.
 *					The order of rotation will be the Euler Rotation Order (Y,Z,X).
 *
 *					This method is slightly more expensive than <code>#rotateByAxis:angle:mode:#</code>
 *					method.
 *
 *	@param			vec
 *					A vector containing the X, Y and Z values to the rotation. These values must be
 *					in degrees.
 *
 *	@param			mode
 *					The mode in which the new rotation will be assigned.
 *
 *	@see			NGLAddMode
 */
- (void) rotateByEuler:(NGLvec3)vec mode:(NGLAddMode)mode;

/*!
 *					Adds a new rotation to the current quaternion according to the mode.
 *
 *					The new rotation is defined by an orthogonal matrix. Only the rotation elements will
 *					be used from the matrix.
 *
 *	@param			mat
 *					A matrix (4x4) containing the rotation values.
 *
 *	@param			mode
 *					The mode in which the new rotation will be assigned.
 *
 *	@see			NGLAddMode
 */
- (void) rotateByMatrix:(NGLmat4)mat mode:(NGLAddMode)mode;

/*!
 *					Adds a new rotation to the current quaternion according to the mode.
 *
 *					The values will be normalized to follow the quaternion rules, even if they are already
 *					normalized.
 *
 *	@param			quaternion
 *					The components are in order X, Y, Z and W, the W is also known as "angle".
 *
 *	@param			mode
 *					The mode in which the new rotation will be assigned.
 *
 *	@see			NGLAddMode
 */
- (void) rotateByQuaternionVector:(NGLvec4)quaternion mode:(NGLAddMode)mode;

/*!
 *					Adds a new rotation to the current quaternion according to the mode following an order.
 *
 *					This method is equivalent to calling #rotateByAxis:angle:mode:# three times using
 *					full X, Y and Z components. This method saves Obj-C message time.
 *
 *	@param			order
 *					The rotation order in which the axes will be rotate.
 *
 *	@param			vec
 *					A vector containing the X, Y and Z values to the rotation. These values must be
 *					in degrees.
 *
 *	@param			mode
 *					The mode in which the new rotation will be assigned.
 *
 *	@see			NGLAddMode
 */
- (void) rotateByAxesOrdered:(NGLRotationOrder)order angles:(NGLvec3)vec mode:(NGLAddMode)mode;

@end