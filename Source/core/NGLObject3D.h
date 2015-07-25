/*
 *	NGLObject3D.h
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
#import "NGLGlobal.h"
#import "NGLDataType.h"
#import "NGLVector.h"
#import "NGLMatrix.h"
#import "NGLQuaternion.h"
#import "NGLBoundingBox.h"
#import "NGLCopying.h"

@class NGLObject3D;

/*!
 *					Defines the movement for local translations.
 *
 *					Represents the movements of an object relative to its own transformation state.
 *
 *	@see			NGLObject3D::moveRelativeTo:distance:
 *
 *	@var			NGLMoveRight
 *					Represents the movement to the right side of the object in local space.
 *	
 *	@var			NGLMoveLeft
 *					Represents the movement to the left side of the object in local space.
 *	
 *	@var			NGLMoveUp
 *					Represents the movement to the top of the object in local space.
 *	
 *	@var			NGLMoveDown
 *					Represents the movement to the bottom of the object in local space.
 *	
 *	@var			NGLMoveForward
 *					Represents the movement to the front of the object in local space.
 *	
 *	@var			NGLMoveBackward
 *					Represents the movement to the back of the object in local space.
 */
typedef enum
{
	NGLMoveRight			= 0x030202,
	NGLMoveLeft				= 0x010202,
	NGLMoveUp				= 0x020302,
	NGLMoveDown				= 0x020102,
	NGLMoveForward			= 0x020203,
	NGLMoveBackward			= 0x020201,
} NGLMove;

/*!
 *					Defines the rebase compatibility. The rebase is a convenient method that can
 *					change the final matrix based on another matrix. As each third party implements its
 *					own metric system, you can choose the rebase type for better compatibility.
 *
 *					Actually the supported engines are:
 *
 *						- Qualcomm (recommended for NinevehGL);
 *
 *	@see			NGLObject3D::rebaseWithMatrix:scale:compatibility:
 *
 *	@var			NGLRebaseNone
 *					Represents no special rebase. Use it with matrices from NinevehGL.
 *	
 *	@var			NGLRebaseQualcommAR
 *					Represents a special rebase to fit the Qualcomm AR matrices.
 */
typedef enum
{
	NGLRebaseNone,
	NGLRebaseQualcommAR,
} NGLRebase;

