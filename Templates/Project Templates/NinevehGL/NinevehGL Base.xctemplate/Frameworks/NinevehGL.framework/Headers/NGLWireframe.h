/*
 *	NGLWireframe.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *	Created by Diney Bomfim on 1/16/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLRuntime.h"
#import "NGLGlobal.h"
#import "NGLVector.h"
#import "NGLMaterial.h"

/*!
 *					The wireframe class can instruct any renderable 3D object to show off its wireframe.
 *
 *					Every NGLWireframe instance supports a NGLMaterial, this means you can define a very
 *					complex looking aspect to the wireframe lines.
 *
 *					The wireframe doesn't include any kind of interaction, it's just a visual reference
 *					to help you to achieve your goals with a 3D object.
 *
 *	@see			NGLMesh
 */
@interface NGLWireframe : NSObject
{
@private
	NGLWireMode				_mode;
	NGLMaterial				*_material;
	float					_thickness;
}

/*!
 *					Indicates the kind(s) of wireframe that will be rendered. Use the bitwise operator
 *					OR (|) to assign multiple values to this property.
 *
 *					For example: NGLWireframeGeometry | NGLWireframeBoundingBox, will show the wireframe
 *					of the geometry and the boundingbox.
 *
 *					The default value is NGLWireframeNone.
 */
@property (nonatomic) NGLWireMode mode;

/*!
 *					This property defines the wireframe material. The same material will be used to all the
 *					wireframe components. Remember that wireframe is just a visual helper, not a line
 *					drawing system, so its resources are limited.
 *
 *					By default the material will have a random diffuse color.
 */
@property (nonatomic, retain) NGLMaterial *material;

/*!
 *					The thickness size for the wireframe. This property affects all the three wireframe
 *					structures: mesh wireframe, volume wireframe and boundingbox wireframe.
 *
 *					By default it's 1.0.
 */
@property (nonatomic) float thickness;

/*!
 *					Initializes this NGLWireframe based on a wireframe mode.
 *
 *					This method creates a wireframe object that can be bound to any renderable 3D object.
 *
 *	@param			mode
 *					The wireframe mode to be used.
 *
 *	@result			A new initialized NGLWireframe instance.
 */
- (id) initWithMode:(NGLWireMode)mode;

/*!
 *					Returns an autoreleased instance of NGLShader.
 *
 *					This method creates a wireframe object that can be bound to any renderable 3D object.
 *
 *	@param			mode
 *					The wireframe mode to be used.
 *
 *	@result			A NGLWireframe autoreleased instance.
 */
+ (id) wireframeWithMode:(NGLWireMode)mode;

@end