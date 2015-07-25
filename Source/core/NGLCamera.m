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

#import "NGLCamera.h"
#import "NGLTween.h"
#import "NGLView.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define kCamAdjust	0.45f

#define kCamAngle	45.0f
#define kCamNear	0.001f
#define kCamFar		100.0f
#define kCamZ		1.0f

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Definitions
//**************************************************
//	Private Definitions
//**************************************************

static NGLView *_telemetryView = nil;

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

// Returns the aspect ratio from a view.
// If the view is not valid (nil) the aspect ratio of the screen will be returned instead.
static CGSize getPreferredViewSize(UIView *view)
{
	CGSize size;
	
	if (view)
	{
		size = view.bounds.size;
	}
	else
	{
		// The UIScreen is not affected by device orientation.
		size = [[UIScreen mainScreen] bounds].size;
		size = nglDeviceOrientationIsPortrait() ? size : CGSizeMake(size.height, size.width);
	}
	
	return size;
}

static NGLvec3 nglUnproject(NGLvec4 vertex, NGLmat4 viewProjectionMatrix)
{
	NGLvec3 vec = kNGLvec3Zero;
	
	vertex = nglVec4ByMatrix(vertex, viewProjectionMatrix);
	
	vertex.w = (vertex.w == 0.0f) ? 1.0f : vertex.w;
	vec.x = vertex.x / vertex.w;
	vec.y = vertex.y / vertex.w;
	vec.z = vertex.z / vertex.w;
	
	return vec;
}
/*
NGLvec3 nglProject(NGLvec4 vertex, NGLmat4 viewProjectionMatrix, CGRect frame)
{
	NGLvec3 vec = kNGLvec3Zero;
	
	vertex = nglVec4ByMatrix(vertex, viewProjectionMatrix);
	
	vertex.w = (vertex.w == 0.0f) ? 1.0f : vertex.w;
	vec.x = vertex.x / vertex.w;
	vec.y = vertex.y / vertex.w;
	vec.z = vertex.z / vertex.w;
	
	// Rangen [0, 1]
	vec.x = vec.x * 0.5 + 0.5;
	vec.y = vec.y * 0.5 + 0.5;
	vec.z = vec.z * 0.5 + 0.5;
	
	// To viewport
	vec.x = vec.x * frame.size.width + frame.origin.x;
	vec.y = vec.y * frame.size.height + frame.origin.y;
	
	return vec;
}
//*/
#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

// Private category.
@interface NGLCamera()

// Initializes a new instance.
- (void) initialize;

// Creates the projection matrix.
- (void) createProjection;

// Invocates the adjust to the screen orientation. (NGLCameraInteractive category).
- (void) didChangeOrientation:(NSNotification *)notification;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLCamera

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@dynamic angleView, nearPlane, farPlane, aspectRatio, projection, preferredView, matrixViewProjection,
		 matrixProjection;

- (float) angleView { return _angleView; }
- (void) setAngleView:(float)value
{
	_angleView = value;
	[self createProjection];
}

- (float) nearPlane { return _nearPlane; }
- (void) setNearPlane:(float)value
{
	_nearPlane = value;
	[self createProjection];
}

- (float) farPlane { return _farPlane; }
- (void) setFarPlane:(float)value
{
	_farPlane = value;
	[self createProjection];
}

- (float) aspectRatio { return _aspectRatio; }
- (void) setAspectRatio:(float)value
{
	_aspectRatio = value;
	[self createProjection];
}

- (NGLProjection) projection { return _projection; }
- (void) setProjection:(NGLProjection)value
{
	_projection = value;
	[self createProjection];
}

- (UIView *) preferredView { return _preferredView; }
- (void) setPreferredView:(UIView *)value
{
	_preferredView = value;
	
	// Changing the aspect ratio.
	CGSize size = getPreferredViewSize(_preferredView);
	self.aspectRatio = size.width / size.height;
}

- (NGLmat4 *) matrixView
{
	if (!_cCache)
	{
		[self matrixViewProjection];
	}
	
	return &_vMatrix;
}

- (NGLmat4 *) matrixProjection
{
	return &_pMatrix;
}

- (NGLmat4 *) matrixViewProjection
{
	if(!_cCache)
	{
		// By default, NGLObject3D transformations order is Scale -> Rotation -> Position.
		// However the camera works with inverse behavior. To deal with this we have two ways:
		// - Send all values to NGLObject3D multiplying they by -1.
		// - Just inverse the final matrix.
		// As the inverse matrix will be necessary to calculate the lights in shaders, is a performance
		// gain inverse the matrix right here instead to calculate all camera value multipling them by -1.
		nglMatrixInverse(*super.matrix, _vMatrix);
		
		// Multiplies matrices PROJECTION by VIEW resulting in VIEW PROJECTION MATRIX.
		nglMatrixMultiply(_pMatrix, _vMatrix, _vpMatrix);
		
		_cCache = YES;
	}
	
	return &_vpMatrix;
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
		[self initialize];
	}
	
	return self;
}