/*!
 *					The base class to every single 3D object in NinevehGL.
 *
 *					This is an abstract class, that means, by itself it does nothing.
 *					When it is extended by other classes, this becomes a powerfull part of 3D objects.
 *					NGLObject3D is responsible for controling, managing and setting the space
 *					coordinates for the 3D objects.
 *
 *					It's important to remember some rules:
 *
 *						- All the transformation properties are given with absolute values.
 *						- Translations can be made in world or local space;
 *						- Scales are always given in local space in which 1.0 means the original scale;
 *						- Rotations can be done in 3D world space or local space.
 *
 *					In the NinevehGL's Render Chain, this is the second class to use cached matrix.
 *					Cached matrix is a very powerfull optimization concept of NinevehGL. It means that a
 *					matrix will be constructed by parts, so the unchaged parts will be cached and this will
 *					reduce the redundant calculations.
 *
 *					There are three important concepts about 3D rotations:
 *
 *						- Absolute VS Relative (Mode);
 *						- World VS Local (Space);
 *						- Rotation Order (Order).
 *
 *					<strong>Absolute VS Relative (Mode)</strong>
 *					Absolute rotation is made always from the origin. Absolute rotations will always
 *					produce the same effect at a specific angle. For example, a rotation in XYZ of 0.0, 0.0,
 *					0.0 will take the object to its default state, with no rotation.
 *
 *					On the other hand, the Relative rotations are always in relation to the object's
 *					current state. So a Relative rotation of 45.0 in Y axis can produce infinities results
 *					depending on the object state. The "object state" is said from the result of all its
 *					previous transformations until here.
 *
 *					<strong>World VS Local (Space)</strong>
 *					World rotation, also known as Global rotation, it's said from that rotation happening
 *					in relation to the world space. It doesn't matter the actual object state, a World 
 *					rotation on axis X always will turn the object toward the screen (assuming no cameras),
 *					for example. It's like the rotations are always happening in relation to the origin of
 *					the world.
 *
 *					On the other side, the Local rotation happens in the local space. For example, a Local
 *					rotation on axis X will turn the object around its own axis X, not the world axis. The
 *					Local rotations suffer influences of the previous rotations. At this point make sure
 *					you don't get confused with Relative rotation. A rotation can be Absolute and Local at
 *					the same time.
 *
 *					<strong>Rotation Order (Order)</strong>
 *					There are 6 Rotation Orders. These orders represent how the consecutive rotations
 *					will happen during an animation. To an Absolute or Relative increment and to a World
 *					or Local reference, the rotations can achieve different results depending on the order
 *					in which they've happened. The six orders are:
 *
 *						- XYZ;
 *						- XZY;
 *						- YXZ;
 *						- YZX;
 *						- ZXY;
 *						- ZYX.
 *
 *					We could be inclined to believe that XYZ was the default behavior, but instead the
 *					default behavior and most used order is XZY. However the Rotation Order exists to help
 *					each object to achieve their objectives. For example, to a camera object the best
 *					choice could be YXZ.
 *
 *					All those three concepts work together inside NinevehGL. The Rotation Order is rarely
 *					used, exist only in few situations where you need to change it to achieve the desired
 *					result, you can set it using a NGLObject3D's property. The World VS Local are used
 *					a little bit more frequently, it's very useful to define an object behavior, objects
 *					which always made Local rotation and objects which always made World rotations. To
 *					set the rotation mode you use another NGLObject3D's property. Now, the Absolute VS
 *					Relative is used too often, because it's normally an object made consecutives Relative
 *					rotations and then make a new Absolute rotation. For this reason, there are no
 *					properties to change every time you need to use one of them, instead NGLObject3D
 *					offers different methods to work with Absolute and Relative rotations.
 *
 *					Another important NGLObject3D's responsibility is to deal with the Pivot concept.
 *					Every 3D object is rotated around its own center, but sometimes it could be important
 *					to make the rotations around another point that isn't its own center, like rotating a
 *					"sling" object, for example. This is what the Pivot concept is for. When you set a new
 *					pivot, all the rotations will be made around that new center. By default, every 
 *					has its pivot set to its own center (0.0, 0.0, 0.0).
 *
 *					Every 3D object could be inscribed into a box. This feature is called bounding box.
 *					NGLObject3D gives a method to set the pivot related to the bounding box. By this way
 *					you can easily construct complex structures, like bones.
 *
 *					Besides, NGLObject3D implements the LookAt concept. It'is a very important behavior
 *					in 3D world. It gives you a simple way to rotate the X and Y axis of an object to face
 *					a specific location in the 3D world, like face front to other object or face to a point.
 *					This behavior is specially useful for 3D cameras. With LookAt the cameras can easily
 *					follow a target wherever it goes.
 */
@interface NGLObject3D : NSObject <NGLCopying>
{
@protected
	// Physics
	NGLBoundingBox			_boundingBox;
	
@private
	// Identifiers
	int						_tag;
	NSString				*_name;
	
	// Caches
	BOOL					_oCache;
	BOOL					_rCache;
	BOOL					_isRebasing;
	
	// Algebra
	NGLmat4					_oMatrix;
	NGLmat4					_rtMatrix;
	NGLmat4					_rebaseMatrix;
	NGLmat4					_matrixModel;
	NGLmat4					_matrixOrtho;
	NGLQuaternion			*_quat;
	
	// Structure
	NGLvec3					_position;
	NGLvec3					_scale;
	NGLvec3					_rotation;
	NGLvec3					_pivot;
	
	// Helpers
	NGLRotationSpace		_rotationSpace;
	NGLRotationOrder		_rotationOrder;
	NGLObject3D				*_lookAtTarget;
	NGLObject3D				*_group;
}

/*!
 *					This is a free property, can act as an identifier to this object.
 *
 *					This property has no specific behavior, it's an identifier to help you to manage your
 *					3D resources in NinevehGL.
 */
@property (nonatomic) int tag;

/*!
 *					This is a free property, can act as an identifier to this object.
 *
 *					This property has no specific behavior, it's an identifier to help you to manage your
 *					3D resources in NinevehGL.
 */
@property (nonatomic, copy) NSString *name;

/*!
 *					The pivot vector to this object.
 */
