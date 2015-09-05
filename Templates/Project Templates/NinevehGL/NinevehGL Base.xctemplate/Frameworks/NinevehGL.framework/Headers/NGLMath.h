/*
 *	NGLMath.h
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

#pragma mark -
#pragma mark Constants Definitions (k)
#pragma mark -
//**********************************************************************************************************
//
//	Constants Definitions (k)
//
//**********************************************************************************************************

/*!
 *					A single color unit from RGBA format in the range [0.0, 1.0].
 */
#define NGL_COLOR_UNIT			1.0f / 255.0f

/*!
 *					The value of PI.
 */
#define NGL_PI					3.141592f

/*!
 *					The value of 2 * PI.
 */
#define NGL_2PI					6.283184f

/*!
 *					The value of PI / 2.
 */
#define NGL_PI2					1.570796f

/*!
 *					Pre-calculated value of PI / 180. It's used to convert degrees to radians.
 */
#define NGL_PI180				0.017453f

/*!
 *					Pre-calculated value of 180 / PI. It's used to convert radians to degrees.
 */
#define NGL_180PI				57.295780f

/*!
 *					Pre-calculated maximum value for ARC4RANDOM function.
 */
#define NGL_ARC4R_MAX			0x100000000


#pragma mark -
#pragma mark Function Definitions
#pragma mark -
//**********************************************************************************************************
//
//	Function Definitions
//
//**********************************************************************************************************

/*!
 *					Checks if a floating data type (float, double or long double) is NaN.
 *
 *					The NaN thing means "not a number" and is returned by the runtime when a floating
 *					point operation results in special cases (like divisions by 0, square root of
 *					negative number, etc. In practical terms, the NaN has the unusual property that it is
 *					not equal to any value, including itself. So NaN == NaN is always false.
 *
 *	@param			x
 *					The value to be compared to it self.
 */
#define nglIsNaN(x)				((x) != (x))

/*!
 *					Convert degrees to radians. Degrees range is 0º - 360º.
 *
 *	@param			x
 *					The value in degrees to be converted.
 */
#define nglDegreesToRadians(x)	((x) * NGL_PI180)

/*!
 *					Converts radians to degrees. Radians range is 0 - 2π.
 *
 *	@param			x
 *					The value in radians to be converted.
 */
#define nglRadiansToDegrees(x)	((x) * NGL_180PI)

/*!
 *					Returns the clamped value within a range from "min" to "max".
 *
 *	@param			x
 *					The value to be clamped.
 *
 *	@param			min
 *					The minimum value.
 *
 *	@param			max
 *					The maximum value.
 */
#define nglClamp(x,min,max)		((x) < (min) ? (min) : ((x) > (max) ? (max) : (x)))

/*!
 *					Returns a random value within the specified "min" and "max" range. This value is a
 *					float data type.
 *
 *	@param			min
 *					The minimum value.
 *
 *	@param			max
 *					The maximum value.
 */
#define nglRandomf(min,max)		((min) + ((double)arc4random() / NGL_ARC4R_MAX) * (1 + (max) - (min)))

/*!
 *					Returns a random value within the specified "min" and "max" range. This value is an
 *					int data type.
 *
 *	@param			min
 *					The minimum value.
 *
 *	@param			max
 *					The maximum value.
 */
#define nglRandomi(min,max)		((int)floorf(nglRandomf((min), (max))))