- (id) initWithMeshes:(NGLMesh *)firstMesh, ...
{
	if ((self = [super init]))
	{
		[self initialize];
		
		NGLMesh *mesh;
		va_list list;
		
		// Executes the list to work with all elements until get nil.
		va_start(list, firstMesh);
		for (mesh = firstMesh; mesh != nil; mesh = va_arg(list, NGLMesh *))
		{
			[self addMesh:mesh];
		}
		va_end(list);
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initialize
{
	if (_telemetryView == nil)
	{
		_telemetryView = [[NGLView alloc] initWithOffscreenFrame:CGRectZero];
		_telemetryView.backgroundColor = [UIColor whiteColor];
	}
	
	// Initializes the meshe's storage.
	_meshes = [[NGLArray alloc] initWithRetainOption];
	
	// Basic camera settings.
	self.rotationOrder = NGLRotationOrderYXZ;
	CGSize size = [[UIScreen mainScreen] bounds].size;
	float aspect = size.width / size.height;
	
	// Default settings.
	[self lensPerspective:aspect near:kCamNear far:kCamFar angle:kCamAngle];
	[self setZ:kCamZ];
}

- (void) createProjection
{
	float top, right, bottom, left;
	
	if (_projection == NGLProjectionPerspective)
	{
		// Tiny correction based on a constant to reduce the effects of different aspect ratios
		// in relation to the Z position.
		float plus = _aspectRatio - 1.0f;
		float angle = _angleView + (_angleView * plus * kCamAdjust);
		
		// Perspective settings.
		float size = _nearPlane * tanf(nglDegreesToRadians(angle) / 2.0f);
		top = size / _aspectRatio;
		right = size;
		bottom = -size / _aspectRatio;
		left = -size;
		
		// Unused values in perspective formula.
		_pMatrix[1] = _pMatrix[2] = _pMatrix[3] = _pMatrix[4] = 0.0f;
		_pMatrix[6] = _pMatrix[7] = _pMatrix[12] = _pMatrix[13] = _pMatrix[15] = 0.0f;
		
		// Perspective formula.
		_pMatrix[0] = 2.0f * _nearPlane / (right - left);
		_pMatrix[5] = 2.0f * _nearPlane / (top - bottom);
		_pMatrix[8] = (right + left) / (right - left);
		_pMatrix[9] = (top + bottom) / (top - bottom);
		_pMatrix[10] = -(_farPlane + _nearPlane) / (_farPlane - _nearPlane);
		_pMatrix[11] = -1.0f;
		_pMatrix[14] = -(2.0f * _farPlane * _nearPlane) / (_farPlane - _nearPlane);
	}
	else if (_projection == NGLProjectionOrthographic)
	{
		// Defines the normalized size.
		float width = 1.0f;
		float height = width / _aspectRatio;
		float max = MAX(width, height) * 2.0f;
		
		// Orthographic settings.
		top = height / max;
		right = width / max;
		bottom = -height / max;
		left = -width / max;
		
		// Unused values in orthographic formula.
		_pMatrix[1] = _pMatrix[2] = _pMatrix[3] = _pMatrix[4] = _pMatrix[6] = 0.0f;
		_pMatrix[7] = _pMatrix[8] = _pMatrix[9] = _pMatrix[11] = 0.0f;
		
		// Orthographic formula.
		_pMatrix[0] = 2 / (right - left);
		_pMatrix[5] = 2 / (top - bottom);
		_pMatrix[10] = -2 / (_farPlane - _nearPlane);
		_pMatrix[12] = -(right + left) / (right - left);
		_pMatrix[13] = -(top + bottom) / (top - bottom);
		_pMatrix[14] = -(_farPlane + _nearPlane) / (_farPlane - _nearPlane);
		_pMatrix[15] = 1.0f;
	}
	
	_cCache = NO;
}

- (void) didChangeOrientation:(NSNotification *)notification
{
	[self adjustAspectRatioAnimated:_rotateAnimated];
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) lensPerspective:(float)aspect near:(float)near far:(float)far angle:(float)angle
{
	_aspectRatio = aspect;
	_nearPlane = near;
	_farPlane = far;
	_angleView = angle;
	_projection = NGLProjectionPerspective;
	
	// Sets perspective.
	[self createProjection];
}

- (void) lensOrthographic:(float)aspect near:(float)near far:(float)far
{
	_aspectRatio = aspect;
	_nearPlane = near;
	_farPlane = far;
	_projection = NGLProjectionOrthographic;
	
	// Sets perspective.
	[self createProjection];
}

- (void) addMesh:(NGLMesh *)mesh
{
	// Meshes in a camera should be unique, so if it already exist, ignore this call.
	[_meshes addPointerOnce:mesh];
}

- (void) addMeshesFromArray:(NSArray *)array
{
	NGLMesh *mesh;
	
	for (mesh in array)
	{
		[self addMesh:mesh];
	}
}

- (void) addMeshesFromGroup3D:(NGLGroup3D *)group
{
	NGLObject3D *object;
	Class meshClass = [NGLMesh class];
	
	for (object in group)
	{
		if ([object isKindOfClass:meshClass])
		{
			[self addMesh:(NGLMesh *)object];
		}
	}
}

- (BOOL) hasMesh:(NGLMesh *)mesh
{
	return [_meshes hasPointer:mesh];
}

- (void) removeMesh:(NGLMesh *)mesh
{
	// Checks if the meshes exist in this camera to avoid errors.
	[_meshes removePointer:mesh];
}

- (void) removeAllMeshes
{
	[_meshes removeAll];
}

- (NSArray *) allMeshes
{
	return [_meshes allPointers];
}

- (void) drawCamera
{
	NGLMesh *mesh;
	
	// Render loop.
	//for (mesh in _meshes)
	nglFor(mesh, _meshes)
	{
		if (mesh.visible)
		{
			[mesh drawMeshWithCamera:self];
		}
	}
}

- (void) drawTelemetry
{
	NGLMesh *mesh;
	unsigned int telemetryId = 0;
	CGSize size = getPreferredViewSize(_preferredView);
	
	// Prepares the offscreen render.
	_telemetryView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
	[_telemetryView drawOffscreen];
	
	// Render loop.
	//for (mesh in _meshes)
	nglFor(mesh, _meshes)
	{
		if (mesh.visible)
		{
			[mesh drawMeshWithCamera:self usingTelemetry:telemetryId];
		}
		
		// The telemetry ID doesn't skip not visible meshes because this ID represents
		// in fact the index of the mesh in this camera.
		++telemetryId;
	}
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) defineCopyTo:(id)aCopy shared:(BOOL)isShared
{
	[super defineCopyTo:aCopy shared:isShared];
	
	NGLCamera *copy = aCopy;
	
	// Copying properties.
	[copy lensPerspective:_aspectRatio near:_nearPlane far:_farPlane angle:_angleView];
	copy.projection = _projection;
	[copy addMeshesFromArray:[self allMeshes]];
}

- (void) setX:(float)value
{
	super.x = value;
	_cCache = NO;
}

- (void) setY:(float)value
{
	super.y = value;
	_cCache = NO;
}

- (void) setZ:(float)value
{
	super.z = value;
	_cCache = NO;
}

- (void) setScaleX:(float)value
{
	// No scale on Camera.
}

- (void) setScaleY:(float)value
{
	// No scale on Camera.
}

- (void) setScaleZ:(float)value
{
	// No scale on Camera.
}

- (void) setRotateX:(float)value
{
	super.rotateX = value;
	_cCache = NO;
}

- (void) setRotateY:(float)value
{
	super.rotateY = value;
	_cCache = NO;
}

- (void) setRotateZ:(float)value
{
	super.rotateZ = value;
	_cCache = NO;
}

- (void) translateRelativeToX:(float)xNum toY:(float)yNum toZ:(float)zNum
{
	// As camera works with inverted behavior, it must take the inverted values.
	[super translateRelativeToX:-xNum toY:-yNum toZ:-zNum];
	_cCache = NO;
}

- (void) rotateRelativeToX:(float)xNum toY:(float)yNum toZ:(float)zNum
{	
	// Camera relative rotations should not be inverted.
	[super rotateRelativeToX:xNum toY:yNum toZ:zNum];
	_cCache = NO;
}

- (void) lookAtVector:(NGLvec3)vector
{
	// As camera works with inverted behavior, it must take the inverted values.
	[super lookAtVector:(NGLvec3){-vector.x,-vector.y,-vector.z}];
	_cCache = NO;
}

- (void) rebaseWithMatrix:(NGLmat4)matrix scale:(float)scale compatibility:(NGLRebase)rebase
{
	NGLMesh *mesh;
	
	// Render loop.
	//for (mesh in _meshes)
	nglFor(mesh, _meshes)
	{
		[mesh rebaseWithMatrix:matrix scale:scale compatibility:rebase];
	}
}

- (void) rebaseReset
{
	NGLMesh *mesh;
	
	// Render loop.
	//for (mesh in _meshes)
	nglFor(mesh, _meshes)
	{
		[mesh rebaseReset];
	}
}

- (void) dealloc
{
	[self removeAllMeshes];
	[self autoAdjustAspectRatio:NO animated:NO];
	
	nglRelease(_meshes);
	
	[super dealloc];
}

@end

#pragma mark -
#pragma mark Categories
#pragma mark -
//**********************************************************************************************************
//
//	Categories
//
//**********************************************************************************************************

@implementation NGLCamera(NGLCameraInteractive)

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) autoAdjustAspectRatio:(BOOL)value animated:(BOOL)animating
{
	_rotateAnimated = animating;
	
	if (value)
	{
		// Makes sure the current application is receiving the device notifications.
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		
		// Registers the observer.
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(didChangeOrientation:)
													name:UIDeviceOrientationDidChangeNotification
												  object:nil];
	}
	else
	{
		// Removes the observer.
		[[NSNotificationCenter defaultCenter] removeObserver:self];
	}
}