@property (nonatomic) NGLvec3 pivot;

/*!
 *					This property defines the rotations's mode, which can be World or Local.
 *
 *					This property has a correlated global property. As any other NinevehGL Global Property,
 *					the final value will be taken from here only if the global property is NGL_NULL,
 *					otherwise the global value will be used.
 *
 *	@see			NGLRotationSpace
 *	@see			nglGlobalRotationSpace
 */
@property (nonatomic) NGLRotationSpace rotationSpace;

/*!
 *					This property defines the rotations's order. This can be one of the 6 different
 *					NGLRotationOrder's possibilities.
 *
 *					This property has a correlated global property. As any other NinevehGL Global Property,
 *					the final value will be taken from here only if the global property is NGL_NULL,
 *					otherwise the global value will be used.
 *
 *	@see			NGLRotationOrder
 *	@see			nglGlobalRotationOrder
 */
@property (nonatomic) NGLRotationOrder rotationOrder;

/*!
 *					Defines the object's position along the axis X. This property always represents
 *					the Absolute position mode. To translate the object using the relative mode, use
 *					<code>#moveRelativeTo:distance:#</code> or <code>#translateRelativeToX:toY:toZ:#</code>
 *					methods.
 *
 *	@see			moveRelativeTo:distance:
 *	@see			translateRelativeToX:toY:toZ:
 */
@property (nonatomic) float x;

/*!
 *					Defines the object's position along the axis Y. This property always represents
 *					the Absolute position mode. To translate the object using the relative mode, use
 *					<code>#moveRelativeTo:distance:#</code> or <code>#translateRelativeToX:toY:toZ:#</code>
 *					methods.
 *
 *	@see			moveRelativeTo:distance:
 *	@see			translateRelativeToX:toY:toZ:
 */
@property (nonatomic) float y;

/*!
 *					Defines the object's position along the axis Z. This property always represents
 *					the Absolute position mode. To translate the object using the relative mode, use
 *					<code>#moveRelativeTo:distance:#</code> or <code>#translateRelativeToX:toY:toZ:#</code>
 *					methods.
 *
 *	@see			moveRelativeTo:distance:
 *	@see			translateRelativeToX:toY:toZ:
 */
@property (nonatomic) float z;

/*!
 *					Defines the object's scale on the axis X. This scales always happens in the object's
 *					local space.
 *
 *	@see			scaleRelativeToX:toY:toZ:
 */
@property (nonatomic) float scaleX;

/*!
 *					Defines the object's scale on the axis Y. This scales always happens in the object's
 *					local space.
 *
 *	@see			scaleRelativeToX:toY:toZ:
 */
@property (nonatomic) float scaleY;

/*!
 *					Defines the object's scale on the axis Z. This scales always happens in the object's
 *					local space.
 *
 *	@see			scaleRelativeToX:toY:toZ:
 */
@property (nonatomic) float scaleZ;

/*!
 *					Defines the object's rotation in Absolute mode along the axis X. To perform Relative
 *					rotations use the method <code>#rotateRelativeToX:toY:toZ:#</code>.
 *
 *	@see			rotationSpace
 *	@see			rotateRelativeToX:toY:toZ:
 */
@property (nonatomic) float rotateX;

/*!
 *					Defines the object's rotation in Absolute mode along the axis Y. To perform Relative
 *					rotations use the method <code>#rotateRelativeToX:toY:toZ:#</code>.
 *
 *	@see			rotationSpace
 *	@see			rotateRelativeToX:toY:toZ:
 */
@property (nonatomic) float rotateY;

/*!
 *					Defines the object's rotation in Absolute mode along the axis Z. To perform Relative
 *					rotations use the method <code>#rotateRelativeToX:toY:toZ:#</code>.
 *
 *	@see			rotationSpace
 *	@see			rotateRelativeToX:toY:toZ:
 */
@property (nonatomic) float rotateZ;

/*!
 *					The bounding box of this object. This information can't be changed externally. Only a
 *					subclasses of NGLObject3D can change its values because it's based on the internal
 *					object structure.
 *
 *					The NinevehGL stores some kinds of informations inside the bounding box structure to
 *					optimize the performance. Those informations work like caches for future calculations.
 *
 *					By default, the box will be filled with zero values at the initialization and the
 *					volume values will never be changed again by NGLObject3D. The subclasses should change
 *					the volume values to alter the bounding box calculations.
 *
 *					So it's a subclass responsibility to fill the volume of the bounding box and it's
 *					a responsibility of NGLObject3D to calculate the bounding box when needed.
 *
 *	@see			NGLBoundingBox
 */
