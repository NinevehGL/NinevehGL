/*
 *	NGLFog.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *	
 *	Created by Diney Bomfim on 5/22/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLRuntime.h"
#import "NGLDataType.h"
#import "NGLVector.h"
#import "NGLView.h"

/*!
 *					Defines the fog's equation.
 *
 *					Fog effect follows an equation to calculate its attenuation factor.
 *
 *	@see			NGLFog::type
 *	
 *	@var			NGLFogTypeNone
 *					Represents that there is no fog effect enabled.
 *	
 *	@var			NGLFogTypeLinear
 *					Represents a fog effect with linear equation.
 */
typedef enum
{
	NGLFogTypeNone,
	NGLFogTypeLinear,
} NGLFogType;

/*!
 *					<strong>(Internal only)</strong> An object that holds the fog scalar values.
 *
 *					This structure is used as a fixed pointer to preserve the necessary information (memory)
 *					to the fog's scalar values.
 *
 *	@see			NGLFogType
 *	@see			NGLvec4
 *	
 *	@var			NGLFogValues::type
 *					Represents the Fog equation type.
 *	
 *	@var			NGLFogValues::color
 *					The fog color.
 *	
 *	@var			NGLFogValues::start
 *					The start position of the fog effect in relation to the camera.
 *	
 *	@var			NGLFogValues::end
 *					The end position of the fog effect in relation to the camera.
 *	
 *	@var			NGLFogValues::factor
 *					The fog equation factor.
 */
typedef struct
{
	NGLFogType		type;
	NGLvec4			color;
	float			start;
	float			end;
	float			factor;
} NGLFogValues;

/*!
 *					Generates and manages the Fog Effect. (Singleton)
 *
 *					The fog effect is usefull to hide the brutal cut on the meshes when they are out of
 *					the field of view (FOV). The NGLFog is connected to the #NGLCamera# and can receive
 *					the field of view from there automatically. By default, NGLFog starts at 75.0 and
 *					ends at 100.0, using generic units.
 *
 *					Besides, by default, the fog effect is turned off (the type property is set to
 *					NGLFogType). To activate the fog effect just set the type property to any other
 *					NGLFogType parameter.
 *
 *					The default color of the fog is the same as the global color to NinevehGL.
 *
 *	@see			NGLCamera
 */
@interface NGLFog : NSObject
{
@private
	NGLFogValues			_values;
}

/*!
 *					Defines the fog effect equation.
 *
 *					By default its value is <code>NGLFogTypeNone</code>, which represents no fog effect.
 *
 *					The default value is NGLFogTypeNone.
 */
@property (nonatomic) NGLFogType type;

/*!
 *					Defines the fog effect color. By default, it will be the same color as that one defined
 *					as global color to NinevehGL Engine.
 *
 *					The default value is equal to the global color.
 */
@property (nonatomic) NGLvec4 color;

/*!
 *					A floating number representing the start position of the fog effect in relation to the
 *					viewer (the camera).
 *
 *					The default value is 75.0.
 */
@property (nonatomic) float start;

/*!
 *					A floating number representing the end position of the fog effect in relation to the
 *					viewer (the camera).
 *
 *					The default value is 100.0.
 */
@property (nonatomic) float end;

/*!
 *					<strong>(Internal only)</strong> Returns a pointer to the fog scalar values.
 *					You should not call this method directly.
 */
@property (nonatomic, readonly) NGLFogValues *values;

/*!
 *					Returns the singleton instance of NGLFog.
 *
 *					The NGLFog is a global effect and affects all the renders with NinevehGL.
 *
 *	@result			The singleton instance of the main Fog.
 */
+ (NGLFog *) defaultFog;

@end