- (void) adjustAspectRatioAnimated:(BOOL)value
{
	// Avoid unknown orientations.
	if (!nglDeviceOrientationIsValid())
	{
		return;
	}
	
	// Gets the aspect ration from the preferred view or from the device's screen.
	CGSize size = getPreferredViewSize(_preferredView);
	float aspect = size.width / size.height;
	
	// Change the current aspect ration with or without animation.
	if (value)
	{
		NSDictionary *values = [NSDictionary dictionaryWithObjectsAndKeys:
								kNGLEaseLinear, kNGLTweenKeyEase,
								kNGLTweenOverrideCurrent, kNGLTweenKeyOverride,
								[NSNumber numberWithFloat:aspect], @"aspectRatio",
								nil];
		
		[NGLTween tweenTo:values duration:NGL_TIME_RESIZE target:self];
	}
	else
	{
		self.aspectRatio = aspect;
	}
}

- (NGLTouching) touchingUnderPoint:(CGPoint)point
{
	// Updates the camera matrices.
	//[self matrixViewProjection];
	
	NGLTouching touching = (NGLTouching){ NULL, 0 };
	
	//*
	// Gets the current bounds from the preferred view or from the device's screen.
	CGSize size = getPreferredViewSize(_preferredView);
	
	GLfloat xp = (point.x / size.width) * 2.0f - 1.0f;
	GLfloat yp = (point.y / size.height) * 2.0f - 1.0f;
	//GLfloat near = (0.0f - _nearPlane / (_farPlane - _nearPlane)) * 2.0f - 1.0f;
	//GLfloat far = (1.0f - _nearPlane / (_farPlane - _nearPlane)) * 2.0f - 1.0f;
	
	yp *= -1.0f;
	
	NGLmat4 vpIMatrix;
	nglMatrixInverse(_vpMatrix, vpIMatrix);
	
	NGLvec3 origin = nglUnproject((NGLvec4){ 0.0f, 0.0f, 0.0f, 1.0f }, vpIMatrix);
	NGLvec3 direction = nglUnproject((NGLvec4){ xp, yp, 1.0f, 1.0f }, vpIMatrix);
	NGLray ray = (NGLray){ origin, direction };
	
	NGLMesh *mesh = nil;
	nglFor(mesh, _meshes)
	{
		if (nglBoundingBoxCollisionWithRay(mesh.boundingBox, ray))
		{
			//NSLog(@"FOUND COLLISION");
			touching.mesh = mesh;
			break;
		}
	}
	/*/
	NGLivec4 rgba;
	unsigned int telemetryID;
	id <NGLSurface> surface;
	
	NGLMesh *mesh = nil;
	unsigned int identifier = 0;
	
	// Draws the telemetry render.
	[self drawTelemetry];
	
	// Extracts the telemetry information.
	rgba = [_telemetryView pixelColorAtPoint:point];
	telemetryID = nglTelemetryIDFromRGBA(rgba);
	
	// Finds the correspondent mesh in this camera.
	if (telemetryID < [_meshes count])
	{
		mesh = [_meshes pointerAtIndex:telemetryID];
		surface = mesh.surface;
		
		// Checks if the surface is a NGLSurfaceMulti, if so retrieves its indentifier.
		if ([surface isKindOfClass:[NGLSurfaceMulti class]])
		{
			identifier = [[(NGLSurfaceMulti *)surface surfaceAtIndex:rgba.b] identifier];
		}
	}
	
	// Fills the touching returning struct.
	touching.mesh = mesh;
	touching.surfaceIdentifier = identifier;
	//*/
	
	return touching;
}

@end