@property (nonatomic, readonly) NGLBoundingBox boundingBox;

/*!
 *					Returns the cache pointer. This property indicates if there are changes inside the
 *					object's position, scale or rotation since the last time its matrices was called.
 *					Don't make any change on the pointer value from the outside.
 */
@property (nonatomic, readonly) BOOL *cachePointer;

/*!
 *					A pointer to the position vector.
 */
@property (nonatomic, readonly) NGLvec3 *position;

/*!
 *					A pointer to the scale vector.
 */
@property (nonatomic, readonly) NGLvec3 *scale;

/*!
 *					A pointer to the rotation vector (euler rotation) in degrees.
 */
@property (nonatomic, readonly) NGLvec3 *rotation;

/*!
 *					This is the final matrix containing translations, scales and rotations of this 3D
 *					object. Also known as MODEL MATRIX.
 *
 *					The transformations happen in the order: scales -> rotations -> translations.
 *					This matrix is of order 4 (4 lines x 4 columns) and is used by OpenGL's core.
 */
@property (nonatomic, readonly) NGLmat4 *matrix;

/*!
 *					This is the orthogonal part of the final matrix. It contains information about the
 *					object's rotation and translation, but not the scale. This is the orthogonal
 *					portion of the MODEL MATRIX.
 */
@property (nonatomic, readonly) NGLmat4 *matrixOrtho;

/*!
 *					Identifies the group in wich this object is attached to.
 *
 *					Each 3D object can have only one group at a time. If you try to attach an object to
 *					a group and that object is already attached to another group, it will be automatically
 *					detached from the old one and will be attached to the new group.
 *
 *					To attach or detach objects from groups use the #NGLGroup3D# class.
 *
 *	@see			NGLGroup3D
 */
@property (nonatomic, assign) NGLObject3D *group;

/*!
 *					Defines a target of look at routine. At every render cycle, this object will perform
 *					a lookAt routine with the specified target. The lookAt affects rotations in X and Y
 *					axis. Any other rotation commands will be ignored to the final result.
 *					The lookAt routine doesn't affect the absolute rotation values.
 */
@property (nonatomic, assign) NGLObject3D *lookAtTarget;

/*!
 *					Translates this 3D object using the Relative mode.
 *
 *					This method produces local translation, that means, the object will be moved along its
 *					own axis. So the final result depends on the object current state.
 *
 *					This method makes use of the NGLMove directions. Those directions points at one of
 *					the six object's side.
 *
 *	@param			axis
 *					The #NGLMove# parameter.
 *
 *	@param			distance
 *					A float data type representing the distance which the object will be moved.
 *
 *	@see			NGLMove
 *	@see			translateRelativeToX:toY:toZ:
 */
- (void) moveRelativeTo:(NGLMove)axis distance:(float)distance;

/*!
 *					Translates this 3D object using the Relative mode.
 *
 *					This method produces local translation, that means, the object will be moved along its
 *					own axis. So the final result depends on the object current state.
 *
 *					It's important to note that the Relative mode only produces increments. That means a
 *					value of 3.0 will produces a result of: <code>&lt;current value&gt; + 3.0</code>.
 *
 *	@param			xNum
 *					The distance along the axis X.
 *
 *	@param			yNum
 *					The distance along the axis Y.
 *
 *	@param			zNum
 *					The distance along the axis Z.
 *
 *	@see			moveRelativeTo:distance:
 */
- (void) translateRelativeToX:(float)xNum toY:(float)yNum toZ:(float)zNum;

/*!
 *					Rotates this 3D object using the Relative mode.
 *
 *					This method will make an increment in the object actual state. The rotations
 *					will follow the previously defined Space and Order.
 *
 *					It's important to note that the Relative mode only produces increments. That means a
 *					value of 3.0 will produces a result of: <code>&lt;current value&gt; + 3.0</code>.
 *
 *	@param			xNum
 *					The rotation increment along the axis X.
 *
 *	@param			yNum
 *					The rotation increment along the axis Y.
 *
 *	@param			zNum
 *					The rotation increment along the axis Z.
 */
- (void) rotateRelativeToX:(float)xNum toY:(float)yNum toZ:(float)zNum;

/*!
 *					Rotates this 3D object with a rotation matrix using the Relative mode.
 *
 *					The matrix must be in column-major format, that means:
 *
 *					<pre>
 *
 *					| 0  4  8  12 |
 *					|             |
 *					| 1  5  9  13 |
 *					|             |
 *					| 2  6  10 14 |
 *					|             |
 *					| 3  7  11 15 |
 *
 *					</pre>
 *
 *					Actually, doesn't matter if the matrix has other transformations, like scale or
 *					translate, only the rotation information will be used.
 *
 *	@param			matrix
 *					The matrix in column-major format.
 */
- (void) rotateRelativeWithMatrix:(NGLmat4)matrix;

/*!
 *					Rotates this 3D object with a quaternion using the Relative mode.
 *
 *					The quaternion must be an instance of NGLQuaternion class.
 *
 *	@param			quaternion
 *					A NGLQuaternion containing the rotation.
 */
- (void) rotateRelativeWithQuaternion:(NGLQuaternion *)quaternion;

/*!
 *					Scales this 3D object using the Relative mode.
 *
 *					This method will make an increment in the object actual state.
 *
 *					It's important to note that the Relative mode only produces increments. That means a
 *					value of 3.0 will produces a result of: <code>&lt;current value&gt; + 3.0</code>.
 *
 *	@param			xNum
 *					The scale increment along the axis X.
 *
 *	@param			yNum
 *					The scale increment along the axis Y.
 *
 *	@param			zNum
 *					The scale increment along the axis Z.
 */
- (void) scaleRelativeToX:(float)xNum toY:(float)yNum toZ:(float)zNum;

/*!
 *					Translates this 3D object to a specific point using Absolute mode.
 *
 *					This method will directly set the position based on the values passed through
 *					parameters.
 *
 *	@param			xNum
 *					The X coordinate to set.
 *
 *	@param			yNum
 *					The Y coordinate to set.
 *
 *	@param			zNum
 *					The Z coordinate to set.
 */
- (void) translateToX:(float)xNum toY:(float)yNum toZ:(float)zNum;

/*!
 *					Scales this 3D object to a specific scale using Absolute mode.
 *
 *					This method will directly set the scale based on the values passed through parameters.
 *
 *	@param			xNum
 *					The new X scale value to set.
 *
 *	@param			yNum
 *					The new Y scale value to set.
 *
 *	@param			zNum
 *					The new Z scale value to set.
 */
- (void) scaleToX:(float)xNum toY:(float)yNum toZ:(float)zNum;

/*!
 *					Rotates this 3D object to a specific rotation using Absolute mode.
 *
 *					This method will directly set the rotation values based on the values passed
 *					through parameters.
 *
 *	@param			xNum
 *					The X rotation to set.
 *
 *	@param			yNum
 *					The Y rotation to set.
 *
 *	@param			zNum
 *					The Z rotation to set.
 */
- (void) rotateToX:(float)xNum toY:(float)yNum toZ:(float)zNum;

/*!
 *					Rotates this 3D object with a rotation matrix.
 *
 *					The matrix must be in column-major format, that means:
 *
 *					<pre>
 *
 *					| 0  4  8  12 |
 *					|             |
 *					| 1  5  9  13 |
 *					|             |
 *					| 2  6  10 14 |
 *					|             |
 *					| 3  7  11 15 |
 *
 *					</pre>
 *
 *					Actually, doesn't matter if the matrix has other transformations, like scale or
 *					translate, only the rotation information will be used.
 *
 *	@param			matrix
 *					The matrix in column-major format.
 */
- (void) rotateWithMatrix:(NGLmat4)matrix;

/*!
 *					Rotates this 3D object with a quaternion.
 *
 *					The quaternion must be an instance of NGLQuaternion class.
 *
 *	@param			quaternion
 *					A NGLQuaternion containing the rotation.
 */
- (void) rotateWithQuaternion:(NGLQuaternion *)quaternion;

/*!
 *					Makes this 3D object face front to other 3D object.
 *
 *					The 3D object "face" is given by it's Z line positive value. This means that the
 *					cube's "face", for example, will be the face which is facing to the Z positive line.
 *					Or in other words, the cube's "face" will be the plane (or point) which has a positive
 *					value to the Z normal.
 *
 *					<pre>
 *						     _____________
 *						    /            /|
 *						   /            / |               +y
 *						  /            /  |               |  -z
 *						 /            /   |               |  /
 *						/____________/    |               | /
 *						|            |    |        -x ____|/_____ +x
 *						|            |    /               |
 *						|   FRONT    |   /               /|
 *						|    FACE    |  /               / |
 *						|            | /               /  |
 *						|____________|/               +z  -y
 *
 *					</pre>
 *
 *					This method changes the X and Y rotations values, it doesn't change position, scale
 *					or Z rotation.
 *
 *	@param			object
 *					The other NGLObject3D which this 3D object will look at.
 *
 *	@see			lookAtPointX:toY:toZ:
 */
- (void) lookAtObject:(NGLObject3D *)object;

/*!
 *					Makes this 3D object turn its face to a 3D point.
 *
 *					This method has the same bahavior as #lookAtObject:# method, but instead
 *					a NGLObject3D will be a 3D point in world space.
 *
 *	@param			xNum
 *					The point's X coordinate.
 *
 *	@param			yNum
 *					The point's Y coordinate.
 *
 *	@param			zNum
 *					The point's Z coordinate.
 *
 *	@see			lookAtObject:
 */
- (void) lookAtPointX:(float)xNum toY:(float)yNum toZ:(float)zNum;

/*!
 *					<strong>(Internal only)</strong> You should not call this one manually.
 *
 *					You never call this method directly! Just custom LookAt routines could call this
 *					method directly to process the triangle equations.
 *
 *					This method is responsible for LookAt routine.
 *					First, it finds the distance between this NGLObject3D and the target 3D point.
 *					With these distances it's possible to trace imaginary triangles between these two
 *					3D points (this NGLObject3D pivot and the target point).
 *
 *					<pre>
 *					                 |\
 *					                 |∂\ --- ∂ angle to find
 *					                 |  \
 *					    Adjacent --- |   \
 *					        Side     |    \ --- Hypotenuse
 *					                 |_    \
 *					                 |_|____\
 *					                     |
 *					                     |___ Opposite
 *					                          Side
 *
 *					</pre>
 *
 *					It's simple to deal with it using SOH-CAH-TOA (formulas based on Pythagoras Theorem to
 *					find the angles of the triangle using two sides):
 *
 *						- Sin(∂) = Opposite / Hypotenuse;
 *						- Cos(∂) = Adjacent / Hypotenuse;
 *						- Tan(∂) = Opposite / Adjacent.
 *
 *	@param			vector
 *					The vector that represents the distances between this 3D object and the target
 *					of LookAt routine.
 */
- (void) lookAtVector:(NGLvec3)vector;

/*!
 *					Rebases this object based on another matrix. This process remains the transformation
 *					properties unchaged (x, y, z, rotateX, rotateY, rotateZ, scaleX, scaleY, scaleZ).
 *
 *					This is a convient method that helps you to change the base plane of your mesh and
 *					still making simple changes on it. Often this method is used with AR engines. The AR
 *					engines are used to output a matrix, but each engine has its own matrix system,
 *					orientation (Right or Left Hand) and work with different scales. So, this method can
 *					deal with all those differences between the engines and translate their matrices to
 *					NinevehGL/OpenGL matrix.
 *
 *					The rebase is a feature that when activated it will remains active until you explicit
 *					deactivate it (or reset). To do that, make a call to #rebaseReset#.
 *
 *	@param			matrix
 *					A matrix to act as rebase.
 *
 *	@param			scale
 *					The scale of the matrix metric system. The NinevehGL/OpenGL uses 1.0.
 *
 *	@param			rebase
 *					The rebase compatibility preset.
 *
 *	@see			rebaseReset
 */
- (void) rebaseWithMatrix:(NGLmat4)matrix scale:(float)scale compatibility:(NGLRebase)rebase;

/*!
 *					Deactivates/Resets the rebase feature. Call this method when you no longer need rebase
 *					this object.
 */
- (void) rebaseReset;

@end